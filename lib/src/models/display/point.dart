/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'dart:ui' as ui;

import '../iproto_model.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

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
