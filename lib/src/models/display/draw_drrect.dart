/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'paint_command.dart';
import 'display_command.dart';
import 'rrect.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

class DrawDRRect extends PaintCommand {
  DrawDRRect(this.outer, this.inner, int paintHashcode) : super(paintHashcode, CommandType.DrawDRRect);
  RRect outer;
  RRect inner;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawDRRectPayload = mutation_payload.DrawDRRectCommandPayload(
        paintIndex: paintIndex,
        outer: outer.toProtobufInstance(),
        inner: inner.toProtobufInstance(),
      );
  }
}
