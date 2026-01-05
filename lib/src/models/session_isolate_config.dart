/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:isolate';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:clarity_flutter/clarity_flutter.dart';

class SessionIsolateConfig {
  SessionIsolateConfig({
    required this.sendPort,
    required this.clarityConfig,
    required this.rootIsolateToken,
  });

  SendPort sendPort;
  ClarityConfig clarityConfig;
  RootIsolateToken rootIsolateToken;
}
