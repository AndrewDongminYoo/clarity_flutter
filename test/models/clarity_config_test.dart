// ignore_for_file: deprecated_member_use_from_same_package

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/clarity_config.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

void main() {
  group('ClarityConfig.isProjectIdValid', () {
    test('returns false for empty or whitespace-only ids', () {
      expect(ClarityConfig(projectId: '').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: '   ').isProjectIdValid(), isFalse);
    });

    test('returns true for valid lowercase base36 projectId', () {
      expect(ClarityConfig(projectId: 'pid').isProjectIdValid(), isTrue);
      expect(ClarityConfig(projectId: 'abc123').isProjectIdValid(), isTrue);
      expect(ClarityConfig(projectId: '1').isProjectIdValid(), isTrue);
    });

    test('returns false for uppercase projectId', () {
      expect(ClarityConfig(projectId: 'PID').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'Abc123').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'ABC').isProjectIdValid(), isFalse);
    });

    test('returns false for projectId with invalid characters', () {
      expect(ClarityConfig(projectId: 'abc-123').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'abc_123').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'abc.123').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'abc 123').isProjectIdValid(), isFalse);
    });

    test('returns true for numeric-only projectId', () {
      expect(ClarityConfig(projectId: '0').isProjectIdValid(), isTrue);
      expect(ClarityConfig(projectId: '123456').isProjectIdValid(), isTrue);
    });

    test('returns false for projectId with leading/trailing whitespace', () {
      expect(ClarityConfig(projectId: ' abc').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'abc ').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: ' abc ').isProjectIdValid(), isFalse);
    });

    test('returns true for single character projectId', () {
      expect(ClarityConfig(projectId: 'a').isProjectIdValid(), isTrue);
      expect(ClarityConfig(projectId: 'z').isProjectIdValid(), isTrue);
    });

    test('returns false for projectId with symbols', () {
      expect(ClarityConfig(projectId: '@abc').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'abc!').isProjectIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'abc#123').isProjectIdValid(), isFalse);
    });
  });

  group('ClarityConfig.isUserIdValid', () {
    test('accepts null user ids', () {
      expect(ClarityConfig(projectId: 'pid').isUserIdValid(), isTrue);
    });

    test('accepts lower-case base36 ids within range', () {
      final config = ClarityConfig(projectId: 'pid', userId: '1z141z3');
      expect(config.isUserIdValid(), isTrue);
    });

    test('rejects uppercase characters or out of range ids', () {
      expect(ClarityConfig(projectId: 'pid', userId: 'ABC123').isUserIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'pid', userId: '1z141z4').isUserIdValid(), isFalse);
      expect(ClarityConfig(projectId: 'pid', userId: '0').isUserIdValid(), isFalse);
    });

    test('accepts minimum valid userId (1)', () {
      final config = ClarityConfig(projectId: 'pid', userId: '1');
      expect(config.isUserIdValid(), isTrue);
    });

    test('rejects userId at exact upper boundary (1z141z4)', () {
      final config = ClarityConfig(projectId: 'pid', userId: '1z141z4');
      expect(config.isUserIdValid(), isFalse);
    });

    test('accepts userId just below upper boundary (1z141z3)', () {
      final config = ClarityConfig(projectId: 'pid', userId: '1z141z3');
      expect(config.isUserIdValid(), isTrue);
    });

    test('rejects empty string userId', () {
      final config = ClarityConfig(projectId: 'pid', userId: '');
      expect(config.isUserIdValid(), isFalse);
    });

    test('rejects whitespace-only userId', () {
      final config = ClarityConfig(projectId: 'pid', userId: '   ');
      expect(config.isUserIdValid(), isFalse);
    });

    test('rejects mixed case userId', () {
      final config = ClarityConfig(projectId: 'pid', userId: 'aBc123');
      expect(config.isUserIdValid(), isFalse);
    });

    test('rejects userId with invalid characters', () {
      final config = ClarityConfig(projectId: 'pid', userId: 'abc-123');
      expect(config.isUserIdValid(), isFalse);
    });
  });

  group('ClarityConfig.isLogLevelValid', () {
    test('respects provided log level in debug mode', () {
      final config = ClarityConfig(projectId: 'pid', logLevel: LogLevel.Error);
      expect(config.isLogLevelValid(), isTrue);
    });
  });
}
