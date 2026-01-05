/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';

class VisibilityEvent extends AnalyticsEvent {
  VisibilityEvent(int timestamp, this.state) : super(timestamp, EventType.Visibility);
  final String state;

  @override
  String serialize(int pageTimestamp) {
    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},"$state"]';
  }
}
