/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:typed_data';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/asset_utils.dart';

class Asset {
  Asset({required this.assetType, required this.fileName}) : hash = fileName;
  final AssetType assetType;
  final String fileName;
  late String hash;

  Uint8List? data;
  ImageSize? originalImageSize;
  ImageSize? bufferSize;

  ImageSize get dataSize => bufferSize ?? originalImageSize!;
}

enum AssetType { unsupported, image, typeface, web }
