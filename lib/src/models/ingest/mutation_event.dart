/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/display/display_frame.dart';
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/generated/mutation_event_version.dart';
import 'package:clarity_flutter/src/models/ingest/base_mutation_event.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

class MutationEvent extends BaseMutationEvent {
  MutationEvent(int timestamp, this.frame, this.screenName) : super(timestamp, EventType.Mutation);

  bool isKeyFrame = true;
  DisplayFrame frame;
  String screenName;

  @override
  String serialize(int pageTimestamp) {
    final data = frame.toProtobufInstance(pageTimestamp).writeToBuffer();
    final base64Data = DataUtils.encodeBase64(data);

    return '['
        '${relativeTimestamp(pageTimestamp)},'
        '${type.customOrdinal},'
        '$isKeyFrame,'
        '"$base64Data",'
        '"",' // placeholder for unused entry
        '${ClarityConstants.mutationEventNativeWebviewRenderNodeId},'
        '$mutationEventVersion'
        ']';
  }
}
