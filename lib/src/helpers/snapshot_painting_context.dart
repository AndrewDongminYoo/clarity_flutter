/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🐦 Flutter imports:
import 'package:flutter/rendering.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/helpers/snapshot_canvas.dart';
import 'package:clarity_flutter/src/helpers/telemetry_tracker.dart';
import 'package:clarity_flutter/src/models/capture/edit_text_info.dart';
import 'package:clarity_flutter/src/models/capture/snapshot.dart';
import 'package:clarity_flutter/src/models/display/display.dart' as clarity_display;
import 'package:clarity_flutter/src/models/display/error_view_annotation.dart';
import 'package:clarity_flutter/src/models/masking.dart';
import 'package:clarity_flutter/src/models/telemetry/telemetry.dart';
import 'package:clarity_flutter/src/models/text/text.dart' as clarity_text;
import 'package:clarity_flutter/src/models/view_hierarchy/view_node.dart';
import 'package:clarity_flutter/src/utils/dev_utils.dart';
import 'package:clarity_flutter/src/utils/int_utils.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';
import 'package:clarity_flutter/src/utils/masking_utils.dart';
import 'package:clarity_flutter/src/utils/rect_utils.dart';
import 'package:clarity_flutter/src/utils/render_object_utils.dart';
import 'package:clarity_flutter/src/widgets/masking_widgets.dart';

class SnapshotPaintingContext extends PaintingContext {
  SnapshotPaintingContext({
    required Snapshot snapshotData,
    required this.onMarkNeedsPaint,
    required Rect paintBounds,
    required MaskingMode maskingMode,
    required Map<int, clarity_display.Paint> paintsCache,
  }) : _snapshotData = snapshotData,
       _snapshotCanvas = SnapshotCanvas(snapshotData, paintsCache),
       deviceTransformation = snapshotData.deviceTransformationMatrix,
       projectDefaultMasking = maskingMode,
       super(OffsetLayer(), paintBounds);

  // Related Issue: https://msasg.visualstudio.com/Clarity/_workitems/edit/9734552
  // This package's (https://pub.dev/packages/visibility_detector) VisibilityDetector Widget creates a RenderVisibilityDetector which notifies its subscribers when paint is called
  // on it, so we skip it to not cause excessive notifications
  final Set<String> skippedRenderObjects = const {
    '_RenderSnapshotWidget',
    'RenderVisibilityDetector',
  };

  final Snapshot _snapshotData;

  final Matrix4 deviceTransformation;

  final SnapshotCanvas? _snapshotCanvas;

  ViewNode? _currentPaintingObject;

  ViewNode? get currentPaintingObject => _currentPaintingObject;

  Matrix4 currentTransformToRoot = Matrix4.identity();

  set currentPaintingObject(ViewNode? node) {
    _currentPaintingObject = node;
    _snapshotCanvas?.currentPainter = node;
  }

  MaskingMode projectDefaultMasking;
  MaskingState? currentWidgetMasking;

  static RenderObject? currentChild;

  VoidCallback onMarkNeedsPaint;

  final bool skippingObjectsDisabled = DebuggingUtils.instance?.paintSkippedObjects ?? false;

  final bool releaseFrameErrors = DebuggingUtils.instance?.releaseFrameErrors ?? false;

  int _allowedErrorCount = ClarityConstants.frameErrorsThrottlingLimit;

  @override
  Canvas get canvas {
    return _snapshotCanvas!;
  }

  @override
  void stopRecordingIfNeeded() {
    super.stopRecordingIfNeeded();
  }

  @override
  PaintingContext createChildContext(ContainerLayer childLayer, Rect bounds) {
    Logger.warn?.out('Invalid call to createChildContext');
    return this;
  }

  @override
  ClipRectLayer? pushClipRect(
    bool needsCompositing,
    Offset offset,
    Rect clipRect,
    PaintingContextCallback painter, {
    Clip clipBehavior = Clip.hardEdge,
    ClipRectLayer? oldLayer,
  }) {
    if (clipBehavior == Clip.none) {
      painter(this, offset);
      return oldLayer;
    }
    final offsetClipRect = clipRect.shift(offset);
    clipRectAndPaint(offsetClipRect, clipBehavior, offsetClipRect, () => painter(this, offset));
    return oldLayer;
  }

  @override
  ClipRRectLayer? pushClipRRect(
    bool needsCompositing,
    Offset offset,
    Rect bounds,
    RRect clipRRect,
    PaintingContextCallback painter, {
    Clip clipBehavior = Clip.antiAlias,
    ClipRRectLayer? oldLayer,
  }) {
    if (clipBehavior == Clip.none) {
      painter(this, offset);
      return oldLayer;
    }
    final offsetBounds = bounds.shift(offset);
    final offsetClipRRect = clipRRect.shift(offset);
    clipRRectAndPaint(offsetClipRRect, clipBehavior, offsetBounds, () => painter(this, offset));
    return oldLayer;
  }

