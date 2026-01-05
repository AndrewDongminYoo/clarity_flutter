/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'display_command.dart';
import 'view_debugging_annotation.dart';

import '../generated/MutationPayload.pb.dart' as mutation_payload;

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
