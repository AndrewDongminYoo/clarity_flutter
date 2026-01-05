/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/utils/http_utils.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

abstract class RetriableHttpService {
  @protected
  final RetryPolicy<HttpClientResponse> retryPolicy = RetryPolicy<HttpClientResponse>(
    ClarityConstants.requestsRetryCount,
    ClarityConstants.requestsRetryDelayInMs,
    resultRetryCriteria,
  );

  static bool resultRetryCriteria(HttpClientResponse response) => !HttpUtils.isSuccessCode(response.statusCode);
}

class RetryPolicy<T> {
  RetryPolicy(this.maxRetryCount, this.delayMilliseconds, this.resultRetryCriteria);

  final int maxRetryCount;
  final int delayMilliseconds;
  final bool Function(T)? resultRetryCriteria;

  Future<T> tryAsync(Future<T> Function() operation) async {
    for (var i = 0; i < maxRetryCount; i++) {
      try {
        final result = await operation();
        if (resultRetryCriteria != null && resultRetryCriteria!(result)) {
          throw _RetryableOperationError('Failed pass criteria!');
        }
        return result;
      } catch (e) {
        Logger.warn?.out('Request failed with $e, retrying!');
        await Future<void>.delayed(Duration(milliseconds: delayMilliseconds));
      }
    }

    return operation();
  }
}

class _RetryableOperationError extends Error {
  _RetryableOperationError(this.message);

  String message;

  @override
  String toString() {
    return '_RetryableOperationError: $message';
  }
}
