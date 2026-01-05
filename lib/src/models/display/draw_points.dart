/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'paint_command.dart';
import 'display_command.dart';
import 'point.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

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
