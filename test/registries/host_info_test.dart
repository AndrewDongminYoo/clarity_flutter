// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/registries/host_info.dart';

void main() {
  group('ApplicationPlatform', () {
    test('getCurrentPlatform returns correct platform for current OS', () {
      final platform = ApplicationPlatform.getCurrentPlatform();

      if (Platform.isAndroid) {
        expect(platform, ApplicationPlatform.android);
      } else if (Platform.isIOS) {
        expect(platform, ApplicationPlatform.ios);
      } else {
        expect(platform, ApplicationPlatform.web);
      }
    });

    test('enum has expected values with correct indices', () {
      expect(ApplicationPlatform.values.length, 3);
      expect(ApplicationPlatform.web.index, 0);
      expect(ApplicationPlatform.android.index, 1);
      expect(ApplicationPlatform.ios.index, 2);
    });
  });
}
