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
    if (e case Exception() || Error()) {
      try {
        // Log error if no catch logic is defined
        final onCatchError =
            catchLogic ??
            (error, stackTrace) =>
                Logger.error?.out('Type: ${error.runtimeType} Message: $error', stackTrace: stackTrace);
        onCatchError.call(e, st);
      } catch (invokeE, st) {
        Logger.error?.out(invokeE.toString(), stackTrace: st);
      }
      if (throwExceptions) {
        // ignore: only_throw_errors
        throw e;
      }
    } else {
      Logger.error?.out('Unknown issue thrown $e', stackTrace: st);
    }
  }
}
