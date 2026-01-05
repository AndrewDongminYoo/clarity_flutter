/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';

class KeystrokesEvent extends AnalyticsEvent {
  KeystrokesEvent(int timestamp, this.count) : super(timestamp, EventType.Keystrokes);
  final int count;

  @override
  String serialize(int pageTimestamp) {
    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},$count]';
  }
}
