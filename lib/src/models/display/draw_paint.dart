/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/paint_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class DrawPaint extends PaintCommand {
  DrawPaint(int paintHashcode) : super(paintHashcode, CommandType.DrawPaint);

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawPaintPayload = mutation_payload.DrawPaintCommandPayload(paintIndex: paintIndex);
  }
}
