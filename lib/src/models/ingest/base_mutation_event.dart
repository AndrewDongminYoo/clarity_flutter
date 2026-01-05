/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';

abstract class BaseMutationEvent extends SessionEvent {
  BaseMutationEvent(super.timestamp, super.type);
}
