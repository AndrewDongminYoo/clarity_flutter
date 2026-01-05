/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// ignore_for_file: deprecated_member_use_from_same_package, constant_identifier_names

// 🎯 Dart imports:
import 'dart:ui' as ui;

// 🐦 Flutter imports:
import 'package:flutter/rendering.dart';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

@immutable
class ShaderContext {
  const ShaderContext(this.gradient, this.rect, this.textDirection);
  final Gradient gradient;
  final ui.Rect rect;
  final TextDirection? textDirection;

  List<double>? get localMatrix {
    final matrix = gradient.transform?.transform(rect, textDirection: textDirection);

    return matrix?.storage.toList(growable: false);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShaderContext &&
        other.gradient == gradient &&
        other.rect == rect &&
        other.textDirection == textDirection;
  }

  @override
  int get hashCode => Object.hash(gradient, rect, textDirection);
}

abstract class Shader implements IProtoModel<mutation_payload.Shader> {
  const Shader(this.type);
  final ShaderType type;

  static Shader unsupportedShader = const UnsupportedShader();

  static Shader? fromDartShader(ui.Shader? shader, {ShaderContext? context}) {
    final gradient = context?.gradient;

    switch (gradient) {
      case LinearGradient():
        return LinearGradientShader.fromDartLinearGradient(
          gradient,
          context!.rect,
          context.textDirection,
          context.localMatrix,
        );

      case RadialGradient():
        return RadialGradientShader.fromDartRadialGradient(
          gradient,
          context!.rect,
          context.textDirection,
          context.localMatrix,
        );

      case SweepGradient():
        return SweepGradientShader.fromDartSweepGradient(
          gradient,
          context!.rect,
          context.textDirection,
          context.localMatrix,
        );
    }

    if (shader == null) return null;

    return unsupportedShader;
  }
}

class UnsupportedShader extends Shader {
  const UnsupportedShader() : super(ShaderType.Unsupported);

  @override
  mutation_payload.Shader toProtobufInstance() {
    return mutation_payload.Shader(type: type.name);
  }
}

class LinearGradientShader extends Shader {
  const LinearGradientShader(this.start, this.end, this.tileMode, this.colors, this.stops, this.localMatrix)
    : super(ShaderType.LinearGradientShader);

  factory LinearGradientShader.fromDartLinearGradient(
    LinearGradient gradient,
    ui.Rect rect,
    TextDirection? textDirection,
    List<double>? localMatrix,
  ) {
    final begin = gradient.begin.resolve(textDirection);
    final end = gradient.end.resolve(textDirection);

    final startOffset = begin.withinRect(rect);
    final endOffset = end.withinRect(rect);

    return LinearGradientShader(
      Point.fromDartOffset(startOffset),
      Point.fromDartOffset(endOffset),
      gradient.tileMode.index,
      gradient.colors.map(Color4f.fromDartColor).toList(growable: false),
      gradient.stops?.toList(growable: false),
      localMatrix,
    );
  }

  final Point start;
  final Point end;
  final int tileMode;
  final List<Color4f> colors;
  final List<double>? stops;
  final List<double>? localMatrix;

  @override
  mutation_payload.Shader toProtobufInstance() {
    return mutation_payload.Shader(
      typeEnum: type.toProtobufType(),
      start: start.toProtobufInstance(),
      end: end.toProtobufInstance(),
      tileMode: tileMode.toDouble(),
      colors: colors.map((e) => e.toProtobufInstance()).toList(growable: false),
      pos: stops?.toList(growable: false),
      localMatrix: localMatrix?.toList(growable: false),
      gradFlags: 1,
    );
  }
}

class RadialGradientShader extends Shader {
  const RadialGradientShader(this.center, this.radius, this.tileMode, this.colors, this.stops, this.localMatrix)
    : super(ShaderType.RadialGradientShader);

  factory RadialGradientShader.fromDartRadialGradient(
    RadialGradient gradient,
    ui.Rect rect,
    TextDirection? textDirection,
    List<double>? localMatrix,
  ) {
    final alignment = gradient.center.resolve(textDirection);
    final centerOffset = alignment.withinRect(rect);

    final radius = gradient.radius * rect.shortestSide;

    return RadialGradientShader(
      Point.fromDartOffset(centerOffset),
      radius,
      gradient.tileMode.index,
      gradient.colors.map(Color4f.fromDartColor).toList(growable: false),
      gradient.stops?.toList(growable: false),
      localMatrix,
    );
  }

  final Point center;
  final double radius;
  final int tileMode;
  final List<Color4f> colors;
  final List<double>? stops;
  final List<double>? localMatrix;

  @override
  mutation_payload.Shader toProtobufInstance() {
    return mutation_payload.Shader(
      typeEnum: type.toProtobufType(),
      center: center.toProtobufInstance(),
      radius: radius,
      tileMode: tileMode.toDouble(),
      colors: colors.map((e) => e.toProtobufInstance()).toList(growable: false),
      pos: stops?.toList(growable: false),
      localMatrix: localMatrix?.toList(growable: false),
      gradFlags: 1,
    );
  }
}

class SweepGradientShader extends Shader {
  const SweepGradientShader(
    this.center,
    this.startAngle,
    this.endAngle,
    this.tileMode,
    this.colors,
    this.stops,
    this.localMatrix,
  ) : super(ShaderType.SweepGradientShader);

  factory SweepGradientShader.fromDartSweepGradient(
    SweepGradient gradient,
    ui.Rect rect,
    TextDirection? textDirection,
    List<double>? localMatrix,
  ) {
    final centerAlignment = gradient.center.resolve(textDirection);
    final centerOffset = centerAlignment.withinRect(rect);

    return SweepGradientShader(
      Point.fromDartOffset(centerOffset),
      gradient.startAngle,
      gradient.endAngle,
      gradient.tileMode.index,
      gradient.colors.map(Color4f.fromDartColor).toList(growable: false),
      gradient.stops?.toList(growable: false),
      localMatrix,
    );
  }

  final Point center;
  final double startAngle;
  final double endAngle;
  final int tileMode;
  final List<Color4f> colors;
  final List<double>? stops;
  final List<double>? localMatrix;

  @override
  mutation_payload.Shader toProtobufInstance() {
    return mutation_payload.Shader(
      typeEnum: type.toProtobufType(),
      center: center.toProtobufInstance(),
      startAngle: startAngle,
      endAngle: endAngle,
      tileMode: tileMode.toDouble(),
      colors: colors.map((e) => e.toProtobufInstance()).toList(growable: false),
      pos: stops?.toList(growable: false),
      localMatrix: localMatrix?.toList(growable: false),
      gradFlags: 1,
    );
  }
}

enum ShaderType {
  ImageShader,
  LinearGradientShader,
  RadialGradientShader,
  SweepGradientShader,
  LocalMatrixShader,
  Color4Shader,
  Unsupported,
}

extension CommandTypeExtension on ShaderType {
  mutation_payload.ShaderType? toProtobufType() {
    return mutation_payload.ShaderType.valueOf(index);
  }
}
