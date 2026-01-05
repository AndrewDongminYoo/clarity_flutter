/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:isolate';

// Project imports:
import 'package:clarity_flutter/src/registries/environment_registry.dart';

abstract class IsolateConfig {
  IsolateConfig({required this.sendPort}) : environmentRegistryItems = EnvRegistry.ensureInitialized().toMap();

  SendPort sendPort;
  Map<EnvRegistryKey, dynamic> environmentRegistryItems;
}
