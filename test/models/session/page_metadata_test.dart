// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/session/page_metadata.dart';
import 'package:clarity_flutter/src/models/session/session_metadata.dart';

void main() {
  group('PageMetadata', () {
    SessionMetadata createTestSession() {
      return SessionMetadata(
        1704067200000,
        'session-123',
        'project-abc',
        'user-xyz',
        'https://ingest.clarity.ms',
        '1.0.0',
      );
    }

    test('toJson serializes all fields including nested session', () {
      final session = createTestSession();
      final page = PageMetadata(3, 1704067300000, 'visible', 'ProfileScreen', session);

      final json = page.toJson();

      expect(json['number'], 3);
      expect(json['startTime'], 1704067300000);
      expect(json['lastVisibilityEventState'], 'visible');
      expect(json['screenName'], 'ProfileScreen');
      expect((json['session'] as Map<String, dynamic>)['id'], 'session-123');
      expect((json['session'] as Map<String, dynamic>)['projectId'], 'project-abc');
    });

    test('fromJson deserializes all fields including nested session', () {
      final json = {
        'number': 5,
        'startTime': 1704067400000,
        'lastVisibilityEventState': 'hidden',
        'screenName': 'SettingsScreen',
        'session': {
          'startTime': 1704067200000,
          'id': 'session-789',
          'projectId': 'proj-xyz',
          'userId': 'user-123',
          'ingestUrl': 'https://test.com',
          'version': '2.0.0',
        },
      };

      final page = PageMetadata.fromJson(json);

      expect(page.number, 5);
      expect(page.startTime, 1704067400000);
      expect(page.lastVisibilityEventState, 'hidden');
      expect(page.screenName, 'SettingsScreen');
      expect(page.session.id, 'session-789');
      expect(page.session.projectId, 'proj-xyz');
    });

    test('roundtrip serialization preserves all values', () {
      final session = createTestSession();
      final original = PageMetadata(10, 1704067500000, 'background', 'HomeScreen', session);

      final restored = PageMetadata.fromJson(original.toJson());

      expect(restored.number, original.number);
      expect(restored.startTime, original.startTime);
      expect(restored.lastVisibilityEventState, original.lastVisibilityEventState);
      expect(restored.screenName, original.screenName);
      expect(restored.session.id, original.session.id);
    });
  });
}
