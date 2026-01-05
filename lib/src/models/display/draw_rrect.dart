/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/paint_command.dart';
import 'package:clarity_flutter/src/models/display/rrect.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class DrawRRect extends PaintCommand {
  DrawRRect(this.rrect, int paintHashcode) : super(paintHashcode, CommandType.DrawRRect);
  RRect rrect;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawRRectPayload = mutation_payload.DrawRRectCommandPayload(
        paintIndex: paintIndex,
        rrect: rrect.toProtobufInstance(),
      );
  }
}
