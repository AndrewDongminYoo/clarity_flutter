// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/low_end_devices_config.dart';
import 'package:clarity_flutter/src/models/network_config.dart';
import 'package:clarity_flutter/src/models/project_config.dart';
import 'package:clarity_flutter/src/models/screen_capture_config.dart';
import 'package:clarity_flutter/src/native/generated/messages.g.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/utils/project_config_utils.dart';

void main() {
  group('ProjectConfigUtils.isUploadingOverNetworkAllowed', () {
    setUp(() {
      // Reset registry before each test to ensure clean state
      EnvRegistry.ensureInitialized().reset();

      // Setup minimal project config for network tests
      EnvRegistry.ensureInitialized(
        initialItems: {
          EnvRegistryKey.projectConfig: ProjectConfig(
            ingestUrl: 'https://test.clarity.ms',
            activate: true,
            network: const NetworkConfig(allowMeteredNetwork: false),
            screenCapture: const ScreenCaptureConfig(allowedScreens: [], disallowedScreens: []),
            lowEndDevices: const LowEndDevicesConfig(disableRecordings: false),
          ),
        },
      );
    });

    tearDown(() {
      // Clean up registry after each test to prevent test pollution
      EnvRegistry.ensureInitialized().reset();
    });

    test('allows upload on WiFi network', () {
      final result = ProjectConfigUtils.isUploadingOverNetworkAllowed([ConnectivityType.wifi]);
      expect(result, isTrue);
    });

    test('allows upload on WiFi with other connections', () {
      final result = ProjectConfigUtils.isUploadingOverNetworkAllowed([
        ConnectivityType.wifi,
        ConnectivityType.ethernet,
      ]);
      expect(result, isTrue);
    });

    test('blocks mobile network when allowMeteredNetwork is false', () {
      final result = ProjectConfigUtils.isUploadingOverNetworkAllowed([ConnectivityType.mobile]);
      expect(result, isFalse);
    });

    test('allows mobile network when allowMeteredNetwork is true', () {
      EnvRegistry.ensureInitialized().registerItem(
        EnvRegistryKey.projectConfig,
        ProjectConfig(
          ingestUrl: 'https://test.clarity.ms',
          activate: true,
          network: const NetworkConfig(allowMeteredNetwork: true),
          screenCapture: const ScreenCaptureConfig(allowedScreens: [], disallowedScreens: []),
          lowEndDevices: const LowEndDevicesConfig(disableRecordings: false),
        ),
      );

      final result = ProjectConfigUtils.isUploadingOverNetworkAllowed([ConnectivityType.mobile]);
      expect(result, isTrue);
    });

    test('allows upload on ethernet with other connections', () {
      final result = ProjectConfigUtils.isUploadingOverNetworkAllowed([ConnectivityType.ethernet]);
      expect(result, isTrue);
    });

    test('blocks when no connectivity available', () {
      final result = ProjectConfigUtils.isUploadingOverNetworkAllowed([ConnectivityType.none]);
      expect(result, isFalse);
    });
  });
}
