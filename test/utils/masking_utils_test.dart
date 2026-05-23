// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/masking.dart';
import 'package:clarity_flutter/src/utils/masking_utils.dart';

void main() {
  group('MaskingUtils.determineMaskingMode', () {
    // Parameterized masking mode determination tests
    final maskingModeCases = [
      (
        state: MaskingState.masking,
        projectDefault: MaskingMode.relaxed,
        expected: MaskingMode.strict,
        description: 'explicit masking overrides to strict',
      ),
      (
        state: MaskingState.masking,
        projectDefault: MaskingMode.balanced,
        expected: MaskingMode.strict,
        description: 'explicit masking overrides balanced to strict',
      ),
      (
        state: MaskingState.unmasking,
        projectDefault: MaskingMode.strict,
        expected: MaskingMode.relaxed,
        description: 'explicit unmasking overrides to relaxed',
      ),
      (
        state: MaskingState.unmasking,
        projectDefault: MaskingMode.balanced,
        expected: MaskingMode.relaxed,
        description: 'explicit unmasking overrides balanced to relaxed',
      ),
    ];

    for (final testCase in maskingModeCases) {
      test(testCase.description, () {
        final mode = MaskingUtils.determineMaskingMode(testCase.state, testCase.projectDefault);
        expect(mode, testCase.expected);
      });
    }

    // Parameterized null state (uses project default) tests
    final nullStateCases = [
      (projectDefault: MaskingMode.relaxed, description: 'relaxed'),
      (projectDefault: MaskingMode.balanced, description: 'balanced'),
      (projectDefault: MaskingMode.strict, description: 'strict'),
    ];

    for (final testCase in nullStateCases) {
      test('returns project default ${testCase.description} when state is null', () {
        final mode = MaskingUtils.determineMaskingMode(null, testCase.projectDefault);
        expect(mode, testCase.projectDefault);
      });
    }
  });

  group('MaskingUtils.maskText', () {
    group('relaxed mode', () {
      test('returns original text unchanged', () {
        final result = MaskingUtils.maskText(MaskingMode.relaxed, 'Hello World', 14);
        expect(result, 'Hello World');
      });

      test('does not mask PII in relaxed mode', () {
        final result = MaskingUtils.maskText(MaskingMode.relaxed, 'Email: user@example.com Phone: 555-1234', 14);
        expect(result, 'Email: user@example.com Phone: 555-1234');
      });
    });

    group('strict mode', () {
      test('obfuscates entire text with placeholder', () {
        final result = MaskingUtils.maskText(MaskingMode.strict, 'Test', 14);
        expect(result, isNotEmpty);
        expect(result, contains(MaskingUtils.maskedCharacterPlaceholder));
        expect(result.length, greaterThan('Test'.length));
      });

      test('uses default font size when fontSize is null', () {
        final result = MaskingUtils.maskText(MaskingMode.strict, 'Test', null);
        expect(result, isNotEmpty);
        expect(result, contains(MaskingUtils.maskedCharacterPlaceholder));
      });

      // Parameterized strict mode tests for various inputs
      final strictModeInputs = ['Short', 'A longer sentence with multiple words', '12345', 'user@email.com'];

      for (final input in strictModeInputs) {
        test('masks "$input" completely', () {
          final result = MaskingUtils.maskText(MaskingMode.strict, input, 14);
          expect(result, contains(MaskingUtils.maskedCharacterPlaceholder));
          expect(result, isNot(contains(input)));
        });
      }
    });

    group('balanced mode - PII patterns', () {
      // Parameterized PII masking tests
      final piiTestCases = [
        (
          input: 'Contact me at user@example.com for details',
          piiToMask: 'user@example.com',
          preservedText: ['Contact me at', 'for details'],
          description: 'email address',
        ),
        (
          input: 'Call me at 1234567890',
          piiToMask: '1234567890',
          preservedText: ['Call me at'],
          description: 'phone number (digits only)',
        ),
        (
          input: 'Phone: 555-123-4567',
          piiToMask: '555',
          preservedText: ['Phone:'],
          description: 'phone number with dashes',
        ),
        (
          input: 'Email: test@mail.com Phone: 555-1234',
          piiToMask: 'test@mail.com',
          preservedText: ['Email:', 'Phone:'],
          description: 'mixed email and phone',
        ),
        (input: 'SSN: 123-45-6789', piiToMask: '123', preservedText: ['SSN:'], description: 'SSN-like number'),
        (
          input: 'Contact: firstname.lastname@company.org',
          piiToMask: 'firstname.lastname@company.org',
          preservedText: ['Contact:'],
          description: 'complex email with dots',
        ),
      ];

      for (final testCase in piiTestCases) {
        test('masks ${testCase.description}', () {
          final result = MaskingUtils.maskText(MaskingMode.balanced, testCase.input, 14);
          expect(result, contains(MaskingUtils.maskedCharacterPlaceholder));
          expect(result, isNot(contains(testCase.piiToMask)));
          for (final preserved in testCase.preservedText) {
            expect(result, contains(preserved));
          }
        });
      }

      // Parameterized non-PII preservation tests
      final nonPiiTexts = ['Hello World', 'This is a simple message', 'No sensitive data here', 'Flutter SDK version'];

      for (final text in nonPiiTexts) {
        test('preserves non-PII text: "$text"', () {
          final result = MaskingUtils.maskText(MaskingMode.balanced, text, 14);
          expect(result, text);
        });
      }
    });
  });
}
