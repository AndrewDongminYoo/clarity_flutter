/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:async';
import 'dart:isolate';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/helpers/services/ingest_service.dart';
import 'package:clarity_flutter/src/helpers/services/telemetry_service.dart';
import 'package:clarity_flutter/src/helpers/telemetry_tracker.dart';
import 'package:clarity_flutter/src/mixins/callback_handler.dart';
import 'package:clarity_flutter/src/mixins/event_queue_handler.dart';
import 'package:clarity_flutter/src/mixins/isolate_handler.dart';
import 'package:clarity_flutter/src/mixins/telemetry_queue_handler.dart';
import 'package:clarity_flutter/src/models/events/asset_event.dart';
import 'package:clarity_flutter/src/models/events/control_event.dart';
import 'package:clarity_flutter/src/models/events/event.dart';
import 'package:clarity_flutter/src/models/events/payload_event.dart';
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/asset.dart';
import 'package:clarity_flutter/src/models/ingest/asset_check.dart';
import 'package:clarity_flutter/src/models/ingest/serialized_payload.dart';
import 'package:clarity_flutter/src/models/isolates/upload_isolate_config.dart';
import 'package:clarity_flutter/src/models/isolates/worker_isolate.dart';
import 'package:clarity_flutter/src/models/session/page_metadata.dart';
import 'package:clarity_flutter/src/models/session/payload_metadata.dart';
import 'package:clarity_flutter/src/models/session/session_metadata.dart';
import 'package:clarity_flutter/src/models/telemetry/telemetry.dart';
import 'package:clarity_flutter/src/repositories/session_repository.dart';
import 'package:clarity_flutter/src/utils/http_utils.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class _SessionPageMetadataTracker {
  final Set<String> _sentSessionMetadata = {};
  final Set<String> _sentPageMetadata = {};

  bool shouldSendSessionMetadata(SessionMetadata sessionMetadata) {
    return _sentSessionMetadata.add(sessionMetadata.id);
  }

  bool shouldSendPageMetadata(PageMetadata pageMetadata) {
    return _sentPageMetadata.add('${pageMetadata.session.id}:${pageMetadata.number}');
  }
}

final Set<int> _pageMetadataEventTypes = {
  EventType.Dimension.customOrdinal,
  EventType.Metric.customOrdinal,
  EventType.Resize.customOrdinal,
};

final Set<int> _sessionMetadataEventTypes = {
  EventType.Variable.customOrdinal,
};

List<String> _filterMetadataEvents(
  List<String> analytics, {
  required bool sendSessionMetadata,
  required bool sendPageMetadata,
}) {
  if (sendSessionMetadata && sendPageMetadata) return analytics;

  final filtered = <String>[];
  for (final event in analytics) {
    final eventType = SerializedPayload.eventType(event);
    if (!sendPageMetadata && _pageMetadataEventTypes.contains(eventType)) {
      continue;
    }
    if (!sendSessionMetadata && _sessionMetadataEventTypes.contains(eventType)) {
      continue;
    }
    filtered.add(event);
  }
  return filtered;
}

class UploadManager with CallbackHandler, IsolateHandler {
  UploadManager._internal() {
    final receivePort = ReceivePort();
    receivePort.listen(handleResponsesFromIsolate);
    final isolateConfig = UploadIsolateConfig(sendPort: receivePort.sendPort);
    unawaited(WorkerIsolate.spawn(isolateConfig));
  }
  static UploadManager? _instance;

  static Future<UploadManager> create() async {
    _instance ??= UploadManager._internal();
    await _instance!.isolateReady.future;
    return _instance!;
  }

  @override
  void handleResponsesFromIsolate(dynamic message) {
    if (message is SendPort) {
      workerIsolatePort = message;
      isolateReady.complete();
    }
  }

  void onNetworkConnectivityChanged(Event event) {
    workerIsolatePort!.send(event);
  }
}

class UploadWorkerIsolate extends WorkerIsolate with EventQueueHandler, TelemetryHandler {
  UploadWorkerIsolate(UploadIsolateConfig super.config) {
    TelemetryTracker.ensureInitialized(onTelemetryOverride: enqueueTelemetry);
    _ingestService = IngestService();
    _sessionRepository = SessionRepository();
  }
  // Late so that Environment Registry is initialized with needed data
  late final IngestService _ingestService;
  late final SessionRepository _sessionRepository;

  bool _payloadQueueCongested = false;
  int _payloadEventsInQueueCount = 0;
  Completer<void>? networkPausedCompleter;

  TelemetryService? _telemetryService;
  PageMetadata? _latestPageMetadata;
  final _metadataTracker = _SessionPageMetadataTracker();

  @override
  void processMessage(dynamic message) {
    if (message is PayloadEvent || message is AssetUploadEvent) {
      unawaited(enqueueEvent(message as Event));
    } else if (message is TelemetryItem) {
      enqueueTelemetry(message);
    } else if (message is NetworkConnectivityChangedEvent) {
      _reactToNetworkChange(message);
    } else {
      throw UnimplementedError('Message type not supported! ${message.runtimeType}');
    }
  }

  @override
  void preProcessEvent(covariant Event event) {
    if (event is PayloadEvent) {
      _payloadEventsInQueueCount++;
    }
    if (_payloadEventsInQueueCount >= ClarityConstants.payloadQueueCongestionLimit && !_payloadQueueCongested) {
      TelemetryTracker.instance?.trackMetric(MetricKey.Clarity_PayloadQueueCongestion, 1);
      _payloadQueueCongested = true;
    }
    super.preProcessEvent(event);
  }

