/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/paint_command.dart';
import 'package:clarity_flutter/src/models/display/rrect.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

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
