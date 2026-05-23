/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/assets/font_asset.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class FontService {
  FontService._();

  static Future<Map<String, List<FontAsset>>> discoverFonts() => _discoverFonts();

  static Future<LoadedFontData?> loadFontAsset(String familyName, FontAsset asset) => _loadFontAsset(familyName, asset);

  static Future<Map<String, List<FontAsset>>> _discoverFonts() async {
    try {
      final manifestJson = await rootBundle.loadString('FontManifest.json');
      final manifest = (json.decode(manifestJson) as List<dynamic>).cast<Map<String, dynamic>>();
      final fontMap = <String, List<FontAsset>>{};

      for (final entry in manifest) {
        final family = entry['family'] as String;
        final fonts = (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>();

        fontMap[family] = fonts.map((f) {
          return FontAsset(
            assetPath: f['asset'] as String,
            weight: f['weight'] as int?,
            isItalic: f['style'] == 'italic',
          );
        }).toList();
      }

      return fontMap;
    } catch (e) {
      Logger.debug?.out('Failed to load FontManifest.json: $e');
      return {};
    }
  }

  static Future<LoadedFontData?> _loadFontAsset(String familyName, FontAsset asset) async {
    try {
      final byteData = await rootBundle.load(asset.assetPath);
      final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      return LoadedFontData(
        familyName: familyName,
        assetPath: asset.assetPath,
        bytes: bytes,
        weightValue: asset.weight?.toDouble(),
        isItalic: asset.isItalic,
      );
    } catch (_) {
      return null;
    }
  }
}
