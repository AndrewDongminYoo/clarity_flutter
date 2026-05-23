// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/masking.dart';
import 'package:clarity_flutter/src/models/project_config.dart';

void main() {
  group('ProjectConfig.fromJson', () {
    Map<String, dynamic> createValidJsonMap({
      String ingestUrl = 'https://ingest.example.com',
      String? reportUrl = 'https://report.example.com',
      bool activate = true,
      bool lean = false,
      int maskingMode = 1,
      Map<String, dynamic>? network,
      Map<String, dynamic>? lowEndDevices,
      Map<String, dynamic>? screenCapture,
    }) {
      return {
        'ingestUrl': ingestUrl,
        'reportUrl': reportUrl,
        'activate': activate,
        'lean': lean,
        'maskingMode': maskingMode,
        'network': network ?? {'allowMeteredNetwork': true, 'maxDataVolume': 100},
        'lowEndDevices': lowEndDevices ?? {'disableRecordings': false},
        'screenCapture':
            screenCapture ??
            {
              'allowedScreens': [
                {'screenName': 'HomeScreen'},
              ],
              'disallowedScreens': [
                {'screenName': 'SettingsScreen'},
              ],
            },
      };
    }

    test('parses all fields and nested configs correctly', () {
      final jsonMap = createValidJsonMap(
        network: {'allowMeteredNetwork': false, 'maxDataVolume': 500},
        lowEndDevices: {'disableRecordings': true},
        screenCapture: {
          'allowedScreens': [
            {'screenName': 'Screen1'},
            {'screenName': 'Screen2'},
          ],
          'disallowedScreens': [
            {'screenName': 'Screen3'},
          ],
        },
      );

      final config = ProjectConfig.fromJson(jsonEncode(jsonMap));

      expect(config.ingestUrl, 'https://ingest.example.com');
      expect(config.reportUrl, 'https://report.example.com');
      expect(config.activate, isTrue);
      expect(config.lean, isFalse);
      expect(config.maskingMode, MaskingMode.strict);
      expect(config.network.allowMeteredNetwork, isFalse);
      expect(config.network.maxDataVolume, 500);
      expect(config.lowEndDevices.disableRecordings, isTrue);
      expect(config.screenCapture.allowedScreens, ['Screen1', 'Screen2']);
      expect(config.screenCapture.disallowedScreens, ['Screen3']);
    });

    test('parses all MaskingMode values correctly', () {
      for (final testCase in [
        (index: 0, expected: MaskingMode.balanced),
        (index: 1, expected: MaskingMode.strict),
        (index: 2, expected: MaskingMode.relaxed),
      ]) {
        final json = jsonEncode(createValidJsonMap(maskingMode: testCase.index));
        expect(ProjectConfig.fromJson(json).maskingMode, testCase.expected);
      }
    });

    test('handles null and empty reportUrl', () {
      final emptyJson = jsonEncode(createValidJsonMap(reportUrl: ''));
      expect(ProjectConfig.fromJson(emptyJson).reportUrl, isNull);

      final nullJson = jsonEncode(createValidJsonMap()..['reportUrl'] = null);
      expect(ProjectConfig.fromJson(nullJson).reportUrl, isNull);
    });

    test('adsStorage defaults to false when absent', () {
      final config = ProjectConfig.fromJson(jsonEncode(createValidJsonMap()));
      expect(config.adsStorage, isFalse);
    });

    test('analyticsStorage defaults to true when absent', () {
      final config = ProjectConfig.fromJson(jsonEncode(createValidJsonMap()));
      expect(config.analyticsStorage, isTrue);
    });

    test('parses explicit adsStorage and analyticsStorage values', () {
      final json = jsonEncode({...createValidJsonMap(), 'adsStorage': true, 'analyticsStorage': false});
      final config = ProjectConfig.fromJson(json);

      expect(config.adsStorage, isTrue);
      expect(config.analyticsStorage, isFalse);
    });
  });
}
