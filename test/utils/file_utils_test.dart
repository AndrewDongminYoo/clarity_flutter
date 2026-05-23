// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/file_utils.dart';

void main() {
  group('FileUtils.concat', () {
    test('joins segments with the platform separator', () {
      final expected = 'root${Platform.pathSeparator}child${Platform.pathSeparator}leaf';
      expect(FileUtils.concat(const ['root', 'child', 'leaf']), expected);
    });

    test('handles edge cases', () {
      expect(FileUtils.concat(const []), '');
      expect(FileUtils.concat(const ['onlySegment']), 'onlySegment');
      expect(FileUtils.concat(const ['', 'middle', '']), '${Platform.pathSeparator}middle${Platform.pathSeparator}');
    });
  });
}
