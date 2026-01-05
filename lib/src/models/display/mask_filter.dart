/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:ui' as ui;

// Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

class MaskFilter implements IProtoModel<mutation_payload.MaskFilter> {
  MaskFilter(this.style, this.sigma);
  int style;
  double sigma;

  static MaskFilter? fromDartMaskFilterString(String maskFilterString) {
    final pattern = RegExp(r'MaskFilter\.blur\(([^)]+),([^)]+)\)');
    final match = pattern.firstMatch(maskFilterString);
    if (match != null) {
      final style = match.group(1);
      final sigma = match.group(2);
      if (style == null || sigma == null) return null;
      final actualBlurStyle = ui.BlurStyle.values.firstWhere((e) => e.toString() == style.replaceAll(' ', ''));
      return MaskFilter(actualBlurStyle.index, double.parse(sigma));
    } else {
      return null;
    }
  }

  @override
  mutation_payload.MaskFilter toProtobufInstance() {
    return mutation_payload.MaskFilter(style: style, sigma: sigma);
  }
}