  @override
  ClipPathLayer? pushClipPath(
    bool needsCompositing,
    Offset offset,
    Rect bounds,
    Path clipPath,
    PaintingContextCallback painter, {
    Clip clipBehavior = Clip.antiAlias,
    ClipPathLayer? oldLayer,
  }) {
    if (clipBehavior == Clip.none) {
      painter(this, offset);
      return oldLayer;
    }
    final offsetBounds = bounds.shift(offset);
    final offsetClipPath = clipPath.shift(offset);
    clipPathAndPaint(offsetClipPath, clipBehavior, offsetBounds, () => painter(this, offset));
    return oldLayer;
  }

  @override
  TransformLayer? pushTransform(
    bool needsCompositing,
    Offset offset,
    Matrix4 transform,
    PaintingContextCallback painter, {
    TransformLayer? oldLayer,
  }) {
    final effectiveTransform = Matrix4.translationValues(offset.dx, offset.dy, 0)
      ..multiply(transform)
      ..translateByDouble(-offset.dx, -offset.dy, 0, 1);
    canvas
      ..save()
      ..transform(effectiveTransform.storage);
    painter(this, offset);
    canvas.restore();
    return oldLayer;
  }

  @override
  void paintChild(RenderObject child, Offset offset) {
    if (!child.isSafeToPaint()) {
      Logger.warn?.out(
        "Skipping painting of ${child.runtimeType} since it's not safe to paint (not attached or has no size)",
      );
      return;
    }

    if (child.runtimeType == ClarityMaskRenderObject || child.runtimeType == ClarityUnmaskRenderObject) {
      final parentWidgetMasking = currentWidgetMasking;
      currentWidgetMasking = child.runtimeType == ClarityMaskRenderObject
          ? MaskingState.masking
          : MaskingState.unmasking;
      child.visitChildren((element) {
        paintChild(element, offset);
      });
      currentWidgetMasking = parentWidgetMasking;
      return;
    } else if (ignoredRenderObjects.contains(child.runtimeType)) {
      Logger.verbose?.out('Ignoring ${child.runtimeType}');
      child.visitChildren((element) {
        paintChild(element, offset);
      });
      return;
    }

    final parent = currentPaintingObject;
    final parentTransform = currentTransformToRoot.clone();
    if (parent != null) {
      _applyTransformToParent(parent, child, currentTransformToRoot);
    }

    final globalRect = MatrixUtils.transformRect(currentTransformToRoot, child.paintBounds);

    final absoluteBounds = MatrixUtils.transformRect(deviceTransformation, globalRect);

    final visibleBounds = absoluteBounds.getVisibleBounds(estimatedBounds);
    final isVisible = visibleBounds.isVisible();

    final explicitMasking = currentWidgetMasking;
    final isMasked =
        (explicitMasking == null && projectDefaultMasking == MaskingMode.strict) ||
        (explicitMasking != null && explicitMasking == MaskingState.masking);

    final node = ViewNode(
      renderNodeId: identityHashCode(child),
      id: parent == null ? 0 : -1,
      type: child.runtimeType.toString(),
      x: IntUtils.safeToInt(visibleBounds.left),
      y: IntUtils.safeToInt(visibleBounds.top),
      width: IntUtils.safeToInt(visibleBounds.width),
      height: IntUtils.safeToInt(visibleBounds.height),
      viewX: IntUtils.safeToInt(absoluteBounds.left),
      viewY: IntUtils.safeToInt(absoluteBounds.top),
      viewWidth: IntUtils.safeToInt(absoluteBounds.width),
      viewHeight: IntUtils.safeToInt(absoluteBounds.height),
      visible: isVisible,
      clickable: child.isClickable(),
      objectRef: WeakReference(child),
      explicitMaskingState: explicitMasking,
      isMasked: isMasked,
      nodeBounds: globalRect,
    );

    currentPaintingObject = node;

    if (parent == null) {
      _snapshotData.root = node;
    } else {
      parent.addChildView(node);
    }

    if (_shouldSetEditTextInfo(child)) {
      _snapshotData.editTextInfo = EditTextInfo(child.hashCode, (child as RenderEditable).plainText.length);
    }

    if (child is RenderDecoratedBox) {
      _snapshotCanvas!.trackRenderDecoratedBox(child);
    } else if (child is RenderDecoratedSliver) {
      _snapshotCanvas!.trackRenderDecoratedSliver(child);
    }

    if (child is RenderParagraph) {
      _drawRenderParagraph(child, node, offset);
    } else if (_shouldDrawRenderEditable(child)) {
      _drawRenderEditable(child as RenderEditable, node, offset);
    } else if (_shouldMaskObject(child)) {
      // Completely omit
      _maskObject(child, offset);
    } else if (_shouldSkipObject(child, isVisible)) {
      // Skip and draw child!
      Logger.verbose?.out('Skipping Painting ${child.runtimeType}');
      child.visitChildren((element) {
        paintChild(element, offset);
      });
    } else {
      _paintWithErrorHandling(child, offset);
    }

    _resetParent(parent, parentTransform);
  }

