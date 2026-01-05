/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import '../events/observed_event.dart';
import '../ingest/analytics/gesture_event.dart';

class UserGesture extends ObservedEvent {
  UserGesture(this.gestureEvent) : super(gestureEvent.timestamp);
  final GestureEvent gestureEvent;
}
