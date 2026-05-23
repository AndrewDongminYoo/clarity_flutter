/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

class GAIDEvent extends AnalyticsEvent {
  GAIDEvent(int timestamp, this.gaid) : super(timestamp, EventType.GAID);
  final String gaid;

  @override
  String serialize(int pageTimestamp) {
    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},"${DataUtils.escape(gaid)}"]';
  }
}
