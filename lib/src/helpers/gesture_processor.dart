/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:collection';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/display/display_frame.dart';
import 'package:clarity_flutter/src/models/ingest/ingest.dart';
import 'package:clarity_flutter/src/models/view_hierarchy/view_hierarchy.dart';
import 'package:clarity_flutter/src/models/view_hierarchy/view_node.dart';
import 'package:clarity_flutter/src/utils/dev_utils.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';
import 'package:clarity_flutter/src/utils/string_utils.dart';

class GestureProcessor {
  ViewHierarchy? _lastViewHierarchy;
  double? _lastDPR;

  void updateFrameState(DisplayFrame newFrame) {
    _lastViewHierarchy = newFrame.viewHierarchy;
    _lastDPR = newFrame.dpr;
  }

  void updateGestureEvent(GestureEvent event) {
    if (_lastViewHierarchy == null || _lastDPR == null) return;
    if (event is Click) {
      profileTimeSync('ClarityClickProcessing', () => _updateAnalyticsClickEvent(event));
    }

    _updateEventCoordinationToGlobal(event);
  }

  void _updateAnalyticsClickEvent(Click event) {
    final clickedViewNode = _getEstimatedClickedViewNode(_lastViewHierarchy!.root, event, 0);

    event.text = _resolveEventText(event, clickedViewNode);
    event.reaction = !clickedViewNode.isPathClickable;
    event.nodeSelector = clickedViewNode.selectorPath.join();
    event.nodeBounds = clickedViewNode.node.nodeBounds;
    Logger.info?.out('Click Target Event Text: ${event.text}');

    _updateRelativePoints(event);
  }

  String _resolveEventText(Click event, ClickedViewNode clickedNode) {
    final nodeText = clickedNode.node.text;
    if (!nodeText.hasStrangeText) return nodeText;

    final treeText = _getLongestTextInNodeTree(clickedNode.node, Offset(event.absX, event.absY));
    if (!treeText.hasStrangeText) return treeText;

    // Content description fallback
    if (clickedNode.isPathClickable) {
      return _findNearestContentDescriptionInSubtree(clickedNode.node) ??
          clickedNode.nearestContentDescription ??
          treeText;
    }
    return clickedNode.nearestContentDescription ?? treeText;
  }

  /// Recursively finds the best-matching clicked node, prioritizing clickable children
  /// and using area as a tiebreaker. Builds a selector path for analytics.
  ClickedViewNode _getEstimatedClickedViewNode(ViewNode node, Click event, int index) {
    ClickedViewNode? clickedChild;

    final typeIdIndexMap = <(String, int), int>{};
    final childClickCandidateArray = <ClickedViewNode>[];

    for (final child in node.children.reversed) {
      final typeIdPair = (child.type, child.id);
      final childIndex = typeIdIndexMap[typeIdPair] ?? 0;

      if (!child.isRoot() && _checkPointWithinBounds(Offset(event.absX, event.absY), child.nodeBounds)) {
        clickedChild = _getEstimatedClickedViewNode(child, event, childIndex);
        clickedChild.prependNodeSelector(node.type, node.id, index);
        childClickCandidateArray.add(clickedChild);
      }

      typeIdIndexMap[typeIdPair] = childIndex + 1;
    }
    ClickedViewNode? clickedViewNode;
    final clickableChildren = childClickCandidateArray.where((c) => c.isPathClickable).toList();

    if (clickableChildren.isNotEmpty) {
      // Priority: clickable children in range, the first one visually on top
      clickedViewNode = clickableChildren.first;
    } else if (node.clickable || childClickCandidateArray.isEmpty) {
      // If current node is clickable or no children in range, return current node
      clickedViewNode = ClickedViewNode(node, index, node.clickable);
    } else {
      // Otherwise, return smallest un-clickable child in range
      childClickCandidateArray.sort((a, b) => a.nodeArea.compareTo(b.nodeArea));
      clickedViewNode = childClickCandidateArray.first;
    }

    _updateClickedNodeContentDescription(node, clickedViewNode);
    return clickedViewNode;
  }

  /// Captures the nearest ancestor's content description during traversal.
  void _updateClickedNodeContentDescription(ViewNode node, ClickedViewNode clickedNode) {
    if (clickedNode.nearestContentDescription == null && (node.contentDescription?.isNotEmpty ?? false)) {
      clickedNode.nearestContentDescription = node.contentDescription;
    }
  }

  void _updateRelativePoints(Click event) {
    final relativeX =
        ((event.absX - event.nodeBounds!.left) / event.nodeBounds!.width) * ClarityConstants.clickPrecision;
    final relativeY =
        ((event.absY - event.nodeBounds!.top) / event.nodeBounds!.height) * ClarityConstants.clickPrecision;

    event.relativeX = max(relativeX.floor(), 0);
    event.relativeY = max(relativeY.floor(), 0);
  }

  String _getLongestTextInNodeTree(ViewNode node, Offset point) {
    var longestText = node.text;

    for (final child in node.children) {
      final childText = _getLongestTextInNodeTree(child, point);
      if (childText.length > longestText.length) {
        longestText = childText;
      }
    }

    return longestText;
  }

  String? _findNearestContentDescriptionInSubtree(ViewNode node) {
    final queue = Queue<ViewNode>()..add(node);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current.contentDescription?.isNotEmpty ?? false) {
        return current.contentDescription;
      }
      queue.addAll(current.children);
    }
    return null;
  }

  bool _checkPointWithinBounds(Offset point, Rect bounds) {
    return bounds.contains(point);
  }

  void _updateEventCoordinationToGlobal(GestureEvent event) {
    event.absX = event.absX * _lastDPR!;
    event.absY = event.absY * _lastDPR!;
  }
}

class ClickedViewNode {
  ClickedViewNode(this.node, this.index, this.isPathClickable, [List<String>? selectorPath])
    : selectorPath = selectorPath ?? [] {
    prependNodeSelector(node.type, node.id, index);
  }
  final ViewNode node;
  final int index;
  final bool isPathClickable;
  final List<String> selectorPath;

  String? nearestContentDescription;
  int get nodeArea => node.width * node.height;

  /// Prepends a selector segment for the current node to the selector path.
  /// This helps uniquely identify the node in the view hierarchy.
  void prependNodeSelector(String type, int id, int index) {
    if (id != -1) {
      selectorPath.insert(0, '/$type#$id[$index]');
    } else {
      selectorPath.insert(0, '/$type[$index]');
    }
  }
}
