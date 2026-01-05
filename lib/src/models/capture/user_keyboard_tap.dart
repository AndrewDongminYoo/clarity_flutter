/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/events/observed_event.dart';

class UserKeyboardTap extends ObservedEvent {
  UserKeyboardTap(super.timestamp, this.count);
  final int count;
}
