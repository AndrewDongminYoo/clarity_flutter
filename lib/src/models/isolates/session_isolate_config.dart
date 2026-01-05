/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/isolates/isolate_config.dart';

class SessionIsolateConfig extends IsolateConfig {
  SessionIsolateConfig({required super.sendPort});
}
