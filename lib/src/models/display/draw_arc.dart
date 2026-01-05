/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/paint_command.dart';
import 'package:clarity_flutter/src/models/display/rect.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class DrawArc extends PaintCommand {
  DrawArc(this.rect, this.startAngle, this.sweepAngle, this.useCenter, int paintHashcode)
    : super(paintHashcode, CommandType.DrawArc);
  Rect rect;
  double startAngle;
  double sweepAngle;
  bool useCenter;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawArcPayload = mutation_payload.DrawArcCommandPayload(
        paintIndex: paintIndex,
        rect: rect.toProtobufInstance(),
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        useCenter: useCenter,
      );
  }
}
