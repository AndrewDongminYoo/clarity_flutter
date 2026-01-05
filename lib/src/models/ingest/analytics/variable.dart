/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

class VariableEvent extends AnalyticsEvent {
  VariableEvent(int timestamp, this.variables) : super(timestamp, EventType.Variable);
  final Map<String, Set<String>> variables;

  @override
  String serialize(int pageTimestamp) {
    final buffer = StringBuffer();
    buffer.write('[${relativeTimestamp(pageTimestamp)},${type.customOrdinal}');

    variables.forEach((key, values) {
      final escapedKey = DataUtils.escape(key);
      final escapedValue = values.map((v) => '"${DataUtils.escape(v)}"').join(',');

      buffer.write(',"$escapedKey",[$escapedValue]');
    });

    buffer.write(']');

    return buffer.toString();
  }
}
