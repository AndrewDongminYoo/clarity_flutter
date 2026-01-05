/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'display_command.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

class Scale extends DisplayCommand {
  Scale(this.sx, this.sy) : super(CommandType.Scale);
  double sx;
  double sy;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()..scalePayload = mutation_payload.ScaleCommandPayload(sx: sx, sy: sy);
  }
}
