/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/events/event.dart';
import 'package:clarity_flutter/src/models/session/payload_metadata.dart';

class PayloadEvent extends Event {
  PayloadEvent(this.metadata);
  PayloadMetadata metadata;
}
