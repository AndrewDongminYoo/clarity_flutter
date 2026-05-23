// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/entry_point.dart';

void main() {
  group('EntryPoint.run', () {
    test('returns result when logic succeeds', () {
      final result = EntryPoint.run(() => 42);
      expect(result, 42);
    });

    test('returns null when exception occurs and throwExceptions is false', () {
      final result = EntryPoint.run(() => throw Exception('test error'));
      expect(result, isNull);
    });

    test('rethrows exception when throwExceptions is true', () {
      expect(() => EntryPoint.run(() => throw Exception('test error'), throwExceptions: true), throwsException);
    });

    test('executes catchLogic when exception occurs', () {
      Object? caughtException;
      StackTrace? caughtStackTrace;

      EntryPoint.run(
        () => throw Exception('test error'),
        catchLogic: (e, st) {
          caughtException = e;
          caughtStackTrace = st;
        },
      );

      expect(caughtException, isA<Exception>());
      expect(caughtStackTrace, isNotNull);
    });

    test('executes finallyLogic even when exception occurs', () {
      var finallyCalled = false;

      EntryPoint.run(() => throw Exception('test error'), finallyLogic: () => finallyCalled = true);

      expect(finallyCalled, isTrue);
    });

    test('handles Error as well as Exception', () {
      Object? caughtError;

      EntryPoint.run(() => throw ArgumentError('test error'), catchLogic: (e, st) => caughtError = e);

      expect(caughtError, isA<ArgumentError>());
    });
  });

  group('EntryPoint.runAsync', () {
    test('returns result when async logic succeeds', () async {
      final result = await EntryPoint.runAsync(() async => 42);
      expect(result, 42);
    });

    test('returns null when async exception occurs and throwExceptions is false', () async {
      final result = await EntryPoint.runAsync(() async => throw Exception('test error'));
      expect(result, isNull);
    });

    test('rethrows exception when throwExceptions is true', () async {
      expect(
        () async => EntryPoint.runAsync(() async => throw Exception('test error'), throwExceptions: true),
        throwsException,
      );
    });

    test('executes catchLogic when async exception occurs', () async {
      Object? caughtException;
      StackTrace? caughtStackTrace;

      await EntryPoint.runAsync(
        () async => throw Exception('test error'),
        catchLogic: (e, st) {
          caughtException = e;
          caughtStackTrace = st;
        },
      );

      expect(caughtException, isA<Exception>());
      expect(caughtStackTrace, isNotNull);
    });

    test('executes finallyLogic even when async exception occurs', () async {
      var finallyCalled = false;

      await EntryPoint.runAsync(() async => throw Exception('test error'), finallyLogic: () => finallyCalled = true);

      expect(finallyCalled, isTrue);
    });
  });
}
