/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/assets/font_asset.dart';
import 'package:clarity_flutter/src/models/consent_status.dart';
import 'package:clarity_flutter/src/models/file_store.dart';
import 'package:clarity_flutter/src/models/session/consent_metadata.dart';
import 'package:clarity_flutter/src/models/session/page_metadata.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class SettingsRepository {
  SettingsRepository()
    : settingsStore = FileStore(EnvRegistry.ensureInitialized().getItem<Directory>(EnvRegistryKey.cacheDir)!);
  FileStore settingsStore;

  static const String _userIdFieldName = 'userId';

  Future<String?> getCachedUserId() async {
    final metadata = await _readMetadata();
    return metadata[_userIdFieldName] as String?;
  }

  Future<void> writeUserId(String userId) async {
    await _updateMetadata({_userIdFieldName: userId});
  }

  Future<PageMetadata?> getCachedPageMetadata() async {
    final content = await _readFileContent(ClarityConstants.pageMetadataFileName);

    if (content == null) return null;

    try {
      return PageMetadata.fromJson(jsonDecode(content) as Map<String, dynamic>);
    } catch (e) {
      Logger.warn?.out('Error parsing cached page metadata: $e, will start a new Session!');
      return null;
    }
  }

  Future<void> writePageMetadata(PageMetadata pageMetadata) async {
    await _writeFileContent(ClarityConstants.pageMetadataFileName, jsonEncode(pageMetadata.toJson()));
  }

  Future<String?> _readFileContent(String fileName) async {
    if (!(await settingsStore.fileExists(fileName))) return null;

    return settingsStore.readFileToString(fileName);
  }

  Future<void> _writeFileContent(String fileName, String content) async {
    await settingsStore.writeToFile(fileName, content, WriteMode.overwrite);
  }

  String get _appVersion => EnvRegistry.ensureInitialized().getItem<String>(EnvRegistryKey.appVersion) ?? '';

  String get _appBuildNumber => EnvRegistry.ensureInitialized().getItem<String>(EnvRegistryKey.appBuildNumber) ?? '';

  Future<FontCacheData?> readFontCache() async {
    try {
      final content = await _readFileContent(ClarityConstants.fontCacheFileName);
      if (content == null) return null;

      final json = jsonDecode(content) as Map<String, dynamic>;
      final cacheData = FontCacheData.fromJson(json);

      if (cacheData.sdkVersion != ClarityConstants.clarityVersion ||
          cacheData.appVersion != _appVersion ||
          cacheData.appBuildNumber != _appBuildNumber) {
        await _deleteFontCache();
        return null;
      }

      return cacheData;
    } catch (e) {
      await _deleteFontCache();
      return null;
    }
  }

  Future<void> updateFontCache(List<Typeface> newFonts) async {
    if (newFonts.isEmpty) return;

    try {
      var cacheData = await readFontCache();
      cacheData ??= FontCacheData(
        sdkVersion: ClarityConstants.clarityVersion,
        appVersion: _appVersion,
        appBuildNumber: _appBuildNumber,
        fonts: {},
      );

      for (final font in newFonts) {
        cacheData.fonts[font.cacheKey] = font;
      }

      await _writeFileContent(ClarityConstants.fontCacheFileName, jsonEncode(cacheData.toJson()));
    } catch (e) {
      Logger.debug?.out('Failed to update font cache: $e');
    }
  }

  Future<void> _deleteFontCache() async {
    try {
      if (await settingsStore.fileExists(ClarityConstants.fontCacheFileName)) {
        await settingsStore.deleteFile(ClarityConstants.fontCacheFileName);
      }
    } catch (e) {
      Logger.debug?.out('Failed to delete font cache: $e');
    }
  }

  Future<ConsentStatus> getConsentStatus({
    required bool projectAdsStorage,
    required bool projectAnalyticsStorage,
  }) async {
    final stored = _consentMetadataFromMap(await _readMetadata());

    if (stored == null) {
      return ConsentStatus(
        source: ConsentSource.implicit,
        adsStorage: projectAdsStorage,
        analyticsStorage: projectAnalyticsStorage,
      );
    }

    final source = stored.sourceOrdinal >= 0 && stored.sourceOrdinal < ConsentSource.values.length
        ? ConsentSource.values[stored.sourceOrdinal]
        : ConsentSource.implicit;

    return ConsentStatus(
      source: source,
      adsStorage: stored.adsStorage ?? projectAdsStorage,
      analyticsStorage: stored.analyticsStorage ?? projectAnalyticsStorage,
    );
  }

  Future<void> updateConsentStatus(ConsentStatus consentStatus) async {
    final current = _consentMetadataFromMap(await _readMetadata());
    await _updateMetadata(
      ConsentMetadata(
        sourceOrdinal: consentStatus.source.index,
        adsStorage: consentStatus.adsStorage,
        analyticsStorage: consentStatus.analyticsStorage,
        cachedGaid: current?.cachedGaid,
      ).toJson(),
    );
  }

  Future<String?> getCachedGaid() async {
    final metadata = await _readMetadata();
    return _consentMetadataFromMap(metadata)?.cachedGaid;
  }

  Future<void> updateCachedGaid(String? gaid) async {
    final current = _consentMetadataFromMap(await _readMetadata());
    if (current == null) return;
    await _updateMetadata(
      ConsentMetadata(
        sourceOrdinal: current.sourceOrdinal,
        adsStorage: current.adsStorage,
        analyticsStorage: current.analyticsStorage,
        cachedGaid: gaid,
      ).toJson(),
    );
  }

  Future<Map<String, dynamic>> _readMetadata() async {
    final content = await _readFileContent(ClarityConstants.metadataFileName);
    if (content == null) return {};

    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      Logger.warn?.out('Error parsing metadata file: $e');
      return {};
    }
  }

  Future<void> _updateMetadata(Map<String, dynamic> updates) async {
    final current = await _readMetadata();
    current.addAll(updates);
    await _writeFileContent(ClarityConstants.metadataFileName, jsonEncode(current));
  }

  ConsentMetadata? _consentMetadataFromMap(Map<String, dynamic> metadata) {
    if (!metadata.containsKey('sourceOrdinal')) return null;
    return ConsentMetadata.fromJson(metadata);
  }
}
