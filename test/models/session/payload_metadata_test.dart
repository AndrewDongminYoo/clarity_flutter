// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/session/page_metadata.dart';
import 'package:clarity_flutter/src/models/session/payload_metadata.dart';
import 'package:clarity_flutter/src/models/session/session_metadata.dart';

void main() {
  late SessionMetadata session;
  late PageMetadata page;

  setUp(() {
    session = SessionMetadata(1000, 'session-123', 'project-456', 'user-789', 'https://ingest.example.com', '1.0.0');
    page = PageMetadata(1, 2000, 'visible', 'HomeScreen', session);
  });

  group('PayloadMetadata.maxPayloadDuration', () {
    test('calculates duration with increment for sequence 0', () {
      final payload = PayloadMetadata(page: page, sequence: 0, start: 0, startTimeRelativeToPage: 0);

      // sequence * 1000 = 0, clamped to [0, 30000]
      expect(payload.maxPayloadDuration, 0);
    });

    test('calculates duration with increment for sequence 5', () {
      final payload = PayloadMetadata(page: page, sequence: 5, start: 0, startTimeRelativeToPage: 0);

      // sequence * 1000 = 5000
      expect(payload.maxPayloadDuration, 5000);
    });

    test('clamps duration to max when sequence is very large', () {
      final payload = PayloadMetadata(page: page, sequence: 50, start: 0, startTimeRelativeToPage: 0);

      // sequence * 1000 = 50000, clamped to maxPayloadDurationInMs (30000)
      expect(payload.maxPayloadDuration, ClarityConstants.maxPayloadDurationInMs);
    });

    test('clamps duration at exactly max threshold', () {
      final payload = PayloadMetadata(page: page, sequence: 30, start: 0, startTimeRelativeToPage: 0);

      // sequence * 1000 = 30000, equals maxPayloadDurationInMs
      expect(payload.maxPayloadDuration, 30000);
    });
  });

  group('PayloadMetadata.updateDuration', () {
    test('sets initial duration based on event timestamp', () {
      final payload = PayloadMetadata(page: page, sequence: 1, start: 500, startTimeRelativeToPage: 500);

      // Event at 3000ms, page starts at 2000ms, payload starts at 500ms relative to page
      // eventPageRelativeTimestamp = 3000 - 2000 = 1000
      // duration = 1000 - 500 = 500
      payload.updateDuration(3000, EventType.Click);

      expect(payload.duration, 500);
    });

    test('updates duration to maximum of existing and new duration', () {
      final payload = PayloadMetadata(page: page, sequence: 1, start: 500, startTimeRelativeToPage: 500);

      payload.updateDuration(3000, EventType.Click);
      expect(payload.duration, 500);

      // New event at 4000ms
      // eventPageRelativeTimestamp = 4000 - 2000 = 2000
      // duration = max(500, 2000 - 500) = 1500
      payload.updateDuration(4000, EventType.Mutation);
      expect(payload.duration, 1500);
    });

    test('does not decrease duration when earlier event comes after', () {
      final payload = PayloadMetadata(page: page, sequence: 1, start: 500, startTimeRelativeToPage: 500);

      payload.updateDuration(4000, EventType.Click);
      expect(payload.duration, 1500);

      // Earlier event at 3000ms should not decrease duration
      payload.updateDuration(3000, EventType.Click);
      expect(payload.duration, 1500);
    });

    test('sets nextFlushDueAt for non-Baseline events', () {
      final payload = PayloadMetadata(page: page, sequence: 1, start: 500, startTimeRelativeToPage: 500);

      payload.updateDuration(3000, EventType.Click);

      // nextFlushDueAt = eventTimestamp + minEventDelayToFlushPayloadMs
      expect(payload.nextFlushDueAt, 3000 + ClarityConstants.minEventDelayToFlushPayloadMs);
    });

    test('does not set nextFlushDueAt for Baseline events', () {
      final payload = PayloadMetadata(page: page, sequence: 1, start: 500, startTimeRelativeToPage: 500);

      payload.updateDuration(3000, EventType.Baseline);

      expect(payload.nextFlushDueAt, isNull);
    });

    test('updates nextFlushDueAt when multiple non-Baseline events occur', () {
      final payload = PayloadMetadata(page: page, sequence: 1, start: 500, startTimeRelativeToPage: 500);

      payload.updateDuration(3000, EventType.Click);
      final firstFlushDueAt = payload.nextFlushDueAt;

      payload.updateDuration(4000, EventType.Mutation);
      final secondFlushDueAt = payload.nextFlushDueAt;

      expect(firstFlushDueAt, 3000 + ClarityConstants.minEventDelayToFlushPayloadMs);
      expect(secondFlushDueAt, 4000 + ClarityConstants.minEventDelayToFlushPayloadMs);
      expect(secondFlushDueAt! > firstFlushDueAt!, true);
    });
  });

  group('PayloadMetadata getters', () {
    test('provides access to session and page properties', () {
      final payload = PayloadMetadata(page: page, sequence: 1, start: 0, startTimeRelativeToPage: 0);

      expect(payload.projectId, 'project-456');
      expect(payload.sessionId, 'session-123');
      expect(payload.userId, 'user-789');
      expect(payload.ingestUrl, 'https://ingest.example.com');
      expect(payload.pageNumber, 1);
      expect(payload.pageStartTime, 2000);
    });
  });
}
