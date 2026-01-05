/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/color4f.dart';
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class DrawColor extends DisplayCommand {
  DrawColor(this.color, this.blendMode) : super(CommandType.DrawColor);
  Color4f color;
  int blendMode;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawColorPayload = mutation_payload.DrawColorCommandPayload(
        color: color.toProtobufInstance(),
        blendMode: blendMode,
      );
  }
}
