/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import '../../events/session_event.dart';
import '../../../utils/data_utils.dart';
import 'analytics_event.dart';

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
