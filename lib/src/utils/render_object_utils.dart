/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'package:flutter/rendering.dart';
import '../models/masking.dart';
import '../utils/dev_utils.dart';
import '../widgets/masking_widgets.dart';
import '../observers/clarity_gesture_observer.dart';

// Render object types to ignore in Painting and View Hierarchy definition (and selector as well)
List<Type> ignoredRenderObjects = [];
Type? snapShotWidgetRenderObject;

void initializeSkippedRenderObjects() {
  if (DebuggingUtils.instance?.paintIgnoredObjects ?? false) return;

  ignoredRenderObjects = [
    RenderIgnorePointer,
    RenderAbsorbPointer,
    RenderSemanticsAnnotations,
    RenderMetaData,
    ClarityRenderPointerListener,
    ClarityMaskRenderObject,
    ClarityUnmaskRenderObject,
  ];

  // Work around for snapshot widget renderObject, ensuring masking correctness
  if (snapShotWidgetRenderObject != null) {
    ignoredRenderObjects.add(snapShotWidgetRenderObject!);
  }
}

extension RenderObjectUtils on RenderObject {
  RenderObject? getParent() {
    // We may have [AbstractNode @Deprecated] as a parent of a render object node (Exists in older versions - From 3.10.*) so we skip it
    dynamic parentObject = parent;
    while (parentObject is! RenderObject && parentObject != null) {
      parentObject = (parentObject as dynamic)?.parent;
    }
    return parentObject as RenderObject?;
  }

  Rect globalPaintBounds(RenderObject? parent) => MatrixUtils.transformRect(getTransformTo(parent), paintBounds);

  bool isClickable() {
    if (parent is RenderSemanticsAnnotations) {
      final renderSemanticsParent = parent! as RenderSemanticsAnnotations;

      return (renderSemanticsParent.properties.button != null) ||
          (renderSemanticsParent.properties.onTap != null) ||
          (renderSemanticsParent.properties.link != null);
    } else if (parent is RenderSemanticsGestureHandler) {
      final renderSemanticsParent = parent! as RenderSemanticsGestureHandler;

      return (renderSemanticsParent.onTap != null) || (renderSemanticsParent.onLongPress != null);
    }

    return false;
  }

  int getIndexAmongSameSiblingsType() {
    var index = 0;
    var counter = 0;

    final parent = getParent();
    parent?.visitChildren((child) {
      if (identical(child.hashCode, hashCode)) index = counter;
      if (child.runtimeType == runtimeType) counter++;
    });

    return index;
  }

  MaskingState? getExplicitMasking() {
    MaskingState? explicitMasking;

    RenderObject? current = this;

    while (current != null) {
      if (current is ClarityMaskRenderObject) {
        explicitMasking = MaskingState.masking;
      } else if (current is ClarityUnmaskRenderObject) {
        explicitMasking = MaskingState.unmasking;
      }

      if (explicitMasking != null) {
        break;
      }

      current = current.getParent();
    }

    return explicitMasking;
  }

  bool isSafeToPaint() {
    if (!attached) return false;
    if (this is RenderBox && !(this as RenderBox).hasSize) return false;
    return true;
  }
}

// This class is made to be used only for RenderParagraph and RenderEditable
// Since they have no common parent with the [firstChild] and [childAfter] methods, we have to use dynamic here
abstract final class RenderTextUtils {
  static List<PlaceholderDimensions> layoutChildren(dynamic obj) {
    return <PlaceholderDimensions>[
      for (
        RenderBox? child = (obj as dynamic).firstChild as RenderBox?;
        child != null;
        child = (obj as dynamic).childAfter(child) as RenderBox?
      )
        _layoutChild(child, ((obj as dynamic).constraints as BoxConstraints).maxWidth),
    ];
  }

  static PlaceholderDimensions _layoutChild(RenderBox child, double maxWidth) {
    final parentData = child.parentData! as TextParentData;
    final span = parentData.span;
    return span == null
        ? PlaceholderDimensions.empty
        : PlaceholderDimensions(
            size: ChildLayoutHelper.layoutChild(child, BoxConstraints(maxWidth: maxWidth)),
            alignment: span.alignment,
            baseline: span.baseline,
            baselineOffset: switch (span.alignment) {
              PlaceholderAlignment.aboveBaseline ||
              PlaceholderAlignment.belowBaseline ||
              PlaceholderAlignment.bottom ||
              PlaceholderAlignment.middle ||
              PlaceholderAlignment.top => null,
              PlaceholderAlignment.baseline => child.getDistanceToBaseline(span.baseline!),
            },
          );
  }
}
