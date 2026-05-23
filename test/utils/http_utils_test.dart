// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/http_utils.dart';

void main() {
  group('HttpUtils.isSuccessCode', () {
    test('returns true for 2xx status codes', () {
      expect(HttpUtils.isSuccessCode(200), isTrue);
      expect(HttpUtils.isSuccessCode(204), isTrue);
      expect(HttpUtils.isSuccessCode(299), isTrue);
    });

    test('returns false for non 2xx status codes', () {
      expect(HttpUtils.isSuccessCode(199), isFalse);
      expect(HttpUtils.isSuccessCode(300), isFalse);
      expect(HttpUtils.isSuccessCode(404), isFalse);
      expect(HttpUtils.isSuccessCode(500), isFalse);
      expect(HttpUtils.isSuccessCode(0), isFalse);
      expect(HttpUtils.isSuccessCode(-1), isFalse);
    });
  });
}
