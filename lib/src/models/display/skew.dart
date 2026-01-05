/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class Skew extends DisplayCommand {
  Skew(this.sx, this.sy) : super(CommandType.Skew);
  double sx;
  double sy;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()..skewPayload = mutation_payload.SkewCommandPayload(sx: sx, sy: sy);
  }
}
