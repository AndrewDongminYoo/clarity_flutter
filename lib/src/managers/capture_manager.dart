/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/cupertino.dart' as cupertino;

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

// Project imports:
import 'package:clarity_flutter/src/helpers/telemetry_tracker.dart';
import 'package:clarity_flutter/src/managers/base_session_manager.dart';
import 'package:clarity_flutter/src/mixins/callback_handler.dart';
import 'package:clarity_flutter/src/mixins/event_queue_handler.dart';
import 'package:clarity_flutter/src/models/assets/image.dart';
import 'package:clarity_flutter/src/models/capture/error_snapshot.dart';
import 'package:clarity_flutter/src/models/capture/native_image_wrapper.dart';
import 'package:clarity_flutter/src/models/capture/snapshot.dart';
import 'package:clarity_flutter/src/models/capture/user_gesture.dart';
import 'package:clarity_flutter/src/models/capture/user_keyboard_tap.dart';
import 'package:clarity_flutter/src/models/display/display.dart';
import 'package:clarity_flutter/src/models/events/control_event.dart';
import 'package:clarity_flutter/src/models/events/observed_event.dart';
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/keystrokes_event.dart';
import 'package:clarity_flutter/src/models/ingest/ingest.dart';
import 'package:clarity_flutter/src/models/ingest/mutation_error_event.dart';
import 'package:clarity_flutter/src/models/project_config.dart';
import 'package:clarity_flutter/src/models/telemetry/telemetry.dart';
import 'package:clarity_flutter/src/models/view_hierarchy/view_hierarchy.dart';
import 'package:clarity_flutter/src/observers/clarity_gesture_observer.dart';
import 'package:clarity_flutter/src/observers/snapshot_capturer.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/registries/host_info.dart';
import 'package:clarity_flutter/src/utils/asset_utils.dart';
import 'package:clarity_flutter/src/utils/dev_utils.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';
import 'package:clarity_flutter/src/utils/project_config_utils.dart';
import 'package:clarity_flutter/src/utils/render_object_utils.dart';

class CaptureManager with CallbackHandler, EventQueueHandler {
  CaptureManager._internal() {
    final registry = EnvRegistry.ensureInitialized();
    final maskingMode = registry.getItem<ProjectConfig>(EnvRegistryKey.projectConfig)!.maskingMode;
    snapshotCapturer = SnapshotCapturer(maskingMode, enqueueEvent, _paintsCache);
    clarityGestureObserver = ClarityGestureObserver(enqueueEvent);

    _listenToNetworkChanges();
  }

  factory CaptureManager.create() {
    _instance ??= CaptureManager._internal();
    return _instance!;
  }

  late SnapshotCapturer snapshotCapturer;
  late ClarityGestureObserver clarityGestureObserver;
  final Map<int, NativeImageWrapper> _imageCache = {};
  final Map<int, Paint> _paintsCache = {};
  bool _started = false;
  bool _observersPaused = false;
  bool _userPaused = false;
  bool _widgetRemoved = false;
  bool _networkPaused = false;
  bool _screenDisallowed = false;
  final _connectivity = Connectivity();

  bool get _forcePause => _userPaused || _widgetRemoved || _networkPaused || _screenDisallowed;

  static CaptureManager? _instance;

  void _listenToNetworkChanges() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      Logger.info?.out('Connectivity changed: $result');
      final allowUploadOverNetwork = ProjectConfigUtils.isUploadingOverNetworkAllowed(result);

      if (allowUploadOverNetwork) {
        _networkPaused = false;
        _resumeObservers();
      } else {
        _networkPaused = true;
        _pauseObservers();
      }

