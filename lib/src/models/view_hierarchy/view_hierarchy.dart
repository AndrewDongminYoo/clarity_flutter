/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/generated/MutationPayload.pb.dart' as mutation_payload;
import 'package:clarity_flutter/src/models/iproto_model.dart';
import 'package:clarity_flutter/src/models/view_hierarchy/view_node.dart';

class ViewHierarchy implements IProtoModel<mutation_payload.ViewHierarchy> {
  ViewHierarchy(this.timestamp, this.root);
  int timestamp;
  ViewNode root;

  @override
  mutation_payload.ViewHierarchy toProtobufInstance() {
    return mutation_payload.ViewHierarchy(timestamp: timestamp.toDouble(), rootDelta: root.toProtobufInstance());
  }
}
