/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Dart imports:
import 'dart:typed_data';

// Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';
import 'package:clarity_flutter/src/utils/asset_utils.dart';

class Image implements IProtoModel<mutation_payload.Image> {
  Image(this.data, this.dartHashCode, this.size);
  Uint8List? data;
  int dartHashCode;
  String? dataHash;
  ImageSize size;

  @override
  mutation_payload.Image toProtobufInstance() {
    return mutation_payload.Image(dataHash: dataHash);
  }
}
