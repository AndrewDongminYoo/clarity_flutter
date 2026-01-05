/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/text/offset.dart';
import 'package:clarity_flutter/src/models/text/render_paragraph.dart';

class DrawRenderParagraph extends DisplayCommand {
  DrawRenderParagraph(this.renderParagraph, this.offset) : super(CommandType.DrawRenderParagraph);
  RenderParagraph renderParagraph;
  Offset offset;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawRenderParagraphPayload = mutation_payload.DrawRenderParagraphCommandPayload(
        renderParagraph: renderParagraph.toProtobufInstance(),
        offset: offset.toProtobufInstance(),
      );
  }
}
