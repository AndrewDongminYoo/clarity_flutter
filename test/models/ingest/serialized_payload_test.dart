// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/ingest/serialized_payload.dart';

void main() {
  group('SerializedPayload.duration', () {
    test('calculates duration from max timestamp minus start', () {
      final payload = SerializedPayload(
        analytics: ['[100,1,data]', '[200,2,data]'],
        playback: ['[150,3,data]'],
        pageNum: 1,
        sequence: 1,
        start: 50,
      );

      // Max timestamp is 200, start is 50, duration = 150
      expect(payload.duration, 150);
    });

    test('uses playback timestamp if larger than analytics', () {
      final payload = SerializedPayload(
        analytics: ['[100,1,data]'],
        playback: ['[300,2,data]'],
        pageNum: 1,
        sequence: 1,
        start: 0,
      );

      expect(payload.duration, 300);
    });

    test('handles empty event lists', () {
      final payload = SerializedPayload(analytics: [], playback: [], pageNum: 1, sequence: 1, start: 100);

      // No events, max timestamp = 0, duration = 0 - 100 = -100
      expect(payload.duration, -100);
    });

    test('handles single event', () {
      final payload = SerializedPayload(analytics: ['[500,1,data]'], playback: [], pageNum: 1, sequence: 1, start: 200);

      expect(payload.duration, 300);
    });
  });

  group('SerializedPayload.eventType', () {
    test('extracts event type from event string', () {
      expect(SerializedPayload.eventType('[123,45,data]'), 45);
      expect(SerializedPayload.eventType('[0,1,data]'), 1);
      expect(SerializedPayload.eventType('[999999,100,data]'), 100);
    });

    test('handles event type with whitespace', () {
      expect(SerializedPayload.eventType('[123, 45 ,data]'), 45);
    });
  });
}
