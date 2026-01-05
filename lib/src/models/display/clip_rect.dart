/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'display_command.dart';
import 'rect.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

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
