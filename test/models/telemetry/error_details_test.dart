// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/telemetry/error_details.dart';
import 'package:clarity_flutter/src/models/telemetry/telemetry_item.dart';

void main() {
  group('ErrorDetails', () {
    test('creates instance with required and optional fields', () {
      const error = ErrorDetails(
        errorType: 'ScreenCapturing',
        timestamp: '2024-01-01T12:30:00Z',
        message: 'Failed to capture screen',
        stackTrace: '#0 main (file.dart:10)',
      );

      expect(error.errorType, 'ScreenCapturing');
      expect(error.timestamp, '2024-01-01T12:30:00Z');
      expect(error.message, 'Failed to capture screen');
      expect(error.stackTrace, '#0 main (file.dart:10)');
      expect(error, isA<TelemetryItem>());
    });

    test('equality is based on errorType and message only', () {
      const error1 = ErrorDetails(
        errorType: 'Initialization',
        timestamp: '2024-01-01T00:00:00Z',
        message: 'Error message',
      );
      const error2 = ErrorDetails(
        errorType: 'Initialization',
        timestamp: '2024-06-15T12:00:00Z', // different timestamp
        message: 'Error message',
        stackTrace: 'different stack', // different stack
      );
      const error3 = ErrorDetails(
        errorType: 'ScreenCapturing', // different type
        timestamp: '2024-01-01T00:00:00Z',
        message: 'Error message',
      );

      expect(error1 == error2, isTrue); // same type + message
      expect(error1 == error3, isFalse); // different type
    });

    test('can be used in Set and as Map key', () {
      const error1 = ErrorDetails(errorType: 'A', timestamp: 't1', message: 'msg');
      const error2 = ErrorDetails(errorType: 'A', timestamp: 't2', message: 'msg');
      const error3 = ErrorDetails(errorType: 'B', timestamp: 't1', message: 'msg');

      final set = {error1, error2, error3};
      expect(set.length, 2); // error1 and error2 are equal

      final map = {error1: 'value1'};
      expect(map[error2], 'value1'); // error2 finds error1's value
    });
  });
}
