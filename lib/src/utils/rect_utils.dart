/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:ui';

double tolerance = 0.5;

extension RectUtils on Rect {
  Rect getVisibleBounds(Rect containerRect) {
    final visibleRect = intersect(containerRect);
    return visibleRect;
  }

  bool isVisible() {
    return !(width < 0 || height < 0);
  }

  bool tolerantEqual(Rect other) {
    return (top - other.top).abs() <= tolerance &&
        (bottom - other.bottom).abs() <= tolerance &&
        (right - other.right).abs() <= tolerance &&
        (left - other.left).abs() <= tolerance;
  }

  String prodToString() =>
      'Rect.fromLTRB(${left.toStringAsFixed(1)}, ${top.toStringAsFixed(1)}, ${right.toStringAsFixed(1)}, ${bottom.toStringAsFixed(1)})';
}
