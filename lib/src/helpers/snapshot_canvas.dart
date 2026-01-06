/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:typed_data';
import 'dart:ui' as ui;

// 🐦 Flutter imports:
import 'package:flutter/rendering.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/capture/native_image_wrapper.dart';
import 'package:clarity_flutter/src/models/capture/snapshot.dart';
import 'package:clarity_flutter/src/models/display/display.dart';
import 'package:clarity_flutter/src/models/display/shader.dart';
import 'package:clarity_flutter/src/models/view_hierarchy/view_node.dart';

typedef GradientRectCallback = ui.Rect Function();

class SnapshotCanvas implements ui.Canvas {
  SnapshotCanvas(Snapshot snapshotData, this._paintsCache) : _data = snapshotData;

  static const double pi = 3.1415926535897932;

  final Snapshot _data;
  final Map<int, Paint> _paintsCache;

  ViewNode? currentPainter;
  final ui.Canvas _nativeCanvas = ui.Canvas(ui.PictureRecorder());

  // Used to mask any image on the screen whether from [RenderImage] or others
  bool get maskImages => currentPainter?.isMasked ?? false;

  ui.Paint emptyPaint = ui.Paint();

  Gradient? _currentGradient;
  TextDirection? _currentTextDirection;

  @override
  void clipPath(ui.Path path, {bool doAntiAlias = true}) {
    clipRect(path.getBounds(), doAntiAlias: doAntiAlias);
  }

  @override
  void clipRSuperellipse(
    ui.RSuperellipse rSuperellipse, {
    bool doAntiAlias = true,
  }) {
    const op = 1;
    final rrect = ui.RRect.fromLTRBAndCorners(
      rSuperellipse.left,
      rSuperellipse.top,
      rSuperellipse.right,
      rSuperellipse.bottom,
      topLeft: rSuperellipse.tlRadius,
      topRight: rSuperellipse.trRadius,
      bottomLeft: rSuperellipse.blRadius,
      bottomRight: rSuperellipse.brRadius,
    );
    trackCommand(ClipRRect(RRect.fromDartRRect(rrect), op, doAntiAlias));
    _nativeCanvas.clipRRect(rrect, doAntiAlias: doAntiAlias);
  }

  @override
  void clipRRect(ui.RRect rrect, {bool doAntiAlias = true}) {
    const op = 1;
    trackCommand(ClipRRect(RRect.fromDartRRect(rrect), op, doAntiAlias));
    _nativeCanvas.clipRRect(rrect, doAntiAlias: doAntiAlias);
  }

