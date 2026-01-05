/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'event.dart';

class ObservedEvent extends Event {
  ObservedEvent(this.timestamp);
  int timestamp;
}
