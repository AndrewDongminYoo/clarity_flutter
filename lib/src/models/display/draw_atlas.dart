/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/image_command.dart';
import 'package:clarity_flutter/src/models/display/rect.dart';
import 'package:clarity_flutter/src/models/display/rsxform.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class DrawAtlas extends ImageCommand {
  DrawAtlas(this.srcRects, this.dstXforms, int? imageHashcode, int paintHashcode, this.blendMode, this.colors)
    : super(imageHashcode, paintHashcode, CommandType.DrawAtlas);
  List<Rect> srcRects;
  List<RSXform> dstXforms;
  int? blendMode;
  List<int>? colors;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawAtlasPayload = mutation_payload.DrawAtlasCommandPayload(
        paintIndex: paintIndex,
        imageIndex: imageIndex,
        srcRects: srcRects.map((rect) => rect.toProtobufInstance()).toList(growable: false),
        dstXforms: dstXforms.map((dstXform) => dstXform.toProtobufInstance()).toList(growable: false),
        blendMode: blendMode,
        colors: colors,
      );
  }
}
