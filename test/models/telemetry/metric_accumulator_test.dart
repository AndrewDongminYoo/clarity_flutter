// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/telemetry/metric_accumulator.dart';

void main() {
  group('MetricAccumulator.add', () {
    test('accumulates single value correctly', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(10);

      final json = accumulator.toJson();
      expect(json['c'], 1);
      expect(json['s'], 10.0);
      expect(json['min'], 10.0);
      expect(json['max'], 10.0);
      expect(json['stdev'], 0.0);
    });

    test('accumulates multiple values and calculates statistics', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(10);
      accumulator.add(20);
      accumulator.add(30);

      final json = accumulator.toJson();
      expect(json['c'], 3);
      expect(json['s'], 60.0);
      expect(json['min'], 10.0);
      expect(json['max'], 30.0);
    });

    test('calculates standard deviation using Welford algorithm', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(2);
      accumulator.add(4);
      accumulator.add(4);
      accumulator.add(4);
      accumulator.add(5);
      accumulator.add(5);
      accumulator.add(7);
      accumulator.add(9);

      final json = accumulator.toJson();
      // Mean = 5.0, Variance = 4.0, StdDev = 2.0
      expect(json['stdev'], closeTo(2.0, 0.01));
    });

    test('tracks minimum value across additions', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(50);
      accumulator.add(10);
      accumulator.add(100);
      accumulator.add(5);

      final json = accumulator.toJson();
      expect(json['min'], 5.0);
    });

    test('tracks maximum value across additions', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(50);
      accumulator.add(100);
      accumulator.add(10);
      accumulator.add(75);

      final json = accumulator.toJson();
      expect(json['max'], 100.0);
    });

    test('handles negative integer values correctly', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(-10);
      accumulator.add(-5);
      accumulator.add(5);

      final json = accumulator.toJson();
      expect(json['s'], -10.0);
      expect(json['min'], -10.0);
      expect(json['max'], 5.0);
    });

    test('handles zero values correctly', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(0);
      accumulator.add(0);
      accumulator.add(0);

      final json = accumulator.toJson();
      expect(json['s'], 0.0);
      expect(json['stdev'], 0.0);
      expect(json['min'], 0.0);
      expect(json['max'], 0.0);
    });
  });

  group('MetricAccumulator.toJson', () {
    test('applies precision limiting to 2 decimal places', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(10);
      accumulator.add(21);
      accumulator.add(30);

      final json = accumulator.toJson();

      expect(json['n'], 'test_metric');
      expect(json['c'], 3);
      expect(json['s'], 61.0);
      expect(json['min'], 10.0);
      expect(json['max'], 30.0);
      expect(json['stdev'], isA<double>());
    });

    test('includes required fields in JSON output', () {
      final accumulator = MetricAccumulator('metric_name');
      accumulator.add(5);

      final json = accumulator.toJson();

      expect(json.keys, containsAll(['v', 'n', 'c', 's', 'min', 'max', 'stdev', 'f']));
      expect(json['n'], 'metric_name');
    });

    test('includes version and platform fields', () {
      final accumulator = MetricAccumulator('test');
      accumulator.add(1);

      final json = accumulator.toJson();

      expect(json['v'], isNotNull);
      expect(json['f'], isA<int>());
    });
  });

  group('MetricAccumulator edge cases', () {
    test('handles large integer values', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(1000000);
      accumulator.add(2000000);

      final json = accumulator.toJson();
      expect(json['s'], 3000000.0);
    });

    test('precision limiting rounds correctly', () {
      final accumulator = MetricAccumulator('test_metric');
      accumulator.add(10);
      accumulator.add(10);
      accumulator.add(11);

      final json = accumulator.toJson();
      // Sum = 31, should be rounded to 2 decimals
      expect(json['s'], 31.0);
    });
  });
}
