// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/int_utils.dart';

void main() {
  group('IntUtils.safeToInt', () {
    test('returns zero when value is NaN or infinite', () {
      expect(IntUtils.safeToInt(double.nan), 0);
      expect(IntUtils.safeToInt(double.infinity), 0);
      expect(IntUtils.safeToInt(double.negativeInfinity), 0);
    });

    test('truncates positive and negative fractional values', () {
      expect(IntUtils.safeToInt(42.9), 42);
      expect(IntUtils.safeToInt(-3.7), -3);
    });
  });
}
