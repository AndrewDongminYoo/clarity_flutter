// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/session/session_metadata.dart';

void main() {
  group('SessionMetadata', () {
    test('toJson serializes all fields correctly', () {
      final metadata = SessionMetadata(
        1704067200000,
        'session-123',
        'project-abc',
        'user-xyz',
        'https://ingest.clarity.ms',
        '1.0.0',
      );

      final json = metadata.toJson();

      expect(json['startTime'], 1704067200000);
      expect(json['id'], 'session-123');
      expect(json['projectId'], 'project-abc');
      expect(json['userId'], 'user-xyz');
      expect(json['ingestUrl'], 'https://ingest.clarity.ms');
      expect(json['version'], '1.0.0');
    });

    test('fromJson deserializes all fields correctly', () {
      final json = {
        'startTime': 1704067200000,
        'id': 'session-456',
        'projectId': 'proj-def',
        'userId': 'usr-abc',
        'ingestUrl': 'https://test.ingest.com',
        'version': '3.2.1',
      };

      final metadata = SessionMetadata.fromJson(json);

      expect(metadata.startTime, 1704067200000);
      expect(metadata.id, 'session-456');
      expect(metadata.projectId, 'proj-def');
      expect(metadata.userId, 'usr-abc');
      expect(metadata.ingestUrl, 'https://test.ingest.com');
      expect(metadata.version, '3.2.1');
    });

    test('roundtrip serialization preserves all values', () {
      final original = SessionMetadata(
        1704067200000,
        'session-roundtrip',
        'project-rt',
        'user-rt',
        'https://roundtrip.com',
        '2.0.0',
      );

      final restored = SessionMetadata.fromJson(original.toJson());

      expect(restored.startTime, original.startTime);
      expect(restored.id, original.id);
      expect(restored.projectId, original.projectId);
      expect(restored.userId, original.userId);
      expect(restored.ingestUrl, original.ingestUrl);
      expect(restored.version, original.version);
    });
  });
}
