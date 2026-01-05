/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import '../events/session_event.dart';

abstract class BaseMutationEvent extends SessionEvent {
  BaseMutationEvent(super.timestamp, super.type);
}
