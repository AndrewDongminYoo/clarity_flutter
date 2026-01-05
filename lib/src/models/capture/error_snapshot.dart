/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/events/observed_event.dart';

class ErrorSnapshot extends ObservedEvent {
  ErrorSnapshot(this.errorMessage, super.timestamp);
  String errorMessage;
}
