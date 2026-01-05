/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';

abstract class GestureEvent extends AnalyticsEvent {
  GestureEvent(super.timestamp, super.type, this.absX, this.absY, this.pointerId);
  double absX;
  double absY;
  int pointerId;

  @override
  String serialize(int pageTimestamp) {
    return '['
        '${relativeTimestamp(pageTimestamp)},'
        '${type.customOrdinal},'
        '$pointerId,'
        '${absX.round()},'
        '${absY.round()}'
        ']';
  }

  String getDebugInfo();
}
