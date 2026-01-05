/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'paint_command.dart';
import 'display_command.dart';
import 'rect.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

class DrawOval extends PaintCommand {
  DrawOval(this.rect, int paintHashcode) : super(paintHashcode, CommandType.DrawOval);
  Rect rect;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawOvalPayload = mutation_payload.DrawOvalCommandPayload(
        paintIndex: paintIndex,
        rect: rect.toProtobufInstance(),
      );
  }
}
