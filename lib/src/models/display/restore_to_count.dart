/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class RestoreToCount extends DisplayCommand {
  RestoreToCount(this.count) : super(CommandType.RestoreToCount);
  int count;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..restoreToCountPayload = mutation_payload.RestoreToCountCommandPayload(count: count);
  }
}
