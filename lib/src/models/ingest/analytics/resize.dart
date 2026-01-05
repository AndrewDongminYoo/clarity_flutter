/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';

class ResizeEvent extends AnalyticsEvent {
  ResizeEvent(int timestamp, this.width, this.height) : super(timestamp, EventType.Resize);
  final int width;
  final int height;

  @override
  String serialize(int pageTimestamp) {
    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},$width,$height]';
  }
}
