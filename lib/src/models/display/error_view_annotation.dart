/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';
import 'package:clarity_flutter/src/models/display/view_debugging_annotation.dart';
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;

class ErrorViewAnnotation extends ViewDebuggingAnnotation {
  ErrorViewAnnotation(this.viewType, this.errorMessage) : super(CommandType.ErrorViewAnnotation);
  String viewType;
  String errorMessage;

  @override
  mutation_payload.DisplayCommandV2 toProtobufInstance() {
    return super.toProtobufInstance()
      ..errorViewAnnotationPayload = mutation_payload.ErrorViewAnnotationCommandPayload(
        viewType: viewType,
        errorMessage: errorMessage,
      );
  }
}