  @override
  void clipRect(
    ui.Rect rect, {
    ui.ClipOp clipOp = ui.ClipOp.intersect,
    bool doAntiAlias = true,
  }) {
    final op = clipOp.index;
    trackCommand(ClipRect(Rect.fromDartRect(rect), op, doAntiAlias));
    _nativeCanvas.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);
  }

  @override
  void drawArc(ui.Rect rect, double startAngle, double sweepAngle, bool useCenter, ui.Paint paint) {
    trackCommand(
      DrawArc(Rect.fromDartRect(rect), _degrees(startAngle), _degrees(sweepAngle), useCenter, trackPaint(paint)),
    );
  }

  double _degrees(double radianAngle) {
    return (radianAngle * 180) / pi;
  }

  @override
  void drawAtlas(
    ui.Image atlas,
    List<ui.RSTransform> transforms,
    List<ui.Rect> rects,
    List<ui.Color>? colors,
    ui.BlendMode? blendMode,
    ui.Rect? cullRect,
    ui.Paint paint,
  ) {
    trackCommand(
      DrawAtlas(
        rects.map(Rect.fromDartRect).toList(),
        transforms.map(RSXform.fromDartRSTransform).toList(),
        maskImages ? null : trackImage(atlas),
        trackPaint(paint),
        blendMode?.index,
        colors?.map((color) => color.toARGB32()).toList(),
      ),
    );
  }

  @override
  void drawCircle(ui.Offset c, double radius, ui.Paint paint) {
    trackCommand(
      DrawCircle(
        Point.fromDartOffset(c),
        radius,
        trackPaint(
          paint,
          gradientRectCallback: () => ui.Rect.fromCircle(center: c, radius: radius),
        ),
      ),
    );
  }

  @override
  void drawColor(ui.Color color, ui.BlendMode blendMode) {
    trackCommand(DrawColor(Color4f.fromDartColor(color), blendMode.index));
  }

  @override
  void drawDRRect(ui.RRect outer, ui.RRect inner, ui.Paint paint) {
    trackCommand(
      DrawDRRect(
        RRect.fromDartRRect(outer),
        RRect.fromDartRRect(inner),
        trackPaint(paint, gradientRectCallback: () => outer.outerRect),
      ),
    );
  }

  @override
  void drawImage(ui.Image image, ui.Offset p, ui.Paint paint) {
    final imageCommand = DrawImage(
      p.dx,
      p.dy,
      maskImages ? null : trackImage(image),
      trackPaint(paint),
      maskedWidth: maskImages ? image.width : null,
      maskedHeight: maskImages ? image.height : null,
    );
    trackCommand(imageCommand);
  }

  @override
  void drawImageNine(ui.Image image, ui.Rect center, ui.Rect dst, ui.Paint paint) {
    trackCommand(
      DrawImageNine(
        IRect.fromDartRect(center),
        Rect.fromDartRect(dst),
        maskImages ? null : trackImage(image),
        trackPaint(paint),
      ),
    );
  }

  @override
  void drawImageRect(ui.Image image, ui.Rect src, ui.Rect dst, ui.Paint paint) {
    trackCommand(
      DrawImageRect(
        Rect.fromDartRect(src),
        Rect.fromDartRect(dst),
        maskImages ? null : trackImage(image),
        trackPaint(paint),
      ),
    );
  }

  @override
  void drawLine(ui.Offset p1, ui.Offset p2, ui.Paint paint) {
    trackCommand(DrawLine(Point.fromDartOffset(p1), Point.fromDartOffset(p2), trackPaint(paint)));
  }

  @override
  void drawRSuperellipse(ui.RSuperellipse rSuperellipse, ui.Paint paint) {
    final rect = ui.RRect.fromLTRBAndCorners(
      rSuperellipse.left,
      rSuperellipse.top,
      rSuperellipse.right,
      rSuperellipse.bottom,
      topLeft: rSuperellipse.tlRadius,
      topRight: rSuperellipse.trRadius,
      bottomLeft: rSuperellipse.blRadius,
      bottomRight: rSuperellipse.brRadius,
    );

    trackCommand(DrawRRect(RRect.fromDartRRect(rect), trackPaint(paint, gradientRectCallback: () => rect.outerRect)));
  }

  @override
  void drawOval(ui.Rect rect, ui.Paint paint) {
    trackCommand(DrawOval(Rect.fromDartRect(rect), trackPaint(paint, gradientRectCallback: () => rect)));
  }

  @override
  void drawPaint(ui.Paint paint) {
    trackCommand(DrawPaint(trackPaint(paint)));
  }

  @override
  void drawParagraph(ui.Paragraph paragraph, ui.Offset offset) {}

  @override
  void drawPath(ui.Path path, ui.Paint paint) {
    drawRect(path.getBounds(), paint);
  }

  @override
  void drawPicture(ui.Picture picture) {
    final pictureX = currentPainter!.renderObject!.paintBounds.left;
    final pictureY = currentPainter!.renderObject!.paintBounds.top;
    final pictureWidth = currentPainter!.renderObject!.paintBounds.width;
    final pictureHeight = currentPainter!.renderObject!.paintBounds.height;
    trackCommand(
      DrawImage(
        pictureX,
        pictureY,
        maskImages ? null : trackPicture(picture, pictureWidth.ceil(), pictureHeight.ceil()),
        trackPaint(emptyPaint),
        maskedHeight: maskImages ? pictureHeight.ceil() : null,
        maskedWidth: maskImages ? pictureWidth.ceil() : null,
      ),
    );
  }

  @override
  void drawPoints(ui.PointMode pointMode, List<ui.Offset> points, ui.Paint paint) {
    trackCommand(DrawPoints(pointMode.index, points.map(Point.fromDartOffset).toList(), trackPaint(paint)));
  }

  @override
  void drawRRect(ui.RRect rrect, ui.Paint paint) {
    trackCommand(DrawRRect(RRect.fromDartRRect(rrect), trackPaint(paint, gradientRectCallback: () => rrect.outerRect)));
  }

  @override
  void drawRawAtlas(
    ui.Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    ui.BlendMode? blendMode,
    ui.Rect? cullRect,
    ui.Paint paint,
  ) {
    trackCommand(DrawRawAtlas());
  }

  @override
  void drawRawPoints(ui.PointMode pointMode, Float32List points, ui.Paint paint) {
    trackCommand(DrawRawPoints());
  }

  @override
  void drawRect(ui.Rect rect, ui.Paint paint) {
    trackCommand(DrawRect(Rect.fromDartRect(rect), trackPaint(paint, gradientRectCallback: () => rect)));
  }

  @override
  void drawShadow(ui.Path path, ui.Color color, double elevation, bool transparentOccluder) {
    trackCommand(DrawShadow());
  }

  @override
  void drawVertices(ui.Vertices vertices, ui.BlendMode blendMode, ui.Paint paint) {
    trackCommand(DrawVertices());
  }

  @override
  int getSaveCount() {
    return _nativeCanvas.getSaveCount();
  }

  @override
  void restore() {
    if (_nativeCanvas.getSaveCount() > 1) {
      trackCommand(Restore());
      _nativeCanvas.restore();
    }
  }

  @override
  void restoreToCount(int count) {
    // Resorting to sending multiple restores, since restore to count is impacted by save operations performed on dashboard canvas
    final restoreCounts = _nativeCanvas.getSaveCount() - count;
    for (var i = 0; i < restoreCounts; i++) {
      restore();
    }
  }

  @override
  void rotate(double radians) {
    trackCommand(Rotate(_degrees(radians), 0, 0));
    _nativeCanvas.rotate(radians);
  }

  @override
  void save() {
    trackCommand(Save());
    _nativeCanvas.save();
  }

  @override
  void saveLayer(ui.Rect? bounds, ui.Paint paint) {
    trackCommand(SaveLayer(bounds != null ? Rect.fromDartRect(bounds) : null, null, null, trackPaint(paint)));
    _nativeCanvas.saveLayer(bounds, paint);
  }

  @override
  void scale(double sx, [double? sy]) {
    trackCommand(Scale(sx, sy ?? 0));
    _nativeCanvas.scale(sx, sy);
  }

  @override
  void skew(double sx, double sy) {
    trackCommand(Skew(sx, sy));
    _nativeCanvas.skew(sx, sy);
  }

  @override
  void transform(Float64List matrix4) {
    trackCommand(Transform(_convertColumnMajorToRowMajor(matrix4).toList()));
    _nativeCanvas.transform(matrix4);
  }

  Float64List _convertColumnMajorToRowMajor(Float64List matrix) {
    final size = matrix.length;
    final dimension = size ~/ 4;
    final rowMajorMatrix = Float64List(size);

    for (var i = 0; i < dimension; i++) {
      for (var j = 0; j < dimension; j++) {
        rowMajorMatrix[i * dimension + j] = matrix[j * dimension + i];
      }
    }

    return rowMajorMatrix;
  }

  @override
  void translate(double dx, double dy) {
    final left = dx;
    final top = dy;
    trackCommand(Translate(left, top));
    _nativeCanvas.translate(dx, dy);
  }

  @override
  Float64List getTransform() {
    return _nativeCanvas.getTransform();
  }

  @override
  ui.Rect getLocalClipBounds() {
    return _nativeCanvas.getLocalClipBounds();
  }

  @override
  ui.Rect getDestinationClipBounds() {
    return _nativeCanvas.getDestinationClipBounds();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    super.noSuchMethod(invocation);
  }

  void trackCommand(DisplayCommand command) {
    _data.addCommand(command);
  }

  int trackPaint(
    ui.Paint dartPaint, {
    GradientRectCallback? gradientRectCallback,
  }) {
    ShaderContext? context;

    if (dartPaint.shader != null && _currentGradient != null && gradientRectCallback != null) {
      context = ShaderContext(_currentGradient!, gradientRectCallback(), _currentTextDirection);
      _currentGradient = null;
      _currentTextDirection = null;
    }

    final customHash = Paint.getDartPaintCustomHash(dartPaint, context: context);

    if (!_data.paints.containsKey(customHash)) {
      if (!_paintsCache.containsKey(customHash)) {
        _paintsCache[customHash] = Paint.fromDartPaint(dartPaint, context: context);
      }

      _data.paints[customHash] = _paintsCache[customHash]!;
    }

    return customHash;
  }

  int trackImage(ui.Image image) {
    final imageWrapper = NativeImageWrapper.fromImage(image);
    _data.images[imageWrapper.hashCode] = imageWrapper;
    return imageWrapper.hashCode;
  }

  int trackPicture(ui.Picture picture, int width, int height) {
    final imageWrapper = NativeImageWrapper.fromPicture(picture, height, width);
    _data.images[imageWrapper.hashCode] = imageWrapper;
    return imageWrapper.hashCode;
  }

  void trackRenderDecoratedBox(RenderDecoratedBox box) {
    final gradient = _getDecorationGradient(box.decoration);

    if (gradient == null) {
      return;
    }

    _currentGradient = gradient;
    _currentTextDirection = box.configuration.textDirection;
  }

  void trackRenderDecoratedSliver(RenderDecoratedSliver sliver) {
    final gradient = _getDecorationGradient(sliver.decoration);

    if (gradient == null) {
      return;
    }

    _currentGradient = gradient;
    _currentTextDirection = sliver.configuration.textDirection;
  }

  Gradient? _getDecorationGradient(Decoration decoration) {
    if (decoration is BoxDecoration) {
      return decoration.gradient;
    } else if (decoration is ShapeDecoration) {
      return decoration.gradient;
    }

    return null;
  }
}
