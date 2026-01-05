/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:typed_data';
import 'dart:ui' as ui;

// Package imports:
import 'package:image/image.dart' as img;

class AssetUtils {
  AssetUtils._();

  static Uint8List encodeAsPng(Uint8List rgbaBytes, int width, int height) {
    final image = img.Image.fromBytes(width: width, height: height, bytes: rgbaBytes.buffer, numChannels: 4);
    return img.encodePng(image);
  }

  static Future<Uint8List> getImageBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    return byteData?.buffer.asUint8List() ?? Uint8List(0);
  }

  static ImageSize getImageSizeFromBytes(List<int> imageBytes) {
    const pngHeaderSize = 8;
    const chunkDataLengthSize = 4;
    const chunkNameSize = 4;

    const offset = pngHeaderSize + chunkDataLengthSize + chunkNameSize;

    final imageWidth = _readBigEndianUInt32(imageBytes, offset);
    final imageHeight = _readBigEndianUInt32(imageBytes, offset + 4);
    return ImageSize(width: imageWidth, height: imageHeight);
  }

  static int _readBigEndianUInt32(List<int> bytes, int offset) {
    if (offset + 4 > bytes.length) {
      throw RangeError('Not enough bytes to read a 32-bit unsigned integer');
    }

    return (bytes[offset] << 24) | (bytes[offset + 1] << 16) | (bytes[offset + 2] << 8) | bytes[offset + 3];
  }
}

class ImageSize {
  ImageSize({required this.width, required this.height});

  final int width;
  final int height;
}
