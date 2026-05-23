// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/consent_status.dart';
import 'package:clarity_flutter/src/models/file_store.dart';
import 'package:clarity_flutter/src/models/session/consent_metadata.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/repositories/settings_repository.dart';

void main() {
  // -------------------------------------------------------------------------
  // ConsentMetadata model — pure JSON round-trip (no I/O needed).
  // -------------------------------------------------------------------------
  group('ConsentMetadata.fromJson / toJson', () {
    test('round-trips all fields', () {
      const original = ConsentMetadata(
        sourceOrdinal: 1,
        adsStorage: true,
        analyticsStorage: false,
        cachedGaid: 'abc-123',
      );

      final json = original.toJson();
      final restored = ConsentMetadata.fromJson(json);

      expect(restored.sourceOrdinal, 1);
      expect(restored.adsStorage, isTrue);
      expect(restored.analyticsStorage, isFalse);
      expect(restored.cachedGaid, 'abc-123');
    });

    test('toJson includes null optional fields', () {
      const prefs = ConsentMetadata(sourceOrdinal: 0);
      final json = prefs.toJson();

      expect(json.containsKey('adsStorage'), isTrue);
      expect(json['adsStorage'], isNull);
      expect(json.containsKey('analyticsStorage'), isTrue);
      expect(json['analyticsStorage'], isNull);
      expect(json.containsKey('cachedGaid'), isTrue);
      expect(json['cachedGaid'], isNull);
    });

    test('fromJson falls back to 0 for missing sourceOrdinal', () {
      final prefs = ConsentMetadata.fromJson({});
      expect(prefs.sourceOrdinal, 0);
    });
  });

  // -------------------------------------------------------------------------
  // SettingsRepository consent — tested with a temp directory.
  // -------------------------------------------------------------------------
  group('SettingsRepository consent', () {
    late Directory tempDir;
    late SettingsRepository repo;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('clarity_test_');
      // Inject the temp Directory so SettingsRepository can construct its FileStore.
      EnvRegistry.ensureInitialized(initialItems: {EnvRegistryKey.cacheDir: tempDir});
      repo = SettingsRepository();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('getConsentStatus returns project defaults when no file exists', () async {
      final status = await repo.getConsentStatus(projectAdsStorage: true, projectAnalyticsStorage: true);

      expect(status.source, ConsentSource.implicit);
      expect(status.adsStorage, isTrue);
      expect(status.analyticsStorage, isTrue);
    });

    test('updateConsentStatus persists and can be read back', () async {
      const written = ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: false);

      await repo.updateConsentStatus(written);

      final status = await repo.getConsentStatus(projectAdsStorage: false, projectAnalyticsStorage: true);

      expect(status.source, ConsentSource.api);
      expect(status.adsStorage, isTrue);
      expect(status.analyticsStorage, isFalse);
    });

    test('getConsentStatus falls back to project values for missing fields', () async {
      // Write a record with only sourceOrdinal, no explicit consent values.
      await repo.settingsStore.writeToFile(
        ClarityConstants.metadataFileName,
        jsonEncode(const ConsentMetadata(sourceOrdinal: 1).toJson()),
        WriteMode.overwrite,
      );

      final status = await repo.getConsentStatus(projectAdsStorage: true, projectAnalyticsStorage: false);

      expect(status.source, ConsentSource.api);
      expect(status.adsStorage, isTrue);
      expect(status.analyticsStorage, isFalse);
    });

    test('updateCachedGaid stores gaid without touching consent fields', () async {
      await repo.updateConsentStatus(
        const ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: true),
      );

      await repo.updateCachedGaid('gaid-value');

      expect(await repo.getCachedGaid(), 'gaid-value');

      // Consent fields must be preserved.
      final status = await repo.getConsentStatus(projectAdsStorage: false, projectAnalyticsStorage: false);
      expect(status.source, ConsentSource.api);
      expect(status.adsStorage, isTrue);
    });

    test('updateCachedGaid does nothing when no metadata exists', () async {
      // No file created yet — should not throw, just be a no-op.
      await repo.updateCachedGaid('no-op');
      expect(await repo.getCachedGaid(), isNull);
    });

    test('updateCachedGaid with null clears the cached gaid', () async {
      await repo.updateConsentStatus(
        const ConsentStatus(source: ConsentSource.api, adsStorage: false, analyticsStorage: true),
      );
      await repo.updateCachedGaid('existing-gaid');
      await repo.updateCachedGaid(null);

      expect(await repo.getCachedGaid(), isNull);
    });

    test('consent data and userId coexist in the same metadata file', () async {
      await repo.writeUserId('user-42');
      await repo.updateConsentStatus(
        const ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: false),
      );

      // Both values must survive in the same file.
      expect(await repo.getCachedUserId(), 'user-42');

      final status = await repo.getConsentStatus(projectAdsStorage: false, projectAnalyticsStorage: true);
      expect(status.source, ConsentSource.api);
      expect(status.adsStorage, isTrue);
      expect(status.analyticsStorage, isFalse);
    });
  });
}
