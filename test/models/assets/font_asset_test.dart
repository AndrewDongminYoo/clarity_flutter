// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/assets/font_asset.dart';

void main() {
  group('Typeface', () {
    test('toProtobufInstance returns correct protobuf message', () {
      final typeface = Typeface(
        familyName: 'Roboto',
        dataHash: 'protohash',
        fullName: 'Roboto Regular',
        weightValue: 400,
      );

      final proto = typeface.toProtobufInstance();

      expect(proto.familyName, 'Roboto');
      expect(proto.dataHash, 'protohash');
      expect(proto.fullName, 'Roboto Regular');
      expect(proto.weightValue, 400.0);
      expect(proto.italicValue, 0.0);
    });
  });

  group('FontCacheData', () {
    test('toJson includes all fields', () {
      final typeface = Typeface(
        familyName: 'Roboto',
        dataHash: 'abc123',
        weightValue: 400,
        assetPath: 'assets/fonts/Roboto-Regular.ttf',
      );
      final cacheData = FontCacheData(
        sdkVersion: '1.7.0',
        appVersion: '3.1.0',
        appBuildNumber: '100',
        fonts: {'Roboto_400_normal': typeface},
      );

      final json = cacheData.toJson();

      expect(json['sdkVersion'], '1.7.0');
      expect(json['appVersion'], '3.1.0');
      expect(json['appBuildNumber'], '100');
      expect(json['fonts'], isA<Map<String, dynamic>>());
      expect((json['fonts'] as Map).containsKey('Roboto_400_normal'), isTrue);
    });

    test('fromJson parses all fields', () {
      final json = {
        'sdkVersion': '1.7.0',
        'appVersion': '3.1.0',
        'appBuildNumber': '100',
        'fonts': {
          'Roboto_400_normal': {
            'familyName': 'Roboto',
            'dataHash': 'abc123',
            'weightValue': 400.0,
            'isItalic': false,
            'assetPath': 'assets/fonts/Roboto-Regular.ttf',
          },
        },
      };

      final cacheData = FontCacheData.fromJson(json);

      expect(cacheData.sdkVersion, '1.7.0');
      expect(cacheData.appVersion, '3.1.0');
      expect(cacheData.appBuildNumber, '100');
      expect(cacheData.fonts.length, 1);
      expect(cacheData.fonts['Roboto_400_normal']?.familyName, 'Roboto');
    });

    test('fromJson defaults missing appVersion and appBuildNumber to empty string', () {
      final json = {'sdkVersion': '1.6.0', 'fonts': <String, dynamic>{}};

      final cacheData = FontCacheData.fromJson(json);

      expect(cacheData.sdkVersion, '1.6.0');
      expect(cacheData.appVersion, '');
      expect(cacheData.appBuildNumber, '');
      expect(cacheData.fonts, isEmpty);
    });

    test('roundtrip toJson/fromJson preserves all data', () {
      final original = FontCacheData(
        sdkVersion: '1.7.0',
        appVersion: '5.0.0',
        appBuildNumber: '256',
        fonts: {
          'Lato_700_italic': Typeface(
            familyName: 'Lato',
            dataHash: 'hash789',
            weightValue: 700,
            isItalic: true,
            assetPath: 'assets/fonts/Lato-BoldItalic.ttf',
          ),
        },
      );

      final restored = FontCacheData.fromJson(original.toJson());

      expect(restored.sdkVersion, original.sdkVersion);
      expect(restored.appVersion, original.appVersion);
      expect(restored.appBuildNumber, original.appBuildNumber);
      expect(restored.fonts.length, original.fonts.length);
      expect(restored.fonts['Lato_700_italic']?.dataHash, original.fonts['Lato_700_italic']?.dataHash);
    });
  });
}
