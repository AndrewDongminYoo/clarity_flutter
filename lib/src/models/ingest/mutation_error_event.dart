/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/base_mutation_event.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

class MutationErrorEvent extends BaseMutationEvent {
  MutationErrorEvent(int timestamp, this.reason, {this.errorMessage}) : super(timestamp, EventType.MutationError);
  ErrorReason reason;
  String? errorMessage;

  @override
  String serialize(int pageTimestamp) {
    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},"${DataUtils.escape(reason.name)}"${errorMessage != null ? ',"${DataUtils.escape(errorMessage!)}"' : ""}]';
  }
}

enum ErrorReason {
  enqueuedSessionFramesExceededLimit,
  frameCapturingError,
  frameProcessingError,
}
