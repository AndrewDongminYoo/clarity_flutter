/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// ignore_for_file: deprecated_member_use_from_same_package

// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

// 🌎 Project imports:
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/helpers/gesture_processor.dart';
import 'package:clarity_flutter/src/helpers/telemetry_tracker.dart';
import 'package:clarity_flutter/src/helpers/view_hierarchy_processor.dart';
import 'package:clarity_flutter/src/managers/base_session_manager.dart';
import 'package:clarity_flutter/src/managers/font_manager.dart';
import 'package:clarity_flutter/src/mixins/callback_handler.dart';
import 'package:clarity_flutter/src/mixins/event_queue_handler.dart';
import 'package:clarity_flutter/src/models/consent_status.dart';
import 'package:clarity_flutter/src/models/events/asset_event.dart';
import 'package:clarity_flutter/src/models/events/control_event.dart';
import 'package:clarity_flutter/src/models/events/event.dart';
import 'package:clarity_flutter/src/models/events/payload_event.dart';
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/baseline.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/consent_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/custom.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/dimension.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/gaid_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/gaid_opt_out_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/metric.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/resize.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/variable.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/visibility.dart';
import 'package:clarity_flutter/src/models/ingest/asset.dart';
import 'package:clarity_flutter/src/models/ingest/ingest.dart';
import 'package:clarity_flutter/src/models/ingest/mutation_error_event.dart';
import 'package:clarity_flutter/src/models/isolates/session_isolate_config.dart';
import 'package:clarity_flutter/src/models/isolates/worker_isolate.dart';
import 'package:clarity_flutter/src/models/project_config.dart';
import 'package:clarity_flutter/src/models/session/page_metadata.dart';
import 'package:clarity_flutter/src/models/session/payload_metadata.dart';
import 'package:clarity_flutter/src/models/session/session_metadata.dart';
import 'package:clarity_flutter/src/models/telemetry/telemetry.dart';
import 'package:clarity_flutter/src/native/clarity_platform.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/registries/host_info.dart';
import 'package:clarity_flutter/src/repositories/session_repository.dart';
import 'package:clarity_flutter/src/repositories/settings_repository.dart';
import 'package:clarity_flutter/src/utils/asset_utils.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';
import 'package:clarity_flutter/src/utils/dev_utils.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class SessionManager extends BaseSessionManager {
  SessionManager._internal() {
    final receivePort = ReceivePort();
    receivePort.listen(handleResponsesFromIsolate);
    final isolateConfig = SessionIsolateConfig(sendPort: receivePort.sendPort);
    unawaited(WorkerIsolate.spawn(isolateConfig));
  }
  static SessionManager? _instance;
  String? _sessionId;
  SessionStartedCallback? _onSessionStartedOrResumedCallback;
  String? _userId;
  String? _projectId;

  AnalyticsConsentChangedCallback? _onAnalyticsConsentChanged;

  static Future<SessionManager> create() async {
    _instance ??= SessionManager._internal();
    await _instance!.isolateReady.future;
    return _instance!;
  }

  @override
  void handleResponsesFromIsolate(dynamic message) {
    if (message is SendPort) {
      workerIsolatePort = message;
      isolateReady.complete();
    } else if (message case PauseCaptureEvent() || ResumeCaptureEvent() || RequestFontBytesEvent()) {
      fireEvent(message as Event);
    } else if (message is SessionStartedEvent) {
      _onSessionStarted(message);
    } else if (message is ConsentAnalyticsChangedEvent) {
      _onAnalyticsConsentChanged?.call();
      _onAnalyticsConsentChanged = null;
    }
  }

  @override
  void onAppLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(enqueueEvent(VisibilityEvent(DateTime.now().millisecondsSinceEpoch, ClarityConstants.visibleState)));
    } else if (state == AppLifecycleState.hidden) {
      // Listen for the “hidden” event across Android, iOS, and Web platforms.
      // Note: the “paused” event is not emitted in Web environments.
      unawaited(enqueueEvent(VisibilityEvent(DateTime.now().millisecondsSinceEpoch, ClarityConstants.hiddenState)));
    }
  }

  @override
  void setCustomTags(String key, Set<String> values) {
    unawaited(enqueueEvent(SetCustomTagEvent(key, values)));
  }

  @override
  void setOnSessionStartedOrResumedCallback(SessionStartedCallback callback) {
    if (_sessionId != null) {
      callback(_sessionId!);
    }

    _onSessionStartedOrResumedCallback = callback;
  }

  @override
  String? getSessionUrl() {
    if (_sessionId == null || _userId == null || _projectId == null) {
      return null;
    }

    final base = Uri.parse(ClarityConstants.sessionBaseUrl);

    return base.replace(pathSegments: [...base.pathSegments, _projectId!, _userId!, _sessionId!]).toString();
  }

  @override
  void sendCustomEvent(String value) {
    unawaited(enqueueEvent(SendCustomValueEvent(value)));
  }

  @override
  void consent(ConsentStatus consentStatus, AnalyticsConsentChangedCallback onAnalyticsConsentChanged) {
    _onAnalyticsConsentChanged = onAnalyticsConsentChanged;
    unawaited(enqueueEvent(ConsentChangedEvent(consentStatus)));
  }

  @override
  Future<void> enqueueEvent(Event event) async {
    profileTimeSync('ClaritySessionManagerSendingEvent', () => workerIsolatePort!.send(event));
  }

  void _onSessionStarted(SessionStartedEvent sessionStartedEvent) {
    _sessionId = sessionStartedEvent.sessionId;
    _userId = sessionStartedEvent.userId;
    _projectId = sessionStartedEvent.projectId;

    Logger.info?.out('[ClaritySession] projectId=$_projectId, userId=$_userId, sessionId=$_sessionId');

    (sessionStartedEvent.callback ?? _onSessionStartedOrResumedCallback)?.call(_sessionId!);
  }
}

