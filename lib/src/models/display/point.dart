/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:ui' as ui;

// Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

class Point implements IProtoModel<mutation_payload.Point> {
  Point(this.x, this.y);

  Point.fromDartOffset(ui.Offset offset) : this(offset.dx, offset.dy);
  double x;
  double y;

  @override
  mutation_payload.Point toProtobufInstance() {
    return mutation_payload.Point(x: x, y: y);
  }
}