      fireEvent(NetworkConnectivityChangedEvent(allowUploadOverNetwork));
    });
  }

  void start() {
    if (_started) {
      Logger.info?.out('Clarity is already capturing');
      return;
    }
    _started = true;
    initializeSkippedRenderObjects();
    snapshotCapturer.start();
    clarityGestureObserver.start();
  }

  void userPause() {
    _userPaused = true;
    _pauseObservers();
  }

  void userResume() {
    _userPaused = false;
    _resumeObservers();
  }

  void widgetRemoved() {
    _widgetRemoved = true;
    _pauseObservers();
  }

  void widgetRestored() {
    _widgetRemoved = false;
    _resumeObservers();
  }

  void throttleCapture() {
    _pauseObservers();
  }

  void unThrottleCapture() {
    _resumeObservers();
  }

  void _pauseObservers() {
    if (_observersPaused) return;

    Logger.info?.out('Clarity capturing paused');
    snapshotCapturer.pause();
    clarityGestureObserver.pause();

    _observersPaused = true;
  }

  void _resumeObservers() {
    if (_forcePause || !_observersPaused) return;

    Logger.info?.out('Clarity capturing resumed');
    snapshotCapturer.resume();
    clarityGestureObserver.resume();

    _observersPaused = false;
  }

  static cupertino.Widget getGestureListenerWidget(cupertino.Widget app) {
    return ClarityGestureObserver.getGestureListenerWidget(app);
  }

  void setUserProvidedScreenName(String? screenName) {
    snapshotCapturer.setUserProvidedScreenName(screenName);

    if (ProjectConfigUtils.isScreenNameAllowed(screenName)) {
      _screenDisallowed = false;
      _resumeObservers();
    } else {
      _screenDisallowed = true;
      _pauseObservers();
    }
  }

  @override
  void preProcessEvent(covariant ObservedEvent event) {
    if (!_started) throw Exception('Clarity not started yet, dropping event');
  }

  @override
  Future<void> processEvent(covariant ObservedEvent event) async {
    await Future<void>.delayed(Duration.zero);

    switch (event) {
      case UserGesture():
        fireEvent<SessionEvent>(event.gestureEvent);

      case Snapshot():
        fireEvent<SessionEvent>(await _processSnapshot(event));

      case UserKeyboardTap():
        fireEvent<SessionEvent>(_processUserKeyboardTap(event));

      case ErrorSnapshot():
        _trackFrameError(event.timestamp, ErrorReason.frameCapturingError, event.errorMessage);
    }
  }

  @override
  void processEventError(covariant ObservedEvent event, Object e, StackTrace st) {
    TelemetryTracker.instance?.trackError(ErrorType.ObservedEventProcessing, e.toString(), st);
    if (event is Snapshot) {
      _trackFrameError(event.timestamp, ErrorReason.frameProcessingError, e.toString());
    }
  }

  void startNewSession(SessionStartedCallback callback) {
    snapshotCapturer.startNewSession(callback);
  }

  Future<MutationEvent> _processSnapshot(Snapshot snapshot) async {
    late DisplayFrame frame;
    await profileTimeSync('ClarityProcessSnapshot', () async {
      frame = await _getDisplayFrame(snapshot);
      _cleanUpCache();
    });

    final hostInfo = EnvRegistry.ensureInitialized().getItem<HostInfo>(EnvRegistryKey.hostInfo)!;

    return MutationEvent(snapshot.timestamp, frame, snapshot.userProvidedScreenName ?? hostInfo.defaultScreenName);
  }

  KeystrokesEvent _processUserKeyboardTap(UserKeyboardTap event) => KeystrokesEvent(event.timestamp, event.count);

  void _trackFrameError(int timestamp, ErrorReason reason, String errorMessage) {
    fireEvent<SessionEvent>(
      MutationErrorEvent(timestamp, ErrorReason.frameProcessingError, errorMessage: errorMessage),
    );
  }

  int? _getImageCloneHashCodeIfExists(NativeImageWrapper imageRef) {
    for (final cachedImage in _imageCache.entries) {
      if (cachedImage.value.isCloneOf(imageRef)) {
        return cachedImage.key;
      }
    }
    return null;
  }

  Future<DisplayFrame> _getDisplayFrame(Snapshot snapshot) async {
    Logger.verbose?.out(
      'Captured a Snapshot with ${snapshot.commands.length} commands, ${snapshot.images.length} images, ${snapshot.paints.length} Paints. Current Paint cache size ${_paintsCache.length}',
    );
    final framePaints = <Paint>[];
    final paintHashcodeToIndex = <int, int>{};
    final frameImages = <Image>[];
    for (final command in snapshot.commands) {
      await profileTimeSync('ClarityProcessCommand', () async {
        if (command is PaintCommand) {
          if (!paintHashcodeToIndex.containsKey(command.paintHashcode)) {
            framePaints.add(snapshot.paints[command.paintHashcode]!);
            paintHashcodeToIndex[command.paintHashcode] = framePaints.length - 1;
          }

          command.paintIndex = paintHashcodeToIndex[command.paintHashcode];
        }
        if (command is ImageCommand && command.imageHashcode != null) {
          Image? imageAsset;
          if (_imageCache.containsKey(command.imageHashcode)) {
            final imageWrapper = _imageCache[command.imageHashcode]!;
            imageAsset = Image(null, command.imageHashcode!, imageWrapper.size);
          } else {
            final cloneHashcode = _getImageCloneHashCodeIfExists(snapshot.images[command.imageHashcode]!);
            if (cloneHashcode == null) {
              // New image, need to fetch data
              final imageWrapper = snapshot.images[command.imageHashcode]!;
              _imageCache[command.imageHashcode!] = imageWrapper;
              Uint8List? imageBytes;
              try {
                final getBytes = profileTimeAsync();
                getBytes?.start('ClarityGetImageBytes');
                imageBytes = await AssetUtils.getImageBytes((await imageWrapper.imageData)!);
                imageWrapper.disposeData();
                getBytes?.finish();
              } catch (e) {
                Logger.warn?.out(
                  'Failed to fetch image ${DateTime.now().millisecondsSinceEpoch - snapshot.timestamp} isPictureSource: ${snapshot.images[command.imageHashcode]?.isFromPicture} Disposed: ${snapshot.images[command.imageHashcode]?.debugDisposed} Error: $e',
                );
              }
              // Yield to main thread after image fetch to not block the main thread too long
              await Future<void>.delayed(Duration.zero);
              imageAsset = Image(imageBytes, command.imageHashcode!, imageWrapper.size);
            } else {
              final imageWrapper = _imageCache[cloneHashcode]!;
              imageAsset = Image(null, cloneHashcode, imageWrapper.size);
            }
          }
          frameImages.add(imageAsset);
          command.imageIndex = frameImages.length - 1;
        }
      });
    }

    final viewHierarchy = ViewHierarchy(snapshot.timestamp, snapshot.root!);

    return DisplayFrame(
      snapshot.timestamp,
      frameImages,
      framePaints,
      snapshot.commands,
      snapshot.root!.width,
      snapshot.root!.height,
      snapshot.keyboardHeight,
      viewHierarchy,
      snapshot.deviceTransformationMatrix.storage[0],
      snapshot.forceStartNewSession,
      snapshot.forceStartNewSessionCallback,
      viewId: snapshot.flutterViewId,
    );
  }

  void _cleanUpCache() {
    // Remove images that got garbage collected.
    _imageCache.removeWhere((key, value) => value.isDisposed());

    if (_imageCache.length > 20) {
      _imageCache.clear();
    }

    if (_paintsCache.length > 100) {
      Logger.debug?.out('Clearing paints cache!');
      _paintsCache.clear();
    }
  }
}
