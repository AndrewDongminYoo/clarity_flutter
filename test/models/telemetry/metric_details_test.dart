// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/telemetry/metric_details.dart';
import 'package:clarity_flutter/src/models/telemetry/telemetry_item.dart';

void main() {
  group('MetricDetails', () {
    test('creates instance with key and value', () {
      final metric = MetricDetails('Clarity_RepaintTriggered', 42);

      expect(metric.key, 'Clarity_RepaintTriggered');
      expect(metric.value, 42);
      expect(metric, isA<TelemetryItem>());
    });

    test('accepts various value ranges', () {
      expect(MetricDetails('key', 0).value, 0);
      expect(MetricDetails('key', -50).value, -50);
      expect(MetricDetails('key', 2147483647).value, 2147483647);
    });

    test('works with all MetricKey enum names', () {
      for (final key in MetricKey.values) {
        final metric = MetricDetails(key.name, 100);
        expect(metric.key, key.name);
      }
    });
  });
}
