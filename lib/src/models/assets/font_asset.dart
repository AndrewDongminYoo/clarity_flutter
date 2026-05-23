/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:typed_data';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

class FontAsset {
  FontAsset({required this.assetPath, this.weight, this.isItalic = false});
  final String assetPath;
  final int? weight;
  final bool isItalic;

  @override
  String toString() {
    return 'FontAsset(path: $assetPath, weight: $weight, isItalic: $isItalic)';
  }
}

class LoadedFontData {
  LoadedFontData({
    required this.familyName,
    required this.assetPath,
    required this.bytes,
    this.weightValue,
    this.isItalic = false,
  });
  final String familyName;
  final String assetPath;
  final Uint8List bytes;
  final double? weightValue;
  final bool isItalic;

  @override
  String toString() {
    return 'LoadedFontData(family: $familyName, path: $assetPath, size: ${bytes.length} bytes, weight: $weightValue, isItalic: $isItalic)';
  }
}

class Typeface implements IProtoModel<mutation_payload.Typeface> {
  Typeface({
    required this.familyName,
    required this.dataHash,
    this.fullName,
    this.postscriptName,
    this.weightValue,
    this.widthValue,
    this.slantValue,
    this.isItalic = false,
    this.assetPath,
  });

  factory Typeface.fromLoadedFont(LoadedFontData font, String hash) {
    return Typeface(
      familyName: font.familyName,
      dataHash: hash,
      fullName: font.familyName,
      weightValue: font.weightValue,
      isItalic: font.isItalic,
      assetPath: font.assetPath,
    );
  }

  factory Typeface.fromJson(Map<String, dynamic> json) {
    return Typeface(
      familyName: json['familyName'] as String,
      dataHash: json['dataHash'] as String,
      weightValue: (json['weightValue'] as num?)?.toDouble(),
      isItalic: json['isItalic'] as bool? ?? false,
      assetPath: json['assetPath'] as String?,
    );
  }
  final String familyName;
  final String? fullName;
  final String? postscriptName;
  final String dataHash;
  final double? weightValue;
  final double? widthValue;
  final double? slantValue;
  final bool isItalic;
  final String? assetPath;

  static String buildCacheKey(String family, {int weight = 400, bool italic = false}) {
    return '${family}_${weight}_${italic ? 'italic' : 'normal'}';
  }

  String get cacheKey => buildCacheKey(familyName, weight: weightValue?.toInt() ?? 400, italic: isItalic);

  Map<String, dynamic> toJson() {
    return {
      'familyName': familyName,
      'dataHash': dataHash,
      'weightValue': weightValue,
      'isItalic': isItalic,
      'assetPath': assetPath,
    };
  }

  @override
  mutation_payload.Typeface toProtobufInstance() {
    return mutation_payload.Typeface(
      familyName: familyName,
      dataHash: dataHash,
      fullName: fullName,
      postscriptName: postscriptName,
      weightValue: weightValue,
      widthValue: widthValue,
      slantValue: slantValue,
      italicValue: isItalic ? 1.0 : 0.0,
    );
  }

  @override
  String toString() {
    return 'Typeface(family: $familyName, hash: $dataHash, weight: $weightValue)';
  }
}

class FontCacheData {
  FontCacheData({
    required this.sdkVersion,
    required this.appVersion,
    required this.appBuildNumber,
    required this.fonts,
  });

  factory FontCacheData.fromJson(Map<String, dynamic> json) {
    final fontsJson = json['fonts'] as Map<String, dynamic>;
    final fonts = fontsJson.map((key, value) {
      return MapEntry(key, Typeface.fromJson(value as Map<String, dynamic>));
    });

    return FontCacheData(
      sdkVersion: json['sdkVersion'] as String,
      appVersion: json['appVersion'] as String? ?? '',
      appBuildNumber: json['appBuildNumber'] as String? ?? '',
      fonts: fonts,
    );
  }
  final String sdkVersion;
  final String appVersion;
  final String appBuildNumber;
  final Map<String, Typeface> fonts;

  Map<String, dynamic> toJson() => {
    'sdkVersion': sdkVersion,
    'appVersion': appVersion,
    'appBuildNumber': appBuildNumber,
    'fonts': fonts.map((key, value) => MapEntry(key, value.toJson())),
  };

  @override
  String toString() {
    return 'FontCacheData(sdkVersion: $sdkVersion, appVersion: $appVersion, appBuildNumber: $appBuildNumber, fonts: ${fonts.length})';
  }
}