class SessionWorkerIsolate extends WorkerIsolate with CallbackHandler, EventQueueHandler {
  SessionWorkerIsolate(SessionIsolateConfig super.config) {
    TelemetryTracker.ensureInitialized();
    final registry = EnvRegistry.ensureInitialized();
    _sessionRepository = SessionRepository();
    _settingsRepository = SettingsRepository();
    _fontManager = FontManager(_sessionRepository, _settingsRepository);
    final assetManagerPort = registry.getItem<SendPort>(EnvRegistryKey.assetIsolatePort)!;
    final uploadManagerPort = registry.getItem<SendPort>(EnvRegistryKey.uploadIsolatePort)!;
    final projectConfig = registry.getItem<ProjectConfig>(EnvRegistryKey.projectConfig)!;
    _dynamicIngestUrl = projectConfig.ingestUrl;
    _packageName = registry.getItem<String>(EnvRegistryKey.packageName)!;

    _consentStatus = ConsentStatus(
      source: ConsentSource.implicit,
      adsStorage: projectConfig.adsStorage,
      analyticsStorage: projectConfig.analyticsStorage,
    );

    registerCallback<PayloadEvent>(uploadManagerPort.send);
    registerCallback<AssetEncodingEvent>(assetManagerPort.send);
    registerCallback<AssetUploadEvent>(uploadManagerPort.send);

    unawaited(enqueueEvent(const InitConsentStatusEvent()));
    unawaited(enqueueEvent(PayloadFlushEvent()));
  }
  // Late so that Environment Registry is initialized with needed data
  late final SessionRepository _sessionRepository;
  late final SettingsRepository _settingsRepository;
  late final FontManager _fontManager;
  late final String _dynamicIngestUrl;
  late final String _packageName;
  final Map<int, String> _dartHashCodeToContentHash = {};
  final Set<String> _writtenImagesHash = {};
  int _mutationEventsInQueueCount = 0;
  bool _capturingThrottled = false;
  SessionMetadata? _currentSessionMetadata;
  PageMetadata? _currentPageMetadata;
  PayloadMetadata? _currentPayloadMetadata;
  ViewHierarchyProcessor? _viewHierarchyProcessor;
  final Map<String, Set<String>> _customTags = {};
  final List<String> _preSessionCustomEventsValues = [];
  GestureProcessor gestureProcessor = GestureProcessor();
  bool _networkPaused = false;
  bool _payloadFlushCheckScheduled = false;
  late ConsentStatus _consentStatus;

