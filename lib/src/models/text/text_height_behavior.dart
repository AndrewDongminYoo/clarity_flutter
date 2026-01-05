/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Flutter imports:
import 'package:flutter/rendering.dart' as rendering;

// Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';

class TextHeightBehavior implements IProtoModel<mutation_payload.TextHeightBehavior> {
  TextHeightBehavior(this.applyHeightToFirstAscent, this.applyHeightToLastDescent, this.leadingDistribution);

  TextHeightBehavior.fromDartTextHeightBehavior(rendering.TextHeightBehavior textHeightBehavior)
    : this(
        textHeightBehavior.applyHeightToFirstAscent,
        textHeightBehavior.applyHeightToLastDescent,
        textHeightBehavior.leadingDistribution.index,
      );
  bool applyHeightToFirstAscent;
  bool applyHeightToLastDescent;
  int leadingDistribution;

  @override
  mutation_payload.TextHeightBehavior toProtobufInstance() {
    return mutation_payload.TextHeightBehavior(
      applyHeightToFirstAscent: applyHeightToFirstAscent,
      applyHeightToLastDescent: applyHeightToLastDescent,
      leadingDistribution: leadingDistribution,
    );
  }
}
