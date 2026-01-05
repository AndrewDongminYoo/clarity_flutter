/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:math';

class SerializedPayload {
  SerializedPayload({
    required this.analytics,
    required this.playback,
    required this.pageNum,
    required this.sequence,
    required this.start,
  });

  final List<String> analytics;
  final List<String> playback;
  final int pageNum;
  final int sequence;
  final int start;

  late final int duration = _calculateDuration();

  int _calculateDuration() {
    var maxTimestamp = 0;

    void updateTimestamps(List<String> events) {
      for (final event in events) {
        final timestamp = _getEventTimestamp(event);
        maxTimestamp = max(maxTimestamp, timestamp);
      }
    }

    updateTimestamps(analytics);
    updateTimestamps(playback);

    return maxTimestamp - start;
  }

  int _getEventTimestamp(String event) {
    return int.parse(event.substring(1, event.indexOf(',')));
  }

  static int eventType(String event) {
    final firstComma = event.indexOf(',');
    final secondComma = event.indexOf(',', firstComma + 1);

    // Extract the substring between the first and second commas
    final eventType = event.substring(firstComma + 1, secondComma).trim();

    return int.parse(eventType);
  }
}
