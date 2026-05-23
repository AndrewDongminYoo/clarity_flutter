/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

class GAIDOptOutEvent extends AnalyticsEvent {
  GAIDOptOutEvent(int timestamp, this.gaid) : super(timestamp, EventType.GAIDOptOut);
  final String gaid;

  @override
  String serialize(int pageTimestamp) {
    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},"${DataUtils.escape(gaid)}"]';
  }
}
