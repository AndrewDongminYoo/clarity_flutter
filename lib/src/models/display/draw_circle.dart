/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'paint_command.dart';
import 'point.dart';
import 'display_command.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

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
