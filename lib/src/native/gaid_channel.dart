/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/native/generated/messages.g.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class GaidChannel {
  GaidChannel._();

  static final ClarityGaidHostApi _api = ClarityGaidHostApi();

  static Future<String?> getGaid() async {
    try {
      return await _api.getGaid();
    } catch (e, st) {
      Logger.error?.out('Failed to get GAID: $e', stackTrace: st);
      return null;
    }
  }
}
