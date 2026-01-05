/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Flutter imports:
import 'package:flutter/rendering.dart' as rendering;

// Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/masking.dart';
import 'package:clarity_flutter/src/models/text/box_constraints.dart';
import 'package:clarity_flutter/src/models/text/inline_span.dart';
import 'package:clarity_flutter/src/models/text/placeholder_dimensions.dart';
import 'package:clarity_flutter/src/models/text/render_text_base.dart';
import 'package:clarity_flutter/src/models/text/strut_style.dart';
import 'package:clarity_flutter/src/models/text/text_height_behavior.dart';
import 'package:clarity_flutter/src/models/text/text_style.dart';

class RenderParagraph extends RenderTextBase {
  RenderParagraph(
    super.text,
    super.constraints,
    super.textAlign,
    super.textDirection,
    super.maxLines,
    super.locale,
    super.strutStyle,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.placeholderDimensions,
    this.softWrap,
    this.overflow,
  );

  factory RenderParagraph.fromDartRenderParagraph(
    rendering.RenderParagraph renderParagraph,
    rendering.BoxConstraints constraints,
    List<rendering.PlaceholderDimensions> placeholderDimensions, [
    MaskingMode maskingMode = MaskingMode.relaxed,
  ]) {
    return RenderParagraph(
      InlineSpan.fromDartInlineSpan(renderParagraph.text, maskingMode: maskingMode),
      BoxConstraints.fromDartBoxConstraints(constraints),
      renderParagraph.textAlign.index,
      renderParagraph.textDirection.index,
      renderParagraph.maxLines,
      renderParagraph.locale == null ? null : Locale.fromDartLocale(renderParagraph.locale!),
      renderParagraph.strutStyle == null ? null : StrutStyle.fromDartStrutStyle(renderParagraph.strutStyle!),
      renderParagraph.textWidthBasis.index,
      renderParagraph.textHeightBehavior == null
          ? null
          : TextHeightBehavior.fromDartTextHeightBehavior(renderParagraph.textHeightBehavior!),
      placeholderDimensions.map(PlaceholderDimensions.fromDartPlaceholderDimensions).toList(),
      renderParagraph.softWrap,
      renderParagraph.overflow.index,
    );
  }

  bool softWrap;
  int overflow;

  @override
  mutation_payload.RenderText toProtobufInstance() {
    return super.toProtobufInstance()
      ..softWrap = softWrap
      ..overflow = overflow;
  }
}
