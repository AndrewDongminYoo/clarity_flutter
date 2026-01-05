/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/event.dart';

class ObservedEvent extends Event {
  ObservedEvent(this.timestamp);
  int timestamp;
}
