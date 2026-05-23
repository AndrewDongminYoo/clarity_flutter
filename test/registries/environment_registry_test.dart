// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/registries/environment_registry.dart';

void main() {
  group('EnvRegistry.ensureInitialized', () {
    test('creates singleton instance', () {
      final registry1 = EnvRegistry.ensureInitialized();
      final registry2 = EnvRegistry.ensureInitialized();
      expect(identical(registry1, registry2), isTrue);
    });

    test('initializes with provided items', () {
      final registry = EnvRegistry.ensureInitialized(
        initialItems: {EnvRegistryKey.telemetryEnabled: true, EnvRegistryKey.packageName: 'test_package'},
      );

      expect(registry.getItem<bool>(EnvRegistryKey.telemetryEnabled), isTrue);
      expect(registry.getItem<String>(EnvRegistryKey.packageName), 'test_package');
    });

    test('merges initial items on subsequent calls', () {
      EnvRegistry.ensureInitialized(initialItems: {EnvRegistryKey.telemetryEnabled: true});

      final registry = EnvRegistry.ensureInitialized(initialItems: {EnvRegistryKey.packageName: 'test_package'});

      expect(registry.getItem<bool>(EnvRegistryKey.telemetryEnabled), isTrue);
      expect(registry.getItem<String>(EnvRegistryKey.packageName), 'test_package');
    });
  });

  group('EnvRegistry.registerItem and getItem', () {
    test('stores and retrieves values', () {
      final registry = EnvRegistry.ensureInitialized();
      registry.registerItem(EnvRegistryKey.cacheDir, '/cache/dir');

      expect(registry.getItem<String>(EnvRegistryKey.cacheDir), '/cache/dir');

      // Clean up for next test
      registry.removeItem(EnvRegistryKey.cacheDir);
    });

    test('returns null for non-existent keys', () {
      final registry = EnvRegistry.ensureInitialized();
      expect(registry.getItem<String>(EnvRegistryKey.uploadIsolatePort), isNull);
    });

    test('overwrites existing values', () {
      final registry = EnvRegistry.ensureInitialized();
      registry.registerItem(EnvRegistryKey.telemetryEnabled, true);
      registry.registerItem(EnvRegistryKey.telemetryEnabled, false);

      expect(registry.getItem<bool>(EnvRegistryKey.telemetryEnabled), isFalse);
    });
  });

  group('EnvRegistry.containsKey', () {
    test('returns true for existing keys', () {
      final registry = EnvRegistry.ensureInitialized();
      registry.registerItem(EnvRegistryKey.rootIsolateToken, 'test_token');

      expect(registry.containsKey(EnvRegistryKey.rootIsolateToken), isTrue);

      // Clean up
      registry.removeItem(EnvRegistryKey.rootIsolateToken);
    });

    test('returns false for non-existent keys', () {
      final registry = EnvRegistry.ensureInitialized();
      expect(registry.containsKey(EnvRegistryKey.clarityConfig), isFalse);
    });
  });

  group('EnvRegistry.removeItem', () {
    test('removes existing items', () {
      final registry = EnvRegistry.ensureInitialized();
      registry.registerItem(EnvRegistryKey.cacheDir, '/cache');
      registry.removeItem(EnvRegistryKey.cacheDir);

      expect(registry.containsKey(EnvRegistryKey.cacheDir), isFalse);
    });
  });

  group('EnvRegistry.reset', () {
    test('clears all items', () {
      final registry = EnvRegistry.ensureInitialized(
        initialItems: {EnvRegistryKey.telemetryEnabled: true, EnvRegistryKey.packageName: 'test'},
      );

      registry.reset();

      expect(registry.containsKey(EnvRegistryKey.telemetryEnabled), isFalse);
      expect(registry.containsKey(EnvRegistryKey.packageName), isFalse);
    });
  });

  group('EnvRegistry.toMap', () {
    test('returns copy of internal items', () {
      final registry = EnvRegistry.ensureInitialized(
        initialItems: {EnvRegistryKey.telemetryEnabled: true, EnvRegistryKey.packageName: 'test'},
      );

      final map = registry.toMap();

      expect(map[EnvRegistryKey.telemetryEnabled], isTrue);
      expect(map[EnvRegistryKey.packageName], 'test');

      // Verify it's a copy, not the original
      map[EnvRegistryKey.cacheDir] = '/new';
      expect(registry.containsKey(EnvRegistryKey.cacheDir), isFalse);
    });
  });
}
