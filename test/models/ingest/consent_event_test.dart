// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/consent_status.dart';
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/consent_event.dart';

void main() {
  group('ConsentEvent', () {
    test('type ordinal is 47 (wire-format parity with Android/JS)', () {
      expect(EventType.Consent.customOrdinal, 47);
    });

    test('serializes all-granted consent correctly', () {
      const status = ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: true);
      // timestamp=1000, pageTimestamp=500 → relTs = 1000-500 = 500
      final event = ConsentEvent(1000, status);
      final serialized = event.serialize(500);

      expect(serialized, '[500,47,1,1,1]');
    });

    test('serializes denied consent correctly', () {
      const status = ConsentStatus(source: ConsentSource.implicit, adsStorage: false, analyticsStorage: false);
      final event = ConsentEvent(2000, status);
      final serialized = event.serialize(1000);

      expect(serialized, '[1000,47,0,0,0]');
    });

    test('serializes api source with mixed values', () {
      const status = ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: false);
      final event = ConsentEvent(3000, status);
      final serialized = event.serialize(0);

      expect(serialized, '[3000,47,1,1,0]');
    });
  });
}
