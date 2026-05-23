/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/consent_status.dart';
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';

class ConsentEvent extends AnalyticsEvent {
  ConsentEvent(int timestamp, this.consentStatus) : super(timestamp, EventType.Consent);
  final ConsentStatus consentStatus;

  @override
  String serialize(int pageTimestamp) {
    return '[${relativeTimestamp(pageTimestamp)},${type.customOrdinal},'
        '${consentStatus.source.index},'
        '${consentStatus.adsStorage ? 1 : 0},'
        '${consentStatus.analyticsStorage ? 1 : 0}]';
  }
}
