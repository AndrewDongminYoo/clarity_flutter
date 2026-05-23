// 🎯 Dart imports:
import 'dart:ui' as ui;

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/rrect.dart';

void main() {
  group('RRect', () {
    test('fromDartRRect converts uniform radius correctly', () {
      final dartRRect = ui.RRect.fromRectAndRadius(
        const ui.Rect.fromLTRB(10, 20, 100, 200),
        const ui.Radius.circular(15),
      );
      final rrect = RRect.fromDartRRect(dartRRect);

      expect(rrect.left, 10.0);
      expect(rrect.top, 20.0);
      expect(rrect.right, 100.0);
      expect(rrect.bottom, 200.0);
      expect(rrect.radii.length, 4);
      for (final radius in rrect.radii) {
        expect(radius, [15.0, 15.0]);
      }
    });

    test('fromDartRRect converts different corner radii correctly', () {
      final dartRRect = ui.RRect.fromRectAndCorners(
        const ui.Rect.fromLTRB(0, 0, 100, 100),
        topLeft: const ui.Radius.circular(5),
        topRight: const ui.Radius.circular(10),
        bottomRight: const ui.Radius.circular(15),
        bottomLeft: const ui.Radius.circular(20),
      );
      final rrect = RRect.fromDartRRect(dartRRect);

      expect(rrect.radii[0], [5.0, 5.0]); // top-left
      expect(rrect.radii[1], [10.0, 10.0]); // top-right
      expect(rrect.radii[2], [15.0, 15.0]); // bottom-right
      expect(rrect.radii[3], [20.0, 20.0]); // bottom-left
    });

    test('fromDartRRect converts elliptical radii correctly', () {
      final dartRRect = ui.RRect.fromRectAndCorners(
        const ui.Rect.fromLTRB(0, 0, 100, 100),
        topLeft: const ui.Radius.elliptical(5, 10),
        topRight: const ui.Radius.elliptical(15, 20),
        bottomRight: const ui.Radius.elliptical(25, 30),
        bottomLeft: const ui.Radius.elliptical(35, 40),
      );
      final rrect = RRect.fromDartRRect(dartRRect);

      expect(rrect.radii[0], [5.0, 10.0]);
      expect(rrect.radii[1], [15.0, 20.0]);
      expect(rrect.radii[2], [25.0, 30.0]);
      expect(rrect.radii[3], [35.0, 40.0]);
    });

    test('toProtobufInstance creates protobuf with coordinates and radii', () {
      final radii = [
        [5.0, 5.0],
        [10.0, 10.0],
        [15.0, 15.0],
        [20.0, 20.0],
      ];
      final rrect = RRect(10, 20, 100, 200, radii);
      final proto = rrect.toProtobufInstance();

      expect(proto.left, 10.0);
      expect(proto.top, 20.0);
      expect(proto.right, 100.0);
      expect(proto.bottom, 200.0);
    });
  });
}
