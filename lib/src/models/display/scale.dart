/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class Scale extends DisplayCommand {
  Scale(this.sx, this.sy) : super(CommandType.Scale);
  double sx;
  double sy;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()..scalePayload = mutation_payload.ScaleCommandPayload(sx: sx, sy: sy);
  }
}
