/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/native/generated/messages.g.dart' as pigeon;
import 'package:clarity_flutter/src/utils/log_utils.dart';

class NetworkChannel {
  NetworkChannel._();

  static final pigeon.ClarityNetworkHostApi _api = pigeon.ClarityNetworkHostApi();

  static const List<pigeon.ConnectivityType> _safeFallback = [pigeon.ConnectivityType.none];

  static Future<List<pigeon.ConnectivityType>> getConnectivityStatus() async {
    try {
      return await _api.getConnectivityStatus();
    } catch (e, st) {
      Logger.error?.out('Failed to get connectivity status: $e', stackTrace: st);
      return _safeFallback;
    }
  }

  static Stream<List<pigeon.ConnectivityType>> get onConnectivityChanged {
    return pigeon.connectivityChanged().map((event) => event.types).handleError((Object error, StackTrace? st) {
      Logger.error?.out('Failed to read connectivity stream: $error', stackTrace: st);
      return _safeFallback;
    });
  }
}
