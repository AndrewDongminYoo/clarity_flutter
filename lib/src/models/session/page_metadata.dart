/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 📦 Package imports:
import 'package:json_annotation/json_annotation.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/session/session_metadata.dart';

part '../generated/page_metadata.g.dart';

@JsonSerializable(explicitToJson: true)
class PageMetadata {
  PageMetadata(this.number, this.startTime, this.lastVisibilityEventState, this.screenName, this.session);

  factory PageMetadata.fromJson(Map<String, dynamic> json) => _$PageMetadataFromJson(json);

  int number;
  int startTime;
  String lastVisibilityEventState;
  String screenName;
  SessionMetadata session;

  @override
  String toString() {
    return 'PageMetadata(number: $number, startTime: $startTime, lastVisibilityEventState: $lastVisibilityEventState, screenName: $screenName, session: $session)';
  }

  Map<String, dynamic> toJson() => _$PageMetadataToJson(this);
}
