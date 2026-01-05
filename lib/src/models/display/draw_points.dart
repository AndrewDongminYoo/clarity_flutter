/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/paint_command.dart';
import 'package:clarity_flutter/src/models/display/point.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class DrawPoints extends PaintCommand {
  DrawPoints(this.pointMode, this.points, int paintHashcode) : super(paintHashcode, CommandType.DrawPoints);
  int pointMode;
  List<Point> points;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawPointsPayload = mutation_payload.DrawPointsCommandPayload(
        paintIndex: paintIndex,
        pointMode: pointMode,
        points: points.map((point) => point.toProtobufInstance()).toList(growable: false),
      );
  }
}
