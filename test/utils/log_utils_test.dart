// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/log_utils.dart';

void main() {
  group('LogLevel', () {
    test('LEVELS list is ordered from lowest to highest', () {
      expect(LogLevel.LEVELS, [
        LogLevel.Verbose,
        LogLevel.Debug,
        LogLevel.Info,
        LogLevel.Warn,
        LogLevel.Error,
        LogLevel.None,
      ]);

      // Verify ordering using comparison operators
      for (var i = 0; i < LogLevel.LEVELS.length - 1; i++) {
        expect(LogLevel.LEVELS[i] < LogLevel.LEVELS[i + 1], isTrue);
      }
    });

    test('toString returns uppercase name', () {
      expect(LogLevel.Verbose.toString(), 'VERBOSE');
      expect(LogLevel.Debug.toString(), 'DEBUG');
      expect(LogLevel.Info.toString(), 'INFO');
      expect(LogLevel.Warn.toString(), 'WARN');
      expect(LogLevel.Error.toString(), 'ERROR');
      expect(LogLevel.None.toString(), 'NONE');
    });

    test('comparison operators work correctly', () {
      // Less than
      expect(LogLevel.Verbose < LogLevel.Debug, isTrue);
      expect(LogLevel.Debug < LogLevel.Verbose, isFalse);
      expect(LogLevel.Info < LogLevel.Info, isFalse);

      // Less than or equal
      expect(LogLevel.Verbose <= LogLevel.Debug, isTrue);
      expect(LogLevel.Info <= LogLevel.Info, isTrue);
      expect(LogLevel.Error <= LogLevel.Warn, isFalse);

      // Greater than
      expect(LogLevel.None > LogLevel.Error, isTrue);
      expect(LogLevel.Verbose > LogLevel.Debug, isFalse);
      expect(LogLevel.Warn > LogLevel.Warn, isFalse);

      // Greater than or equal
      expect(LogLevel.Error >= LogLevel.Warn, isTrue);
      expect(LogLevel.Debug >= LogLevel.Debug, isTrue);
      expect(LogLevel.Info >= LogLevel.Error, isFalse);
    });

    test('compareTo returns correct sign', () {
      expect(LogLevel.Verbose.compareTo(LogLevel.Debug), lessThan(0));
      expect(LogLevel.Info.compareTo(LogLevel.Info), 0);
      expect(LogLevel.Error.compareTo(LogLevel.Warn), greaterThan(0));
    });

    test('equality compares by value', () {
      expect(LogLevel.Verbose == LogLevel.Verbose, isTrue);
      expect(LogLevel.Debug == LogLevel.Info, isFalse);
    });

    test('hashCode is consistent with equality', () {
      expect(LogLevel.Info.hashCode, LogLevel.Info.hashCode);
    });
  });
}
