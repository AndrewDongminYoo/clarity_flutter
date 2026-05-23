/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

// 📦 Package imports:
import 'package:image/image.dart' as img;

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';

class AssetUtils {
  AssetUtils._();

  static double computeScaleFactor(int width, int height, double dpr) {
    var factor = ClarityConstants.imageDownsamplingFactor / dpr.clamp(1.0, double.infinity);

    if ((width * factor).ceil() < ClarityConstants.imageMinimumDimension ||
        (height * factor).ceil() < ClarityConstants.imageMinimumDimension) {
      factor = min(
        ClarityConstants.imageMinimumDimension / width,
        ClarityConstants.imageMinimumDimension / height,
      ).clamp(0.0, 1.0);
    }

    return factor >= 1.0 ? 1.0 : factor;
  }

  static Uint8List encodePng(Uint8List rgbaBytes, ImageSize size) {
    return img.encodePng(
      img.Image.fromBytes(width: size.width, height: size.height, bytes: rgbaBytes.buffer, numChannels: 4),
    );
  }

  static Future<Uint8List> getImageBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    return byteData?.buffer.asUint8List() ?? Uint8List(0);
  }

  static Future<({Uint8List bytes, ImageSize size})> getScaledImageBytes(ui.Image image, double dpr) async {
    final factor = computeScaleFactor(image.width, image.height, dpr);

    if (factor >= 1.0) {
      return (bytes: await getImageBytes(image), size: ImageSize(width: image.width, height: image.height));
    }

    final w = (image.width * factor).ceil();
    final h = (image.height * factor).ceil();

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.low,
    );

    final picture = recorder.endRecording();
    final scaled = await picture.toImage(w, h);
    picture.dispose();

    final byteData = await scaled.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    scaled.dispose();

    return (bytes: byteData?.buffer.asUint8List() ?? Uint8List(0), size: ImageSize(width: w, height: h));
  }
}

class ImageSize {
  ImageSize({required this.width, required this.height});
  final int width;
  final int height;
}
