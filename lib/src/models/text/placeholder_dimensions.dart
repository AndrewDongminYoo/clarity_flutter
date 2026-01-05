/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Flutter imports:
import 'package:flutter/rendering.dart' as rendering;

// Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';
import 'package:clarity_flutter/src/models/text/offset.dart';

class PlaceholderDimensions implements IProtoModel<mutation_payload.PlaceholderDimensions> {
  PlaceholderDimensions(this.size, this.alignment, this.baseline, this.baselineOffset);

  PlaceholderDimensions.fromDartPlaceholderDimensions(rendering.PlaceholderDimensions placeholderDimensions)
    : this(
        Size.fromDartSize(placeholderDimensions.size),
        placeholderDimensions.alignment.index,
        placeholderDimensions.baseline?.index,
        placeholderDimensions.baselineOffset,
      );
  Size size;
  int alignment;
  int? baseline;
  double? baselineOffset;

  @override
  mutation_payload.PlaceholderDimensions toProtobufInstance() {
    return mutation_payload.PlaceholderDimensions(
      size: size.toProtobufInstance(),
      alignment: alignment,
      baseline: baseline,
      baselineOffset: baselineOffset,
    );
  }
}
