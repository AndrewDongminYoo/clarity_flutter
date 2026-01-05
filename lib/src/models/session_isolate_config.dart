/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'dart:isolate';

import 'package:flutter/services.dart';

import '../../clarity_flutter.dart';

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
