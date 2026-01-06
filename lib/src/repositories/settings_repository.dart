/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/file_store.dart';
import 'package:clarity_flutter/src/models/session/page_metadata.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class SettingsRepository {
  SettingsRepository()
    : settingsStore = FileStore(EnvRegistry.ensureInitialized().getItem<Directory>(EnvRegistryKey.cacheDir)!);

  FileStore settingsStore;

  static const String _userIdFieldName = 'userId';

  Future<String?> getCachedUserId() async {
    final metadataContent = await _readFileContent(ClarityConstants.metadataFileName);
    final cachedUserId = _parseUserIdFromMetadata(metadataContent);

    if (cachedUserId != null) return cachedUserId;

    final pageMetadataContent = await _readFileContent(ClarityConstants.pageMetadataFileName);
    final userIdFromPageMetadata = _parseUserIdFromPageMetadata(pageMetadataContent);

    if (userIdFromPageMetadata == null) return null;

    await _writeFileContent(
      ClarityConstants.metadataFileName,
      jsonEncode(<String, String>{_userIdFieldName: userIdFromPageMetadata}),
    );

    return userIdFromPageMetadata;
  }

  Future<void> writeUserId(String userId) async {
    final json = <String, String>{
      _userIdFieldName: userId,
    };

    await _writeFileContent(ClarityConstants.metadataFileName, jsonEncode(json));
    await _updateUserIdInPageMetadata(userId);
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

  String? _parseUserIdFromMetadata(String? content) {
    if (content == null) return null;

    try {
      final storedMap = jsonDecode(content) as Map<String, dynamic>;
      final userId = storedMap[_userIdFieldName];
      return userId is String ? userId : null;
    } catch (e) {
      Logger.warn?.out('Error parsing cached userId: $e, will use a new one!');
      return null;
    }
  }

  String? _parseUserIdFromPageMetadata(String? content) {
    if (content == null) return null;

    try {
      final storedMap = jsonDecode(content) as Map<String, dynamic>;
      final sessionMap = storedMap['session'];
      if (sessionMap is! Map<String, dynamic>) return null;

      final userId = sessionMap[_userIdFieldName];
      return userId is String ? userId : null;
    } catch (e) {
      Logger.warn?.out('Error parsing cached page metadata userId: $e, will use a new one!');
      return null;
    }
  }

  Future<void> _updateUserIdInPageMetadata(String userId) async {
    if (!settingsStore.fileExists(ClarityConstants.pageMetadataFileName)) return;

    final content = await _readFileContent(ClarityConstants.pageMetadataFileName);
    if (content == null) return;

    try {
      final storedMap = jsonDecode(content) as Map<String, dynamic>;
      final sessionMap = storedMap['session'];
      if (sessionMap is! Map<String, dynamic>) return;

      if (sessionMap[_userIdFieldName] == userId) return;

      sessionMap[_userIdFieldName] = userId;
      await _writeFileContent(ClarityConstants.pageMetadataFileName, jsonEncode(storedMap));
    } catch (e) {
      Logger.warn?.out('Error updating cached page metadata userId: $e');
    }
  }
}
