/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/assets/font_asset.dart';
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/draw_render_editable.dart';
import 'package:clarity_flutter/src/models/display/draw_render_paragraph.dart';
import 'package:clarity_flutter/src/models/events/control_event.dart';
import 'package:clarity_flutter/src/models/ingest/asset.dart';
import 'package:clarity_flutter/src/models/text/inline_span.dart';
import 'package:clarity_flutter/src/repositories/session_repository.dart';
import 'package:clarity_flutter/src/repositories/settings_repository.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

class FontManager {
  FontManager(this._sessionRepository, this._settingsRepository);
  final SessionRepository _sessionRepository;
  final SettingsRepository _settingsRepository;

  final List<Typeface> _typefaces = [];
  final Set<String> _registeredHashes = {};
  final Set<String> _registeredFamilies = {};
  final List<LoadedFontData> _pendingNewFonts = [];
  final List<FontLoadRequest> _pendingLoadRequests = [];
  final Map<String, _UnloadedFontInfo> _unloadedFonts = {};
  final Set<String> _loadingInProgress = {};
  bool _sessionReady = false;

  List<Typeface> get typefaces => _typefaces;

  bool get hasTypefaces => _typefaces.isNotEmpty;

  bool get hasUnloadedFonts => _unloadedFonts.isNotEmpty;

  Future<void> initializeFromMetadata(Map<String, List<FontAsset>> fontMap) async {
    final cachedData = await _settingsRepository.readFontCache();
    final cachedKeys = cachedData?.fonts.keys.toSet() ?? <String>{};
    final cachedFonts = <Typeface>[];

    for (final entry in fontMap.entries) {
      final familyName = entry.key;
      for (final asset in entry.value) {
        final weight = asset.weight ?? 400;
        final italic = asset.isItalic;
        final cacheKey = Typeface.buildCacheKey(familyName, weight: weight, italic: italic);

        if (cachedKeys.contains(cacheKey)) {
          final cachedFont = cachedData!.fonts[cacheKey]!;
          final pathUnchanged = cachedFont.assetPath == asset.assetPath;
          if (pathUnchanged) {
            cachedFonts.add(cachedFont);
            continue;
          }
        }

        _unloadedFonts[cacheKey] = _UnloadedFontInfo(familyName: familyName, asset: asset);
      }
    }

    if (cachedFonts.isNotEmpty) {
      _registerTypefaces(cachedFonts);
    }
  }

  Future<List<Asset>> onSessionReady() async {
    _sessionReady = true;
    if (_pendingNewFonts.isEmpty) return [];
    final result = await _registerFonts(_pendingNewFonts);
    _pendingNewFonts.clear();
    return result;
  }

  Future<List<Asset>> registerLoadedFonts(List<LoadedFontData> fonts) async {
    if (!_sessionReady) {
      _pendingNewFonts.addAll(fonts);
      return [];
    }
    return _registerFonts(fonts);
  }

  List<FontLoadRequest> consumePendingLoadRequests() {
    if (_pendingLoadRequests.isEmpty) return const [];
    final requests = List<FontLoadRequest>.of(_pendingLoadRequests);
    _pendingLoadRequests.clear();
    return requests;
  }

  Future<List<Asset>> _registerFonts(List<LoadedFontData> loadedFonts) async {
    final savedAssets = <Asset>[];
    final newTypefaces = <Typeface>[];

    for (final font in loadedFonts) {
      final hash = DataUtils.xxHashBase64(font.bytes);

      await _sessionRepository.saveSessionAsset(hash, font.bytes);
      newTypefaces.add(Typeface.fromLoadedFont(font, hash));
      savedAssets.add(Asset(assetType: AssetType.typeface, fileName: hash));
    }

    _registerTypefaces(newTypefaces);

    if (newTypefaces.isNotEmpty) {
      await _settingsRepository.updateFontCache(newTypefaces);
    }

    return savedAssets;
  }

  void triggerLazyFontLoading(List<DisplayCommand> commands) {
    if (_unloadedFonts.isEmpty) return;

    for (final command in commands) {
      InlineSpan? root;
      if (command is DrawRenderParagraph) {
        root = command.renderParagraph.text;
      } else if (command is DrawRenderEditable) {
        root = command.renderEditable.text;
      }
      if (root != null) {
        _resolveSpanTree(root);
      }
    }
  }

  void _resolveSpanTree(InlineSpan span) {
    String? fontFamily;
    List<InlineSpan>? children;

    if (span is TextSpan) {
      fontFamily = span.style?.fontFamily;
      children = span.children;
    } else if (span is WidgetSpan) {
      fontFamily = span.style?.fontFamily;
    }

    if (fontFamily != null && !_registeredFamilies.contains(fontFamily)) {
      _requestLazyLoadIfNeeded(fontFamily);
    }

    if (children != null) {
      children.forEach(_resolveSpanTree);
    }
  }

  void _requestLazyLoadIfNeeded(String familyName) {
    final keysToLoad = _unloadedFonts.entries
        .where((e) => e.value.familyName == familyName && !_loadingInProgress.contains(e.key))
        .map((e) => e.key)
        .toList();

    for (final key in keysToLoad) {
      final info = _unloadedFonts[key]!;
      _loadingInProgress.add(key);
      _pendingLoadRequests.add(FontLoadRequest(familyName: info.familyName, asset: info.asset));
    }
  }

  void _registerTypefaces(List<Typeface> typefaces) {
    for (final typeface in typefaces) {
      if (_registeredHashes.contains(typeface.dataHash)) {
        continue;
      }

      _typefaces.add(typeface);
      _registeredHashes.add(typeface.dataHash);
      _registeredFamilies.add(typeface.familyName);

      final weight = typeface.weightValue?.toInt() ?? 400;
      final isItalic = typeface.isItalic;
      final key = Typeface.buildCacheKey(typeface.familyName, weight: weight, italic: isItalic);
      _unloadedFonts.remove(key);
      _loadingInProgress.remove(key);
    }
  }
}

class _UnloadedFontInfo {
  const _UnloadedFontInfo({required this.familyName, required this.asset});
  final String familyName;
  final FontAsset asset;
}
