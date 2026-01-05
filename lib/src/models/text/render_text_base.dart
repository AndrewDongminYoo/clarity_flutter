/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';
import 'package:clarity_flutter/src/models/text/box_constraints.dart';
import 'package:clarity_flutter/src/models/text/inline_span.dart';
import 'package:clarity_flutter/src/models/text/placeholder_dimensions.dart';
import 'package:clarity_flutter/src/models/text/strut_style.dart';
import 'package:clarity_flutter/src/models/text/text_height_behavior.dart';
import 'package:clarity_flutter/src/models/text/text_style.dart';

abstract class RenderTextBase implements IProtoModel<mutation_payload.RenderText> {
  RenderTextBase(
    this.text,
    this.constraints,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.placeholderDimensions,
  );
  InlineSpan? text;
  BoxConstraints constraints;
  int textAlign;
  int textDirection;
  int? maxLines;
  Locale? locale;
  StrutStyle? strutStyle;
  int textWidthBasis;
  TextHeightBehavior? textHeightBehavior;
  List<PlaceholderDimensions> placeholderDimensions;

  @override
  mutation_payload.RenderText toProtobufInstance() {
    return mutation_payload.RenderText(
      text: text?.toProtobufInstance(),
      constraints: constraints.toProtobufInstance(),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      locale: locale?.toProtobufInstance(),
      strutStyle: strutStyle?.toProtobufInstance(),
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior?.toProtobufInstance(),
      placeholderDimensions: placeholderDimensions
          .map((placeholderDimension) => placeholderDimension.toProtobufInstance())
          .toList(growable: false),
    );
  }
}
