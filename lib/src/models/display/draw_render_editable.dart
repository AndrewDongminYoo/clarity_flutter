/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/text/offset.dart';
import 'package:clarity_flutter/src/models/text/render_editable.dart';

class DrawRenderEditable extends DisplayCommand {
  DrawRenderEditable(this.renderEditable, this.offset) : super(CommandType.DrawRenderEditable);
  RenderEditable renderEditable;
  Offset offset;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..drawRenderEditablePayload = mutation_payload.DrawRenderEditableCommandPayload(
        renderEditable: renderEditable.toProtobufInstance(),
        offset: offset.toProtobufInstance(),
      );
  }
}
