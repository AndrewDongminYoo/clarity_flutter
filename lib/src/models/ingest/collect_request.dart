/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/ingest/envelope.dart';

class CollectRequest {
  CollectRequest(this.e, this.a, this.p);

  final Envelope e;
  final List<String> a;
  final List<String> p;

  String serialize() {
    final serializedA = '[${a.join(",")}]';
    final serializedP = '[${p.join(",")}]';

    return '{"e":${e.serialize()},"a":$serializedA,"p":$serializedP}';
  }
}
