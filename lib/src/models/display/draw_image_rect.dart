/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'image_command.dart';
import 'display_command.dart';
import 'rect.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

class DrawImageRect extends ImageCommand {
  DrawImageRect(this.src, this.dst, int? imageHashcode, int paintHashcode)
    : super(imageHashcode, paintHashcode, CommandType.DrawImageRect);
  Rect src;
  Rect dst;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawImageRectPayload = mutation_payload.DrawImageRectCommandPayload(
        paintIndex: paintIndex,
        imageIndex: imageIndex,
        src: src.toProtobufInstance(),
        dst: dst.toProtobufInstance(),
      );
  }
}
