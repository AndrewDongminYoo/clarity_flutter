// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/network_config.dart';

void main() {
  group('NetworkConfig constructor', () {
    test('creates instance with required and optional fields', () {
      const config = NetworkConfig(allowMeteredNetwork: true, maxDataVolume: 2048);

      expect(config.allowMeteredNetwork, isTrue);
      expect(config.maxDataVolume, 2048);
    });

    test('creates instance with only required field', () {
      const config = NetworkConfig(allowMeteredNetwork: false);

      expect(config.allowMeteredNetwork, isFalse);
      expect(config.maxDataVolume, isNull);
    });
  });

  group('NetworkConfig.fromJson', () {
    test('deserializes with all fields present', () {
      final json = {'allowMeteredNetwork': true, 'maxDataVolume': 1024};

      final config = NetworkConfig.fromJson(json);

      expect(config.allowMeteredNetwork, isTrue);
      expect(config.maxDataVolume, 1024);
    });

    test('deserializes with allowMeteredNetwork false', () {
      final json = {'allowMeteredNetwork': false, 'maxDataVolume': 2048};

      final config = NetworkConfig.fromJson(json);

      expect(config.allowMeteredNetwork, isFalse);
      expect(config.maxDataVolume, 2048);
    });

    test('deserializes with missing optional maxDataVolume', () {
      final json = {'allowMeteredNetwork': true};

      final config = NetworkConfig.fromJson(json);

      expect(config.allowMeteredNetwork, isTrue);
      expect(config.maxDataVolume, isNull);
    });

    test('deserializes with null maxDataVolume', () {
      final json = {'allowMeteredNetwork': false, 'maxDataVolume': null};

      final config = NetworkConfig.fromJson(json);

      expect(config.allowMeteredNetwork, isFalse);
      expect(config.maxDataVolume, isNull);
    });

    test('roundtrip: deserialized values match input', () {
      final json = {'allowMeteredNetwork': true, 'maxDataVolume': 5000};

      final config = NetworkConfig.fromJson(json);

      expect(config.allowMeteredNetwork, json['allowMeteredNetwork']);
      expect(config.maxDataVolume, json['maxDataVolume']);
    });

    test('deserializes with zero maxDataVolume', () {
      final json = {'allowMeteredNetwork': true, 'maxDataVolume': 0};

      final config = NetworkConfig.fromJson(json);

      expect(config.maxDataVolume, 0);
    });

    test('deserializes with negative maxDataVolume', () {
      final json = {'allowMeteredNetwork': true, 'maxDataVolume': -100};

      final config = NetworkConfig.fromJson(json);

      expect(config.maxDataVolume, -100);
    });

    test('deserializes with large maxDataVolume', () {
      final json = {
        'allowMeteredNetwork': false,
        'maxDataVolume': 2147483647, // Max 32-bit int
      };

      final config = NetworkConfig.fromJson(json);

      expect(config.maxDataVolume, 2147483647);
    });
  });
}
