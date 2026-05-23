// 🎯 Dart imports:
import 'dart:ui' as ui;

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/irect.dart';

void main() {
  group('IRect', () {
    test('fromDartRect converts ui.Rect correctly', () {
      const dartRect = ui.Rect.fromLTRB(10, 20, 100, 200);
      final rect = IRect.fromDartRect(dartRect);

      expect(rect.left, 10.0);
      expect(rect.top, 20.0);
      expect(rect.right, 100.0);
      expect(rect.bottom, 200.0);
    });

    test('toProtobufInstance creates protobuf with all coordinates', () {
      final rect = IRect(10, 20, 100, 200);
      final proto = rect.toProtobufInstance();

      expect(proto.left, 10.0);
      expect(proto.top, 20.0);
      expect(proto.right, 100.0);
      expect(proto.bottom, 200.0);
    });

    test('roundtrip from ui.Rect to protobuf preserves values', () {
      const dartRect = ui.Rect.fromLTWH(10, 20, 90, 180);
      final rect = IRect.fromDartRect(dartRect);
      final proto = rect.toProtobufInstance();

      expect(proto.left, dartRect.left);
      expect(proto.top, dartRect.top);
      expect(proto.right, dartRect.right);
      expect(proto.bottom, dartRect.bottom);
    });
  });
}
