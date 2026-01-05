/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/rect.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class ClipRect extends DisplayCommand {
  ClipRect(this.rect, this.op, this.antiAlias) : super(CommandType.ClipRect);
  Rect rect;
  int op;
  bool antiAlias;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..clipRectPayload = mutation_payload.ClipRectCommandPayload(
        rect: rect.toProtobufInstance(),
        op: op,
        antiAlias: antiAlias,
      );
  }
}
