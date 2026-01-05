/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:async';
import 'dart:isolate';

// Flutter imports:
import 'package:flutter/cupertino.dart';

mixin IsolateHandler {
  @protected
  final Completer<dynamic> isolateReady = Completer();
  SendPort? workerIsolatePort;

  @protected
  void handleResponsesFromIsolate(dynamic message);
}
