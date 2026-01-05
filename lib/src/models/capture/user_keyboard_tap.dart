/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import '../events/observed_event.dart';

class UserKeyboardTap extends ObservedEvent {
  UserKeyboardTap(super.timestamp, this.count);
  final int count;
}
