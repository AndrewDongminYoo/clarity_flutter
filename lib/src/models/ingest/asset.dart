/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/utils/asset_utils.dart';

class Asset {
  Asset({required this.assetType, required this.fileName}) : md5Hash = fileName;

  final AssetType assetType;
  List<int>? _data;
  final String fileName;
  String md5Hash;

  int width = 0;
  int height = 0;

  ImageSize? imageSize;

  set data(List<int> value) {
    _data = value;
    imageSize = assetType == AssetType.image ? AssetUtils.getImageSizeFromBytes(_data!) : null;
  }

  List<int> get data => _data!;
}

enum AssetType {
  unsupported,
  image,
  typeface,
  web,
}
