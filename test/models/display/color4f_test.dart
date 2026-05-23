// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/color4f.dart';

void main() {
  group('Color4f.fromDartColorString', () {
    // Parameterized valid color parsing tests
    final validColorCases = [
      (
        input: 'Color(0xFF123456)',
        expectedA: 0xFF / 255.0,
        expectedR: 0x12 / 255.0,
        expectedG: 0x34 / 255.0,
        expectedB: 0x56 / 255.0,
        description: '8-digit hex with uppercase',
      ),
      (
        input: 'Color(0xffaabbcc)',
        expectedA: 1.0,
        expectedR: 0xaa / 255.0,
        expectedG: 0xbb / 255.0,
        expectedB: 0xcc / 255.0,
        description: 'lowercase hex',
      ),
      (
        input: 'Color(0x80FF0000)',
        expectedA: 0x80 / 255.0,
        expectedR: 1.0,
        expectedG: 0.0,
        expectedB: 0.0,
        description: 'semi-transparent red',
      ),
      (
        input: 'Color(0x00000000)',
        expectedA: 0.0,
        expectedR: 0.0,
        expectedG: 0.0,
        expectedB: 0.0,
        description: 'fully transparent black',
      ),
      (
        input: 'Color(0xFFFFFFFF)',
        expectedA: 1.0,
        expectedR: 1.0,
        expectedG: 1.0,
        expectedB: 1.0,
        description: 'opaque white',
      ),
    ];

    for (final testCase in validColorCases) {
      test('parses ${testCase.description}: ${testCase.input}', () {
        final color = Color4f.fromDartColorString(testCase.input);

        expect(color, isNotNull);
        expect(color!.a, closeTo(testCase.expectedA, 0.001));
        expect(color.r, closeTo(testCase.expectedR, 0.001));
        expect(color.g, closeTo(testCase.expectedG, 0.001));
        expect(color.b, closeTo(testCase.expectedB, 0.001));
      });
    }

    // Parameterized invalid input tests
    final invalidColorCases = [
      (input: '0xFF123456', description: 'missing Color prefix'),
      (input: 'Color(123456)', description: 'missing 0x prefix'),
      (input: '', description: 'empty string'),
      (input: 'Color(0xGGHHIIJJ)', description: 'malformed hex characters'),
      (input: 'color(0xFF000000)', description: 'lowercase Color keyword'),
      (input: 'Color()', description: 'empty parentheses'),
      (input: 'Color', description: 'no parentheses'),
    ];

    for (final testCase in invalidColorCases) {
      test('returns null for ${testCase.description}: "${testCase.input}"', () {
        final color = Color4f.fromDartColorString(testCase.input);
        expect(color, isNull);
      });
    }
  });

  group('Color4f.fromDartColor', () {
    // Parameterized Dart Color conversion tests
    final dartColorCases = [
      (
        color: const Color(0xFFFF0000),
        expectedA: 1.0,
        expectedR: 1.0,
        expectedG: 0.0,
        expectedB: 0.0,
        description: 'opaque red',
      ),
      (
        color: const Color(0xFF00FF00),
        expectedA: 1.0,
        expectedR: 0.0,
        expectedG: 1.0,
        expectedB: 0.0,
        description: 'opaque green',
      ),
      (
        color: const Color(0xFF0000FF),
        expectedA: 1.0,
        expectedR: 0.0,
        expectedG: 0.0,
        expectedB: 1.0,
        description: 'opaque blue',
      ),
      (
        color: const Color(0x80000000),
        expectedA: 0x80 / 255.0,
        expectedR: 0.0,
        expectedG: 0.0,
        expectedB: 0.0,
        description: 'semi-transparent black',
      ),
      (
        color: const Color(0x00FFFFFF),
        expectedA: 0.0,
        expectedR: 1.0,
        expectedG: 1.0,
        expectedB: 1.0,
        description: 'fully transparent white',
      ),
    ];

    for (final testCase in dartColorCases) {
      test('converts ${testCase.description}', () {
        final color = Color4f.fromDartColor(testCase.color);

        expect(color.a, closeTo(testCase.expectedA, 0.001));
        expect(color.r, closeTo(testCase.expectedR, 0.001));
        expect(color.g, closeTo(testCase.expectedG, 0.001));
        expect(color.b, closeTo(testCase.expectedB, 0.001));
      });
    }
  });
}
