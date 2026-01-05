/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:convert';
import 'dart:io';

// Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/file_store.dart';
import 'package:clarity_flutter/src/models/session/page_metadata.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class SettingsRepository {
  SettingsRepository()
    : settingsStore = FileStore(EnvRegistry.ensureInitialized().getItem<Directory>(EnvRegistryKey.cacheDir)!);

  FileStore settingsStore;

  // TODO: unify userId storage across Metadata files
  static const String _userIdFieldName = 'userId';

  Future<String?> getCachedUserId() async {
    final content = await _readFileContent(ClarityConstants.metadataFileName);

    if (content == null) return null;

    try {
      final storedMap = jsonDecode(content) as Map<String, dynamic>;
      return storedMap[_userIdFieldName] as String;
    } catch (e) {
      Logger.warn?.out('Error parsing cached userId: $e, will use a new one!');
      return null;
    }
  }

  Future<void> writeUserId(String userId) async {
    final json = <String, String>{
      _userIdFieldName: userId,
    };

    await _writeFileContent(ClarityConstants.metadataFileName, jsonEncode(json));
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
    if (!settingsStore.fileExists(fileName)) return null;

    return settingsStore.readFileToString(fileName);
  }

  Future<void> _writeFileContent(String fileName, String content) async {
    await settingsStore.writeToFile(fileName, content, WriteMode.overwrite);
  }
}
