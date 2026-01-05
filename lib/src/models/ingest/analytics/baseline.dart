/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';

class BaselineEvent extends AnalyticsEvent {
  BaselineEvent(int timestamp, this.visible) : super(timestamp, EventType.Baseline);
  final bool visible;

  @override
  String serialize(int pageTimestamp) {
    final visibleInt = visible ? 1 : 0;
    const documentWidth = 0; // Do not care.
    const documentHeight = 0; // Do not care.
    const screenWidth = 0; // Do not care.
    const screenHeight = 0; // Do not care.
    const scrollX = 0; // Do not care.
    const scrollY = 0; // Do not care.
    const pointerX = 0; // Do not care.
    const pointerY = 0; // Do not care.
    const activityTime = 0; // Do not care.

    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},$visibleInt,$documentWidth,'
        '$documentHeight,$screenWidth,$screenHeight,$scrollX,$scrollY,$pointerX,$pointerY,$activityTime]';
  }
}
