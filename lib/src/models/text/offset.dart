/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:ui' as ui;

// Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

abstract class OffsetBase implements IProtoModel<mutation_payload.Offset> {
  OffsetBase(this.dx, this.dy);
  double dx;
  double dy;

  @override
  mutation_payload.Offset toProtobufInstance() {
    return mutation_payload.Offset(dx: dx, dy: dy);
  }
}

class Offset extends OffsetBase {
  Offset(super.dx, super.dy);

  Offset.fromDartOffset(ui.Offset offset)
    : this(offset.dx.isInfinite ? double.maxFinite : offset.dx, offset.dy.isInfinite ? double.maxFinite : offset.dy);
}

class Size extends OffsetBase {
  Size(super.dx, super.dy);

  Size.fromDartSize(ui.Size size)
    : this(
        size.width.isInfinite ? double.maxFinite : size.width,
        size.height.isInfinite ? double.maxFinite : size.height,
      );
}
