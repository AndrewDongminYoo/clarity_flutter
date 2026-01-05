/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart' as rendering;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';
import 'package:clarity_flutter/src/models/masking.dart';
import 'package:clarity_flutter/src/models/text/text_style.dart';
import 'package:clarity_flutter/src/utils/masking_utils.dart';

abstract class InlineSpan implements IProtoModel<mutation_payload.InlineSpan> {
  InlineSpan(this.type);
  String type;

  static InlineSpan? fromDartInlineSpan(
    rendering.InlineSpan? inlineSpan, {
    MaskingMode maskingMode = MaskingMode.relaxed,
  }) {
    if (inlineSpan is rendering.TextSpan) {
      return TextSpan._fromDartTextSpan(inlineSpan, maskingMode: maskingMode);
    } else if (inlineSpan is rendering.WidgetSpan) {
      return WidgetSpan._fromDartWidgetSpan(inlineSpan);
    }
    return null;
  }
}

class TextSpan extends InlineSpan {
  TextSpan(this.text, this.children, this.style, this.locale, this.spellOut) : super('TS');

  factory TextSpan._fromDartTextSpan(
    rendering.TextSpan textSpan, {
    MaskingMode maskingMode = MaskingMode.relaxed,
  }) {
    return TextSpan(
      MaskingUtils.maskText(maskingMode, textSpan.text, textSpan.style?.fontSize),
      textSpan.children?.map((e) => InlineSpan.fromDartInlineSpan(e, maskingMode: maskingMode)).nonNulls.toList(),
      textSpan.style == null ? null : TextStyle.fromDartTextStyle(textSpan.style!),
      textSpan.locale == null ? null : Locale.fromDartLocale(textSpan.locale!),
      textSpan.spellOut,
    );
  }

  String? text;
  List<InlineSpan>? children;
  TextStyle? style;

  // Ignoring semantics label
  Locale? locale;
  bool? spellOut;

  @override
  mutation_payload.InlineSpan toProtobufInstance() {
    return mutation_payload.InlineSpan(
      type: type,
      text: text,
      children: children?.map((child) => child.toProtobufInstance()).toList(growable: false),
      style: style?.toProtobufInstance(),
      locale: locale?.toProtobufInstance(),
      spellOut: spellOut,
    );
  }
}

class WidgetSpan extends InlineSpan {
  WidgetSpan(this.style, this.alignment, this.baseline) : super('WS');
  factory WidgetSpan._fromDartWidgetSpan(rendering.WidgetSpan widgetSpan) {
    return WidgetSpan(
      widgetSpan.style == null ? null : TextStyle.fromDartTextStyle(widgetSpan.style!),
      widgetSpan.alignment.index,
      widgetSpan.baseline?.index,
    );
  }

  TextStyle? style;
  int alignment;
  int? baseline;

  @override
  mutation_payload.InlineSpan toProtobufInstance() {
    return mutation_payload.InlineSpan(
      type: type,
      style: style?.toProtobufInstance(),
      alignment: alignment,
      baseline: baseline,
    );
  }
}
