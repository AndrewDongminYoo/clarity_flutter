// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/ingest/asset_check.dart';

void main() {
  group('AssetCheck.toJsonObject', () {
    test('returns map with all fields', () {
      final check = AssetCheck(hash: 'abc123', path: '/assets/image.png', version: '1.0.0', type: 1);

      final json = check.toJsonObject();

      expect(json['hash'], 'abc123');
      expect(json['path'], '/assets/image.png');
      expect(json['version'], '1.0.0');
      expect(json['type'], 1);
    });

    test('handles null optional fields', () {
      final check = AssetCheck(type: 2);

      final json = check.toJsonObject();

      expect(json['hash'], isNull);
      expect(json['path'], isNull);
      expect(json['version'], isNull);
      expect(json['type'], 2);
    });
  });

  group('AssetCheck.toJson', () {
    test('produces valid JSON string', () {
      final check = AssetCheck(hash: 'xyz', path: '/path', version: '2.0', type: 3);

      final jsonString = check.toJson();
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(decoded['hash'], 'xyz');
      expect(decoded['type'], 3);
    });

    test('roundtrip through JSON encode/decode', () {
      final check = AssetCheck(hash: 'hash123', path: '/some/path.png', version: '1.2.3', type: 1);

      final jsonString = check.toJson();
      final decoded = jsonDecode(jsonString);

      expect(decoded, check.toJsonObject());
    });
  });
}
