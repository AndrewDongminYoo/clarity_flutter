/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:clarity_flutter/src/managers/session_manager.dart';
import 'package:clarity_flutter/src/managers/upload_manager.dart';
import 'package:clarity_flutter/src/models/isolates/isolate_config.dart';
import 'package:clarity_flutter/src/models/isolates/session_isolate_config.dart';
import 'package:clarity_flutter/src/models/isolates/upload_isolate_config.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/utils/dev_utils.dart';
import 'package:clarity_flutter/src/utils/entry_point.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

abstract class WorkerIsolate {
  @protected
  WorkerIsolate(IsolateConfig isolateConfig)
    : sendPort = isolateConfig.sendPort,
      clarityConfig = EnvRegistry.ensureInitialized().getItem<ClarityConfig>(EnvRegistryKey.clarityConfig)!;

  @protected
  final SendPort sendPort;
  @protected
  final ClarityConfig clarityConfig;

  static Future<Isolate> spawn(IsolateConfig config) {
    return Isolate.spawn(_initializeIsolate, config);
  }

  static Future<void> _initializeIsolate(IsolateConfig isolateConfig) async {
    final registry = EnvRegistry.ensureInitialized(initialItems: isolateConfig.environmentRegistryItems);
    Logger.configuredLogLevel = registry.getItem<ClarityConfig>(EnvRegistryKey.clarityConfig)!.logLevel;
    await DebuggingUtils.init();

    WorkerIsolate instance;
    if (isolateConfig is SessionIsolateConfig) {
      // Needed for Host Info data retrieval
      final rootIsolateToken = registry.getItem<RootIsolateToken>(EnvRegistryKey.rootIsolateToken)!;
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      instance = SessionWorkerIsolate(isolateConfig);
    } else if (isolateConfig is UploadIsolateConfig) {
      instance = UploadWorkerIsolate(isolateConfig);
    } else {
      throw UnimplementedError('Provided Config is not a valid type must be implemented in subclasses');
    }

    final receivePort = ReceivePort();
    instance.sendPort.send(receivePort.sendPort);

    receivePort.listen((message) => EntryPoint.run(() => instance.processMessage(message)));
  }

  void processMessage(dynamic message);
}
