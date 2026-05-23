// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/rect_utils.dart';

void main() {
  group('RectUtils.getVisibleBounds', () {
    test('returns intersection when rect is fully inside container', () {
      const rect = Rect.fromLTWH(10, 10, 20, 20);
      const container = Rect.fromLTWH(0, 0, 100, 100);
      final visible = rect.getVisibleBounds(container);
      expect(visible, rect);
    });

    test('returns clipped bounds when rect partially outside container', () {
      const rect = Rect.fromLTWH(80, 80, 40, 40);
      const container = Rect.fromLTWH(0, 0, 100, 100);
      final visible = rect.getVisibleBounds(container);
      expect(visible, const Rect.fromLTWH(80, 80, 20, 20));
    });

    test('returns empty rect when fully outside container', () {
      const rect = Rect.fromLTWH(150, 150, 20, 20);
      const container = Rect.fromLTWH(0, 0, 100, 100);
      final visible = rect.getVisibleBounds(container);
      expect(visible.isEmpty, isTrue);
    });
  });

  group('RectUtils.isVisible', () {
    test('returns true for valid positive dimensions', () {
      const rect = Rect.fromLTWH(10, 10, 20, 30);
      expect(rect.isVisible(), isTrue);
    });

    test('returns false for negative width or height', () {
      const rectNegWidth = Rect.fromLTRB(10, 10, 5, 20);
      const rectNegHeight = Rect.fromLTRB(10, 10, 20, 5);
      expect(rectNegWidth.isVisible(), isFalse);
      expect(rectNegHeight.isVisible(), isFalse);
    });
  });

  group('RectUtils.tolerantEqual', () {
    test('returns true when differences are within tolerance', () {
      const rect1 = Rect.fromLTRB(10, 20, 30, 40);
      const rect2 = Rect.fromLTRB(10.3, 20.4, 30.2, 40.5);
      expect(rect1.tolerantEqual(rect2), isTrue);
    });

    test('returns false when differences exceed tolerance', () {
      const rect1 = Rect.fromLTRB(10, 20, 30, 40);
      const rect2 = Rect.fromLTRB(10, 20, 31, 40);
      expect(rect1.tolerantEqual(rect2), isFalse);
    });
  });

  group('RectUtils.prodToString', () {
    test('formats rect coordinates to one decimal place', () {
      const rect = Rect.fromLTRB(10.567, 20.123, 30.999, 40.001);
      expect(rect.prodToString(), 'Rect.fromLTRB(10.6, 20.1, 31.0, 40.0)');
    });
  });
}
