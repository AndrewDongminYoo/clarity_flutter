/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:ui' as ui;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

class RSXform implements IProtoModel<mutation_payload.RSXform> {
  RSXform(this.scos, this.ssin, this.tx, this.ty);

  RSXform.fromDartRSTransform(ui.RSTransform transform)
    : this(transform.scos, transform.ssin, transform.tx, transform.ty);
  double scos;
  double ssin;
  double tx;
  double ty;

  @override
  mutation_payload.RSXform toProtobufInstance() {
    return mutation_payload.RSXform(scos: scos, ssin: ssin, tx: tx, ty: ty);
  }
}
