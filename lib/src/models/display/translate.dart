/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class Translate extends DisplayCommand {
  Translate(this.left, this.top) : super(CommandType.Translate);
  double left;
  double top;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..translatePayload = mutation_payload.TranslateCommandPayload(left: left, top: top);
  }
}
