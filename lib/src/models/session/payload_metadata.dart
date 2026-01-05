/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:math';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/session/page_metadata.dart';

class PayloadMetadata {
  PayloadMetadata({
    required this.page,
    required this.sequence,
    required this.start,
    required this.startTimeRelativeToPage,
  });

  PageMetadata page;
  final int sequence;

  // Start time relative to the previous payload in the same page
  final int start;
  int? duration;

  // This indicates the actual payload start time relative to the page
  int startTimeRelativeToPage;

  String get projectId => page.session.projectId;

  String get sessionId => page.session.id;

  String get userId => page.session.userId;

  String get ingestUrl => page.session.ingestUrl;

  int get pageNumber => page.number;

  int get pageStartTime => page.startTime;

  int get maxPayloadDuration =>
      (sequence * ClarityConstants.payloadDurationIncrementInMs).clamp(0, ClarityConstants.maxPayloadDurationInMs);

  void updateDuration(int eventTimestamp) {
    final eventPageRelativeTimestamp = eventTimestamp - pageStartTime;
    duration = max(duration ?? 0, eventPageRelativeTimestamp - start);
  }

  @override
  String toString() {
    return 'PayloadMetadata(sessionId: ${page.session.id}, pageNum: ${page.number}, sequence: $sequence, start: $start, startTimeRelativeToPage: $startTimeRelativeToPage)';
  }
}