  @override
  void processMessage(dynamic message) {
    if (message is Event) {
      unawaited(enqueueEvent(message));
    } else {
      throw UnimplementedError('Message type not supported! ${message.runtimeType}');
    }
  }

  @override
  void preProcessEvent(Event event) {
    if (event is MutationEvent) {
      _mutationEventsInQueueCount++;
      _throttleCapturingIfNeeded();
    }
  }

  @override
  Future<void> processEvent(Event event) async {
    switch (event) {
      case NetworkConnectivityChangedEvent():
        _reactToNetworkChange(event);

      case MutationEvent():
        _mutationEventsInQueueCount--;
        await _processMutationEvent(event);

      case AnalyticsEvent():
        await _processAnalyticsEvent(event);

      case MutationErrorEvent():
        await _processMutationErrorEvent(event);

      case SetCustomTagEvent():
        await _processSetCustomTagEvent(event);

      case SendCustomValueEvent():
        await _processSendCustomValueEvent(event);

      case PayloadFlushEvent():
        await _processPeriodicPayloadFlushCheck();

      case FontMetadataEvent():
        await _processFontMetadataEvent(event);

      case FontBytesLoadedEvent():
        await _processFontBytesLoadedEvent(event);

      case InitConsentStatusEvent():
        await _processInitConsentStatusEvent(event);

      case ConsentChangedEvent():
        await _processConsentChangedEvent(event);

      default:
        throw UnsupportedError('Unsupported Event Type enqueued ${event.runtimeType}');
    }
  }

  @override
  void postProcessEventsQueue() {
    _unthrottleCapturingIfNeeded();
    _cleanUpCache();
  }

  @override
  void processEventError(Event event, Object e, StackTrace st) {
    TelemetryTracker.instance?.trackError(ErrorType.SessionEventProcessing, e.toString(), st);
  }

  void _reactToNetworkChange(NetworkConnectivityChangedEvent event) {
    _networkPaused = !event.allowUploadOverNetwork;
    if (!_networkPaused) {
      Logger.info?.out('Network connectivity allows uploading, resuming uploads and flushing payload.');
      unawaited(enqueueEvent(PayloadFlushEvent()));
    }
  }

  Future<void> _processSetCustomTagEvent(SetCustomTagEvent event) async {
    if (_currentPageMetadata != null) {
      await _processAnalyticsEvent(VariableEvent(_currentPageMetadata!.startTime, {event.key: event.values}));
    }

    _customTags[event.key] = event.values;
  }

  Future<void> _processSendCustomValueEvent(SendCustomValueEvent event) async {
    if (_currentPageMetadata == null) {
      _preSessionCustomEventsValues.add(event.value);
    } else {
      await _processAnalyticsEvent(CustomEvent(DateTime.now().millisecondsSinceEpoch, event.value));
    }
  }

  Future<void> _processMutationEvent(MutationEvent mutationEvent) async {
    await _startNewSessionIfNeeded(mutationEvent);
    await _startNewPageIfNeeded(mutationEvent);
    await _startNewPayloadIfNeeded(mutationEvent);

    gestureProcessor.updateFrameState(mutationEvent.frame);
    _viewHierarchyProcessor!.process(mutationEvent.frame.viewHierarchy);
    // Must be done before we serialize the frame, so the hash of the image is correct and exists!
    await _hashAndStoreAssets(mutationEvent);

    mutationEvent.frame.typefaces = _fontManager.typefaces;

    _fontManager.triggerLazyFontLoading(mutationEvent.frame.commands);

    final pendingFontRequests = _fontManager.consumePendingLoadRequests();
    if (pendingFontRequests.isNotEmpty) {
      sendPort.send(RequestFontBytesEvent(pendingFontRequests));
    }

    await _addEventToPayload(mutationEvent);
  }

  Future<void> _processAnalyticsEvent(AnalyticsEvent event) async {
    if (_shouldDropAnalyticsEvent(event)) return;

    if (event is GestureEvent) {
      gestureProcessor.updateGestureEvent(event);
    }

    await _startNewPayloadIfNeeded(event);
    await _addEventToPayload(event);
  }