  void _paintWithErrorHandling(RenderObject child, Offset offset) {
    try {
      child.paint(this, offset);
    } catch (e, st) {
      if (!releaseFrameErrors && _allowedErrorCount <= 0) {
        rethrow;
      }
      Logger.error?.out('View painting error for Type: ${child.runtimeType} with Error: $e', stackTrace: st);
      TelemetryTracker.instance?.trackError(ErrorType.PartialScreenCapturing, e.toString(), st);
      _snapshotCanvas!.trackCommand(ErrorViewAnnotation(child.runtimeType.toString(), e.toString()));
      _allowedErrorCount--;
      _maskObject(child, offset);
    }
  }

  bool _shouldMaskObject(RenderObject child) =>
      !skippingObjectsDisabled &&
      (child is RenderEditable || child is PlatformViewRenderBox || child is RenderUiKitView);

  void _maskObject(RenderObject child, Offset offset) {
    final bounds = clarity_display.Rect.fromDartRect(child.paintBounds.shift(offset));
    _snapshotCanvas!.trackCommand(
      clarity_display.DrawImageRect(bounds, bounds, null, _snapshotCanvas.trackPaint(MaskingUtils.maskedImagePaint)),
    );
  }

  bool _shouldSkipObject(RenderObject child, bool isVisible) =>
      !skippingObjectsDisabled &&
      (!isVisible ||
          skippedRenderObjects.contains(child.runtimeType.toString()) ||
          ClarityObjectWrapper(child).alwaysNeedsCompositing);

  // Needed since we sometimes skip parents in painting to ensure correct transformation
  void _applyTransformToParent(ViewNode targetParent, RenderObject child, Matrix4 parentTransform) {
    final fromPath = <RenderObject>[child];
    var current = child;

    while (current.parent != null && current.parent != targetParent.renderObject) {
      fromPath.add(current.parent!);
      current = current.parent!;
    }

    // Exclude rootNode transformation, following suit of [getTransformTo].
    // The rootNode transformation is the device transformation from Logical to physical pixels applied at the end.
    if (current.parent != null && current.parent != child.owner!.rootNode) {
      fromPath.add(current.parent!);
    }

    final lastIndex = fromPath.length - 1;
    // If child has a valid added parent
    for (var index = lastIndex; index > 0; index -= 1) {
      fromPath[index].applyPaintTransform(fromPath[index - 1], parentTransform);
    }
  }

  void _resetParent(ViewNode? parent, Matrix4 transform) {
    currentPaintingObject = parent;
    currentTransformToRoot = transform;
  }

  void _drawRenderParagraph(RenderParagraph child, ViewNode node, Offset offset) {
    final currentPainterMaskingMode = MaskingUtils.determineMaskingMode(
      currentPaintingObject!.explicitMaskingState,
      projectDefaultMasking,
    );

    node.text = _paintRenderTextWithPlaceholders(
      child,
      offset,
      currentPainterMaskingMode,
      clarity_text.RenderParagraph.fromDartRenderParagraph,
      clarity_display.DrawRenderParagraph.new,
    );
  }

  bool _shouldDrawRenderEditable(RenderObject child) {
    if (child is! RenderEditable) return false;

    return child.readOnly && !child.obscureText;
  }

  void _drawRenderEditable(RenderEditable child, ViewNode node, Offset offset) {
    final currentPainterMaskingMode = MaskingUtils.determineMaskingMode(
      currentPaintingObject!.explicitMaskingState,
      projectDefaultMasking,
    );

    node.text = _paintRenderTextWithPlaceholders(
      child,
      offset,
      currentPainterMaskingMode,
      clarity_text.RenderEditable.fromDartRenderEditable,
      clarity_display.DrawRenderEditable.new,
    );
  }

  bool _shouldSetEditTextInfo(RenderObject child) =>
      _snapshotData.editTextInfo == null &&
      _snapshotData.keyboardHeight > 0 &&
      child is RenderEditable &&
      child.hasFocus &&
      !child.readOnly;

