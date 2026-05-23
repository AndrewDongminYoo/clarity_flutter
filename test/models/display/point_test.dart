// 🎯 Dart imports:
import 'dart:ui' as ui;

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/point.dart';

void main() {
  group('Point', () {
    test('fromDartOffset converts ui.Offset correctly', () {
      const offset = ui.Offset(100, 200);
      final point = Point.fromDartOffset(offset);

      expect(point.x, 100.0);
      expect(point.y, 200.0);
    });

    test('toProtobufInstance creates protobuf with x and y', () {
      final point = Point(100, 200);
      final proto = point.toProtobufInstance();

      expect(proto.x, 100.0);
      expect(proto.y, 200.0);
    });

    test('roundtrip from ui.Offset to protobuf preserves values', () {
      const offset = ui.Offset(123.456, 789.012);
      final point = Point.fromDartOffset(offset);
      final proto = point.toProtobufInstance();

      expect(proto.x, closeTo(offset.dx, 0.0001));
      expect(proto.y, closeTo(offset.dy, 0.0001));
    });

    test('handles edge cases', () {
      // Zero
      final zeroPoint = Point.fromDartOffset(ui.Offset.zero);
      expect(zeroPoint.toProtobufInstance().x, 0.0);

      // Negative
      final negPoint = Point(-25, -50);
      expect(negPoint.toProtobufInstance().x, -25.0);

      // Infinite
      final infPoint = Point.fromDartOffset(const ui.Offset(double.infinity, double.negativeInfinity));
      expect(infPoint.x, double.infinity);
    });
  });
}
