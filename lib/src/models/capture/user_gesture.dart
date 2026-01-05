/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/events/observed_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/gesture_event.dart';

class UserGesture extends ObservedEvent {
  UserGesture(this.gestureEvent) : super(gestureEvent.timestamp);
  final GestureEvent gestureEvent;
}
