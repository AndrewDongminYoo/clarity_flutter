/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/paint_command.dart';
import 'package:clarity_flutter/src/models/display/rect.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class SaveLayer extends PaintCommand {
  SaveLayer(this.bounds, this.flags, this.imageFilterPaint, int paintHashcode)
    : super(paintHashcode, CommandType.SaveLayer);
  Rect? bounds;
  int? flags;
  int? imageFilterPaint;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..saveLayerPayload = mutation_payload.SaveLayerCommandPayload(
        paintIndex: paintIndex,
        bounds: bounds?.toProtobufInstance(),
        flags: flags,
        imageFilterPaint: imageFilterPaint,
      );
  }
}
