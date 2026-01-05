/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/managers/base_session_manager.dart';
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
