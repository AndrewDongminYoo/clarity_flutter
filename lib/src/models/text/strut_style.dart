/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🐦 Flutter imports:
import 'package:flutter/rendering.dart' as rendering;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';
import 'package:clarity_flutter/src/models/text/text_style.dart';

class StrutStyle implements IProtoModel<mutation_payload.StrutStyle> {
  StrutStyle(
    this.fontFamily,
    this.fontFamilyFallback,
    this.fontSize,
    this.height,
    this.leadingDistribution,
    this.leading,
    this.fontWeight,
    this.fontStyle,
    this.forceStrutHeight,
  );

  factory StrutStyle.fromDartStrutStyle(rendering.StrutStyle strutStyle) {
    return StrutStyle(
      strutStyle.fontFamily,
      strutStyle.fontFamilyFallback?.map((c) => c).toList(),
      strutStyle.fontSize,
      strutStyle.height,
      strutStyle.leadingDistribution?.index,
      strutStyle.leading,
      strutStyle.fontWeight == null ? null : FontWeight.fromDartFontWeight(strutStyle.fontWeight!),
      strutStyle.fontStyle?.index,
      strutStyle.forceStrutHeight,
    );
  }

  String? fontFamily;
  List<String>? fontFamilyFallback;
  double? fontSize;
  double? height;
  double? leading;
  int? leadingDistribution;
  FontWeight? fontWeight;
  int? fontStyle;
  bool? forceStrutHeight;

  @override
  mutation_payload.StrutStyle toProtobufInstance() {
    return mutation_payload.StrutStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      height: height,
      leading: leading,
      leadingDistribution: leadingDistribution,
      fontWeight: fontWeight?.toProtobufInstance(),
      fontStyle: fontStyle,
      forceStrutHeight: forceStrutHeight,
    );
  }
}