  @override
  Future<void> processEvent(covariant Event event) async {
    await networkPausedCompleter?.future;

    if (event is PayloadEvent) {
      _latestPageMetadata = event.metadata.page;
      _payloadEventsInQueueCount--;

      await _uploadSessionPayload(event.metadata);
    } else if (event is AssetUploadEvent) {
      await _uploadSessionAssets(event);
    }
  }

  @override
  Future<void> processTelemetry(TelemetryContainer telemetryContainer) async {
    await networkPausedCompleter?.future;

    Logger.verbose?.out('Processing Telemetry! $telemetryContainer');
    final telemetryUploadFutures = <Future<bool>>[];
    _telemetryService ??= TelemetryService();
    telemetryUploadFutures.add(_telemetryService!.reportMetrics(telemetryContainer.metrics));
    for (final error in telemetryContainer.errors) {
      telemetryUploadFutures.add(_telemetryService!.reportError(error, pageMetadata: _latestPageMetadata));
    }
    final uploadResult = await Future.wait(telemetryUploadFutures);
    final failureCounts = uploadResult.where((success) => !success).length;
    if (failureCounts > 0) {
      Logger.warn?.out('$failureCounts/${uploadResult.length} Telemetry Items failed to upload.');
    }
  }

  @override
  void postProcessEventsQueue() {
    _payloadQueueCongested = false;
  }

  @override
  void processEventError(Event event, Object e, StackTrace st) {
    TelemetryTracker.instance?.trackError(ErrorType.PayloadProcessing, e.toString(), st);
  }

  void _reactToNetworkChange(NetworkConnectivityChangedEvent event) {
    if (event.allowUploadOverNetwork) {
      networkPausedCompleter?.complete();
      networkPausedCompleter = null;
    } else {
      networkPausedCompleter ??= Completer<void>();
    }
  }

  Future<void> _uploadSessionPayload(PayloadMetadata payloadMetadata) async {
    Logger.debug?.out('Starting upload of payload $payloadMetadata');
    _sessionRepository.setSessionStores(payloadMetadata.page.session);

    try {
      final payloadUploadResponseCode = await _uploadPayload(payloadMetadata);

      if (HttpUtils.isSuccessCode(payloadUploadResponseCode)) {
        Logger.debug?.out('Successfully uploaded payload with response $payloadUploadResponseCode');
        await _sessionRepository.deleteSessionPayload(payloadMetadata);
      } else {
        Logger.warn?.out('Uh oh! payload $payloadMetadata upload failed with response $payloadUploadResponseCode');
      }
    } catch (e, st) {
      Logger.error?.out('Error Uploading Payload! Type: ${e.runtimeType} message: $e', stackTrace: st);
      TelemetryTracker.instance?.trackError(ErrorType.UploadSession, e.toString(), st);
    }
  }

  Future<int> _uploadPayload(PayloadMetadata payloadMetadata) async {
    final analytics = await _sessionRepository.getPayloadSerializedEvents(payloadMetadata, PayloadDataType.analytics);
    final playback = await _sessionRepository.getPayloadSerializedEvents(payloadMetadata, PayloadDataType.playback);
    final sendSessionMetadata = _metadataTracker.shouldSendSessionMetadata(payloadMetadata.page.session);
    final sendPageMetadata = _metadataTracker.shouldSendPageMetadata(payloadMetadata.page);
    final filteredAnalytics = _filterMetadataEvents(
      analytics,
      sendSessionMetadata: sendSessionMetadata,
      sendPageMetadata: sendPageMetadata,
    );
    return _ingestService.uploadSessionPayload(
      SerializedPayload(
        analytics: filteredAnalytics,
        playback: playback,
        pageNum: payloadMetadata.pageNumber,
        sequence: payloadMetadata.sequence,
        start: payloadMetadata.start,
      ),
      payloadMetadata,
    );
  }

  Future<void> _uploadSessionAssets(AssetUploadEvent event) async {
    Logger.debug?.out('Starting upload of assets for ${event.sessionMetadata.id}');
    _sessionRepository.setSessionStores(event.sessionMetadata);

    try {
      final assets = event.assets;

      if (assets.isEmpty) return;

      final assetCheckRequests = assets.map((it) => AssetCheck(hash: it.hash, type: it.assetType.index)).toList();

      final assetsCheckResponses = await _ingestService.checkIfAssetsExist(
        event.sessionMetadata.ingestUrl,
        clarityConfig.projectId,
        assetCheckRequests,
      );

      Logger.debug?.out('Result of assets check $assetsCheckResponses');

      final assetsToUpload = assets.where((it) => !(assetsCheckResponses[it.hash] ?? false)).toList();
      final assetsToDelete = assets.where((it) => assetsCheckResponses[it.hash] ?? false).toList();

      final uploadAndDeleteFutures = <Future<void>>[];
      for (final asset in assetsToDelete) {
        uploadAndDeleteFutures.add(_sessionRepository.deleteSessionAsset(asset.fileName));
      }

      for (final asset in assetsToUpload) {
        uploadAndDeleteFutures.add(_uploadAsset(event.sessionMetadata, asset));
      }
      await Future.wait(uploadAndDeleteFutures);
    } catch (e) {
      Logger.warn?.out('Error uploading session assets: $e');
    }
  }

  Future<void> _uploadAsset(SessionMetadata sessionMetadata, Asset asset) async {
    asset.data = await _sessionRepository.getSessionAsset(sessionMetadata.id, asset.fileName);
    final success = await _ingestService.uploadAsset(sessionMetadata.ingestUrl, clarityConfig.projectId, asset);
    Logger.debug?.out('Result of Asset ${asset.hash} upload $success');
    if (success) {
      await _sessionRepository.deleteSessionAsset(asset.fileName);
    }
  }
}
