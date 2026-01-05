/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Flutter imports:
import 'package:flutter/rendering.dart' as rendering;

// Project imports:
import 'package:clarity_flutter/src/models/masking.dart';
import 'package:clarity_flutter/src/models/text/box_constraints.dart';
import 'package:clarity_flutter/src/models/text/inline_span.dart';
import 'package:clarity_flutter/src/models/text/placeholder_dimensions.dart';
import 'package:clarity_flutter/src/models/text/render_text_base.dart';
import 'package:clarity_flutter/src/models/text/strut_style.dart';
import 'package:clarity_flutter/src/models/text/text_height_behavior.dart';
import 'package:clarity_flutter/src/models/text/text_style.dart';

class RenderEditable extends RenderTextBase {
  RenderEditable(
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
  );

  factory RenderEditable.fromDartRenderEditable(
    rendering.RenderEditable renderEditable,
    rendering.BoxConstraints constraints,
    List<rendering.PlaceholderDimensions> placeholderDimensions, [
    MaskingMode maskingMode = MaskingMode.relaxed,
  ]) {
    return RenderEditable(
      InlineSpan.fromDartInlineSpan(renderEditable.text, maskingMode: maskingMode),
      BoxConstraints.fromDartBoxConstraints(constraints),
      renderEditable.textAlign.index,
      renderEditable.textDirection.index,
      renderEditable.maxLines,
      renderEditable.locale == null ? null : Locale.fromDartLocale(renderEditable.locale!),
      renderEditable.strutStyle == null ? null : StrutStyle.fromDartStrutStyle(renderEditable.strutStyle!),
      renderEditable.textWidthBasis.index,
      renderEditable.textHeightBehavior == null
          ? null
          : TextHeightBehavior.fromDartTextHeightBehavior(renderEditable.textHeightBehavior!),
      placeholderDimensions.map(PlaceholderDimensions.fromDartPlaceholderDimensions).toList(),
    );
  }
}
