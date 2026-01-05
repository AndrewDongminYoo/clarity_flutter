/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:ui' as ui;

// Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

class IRect implements IProtoModel<mutation_payload.Rect> {
  IRect(this.left, this.top, this.right, this.bottom);

  IRect.fromDartRect(ui.Rect rect) : this(rect.left, rect.top, rect.right, rect.bottom);
  double left;
  double top;
  double right;
  double bottom;

  @override
  mutation_payload.Rect toProtobufInstance() {
    return mutation_payload.Rect(left: left, top: top, right: right, bottom: bottom);
  }
}
