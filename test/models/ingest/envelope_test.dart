// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/ingest/envelope.dart';
import 'package:clarity_flutter/src/registries/host_info.dart';

void main() {
  group('Envelope', () {
    test('constructor sets all fields including defaults', () {
      final envelope = Envelope('proj', 'user', 'sess', 1, 2, 1000, 500);

      expect(envelope.projectId, 'proj');
      expect(envelope.userId, 'user');
      expect(envelope.sessionId, 'sess');
      expect(envelope.pageNum, 1);
      expect(envelope.sequence, 2);
      expect(envelope.start, 1000);
      expect(envelope.duration, 500);
      expect(envelope.upload, 0);
      expect(envelope.end, 0);
      expect(envelope.version, ClarityConstants.clarityVersion);
      expect(envelope.platform, ApplicationPlatform.getCurrentPlatform().index);
    });

    test('serialize produces correct JSON array format', () {
      final envelope = Envelope('abc123', 'user-xyz', 'session-001', 3, 15, 1704067200000, 30000);
      final platform = ApplicationPlatform.getCurrentPlatform().index;

      final serialized = envelope.serialize();

      expect(
        serialized,
        '["${ClarityConstants.clarityVersion}",15,1704067200000,30000,"abc123","user-xyz","session-001",3,0,0,$platform]',
      );
    });

    test('serialize escapes special characters', () {
      // Quotes
      var envelope = Envelope('proj"ect', 'us"er', 'ses"s', 1, 1, 0, 0);
      var serialized = envelope.serialize();
      expect(serialized, contains(r'proj\"ect'));
      expect(serialized, contains(r'us\"er'));
      expect(serialized, contains(r'ses\"s'));

      // Backslashes
      envelope = Envelope(r'proj\ect', 'user', 'sess', 1, 1, 0, 0);
      serialized = envelope.serialize();
      expect(serialized, contains(r'proj\\ect'));
    });

    test('serialize handles edge cases', () {
      // Empty strings
      var envelope = Envelope('', '', '', 0, 0, 0, 0);
      expect(envelope.serialize(), contains('""'));

      // Large numbers
      envelope = Envelope('p', 'u', 's', 999999, 999999, 9999999999999, 9999999999);
      final serialized = envelope.serialize();
      expect(serialized, contains('9999999999999'));
    });
  });
}
