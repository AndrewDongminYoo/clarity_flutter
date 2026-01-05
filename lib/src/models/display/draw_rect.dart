/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'paint_command.dart';
import 'display_command.dart';
import 'rect.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

class DrawRect extends PaintCommand {
  DrawRect(this.rect, int paintHashcode) : super(paintHashcode, CommandType.DrawRect);
  Rect rect;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawRectPayload = mutation_payload.DrawRectCommandPayload(
        paintIndex: paintIndex,
        rect: rect.toProtobufInstance(),
      );
  }
}