  bool _shouldDropAnalyticsEvent(AnalyticsEvent event) {
    // Drop event if no frame has been received yet
    if (_currentPageMetadata == null) return true;

    if (event is VisibilityEvent) {
      if (event.state == _currentPageMetadata!.lastVisibilityEventState) {
        return true;
      }

      _currentPageMetadata!.lastVisibilityEventState = event.state;
    }

    return false;
  }

  Future<void> _processMutationErrorEvent(MutationErrorEvent event) async {
    if (_currentSessionMetadata == null) return;
    await _startNewPayloadIfNeeded(event);
    await _addEventToPayload(event);
  }

  Future<void> _startNewPayloadIfNeeded(SessionEvent event) async {
    if (!_shouldStartNewPayload(event.timestamp)) return;

    await _forceNewPayload(event.timestamp);
  }

  Future<void> _forceNewPayload(int timestamp) async {
    _sendCurrentPayloadMetadataForUpload();
    await _startNewPayload(
      _currentPayloadMetadata?.sequence == null
          ? ClarityConstants.firstPayloadSequence
          : _currentPayloadMetadata!.sequence + 1,
      timestamp,
    );
  }

  void _sendCurrentPayloadMetadataForUpload() {
    if (_currentPayloadMetadata == null) return;

    Logger.verbose?.out('Sending PayloadMetadata $_currentPayloadMetadata for upload');
    fireEvent(PayloadEvent(_currentPayloadMetadata!));
  }

  Future<void> _hashAndStoreAssets(MutationEvent mutationEvent) async {
    final imagesToEncode = <Asset>[];
    for (final image in mutationEvent.frame.images) {
      if (!_dartHashCodeToContentHash.containsKey(image.dartHashCode) && image.data != null) {
        _dartHashCodeToContentHash[image.dartHashCode] = await _processAndHashImage(
          image.data!,
          image.size,
          image.dataSize,
          imagesToEncode,
        );
      }
      image.dataHash = _dartHashCodeToContentHash[image.dartHashCode];
    }

    if (imagesToEncode.isNotEmpty) {
      fireEvent(AssetEncodingEvent(assets: imagesToEncode, sessionMetadata: _currentSessionMetadata!));
    }
  }

  Future<String> _processAndHashImage(
    Uint8List imageBytes,
    ImageSize originalSize,
    ImageSize bufferSize,
    List<Asset> imagesToEncode,
  ) async {
    final profileTime = profileTimeAsync();
    profileTime?.start('ClarityHashImageBytes');
    final hash = DataUtils.xxHashBase64(imageBytes);
    profileTime?.finish();

    if (_writtenImagesHash.contains(hash)) return hash;
    _writtenImagesHash.add(hash);

    final asset = Asset(assetType: AssetType.image, fileName: hash)
      ..data = imageBytes
      ..originalImageSize = originalSize
      ..bufferSize = bufferSize;

    imagesToEncode.add(asset);

    return hash;
  }

  void _throttleCapturingIfNeeded() {
    if (!_capturingThrottled && _mutationEventsInQueueCount >= ClarityConstants.mutationEventsThrottlingLimit) {
      Logger.debug?.out(
        'Mutation events count $_mutationEventsInQueueCount exceeded allowed limit, throttling capture.',
      );
      TelemetryTracker.instance?.trackMetric(MetricKey.Clarity_CapturingThrottled, 1);
      sendPort.send(PauseCaptureEvent());
      _capturingThrottled = true;

      unawaited(
        processEvent(
          MutationErrorEvent(DateTime.now().millisecondsSinceEpoch, ErrorReason.enqueuedSessionFramesExceededLimit),
        ),
      );
    }
  }

  void _unthrottleCapturingIfNeeded() {
    if (_capturingThrottled) {
      Logger.debug?.out('Mutation events are processed, unthrottling capture');
      sendPort.send(ResumeCaptureEvent());
      _capturingThrottled = false;
    }
  }

  Future<void> _addEventToPayload(SessionEvent event) async {
    _currentPayloadMetadata?.updateDuration(event.timestamp, event.type);
    await _sessionRepository.appendEventToSessionPayload(_currentPayloadMetadata!, event);
  }

