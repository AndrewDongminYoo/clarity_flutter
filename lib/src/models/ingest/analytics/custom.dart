/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

class CustomEvent extends AnalyticsEvent {
  CustomEvent(int timestamp, this.value) : super(timestamp, EventType.Custom);
  final String value;

  @override
  String serialize(int pageTimestamp) {
    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},"${DataUtils.escape(value)}"]';
  }
}
