/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/image_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class DrawImage extends ImageCommand {
  DrawImage(
    this.x,
    this.y,
    int? imageHashcode,
    int paintHashcode, {
    this.maskedWidth,
    this.maskedHeight,
  }) : super(imageHashcode, paintHashcode, CommandType.DrawImage);
  double x;
  double y;
  int? maskedWidth;
  int? maskedHeight;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawImagePayload = mutation_payload.DrawImageCommandPayload(
        paintIndex: paintIndex,
        imageIndex: imageIndex,
        x: x,
        y: y,
        maskedWidth: maskedWidth,
        maskedHeight: maskedHeight,
      );
  }
}
