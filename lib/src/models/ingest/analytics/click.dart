/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:ui';

// Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/gesture_event.dart';
import 'package:clarity_flutter/src/models/view_hierarchy/view_node.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

class Click extends GestureEvent {
  Click(int timestamp, double absX, double absY, this.viewId)
    : super(
        timestamp,
        EventType.Click,
        absX,
        absY,
        0, // Ignore it, we don't use the pointerId for the click events
      );
  int relativeX = 0;
  int relativeY = 0;
  bool? reaction;
  int viewId = 0;
  Rect? nodeBounds;
  String? nodeSelector;
  final ViewNodeText _text = ViewNodeText('');

  set text(String value) {
    _text.text = value;
  }

  String get text => _text.text;

  bool get isFullText => _text.isFullText;

  @override
  String serialize(int pageTimestamp) {
    final hash = viewId.toRadixString(36);
    return '['
        '${relativeTimestamp(pageTimestamp)},'
        '${type.customOrdinal},'
        '$viewId,'
        '${absX.round()},'
        '${absY.round()},'
        '$relativeX,'
        '$relativeY,'
        '0,' // Ignore button
        '${reaction ?? false ? 1 : 0},'
        '0,' // Ignore context
        '"${DataUtils.escape(text)}",'
        'null,' // Ignore link
        '"$hash.${hashViewNodeSelector(nodeSelector)}",'
        '1,' // trust
        '-2,' // webview id
        '-2,' // webview render node id
        '${isFullText ? 1 : 0}'
        ']';
  }

  @override
  String getDebugInfo() {
    return 'Click(timestamp: $timestamp, absX: $absX, absY: $absY, nodeSelector: $nodeSelector, reaction: $reaction, nodeBounds: $nodeBounds, viewId: $viewId, text: $text)';
  }
}

String? hashViewNodeSelector(String? selector) {
  if (selector == null) return null;

  // Logic ported from ClarityJS hashing functions.
  var hashOne = 5381;
  var hashTwo = hashOne;

  for (var i = 0; i < selector.length; i += 2) {
    final charOne = selector[i];
    hashOne = (((hashOne << 5) + hashOne) ^ charOne.codeUnits[0]).toSigned(32);

    if (i + 1 < selector.length) {
      final charTwo = selector[i + 1];
      hashTwo = (((hashTwo << 5) + hashTwo) ^ charTwo.codeUnits[0]).toSigned(32);
    }
  }

  return (hashOne + (hashTwo * 11579)).abs().toRadixString(36);
}
