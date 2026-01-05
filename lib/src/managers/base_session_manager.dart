/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:ui';

// 🌎 Project imports:
import 'package:clarity_flutter/src/mixins/callback_handler.dart';
import 'package:clarity_flutter/src/mixins/event_queue_handler.dart';
import 'package:clarity_flutter/src/mixins/isolate_handler.dart';

typedef SessionStartedCallback = void Function(String sessionId);

abstract class BaseSessionManager with CallbackHandler, IsolateHandler, EventQueueHandler {
  void onAppLifecycleChanged(AppLifecycleState state);

  void setCustomTags(String key, Set<String> values);

  void setOnSessionStartedOrResumedCallback(SessionStartedCallback callback);

  String? getSessionUrl();

  void sendCustomEvent(String value);
}
