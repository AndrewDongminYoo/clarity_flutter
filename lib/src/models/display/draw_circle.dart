/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/paint_command.dart';
import 'package:clarity_flutter/src/models/display/point.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class DrawCircle extends PaintCommand {
  DrawCircle(this.point, this.radius, int paintHashcode) : super(paintHashcode, CommandType.DrawCircle);
  Point point;
  double radius;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawCirclePayload = mutation_payload.DrawCircleCommandPayload(
        paintIndex: paintIndex,
        point: point.toProtobufInstance(),
        radius: radius,
      );
  }
}
