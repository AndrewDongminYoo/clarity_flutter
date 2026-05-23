// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/low_end_devices_config.dart';

void main() {
  group('LowEndDevicesConfig constructor', () {
    test('creates instance with disableRecordings true', () {
      const config = LowEndDevicesConfig(disableRecordings: true);
      expect(config.disableRecordings, isTrue);
    });

    test('creates instance with disableRecordings false', () {
      const config = LowEndDevicesConfig(disableRecordings: false);
      expect(config.disableRecordings, isFalse);
    });
  });

  group('LowEndDevicesConfig.fromJson', () {
    test('deserializes with disableRecordings true', () {
      final json = {'disableRecordings': true};

      final config = LowEndDevicesConfig.fromJson(json);

      expect(config.disableRecordings, isTrue);
    });

    test('deserializes with disableRecordings false', () {
      final json = {'disableRecordings': false};

      final config = LowEndDevicesConfig.fromJson(json);

      expect(config.disableRecordings, isFalse);
    });

    test('roundtrip: deserialized value matches input', () {
      final jsonTrue = {'disableRecordings': true};
      final jsonFalse = {'disableRecordings': false};

      final configTrue = LowEndDevicesConfig.fromJson(jsonTrue);
      final configFalse = LowEndDevicesConfig.fromJson(jsonFalse);

      expect(configTrue.disableRecordings, jsonTrue['disableRecordings']);
      expect(configFalse.disableRecordings, jsonFalse['disableRecordings']);
    });

    test('deserializes from json with extra fields (ignores them)', () {
      final json = {'disableRecordings': true, 'extraField': 'ignored', 'anotherField': 123};

      final config = LowEndDevicesConfig.fromJson(json);

      expect(config.disableRecordings, isTrue);
    });
  });
}
