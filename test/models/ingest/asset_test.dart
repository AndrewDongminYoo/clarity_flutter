// 🎯 Dart imports:
import 'dart:typed_data';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/ingest/asset.dart';
import 'package:clarity_flutter/src/utils/asset_utils.dart';

void main() {
  group('Asset', () {
    test('constructor initializes fields correctly', () {
      final asset = Asset(assetType: AssetType.image, fileName: 'test.png');

      expect(asset.assetType, AssetType.image);
      expect(asset.fileName, 'test.png');
      expect(asset.hash, 'test.png'); // defaults to fileName
      expect(asset.originalImageSize, isNull);
    });

    test('data setter does not set imageSize for non-image assets', () {
      for (final type in [AssetType.typeface, AssetType.web, AssetType.unsupported]) {
        final asset = Asset(assetType: type, fileName: 'file');
        asset.data = Uint8List.fromList([1, 2, 3, 4, 5]);
        expect(asset.originalImageSize, isNull, reason: '${type.name} should not set imageSize');
      }
    });

    test('hash can be updated', () {
      final asset = Asset(assetType: AssetType.image, fileName: 'original.png');
      asset.hash = 'abc123hash';
      expect(asset.hash, 'abc123hash');
    });
  });

  group('AssetType enum', () {
    test('has expected values with correct indices', () {
      expect(AssetType.unsupported.index, 0);
      expect(AssetType.image.index, 1);
      expect(AssetType.typeface.index, 2);
      expect(AssetType.web.index, 3);
      expect(AssetType.values.length, 4);
    });
  });

  group('ImageSize', () {
    test('stores width and height', () {
      final size = ImageSize(width: 1920, height: 1080);
      expect(size.width, 1920);
      expect(size.height, 1080);
    });
  });
}
