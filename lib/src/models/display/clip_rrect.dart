/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/rrect.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class ClipRRect extends DisplayCommand {
  ClipRRect(this.rrect, this.op, this.antiAlias) : super(CommandType.ClipRRect);
  RRect rrect;
  int op;
  bool antiAlias;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..clipRRectPayload = mutation_payload.ClipRRectCommandPayload(
        rrect: rrect.toProtobufInstance(),
        op: op,
        antiAlias: antiAlias,
      );
  }
}
