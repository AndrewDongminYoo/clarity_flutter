/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/image_command.dart';
import 'package:clarity_flutter/src/models/display/irect.dart';
import 'package:clarity_flutter/src/models/display/rect.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class DrawImageNine extends ImageCommand {
  DrawImageNine(this.center, this.dst, int? imageHashcode, int paintHashcode)
    : super(imageHashcode, paintHashcode, CommandType.DrawImageNine);
  IRect center;
  Rect dst;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawImageNinePayload = mutation_payload.DrawImageNineCommandPayload(
        paintIndex: paintIndex,
        imageIndex: imageIndex,
        center: center.toProtobufInstance(),
        dst: dst.toProtobufInstance(),
      );
  }
}