  Future<void> _startNewSessionIfNeeded(MutationEvent event) async {
    // There is an ongoing session
    if (_currentSessionMetadata != null) {
      if (_eventShouldStartNewSession(_currentSessionMetadata!.startTime, event.timestamp) ||
          event.frame.forceStartNewSession) {
        await _startNewSession(event);

        sendPort.send(SessionStartedEvent(_currentSessionMetadata!, event.frame.forceStartNewSessionCallback));
      }

      return;
    }

    // We just launched the app so get cached page metadata
    final cachedPageMetadata = await _settingsRepository.getCachedPageMetadata();
    final cachedSessionMetadata = cachedPageMetadata?.session;

    final shouldStartNewSession =
        (clarityConfig.userId != null && clarityConfig.userId != cachedSessionMetadata?.userId) ||
        clarityConfig.projectId != cachedSessionMetadata?.projectId ||
        ClarityConstants.clarityVersion != cachedSessionMetadata?.version ||
        (event.timestamp - (cachedSessionMetadata?.startTime ?? 0) > ClarityConstants.maxSessionDurationInMs) ||
        event.frame.forceStartNewSession;

    if (shouldStartNewSession) {
      await _sessionRepository.deleteResidualSessionData();
      await _startNewSession(event);
    } else {
      _currentSessionMetadata = cachedSessionMetadata;

      await _startNewPage(event, cachedPageMetadata!.number + 1);
    }

    final fontAssets = await _fontManager.onSessionReady();
    _fireFontAssetUploadEvent(fontAssets);

    sendPort.send(SessionStartedEvent(_currentSessionMetadata!, event.frame.forceStartNewSessionCallback));
  }

  bool _eventShouldStartNewSession(int sessionTimestamp, int eventTimestamp) {
    return eventTimestamp - sessionTimestamp > ClarityConstants.maxSessionDurationInMs;
  }

  Future<void> _startNewPageIfNeeded(MutationEvent event) async {
    if (event.screenName == _currentPageMetadata!.screenName) return;

    await _startNewPage(event, _currentPageMetadata!.number + 1);
  }

  Future<void> _startNewSession(MutationEvent event) async {
    final userId = await _computeUserId(clarityConfig, _consentStatus.analyticsStorage);

    _currentSessionMetadata = SessionMetadata(
      event.timestamp,
      _generateId(),
      clarityConfig.projectId,
      userId,
      _dynamicIngestUrl,
      ClarityConstants.clarityVersion,
    );
    Logger.info?.out('Starting new Clarity Session');
    Logger.debug?.out('SessionMetadata $_currentSessionMetadata');

    await _startNewPage(event, ClarityConstants.firstPageNumber);
  }

  Future<void> _startNewPage(MutationEvent event, int newPageNumber) async {
    _finalizeCurrentPage(event);
    _sessionRepository.setSessionStores(_currentSessionMetadata!);

    _currentPageMetadata = PageMetadata(
      newPageNumber,
      event.timestamp,
      ClarityConstants.visibleState,
      event.screenName,
      _currentSessionMetadata!,
    );
    _currentPayloadMetadata = null;
    _viewHierarchyProcessor = ViewHierarchyProcessor();

    Logger.info?.out('Starting new Clarity Page');
    Logger.debug?.out('PageMetadata $_currentPageMetadata');

    final hostInfo = EnvRegistry.ensureInitialized().getItem<HostInfo>(EnvRegistryKey.hostInfo)!;

    final dimensions = <Dimension, String>{
      Dimension.UserAgent: hostInfo.userAgent,
      Dimension.Platform: ApplicationPlatform.getCurrentPlatform().index.toString(),
      Dimension.PlatformVersion: hostInfo.platformVersion,
      Dimension.Model: hostInfo.model,
      Dimension.PageTitle: event.screenName,
      if (hostInfo.deviceFamily != null) Dimension.DeviceFamily: hostInfo.deviceFamily!,
    };

    final metrics = <Metric, int>{
      Metric.Playback: 1,
      Metric.ClientTimestamp: _currentPageMetadata!.startTime ~/ 1000,
      Metric.ScreenWidth: event.frame.screenWidth,
      Metric.ScreenHeight: event.frame.screenHeight,
      Metric.HardwareConcurrency: hostInfo.deviceCoreCount,
    };

    final variables = <String, Set<String>>{
      ClarityConstants.applicationVersionVariableLabel: {hostInfo.applicationVersion},
      ClarityConstants.frameworkVariableLabel: {hostInfo.applicationFramework},
      ClarityConstants.clarityVersionVariableLabel: {ClarityConstants.clarityVersion},
      ClarityConstants.packageNameVariableLabel: {_packageName},
    };

    variables.addAll(_customTags);

    await _startNewPayloadIfNeeded(event);

    await _addEventToPayload(
      ResizeEvent(_currentPageMetadata!.startTime, event.frame.screenWidth, event.frame.screenHeight),
    );
    await _addEventToPayload(DimensionEvent(_currentPageMetadata!.startTime, dimensions));
    await _addEventToPayload(MetricEvent(_currentPageMetadata!.startTime, metrics));
    await _addEventToPayload(VariableEvent(_currentPageMetadata!.startTime, variables));

    for (final value in _preSessionCustomEventsValues) {
      await _addEventToPayload(CustomEvent(_currentPageMetadata!.startTime, value));
    }

    _preSessionCustomEventsValues.clear();

    await _addEventToPayload(ConsentEvent(_currentPageMetadata!.startTime, _consentStatus));
    await _enforceAdsConsentPolicy();

    // The upstream components depend on having a visibility event at the start of every new page.
    await _addEventToPayload(VisibilityEvent(_currentPageMetadata!.startTime, ClarityConstants.visibleState));

    await _settingsRepository.writePageMetadata(_currentPageMetadata!);
  }

