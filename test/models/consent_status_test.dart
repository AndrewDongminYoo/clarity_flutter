// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/consent_status.dart';

void main() {
  group('ConsentSource', () {
    test('has expected ordinals that match Android/JS wire format', () {
      expect(ConsentSource.implicit.index, 0);
      expect(ConsentSource.api.index, 1);
    });

    test('has exactly three values', () {
      expect(ConsentSource.values.length, 3);
    });
  });

  group('ConsentStatus', () {
    test('stores fields correctly', () {
      const status = ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: false);

      expect(status.source, ConsentSource.api);
      expect(status.adsStorage, isTrue);
      expect(status.analyticsStorage, isFalse);
    });

    test('equality holds when all fields match', () {
      const a = ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: true);
      const b = ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: true);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when any field differs', () {
      const base = ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: true);

      expect(
        base == const ConsentStatus(source: ConsentSource.implicit, adsStorage: true, analyticsStorage: true),
        isFalse,
      );
      expect(
        base == const ConsentStatus(source: ConsentSource.api, adsStorage: false, analyticsStorage: true),
        isFalse,
      );
      expect(
        base == const ConsentStatus(source: ConsentSource.api, adsStorage: true, analyticsStorage: false),
        isFalse,
      );
    });

    test('toString contains field values', () {
      const status = ConsentStatus(source: ConsentSource.api, adsStorage: false, analyticsStorage: true);
      final str = status.toString();

      expect(str, contains('api'));
      expect(str, contains('false'));
      expect(str, contains('true'));
    });
  });
}
