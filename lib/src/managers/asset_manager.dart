/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:async';
import 'dart:isolate';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/helpers/telemetry_tracker.dart';
import 'package:clarity_flutter/src/mixins/callback_handler.dart';
import 'package:clarity_flutter/src/mixins/event_queue_handler.dart';
import 'package:clarity_flutter/src/mixins/isolate_handler.dart';
import 'package:clarity_flutter/src/models/events/asset_event.dart';
import 'package:clarity_flutter/src/models/events/event.dart';
import 'package:clarity_flutter/src/models/isolates/asset_isolate_config.dart';
import 'package:clarity_flutter/src/models/isolates/worker_isolate.dart';
import 'package:clarity_flutter/src/models/session/session_metadata.dart';
import 'package:clarity_flutter/src/models/telemetry/telemetry_item.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/repositories/session_repository.dart';
import 'package:clarity_flutter/src/utils/asset_utils.dart';
import 'package:clarity_flutter/src/utils/dev_utils.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class AssetManager with CallbackHandler, IsolateHandler {
  AssetManager._internal() {
    final receivePort = ReceivePort();
    receivePort.listen(handleResponsesFromIsolate);
    final isolateConfig = AssetIsolateConfig(sendPort: receivePort.sendPort);
    unawaited(WorkerIsolate.spawn(isolateConfig));
  }
  static AssetManager? _instance;

  static Future<AssetManager> create() async {
    _instance ??= AssetManager._internal();
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

  Future<void> enqueueEvent(Event event) async {
    profileTimeSync('ClarityAssetManagerSendingEvent', () => workerIsolatePort!.send(event));
  }
}

class AssetWorkerIsolate extends WorkerIsolate with CallbackHandler, EventQueueHandler {
  AssetWorkerIsolate(AssetIsolateConfig super.config) {
    final registry = EnvRegistry.ensureInitialized();
    _sessionRepository = SessionRepository();
    final uploadManagerPort = registry.getItem<SendPort>(EnvRegistryKey.uploadIsolatePort)!;
    registerCallback<AssetUploadEvent>(uploadManagerPort.send);
  }
  late final SessionRepository _sessionRepository;
  String? _currentSessionId;
  int _imagesInQueueCount = 0;
  bool _capturingThrottled = false;

  @override
  void processMessage(dynamic message) {
    if (message is Event) {
      if (!_canEnqueueMoreEvents()) {
        return;
      }
      unawaited(enqueueEvent(message));
    } else {
      throw UnimplementedError('Message type not supported! ${message.runtimeType}');
    }
  }

  @override
  void preProcessEvent(Event event) {
    if (event is AssetEncodingEvent) {
      _imagesInQueueCount += event.assets.length;
      _throttleCapturingIfNeeded();
    }
  }

  @override
  Future<void> processEvent(Event event) async {
    switch (event) {
      case AssetEncodingEvent():
        _imagesInQueueCount -= event.assets.length;
        await _processAssetEncodingEvent(event);

      default:
        throw UnsupportedError('Unsupported Event Type enqueued ${event.runtimeType}');
    }
  }

  @override
  void postProcessEventsQueue() {
    _unthrottleCapturingIfNeeded();
  }

  @override
  void processEventError(Event event, Object e, StackTrace st) {
    TelemetryTracker.instance?.trackError(ErrorType.AssetProcessing, e.toString(), st);
  }

  bool _canEnqueueMoreEvents() {
    if (_capturingThrottled) {
      Logger.warn?.out('Asset capturing is currently throttled - Dropping event');
      return false;
    }
    return true;
  }

  Future<void> _processAssetEncodingEvent(AssetEncodingEvent event) async {
    // Initialize session stores if this is a new session
    await _ensureSessionStoresInitialized(event.sessionMetadata);

    for (final asset in event.assets) {
      final profileTime = profileTimeAsync();
      profileTime?.start('ClarityEncodeImageBytes');
      final pngBytes = AssetUtils.encodePng(asset.data!, asset.dataSize);
      profileTime?.finish();

      await _sessionRepository.saveSessionAsset(asset.fileName, pngBytes);
      asset.data =
          null; // Clear data to send only metadata to the upload manager, the data will be read from its filename location
    }

    fireEvent(AssetUploadEvent(assets: event.assets, sessionMetadata: event.sessionMetadata));
  }

  Future<void> _ensureSessionStoresInitialized(SessionMetadata sessionMetadata) async {
    if (_currentSessionId == sessionMetadata.id) return;

    _currentSessionId = sessionMetadata.id;

    _sessionRepository.setSessionStores(sessionMetadata);
  }

  void _throttleCapturingIfNeeded() {
    if (!_capturingThrottled && _imagesInQueueCount >= ClarityConstants.assetEncodingCountCongestionLimit) {
      Logger.warn?.out('Throttling asset capturing - Images in queue: $_imagesInQueueCount');
      _capturingThrottled = true;
    }
  }

  void _unthrottleCapturingIfNeeded() {
    if (_capturingThrottled && _imagesInQueueCount <= ClarityConstants.assetEncodingCountCongestionLimit) {
      _capturingThrottled = false;
    }
  }
}
