// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/data_utils.dart';

void main() {
  group('DataUtils.escape', () {
    test('escapes quotes, backslashes, and new lines', () {
      const original = 'He said: "ok"\nNext line\\path\r\n"done"';
      const expected = r'He said: \"ok\" Next line\\path \"done\"';
      expect(DataUtils.escape(original), expected);
    });

    test('returns empty string for empty input', () {
      expect(DataUtils.escape(''), '');
    });

    test('returns unchanged string when no escaping needed', () {
      const input = 'Hello World';
      expect(DataUtils.escape(input), input);
    });

    test('escapes only quotes', () {
      const original = '"quoted"';
      const expected = r'\"quoted\"';
      expect(DataUtils.escape(original), expected);
    });

    test('escapes only backslashes', () {
      const original = r'path\to\file';
      const expected = r'path\\to\\file';
      expect(DataUtils.escape(original), expected);
    });

    test('handles multiple consecutive special characters', () {
      const original = '""\n\n\\\\"';
      expect(DataUtils.escape(original), contains(r'\"'));
      expect(DataUtils.escape(original), contains(r'\\'));
    });

    test('handles Unicode characters without escaping', () {
      const original = 'Hello 世界 🌍';
      expect(DataUtils.escape(original), original);
    });
  });

  group('DataUtils.encodeBase64', () {
    test('matches standard base64 encoding and trim behavior', () {
      final payload = utf8.encode('clarity');
      final expected = base64Encode(payload).trim();
      expect(DataUtils.encodeBase64(payload), expected);
    });

    test('supports url safe encoding', () {
      final payload = utf8.encode('+/foobar');
      final expected = base64UrlEncode(payload).trim();
      expect(DataUtils.encodeBase64(payload, urlSafe: true), expected);
    });

    test('returns empty string for empty byte array', () {
      expect(DataUtils.encodeBase64([]), '');
    });

    test('encodes single byte', () {
      final result = DataUtils.encodeBase64([65]); // 'A'
      expect(result, isNotEmpty);
      expect(result, 'QQ==');
    });

    test('handles binary data with all byte values', () {
      final bytes = List<int>.generate(256, (i) => i);
      final result = DataUtils.encodeBase64(bytes);
      expect(result, isNotEmpty);
      // Verify it can be decoded back
      expect(base64Decode(result), bytes);
    });
  });

  group('DataUtils.xxHashBase64', () {
    test('returns base64url xxHash hash for given bytes', () {
      final bytes = utf8.encode('abc');
      expect(DataUtils.xxHashBase64(bytes), 'UDkviZRfr3g=');
    });

    test('returns consistent hash for same input', () {
      final bytes = utf8.encode('test');
      final hash1 = DataUtils.xxHashBase64(bytes);
      final hash2 = DataUtils.xxHashBase64(bytes);
      expect(hash1, hash2);
    });

    test('returns different hash for different input', () {
      final hash1 = DataUtils.xxHashBase64(utf8.encode('abc'));
      final hash2 = DataUtils.xxHashBase64(utf8.encode('def'));
      expect(hash1, isNot(equals(hash2)));
    });

    test('handles empty byte array', () {
      final result = DataUtils.xxHashBase64([]);
      expect(result, isNotEmpty);
      // Verify consistent hash for empty input
      expect(result, DataUtils.xxHashBase64([]));
    });
  });
}
