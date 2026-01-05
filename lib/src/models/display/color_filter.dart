/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:ui' as ui;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/color4f.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

class ColorFilter implements IProtoModel<mutation_payload.ColorFilter> {
  ColorFilter(this.color4f, this.mode);
  Color4f color4f;
  int mode;

  static ColorFilter? fromDartColorFilterString(String colorFilterString) {
    final pattern = RegExp(r'ColorFilter\.mode\((.+),(.+)\)');
    final match = pattern.firstMatch(colorFilterString);
    if (match != null) {
      final color = match.group(1);
      final blendMode = match.group(2);
      if (color == null || blendMode == null) return null;
      final actualBlendMode = ui.BlendMode.values.firstWhere((e) => e.toString() == blendMode.replaceAll(' ', ''));
      return ColorFilter(Color4f.fromDartColorString(color)!, actualBlendMode.index);
    } else {
      return null;
    }
  }

  @override
  mutation_payload.ColorFilter toProtobufInstance() {
    return mutation_payload.ColorFilter(color4f: color4f.toProtobufInstance(), mode: mode.toDouble());
  }
}
