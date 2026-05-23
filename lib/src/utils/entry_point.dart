/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/log_utils.dart';

class EntryPoint {
  EntryPoint._();

  static T? run<T>(
    T Function() logic, {
    bool throwExceptions = false,
    void Function(Object, StackTrace)? catchLogic,
    void Function()? finallyLogic,
  }) {
    try {
      return logic();
    } catch (e, st) {
      _handleException(e, st, catchLogic, throwExceptions);
      return null;
    } finally {
      finallyLogic?.call();
    }
  }

  static Future<T?> runAsync<T>(
    Future<T> Function() logic, {
    bool throwExceptions = false,
    void Function(Object, StackTrace)? catchLogic,
    void Function()? finallyLogic,
  }) async {
    try {
      return await logic();
    } catch (e, st) {
      _handleException(e, st, catchLogic, throwExceptions);
      return Future.value();
    } finally {
      finallyLogic?.call();
    }
  }

  static void _handleException(
    Object e,
    StackTrace st,
    void Function(Object, StackTrace)? catchLogic,
    bool throwExceptions,
  ) {
    if (e is Exception || e is Error) {
      try {
        final onCatch =
            catchLogic ?? (e, st) => Logger.error?.out('Type: ${e.runtimeType} Message: $e', stackTrace: st);
        onCatch.call(e, st);
      } catch (invokeE, st) {
        Logger.error?.out(invokeE.toString(), stackTrace: st);
      }
      if (throwExceptions) {
        if (e is Error) {
          Error.throwWithStackTrace(e, st);
        }
        Error.throwWithStackTrace(Exception(e.toString()), st);
      }
    } else {
      Logger.error?.out('Unknown issue thrown $e', stackTrace: st);
    }
  }
}