  void _finalizeCurrentPage(MutationEvent event) {
    if (_currentPayloadMetadata == null) return;

    unawaited(_processAnalyticsEvent(VisibilityEvent(event.timestamp - 1, ClarityConstants.hiddenState)));
    _sendCurrentPayloadMetadataForUpload();
  }

  Future<void> _startNewPayload(int sequence, int eventTime) async {
    Logger.debug?.out('Starting a new Payload with sequence $sequence');
    final startTimeRelativeToPrev = _currentPayloadMetadata == null
        ? 0
        : _currentPayloadMetadata!.start + _currentPayloadMetadata!.duration!;
    _currentPayloadMetadata = PayloadMetadata(
      page: _currentPageMetadata!,
      sequence: sequence,
      start: startTimeRelativeToPrev,
      startTimeRelativeToPage: eventTime - _currentPageMetadata!.startTime,
    );
    await _sessionRepository.createSessionPayload(_currentPayloadMetadata!);
    await _addEventToPayload(
      BaselineEvent(
        _currentPageMetadata!.startTime + _currentPayloadMetadata!.start,
        _currentPageMetadata!.lastVisibilityEventState == ClarityConstants.visibleState,
      ),
    );
  }

  bool _shouldStartNewPayload(int timestamp) {
    final eventRelativeTimestamp = timestamp - _currentPageMetadata!.startTime;
    return _currentPayloadMetadata == null ||
        eventRelativeTimestamp - _currentPayloadMetadata!.startTimeRelativeToPage >
            _currentPayloadMetadata!.maxPayloadDuration;
  }

  void _cleanUpCache() {
    if (_dartHashCodeToContentHash.length > 100) {
      _dartHashCodeToContentHash.clear();
    }

    if (_writtenImagesHash.length > 100) {
      _writtenImagesHash.clear();
    }
  }

  Future<void> _processFontMetadataEvent(FontMetadataEvent event) async {
    await _fontManager.initializeFromMetadata(event.fontMap);
  }

  Future<void> _processFontBytesLoadedEvent(FontBytesLoadedEvent event) async {
    final savedAssets = await _fontManager.registerLoadedFonts(event.loadedFonts);
    _fireFontAssetUploadEvent(savedAssets);
  }

  void _fireFontAssetUploadEvent(List<Asset> assets) {
    if (assets.isNotEmpty && _currentSessionMetadata != null) {
      fireEvent(AssetUploadEvent(assets: assets, sessionMetadata: _currentSessionMetadata!));
    }
  }

  Future<void> _processPeriodicPayloadFlushCheck() async {
    final payloadMetadata = _currentPayloadMetadata;
    final nextFlushDueAt = payloadMetadata?.nextFlushDueAt;

    if (payloadMetadata != null && nextFlushDueAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > nextFlushDueAt) {
        Logger.info?.out('Flushing payload events due to periodic check.');
        await _forceNewPayload(now);
      }
    }

