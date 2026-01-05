/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'dart:isolate';
import '../../registries/environment_registry.dart';

abstract class IsolateConfig {
  IsolateConfig({required this.sendPort}) : environmentRegistryItems = EnvRegistry.ensureInitialized().toMap();

  SendPort sendPort;
  Map<EnvRegistryKey, dynamic> environmentRegistryItems;
}
