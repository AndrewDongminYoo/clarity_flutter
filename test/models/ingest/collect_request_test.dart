// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/ingest/collect_request.dart';
import 'package:clarity_flutter/src/models/ingest/envelope.dart';

void main() {
  group('CollectRequest.serialize', () {
    test('produces correct JSON structure', () {
      final envelope = Envelope('proj', 'user', 'sess', 1, 1, 1000, 500);
      final request = CollectRequest(envelope, ['[100,1,a]', '[200,2,b]'], ['[150,3,p]']);

      final serialized = request.serialize();

      // Verify structure
      expect(serialized, startsWith('{"e":'));
      expect(serialized, contains('"a":['));
      expect(serialized, contains('"p":['));
      expect(serialized, endsWith('}'));

      // Verify analytics array
      expect(serialized, contains('[100,1,a],[200,2,b]'));

      // Verify playback array
      expect(serialized, contains('[150,3,p]'));
    });

    test('handles empty analytics and playback arrays', () {
      final envelope = Envelope('proj', 'user', 'sess', 1, 1, 0, 0);
      final request = CollectRequest(envelope, [], []);

      final serialized = request.serialize();

      expect(serialized, contains('"a":[]'));
      expect(serialized, contains('"p":[]'));
    });

    test('handles single item in arrays', () {
      final envelope = Envelope('p', 'u', 's', 1, 1, 0, 0);
      final request = CollectRequest(envelope, ['[1,1,x]'], ['[2,2,y]']);

      final serialized = request.serialize();

      expect(serialized, contains('"a":[[1,1,x]]'));
      expect(serialized, contains('"p":[[2,2,y]]'));
    });
  });
}
