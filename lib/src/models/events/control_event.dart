/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/managers/base_session_manager.dart';
import 'package:clarity_flutter/src/models/assets/font_asset.dart';
import 'package:clarity_flutter/src/models/consent_status.dart';
import 'package:clarity_flutter/src/models/events/event.dart';
import 'package:clarity_flutter/src/models/session/session_metadata.dart';

@pragma('vm:deeply-immutable')
final class PauseCaptureEvent implements Event {}

@pragma('vm:deeply-immutable')
final class ResumeCaptureEvent implements Event {}

@pragma('vm:deeply-immutable')
final class NetworkConnectivityChangedEvent implements Event {
  NetworkConnectivityChangedEvent(this.allowUploadOverNetwork);
  final bool allowUploadOverNetwork;
}

final class SessionStartedEvent implements Event {
  SessionStartedEvent(SessionMetadata sessionMetadata, this.callback)
    : sessionId = sessionMetadata.id,
      userId = sessionMetadata.userId,
      projectId = sessionMetadata.projectId;
  final String sessionId;
  final String userId;
  final String projectId;
  final SessionStartedCallback? callback;

  @override
  String toString() => 'SessionStartedEvent(sessionId: $sessionId, userId: $userId, projectId: $projectId)';
}

final class SetCustomTagEvent implements Event {
  SetCustomTagEvent(this.key, this.values);
  final String key;
  final Set<String> values;

  @override
  String toString() => 'SetCustomTagEvent(key: $key, value: $values)';
}

@pragma('vm:deeply-immutable')
final class SendCustomValueEvent implements Event {
  SendCustomValueEvent(this.value);
  final String value;

  @override
  String toString() => 'SendCustomValueEvent(value: $value)';
}

final class FontMetadataEvent implements Event {
  FontMetadataEvent({required this.fontMap});
  final Map<String, List<FontAsset>> fontMap;

  @override
  String toString() => 'FontMetadataEvent(families: ${fontMap.length})';
}

final class FontLoadRequest {
  FontLoadRequest({required this.familyName, required this.asset});
  final String familyName;
  final FontAsset asset;

  @override
  String toString() {
    return 'FontLoadRequest(family: $familyName, asset: $asset)';
  }
}

final class RequestFontBytesEvent implements Event {
  RequestFontBytesEvent(this.fontsToLoad);
  final List<FontLoadRequest> fontsToLoad;

  @override
  String toString() => 'RequestFontBytesEvent(count: ${fontsToLoad.length})';
}

final class FontBytesLoadedEvent implements Event {
  FontBytesLoadedEvent(this.loadedFonts);
  final List<LoadedFontData> loadedFonts;

  @override
  String toString() => 'FontBytesLoadedEvent(count: ${loadedFonts.length})';
}

@pragma('vm:deeply-immutable')
final class InitConsentStatusEvent implements Event {
  const InitConsentStatusEvent();

  @override
  String toString() => 'InitConsentStatusEvent()';
}

final class ConsentChangedEvent implements Event {
  ConsentChangedEvent(this.consentStatus);
  final ConsentStatus consentStatus;

  @override
  String toString() => 'ConsentChangedEvent($consentStatus)';
}

@pragma('vm:deeply-immutable')
final class ConsentAnalyticsChangedEvent implements Event {}
