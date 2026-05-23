// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/screen_capture_config.dart';

void main() {
  group('ScreenCaptureConfig constructor', () {
    test('creates instance with provided screen lists', () {
      const config = ScreenCaptureConfig(
        allowedScreens: ['HomeScreen', 'ProfileScreen'],
        disallowedScreens: ['AdminScreen'],
      );

      expect(config.allowedScreens, ['HomeScreen', 'ProfileScreen']);
      expect(config.disallowedScreens, ['AdminScreen']);
    });

    test('creates instance with empty lists', () {
      const config = ScreenCaptureConfig(allowedScreens: [], disallowedScreens: []);

      expect(config.allowedScreens, isEmpty);
      expect(config.disallowedScreens, isEmpty);
    });
  });

  group('ScreenCaptureConfig.fromJson', () {
    test('deserializes with valid screen arrays', () {
      final json = {
        'allowedScreens': [
          {'screenName': 'HomeScreen'},
          {'screenName': 'ProfileScreen'},
        ],
        'disallowedScreens': [
          {'screenName': 'SettingsScreen'},
        ],
      };

      final config = ScreenCaptureConfig.fromJson(json);

      expect(config.allowedScreens, ['HomeScreen', 'ProfileScreen']);
      expect(config.disallowedScreens, ['SettingsScreen']);
    });

    test('deserializes with empty arrays', () {
      final json = {'allowedScreens': <String>[], 'disallowedScreens': <String>[]};

      final config = ScreenCaptureConfig.fromJson(json);

      expect(config.allowedScreens, isEmpty);
      expect(config.disallowedScreens, isEmpty);
    });

    test('handles missing arrays with defaults', () {
      final json = <String, dynamic>{};

      final config = ScreenCaptureConfig.fromJson(json);

      expect(config.allowedScreens, isEmpty);
      expect(config.disallowedScreens, isEmpty);
    });

    test('deserializes mixed scenario', () {
      final json = {
        'allowedScreens': [
          {'screenName': 'Screen1'},
          {'screenName': 'Screen2'},
          {'screenName': 'Screen3'},
        ],
        'disallowedScreens': null,
      };

      final config = ScreenCaptureConfig.fromJson(json);

      expect(config.allowedScreens, ['Screen1', 'Screen2', 'Screen3']);
      expect(config.disallowedScreens, isEmpty);
    });

    test('roundtrip: deserialized screen names match input', () {
      final json = {
        'allowedScreens': [
          {'screenName': 'Dashboard'},
          {'screenName': 'Settings'},
        ],
        'disallowedScreens': [
          {'screenName': 'Debug'},
        ],
      };

      final config = ScreenCaptureConfig.fromJson(json);

      expect(config.allowedScreens.length, 2);
      expect(config.allowedScreens[0], 'Dashboard');
      expect(config.allowedScreens[1], 'Settings');
      expect(config.disallowedScreens.length, 1);
      expect(config.disallowedScreens[0], 'Debug');
    });

    test('preserves order of screens', () {
      final json = {
        'allowedScreens': [
          {'screenName': 'A'},
          {'screenName': 'B'},
          {'screenName': 'C'},
        ],
        'disallowedScreens': <String>[],
      };

      final config = ScreenCaptureConfig.fromJson(json);

      expect(config.allowedScreens, orderedEquals(['A', 'B', 'C']));
    });
  });
}
