/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/registries/host_info.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

class Envelope {
  Envelope(this.projectId, this.userId, this.sessionId, this.pageNum, this.sequence, this.start, this.duration)
    : platform = ApplicationPlatform.getCurrentPlatform().index;

  final String projectId;
  final String userId;
  final String sessionId;
  final int pageNum;
  final int sequence;
  final int start;
  final int duration;
  final int upload = 0;
  final int end = 0;
  final int platform;
  final String version = ClarityConstants.clarityVersion;

  String serialize() {
    final escapedVersion = DataUtils.escape(version);
    final escapedProjectId = DataUtils.escape(projectId);
    final escapedUserId = DataUtils.escape(userId);
    final escapedSessionId = DataUtils.escape(sessionId);

    return '["$escapedVersion",$sequence,$start,$duration,"$escapedProjectId","$escapedUserId","$escapedSessionId",$pageNum,$upload,$end,$platform]';
  }
}
