// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/gaid_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/gaid_opt_out_event.dart';

void main() {
  group('GAIDEvent', () {
    test('type ordinal is 108 (wire-format parity with Android/JS)', () {
      expect(EventType.GAID.customOrdinal, 108);
    });

    test('serializes gaid string with correct ordinal', () {
      final event = GAIDEvent(1500, 'abc-1234-xyz');
      final serialized = event.serialize(500);

      // relTs = 1500-500 = 1000
      expect(serialized, '[1000,108,"abc-1234-xyz"]');
    });

    test('escapes quotes inside the gaid string', () {
      // DataUtils.escape should handle special chars.
      final event = GAIDEvent(1000, 'id"with"quotes');
      final serialized = event.serialize(0);

      expect(serialized, contains(r'"id\"with\"quotes"'));
    });
  });

  group('GAIDOptOutEvent', () {
    test('type ordinal is 109 (wire-format parity with Android/JS)', () {
      expect(EventType.GAIDOptOut.customOrdinal, 109);
    });

    test('serializes gaid string with correct ordinal', () {
      final event = GAIDOptOutEvent(2000, 'opt-out-id');
      final serialized = event.serialize(1000);

      // relTs = 2000-1000 = 1000
      expect(serialized, '[1000,109,"opt-out-id"]');
    });
  });
}
