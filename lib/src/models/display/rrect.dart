/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:ui' as ui;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

class RRect implements IProtoModel<mutation_payload.Rect> {
  RRect(this.left, this.top, this.right, this.bottom, this.radii);

  RRect.fromDartRRect(ui.RRect rrect)
    : this(rrect.left, rrect.top, rrect.right, rrect.bottom, [
        [rrect.tlRadiusX, rrect.tlRadiusY],
        [rrect.trRadiusX, rrect.trRadiusY],
        [rrect.brRadiusX, rrect.brRadiusY],
        [rrect.blRadiusX, rrect.blRadiusY],
      ]);
  double left;
  double top;
  double right;
  double bottom;
  List<List<double>> radii;

  @override
  mutation_payload.Rect toProtobufInstance() {
    return mutation_payload.Rect(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      radii: radii.map((list) => mutation_payload.FloatList(value: list)).toList(growable: false),
    );
  }
}
