/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/gesture_event.dart';

class DoubleClick extends GestureEvent {
  DoubleClick(int timestamp, int pointerId, double absX, double absY)
    : super(timestamp, EventType.DoubleClick, absX, absY, pointerId);

  @override
  String getDebugInfo() {
    return 'DoubleClick(timestamp: $timestamp, pointerId: $pointerId, absX: $absX, absY: $absY)';
  }
}