    if (_networkPaused) {
      Logger.info?.out('Network is currently paused, skipping periodic payload flush.');
      return;
    }

    if (_payloadFlushCheckScheduled) return;

    _payloadFlushCheckScheduled = true;
    Future.delayed(const Duration(milliseconds: ClarityConstants.periodicPayloadFlushCheckIntervalMs), () {
      _payloadFlushCheckScheduled = false;
      unawaited(enqueueEvent(PayloadFlushEvent()));
    });
  }

  String _generateId() {
    final rand = Random(DateTime.now().millisecondsSinceEpoch).nextInt(1 << 32);
    return rand.toRadixString(ClarityConstants.idRadix);
  }

  Future<void> _processInitConsentStatusEvent(InitConsentStatusEvent event) async {
    final resolved = await _settingsRepository.getConsentStatus(
      projectAdsStorage: _consentStatus.adsStorage,
      projectAnalyticsStorage: _consentStatus.analyticsStorage,
    );
    if (resolved != _consentStatus) {
      _consentStatus = resolved;
    }
  }

  Future<void> _processConsentChangedEvent(ConsentChangedEvent event) async {
    final previousStatus = _consentStatus;

    await _settingsRepository.updateConsentStatus(event.consentStatus);
    _consentStatus = event.consentStatus;

    if (previousStatus.analyticsStorage != _consentStatus.analyticsStorage) {
      sendPort.send(ConsentAnalyticsChangedEvent());
    }

    if (_currentPageMetadata == null) return;

    if (_consentStatus != previousStatus) {
      await _processAnalyticsEvent(ConsentEvent(DateTime.now().millisecondsSinceEpoch, _consentStatus));
    }

    if (previousStatus.adsStorage != _consentStatus.adsStorage) {
      await _enforceAdsConsentPolicy();
    }
  }

  Future<void> _enforceAdsConsentPolicy() async {
    if (_consentStatus.adsStorage) {
      await _sendGaid();
    } else {
      await _discardCachedGaidIfExists();
    }
  }

  Future<void> _sendGaid() async {
    if (!Platform.isAndroid) return;

    try {
      final gaid = await ClarityPlatform.getGaid();

      // Consent may have been revoked between the GAID request and this callback.
      if (!_consentStatus.adsStorage) return;
      if (_currentPageMetadata == null) return;

      final cachedGaid = await _settingsRepository.getCachedGaid();

      if (cachedGaid != gaid) {
        await _settingsRepository.updateCachedGaid(gaid);

        if (cachedGaid != null) {
          await _processAnalyticsEvent(GAIDOptOutEvent(DateTime.now().millisecondsSinceEpoch, cachedGaid));
        }
      }

      if (gaid != null) {
        await _processAnalyticsEvent(GAIDEvent(DateTime.now().millisecondsSinceEpoch, gaid));
      }
    } catch (_) {
      // GAID unavailable — no-op.
    }
  }

  Future<void> _discardCachedGaidIfExists() async {
    try {
      final cachedGaid = await _settingsRepository.getCachedGaid();
      if (cachedGaid == null) return;

      await _settingsRepository.updateCachedGaid(null);

      if (_currentPageMetadata == null) return;

      await _processAnalyticsEvent(GAIDOptOutEvent(DateTime.now().millisecondsSinceEpoch, cachedGaid));
    } catch (_) {}
  }

  Future<String> _computeUserId(ClarityConfig clarityConfig, bool analyticsStorage) async {
    if (!analyticsStorage) return _generateId();

    var cachedUserId = await _settingsRepository.getCachedUserId();

    if (cachedUserId != null && cachedUserId == clarityConfig.userId) {
      return cachedUserId;
    }

    if (clarityConfig.userId != null && clarityConfig.isUserIdValid()) {
      await _settingsRepository.writeUserId(clarityConfig.userId!);

      return clarityConfig.userId!;
    }

    cachedUserId ??= _generateId();

    await _settingsRepository.writeUserId(cachedUserId);

    return cachedUserId;
  }
}
