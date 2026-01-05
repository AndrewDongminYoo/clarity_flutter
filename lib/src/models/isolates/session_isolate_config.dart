/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'isolate_config.dart';

class SessionIsolateConfig extends IsolateConfig {
  SessionIsolateConfig({required super.sendPort});
}
