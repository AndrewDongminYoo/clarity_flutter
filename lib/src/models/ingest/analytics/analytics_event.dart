/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';

abstract class AnalyticsEvent extends SessionEvent {
  AnalyticsEvent(super.timestamp, super.type);
}
