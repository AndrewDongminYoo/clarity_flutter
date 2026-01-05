/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class Transform extends DisplayCommand {
  Transform(this.matrix) : super(CommandType.Transform);
  List<double> matrix;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()..transformPayload = mutation_payload.TransformCommandPayload(matrix: matrix);
  }
}
