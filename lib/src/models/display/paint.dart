/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:ui' as ui;

// Project imports:
import 'package:clarity_flutter/src/models/display/color4f.dart';
import 'package:clarity_flutter/src/models/display/color_filter.dart';
import 'package:clarity_flutter/src/models/display/mask_filter.dart';
import 'package:clarity_flutter/src/models/display/shader.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

class Paint implements IProtoModel<mutation_payload.Paint> {
  Paint(
    this.color,
    this.style,
    this.blendMode,
    this.strokeCap,
    this.strokeJoin,
    this.strokeWidth,
    this.strokeMiter,
    this.antiAlias,
    this.shader,
    this.colorFilter,
    this.maskFilter,
  );

  Paint.fromDartPaint(ui.Paint paint, {ShaderContext? context})
    : this(
        Color4f.fromDartColor(paint.color),
        paint.style.index,
        paint.blendMode.index,
        paint.strokeCap.index,
        paint.strokeJoin.index,
        paint.strokeWidth,
        paint.strokeMiterLimit,
        paint.isAntiAlias,
        Shader.fromDartShader(paint.shader, context: context),
        // Not supported after Flutter v3.21 in release mode
        // ColorFilter.fromDartColorFilterString(paint.colorFilter.toString()),
        // MaskFilter.fromDartMaskFilterString(paint.maskFilter.toString())
        null,
        null,
      );
  Color4f color;
  int style = ui.PaintingStyle.fill.index;
  int blendMode = ui.BlendMode.srcOver.index;
  int strokeCap = ui.StrokeCap.butt.index;
  int strokeJoin = ui.StrokeJoin.miter.index;
  double strokeWidth = 0;
  double strokeMiter = 4;
  bool antiAlias = true;
  Shader? shader;
  ColorFilter? colorFilter;
  MaskFilter? maskFilter;

  static int getDartPaintCustomHash(ui.Paint paint, {ShaderContext? context}) {
    return Object.hash(
      paint.color,
      paint.style,
      paint.strokeCap,
      paint.strokeJoin.index,
      paint.strokeWidth,
      paint.strokeMiterLimit,
      paint.isAntiAlias,
      paint.shader != null ? Shader.unsupportedShader : null,
      context,
    );
  }

  @override
  mutation_payload.Paint toProtobufInstance() {
    return mutation_payload.Paint(
      color: color.toProtobufInstance(),
      style: style.toDouble(),
      blendMode: blendMode.toDouble(),
      strokeCap: strokeCap.toDouble(),
      strokeJoin: strokeJoin.toDouble(),
      strokeWidth: strokeWidth,
      strokeMiter: strokeMiter,
      antiAlias: antiAlias,
      shader: shader?.toProtobufInstance(),
      colorFilter: colorFilter?.toProtobufInstance(),
      maskFilter: maskFilter?.toProtobufInstance(),
    );
  }
}