  // Have to put child as dynamic because there is no way to specify that the type T is a RenderBox and also implements the ContainerRenderObjectMixin<RenderBox, TextParentData> mixin.
  String _paintRenderTextWithPlaceholders<T extends RenderBox, U extends clarity_text.RenderTextBase>(
    dynamic child,
    Offset offset,
    MaskingMode currentPainterMaskingMode,
    U Function(T, BoxConstraints, List<PlaceholderDimensions>, [MaskingMode]) createObjectCallback,
    clarity_display.DisplayCommand Function(U, clarity_text.Offset) trackCommandCallback,
  ) {
    var placeholders = <PlaceholderDimensions>[];
    if ((child as dynamic).childCount as int > 0) {
      placeholders = RenderTextUtils.layoutChildren(child);
    }

    final text = createObjectCallback(child as T, child.constraints, placeholders, currentPainterMaskingMode);

    _snapshotCanvas!.trackCommand(trackCommandCallback(text, clarity_text.Offset.fromDartOffset(offset)));

    // Only paint if has children, to paint the children and apply needed transformations to them.
    // To cover WidgetSpans for instance.
    if ((child as dynamic).childCount as int > 0) {
      _paintWithErrorHandling(child, offset);
    }

    return _getInlineSpanChildrenText(text.text);
  }

  String _getInlineSpanChildrenText(clarity_text.InlineSpan? span) {
    if (span is clarity_text.TextSpan) {
      final parts = <String>[];
      if (span.children != null) {
        for (final child in span.children!) {
          parts.add(_getInlineSpanChildrenText(child));
        }
      }
      return (span.text ?? '') + parts.join(' ');
    } else if (span is clarity_text.WidgetSpan) {
      return ''; // WidgetSpan does not contribute to text
    }
    return '';
  }

  // The following set of apis should not be called due to the [RenderObject.alwaysNeedsCompositing] skip,
  // however, if they get called for some reason we call [RenderObject.markNeedsPaint] on containing
  // render object to make sure we don't cause inconsistency in the RenderObject Tree.
  @override
  void pushLayer(
    ContainerLayer childLayer,
    PaintingContextCallback painter,
    Offset offset, {
    Rect? childPaintBounds,
  }) {
    Logger.warn?.out(
      'Pushing layer! Painter: ${currentPaintingObject?.runtimeType} ${childLayer.runtimeType} ${currentPaintingObject?.renderObject?.isRepaintBoundary}',
    );
    currentPaintingObject?.objectRef.target?.markNeedsPaint();
    onMarkNeedsPaint();
    painter(this, offset);
  }

  @override
  void appendLayer(Layer layer) {
    Logger.warn?.out('Append layer called! Painter: ${currentPaintingObject?.runtimeType}');
    currentPaintingObject?.renderObject?.markNeedsPaint();
    onMarkNeedsPaint();
  }

  @override
  void addLayer(Layer layer) {
    Logger.warn?.out('Add layer called! Painter: ${currentPaintingObject?.runtimeType}');
    currentPaintingObject?.renderObject?.markNeedsPaint();
    onMarkNeedsPaint();
  }

  @override
  ColorFilterLayer pushColorFilter(
    Offset offset,
    ColorFilter colorFilter,
    PaintingContextCallback painter, {
    ColorFilterLayer? oldLayer,
  }) {
    if (oldLayer == null) {
      currentPaintingObject?.renderObject?.markNeedsPaint();
      onMarkNeedsPaint();
      return super.pushColorFilter(offset, colorFilter, painter);
    }
    return oldLayer;
  }

  @override
  OpacityLayer pushOpacity(
    Offset offset,
    int alpha,
    PaintingContextCallback painter, {
    OpacityLayer? oldLayer,
  }) {
    if (oldLayer == null) {
      currentPaintingObject?.renderObject?.markNeedsPaint();
      onMarkNeedsPaint();
      return super.pushOpacity(offset, alpha, painter);
    }
    return oldLayer;
  }
}

// Used to bypass protection layer over [alwaysNeedsCompositing]
class ClarityObjectWrapper extends RenderObject {
  ClarityObjectWrapper(this.object);

  RenderObject object;

  @override
  bool get alwaysNeedsCompositing => object.alwaysNeedsCompositing;

  @override
  void debugAssertDoesMeetConstraints() {}

  @override
  Rect get paintBounds => throw UnimplementedError();

  @override
  void performLayout() {}

  @override
  void performResize() {}

  @override
  Rect get semanticBounds => throw UnimplementedError();
}
