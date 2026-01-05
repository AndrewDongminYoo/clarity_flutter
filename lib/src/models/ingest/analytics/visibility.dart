/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import '../../events/session_event.dart';
import 'analytics_event.dart';

class VisibilityEvent extends AnalyticsEvent {
  VisibilityEvent(int timestamp, this.state) : super(timestamp, EventType.Visibility);
  final String state;

  @override
  String serialize(int pageTimestamp) {
    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},"$state"]';
  }
}
