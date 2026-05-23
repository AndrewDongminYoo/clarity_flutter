/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/event.dart';
import 'package:clarity_flutter/src/models/ingest/asset.dart';
import 'package:clarity_flutter/src/models/session/session_metadata.dart';

abstract base class AssetEvent implements Event {
  AssetEvent({required this.assets, required this.sessionMetadata});
  final List<Asset> assets;
  final SessionMetadata sessionMetadata;
}

final class AssetEncodingEvent extends AssetEvent {
  AssetEncodingEvent({required super.assets, required super.sessionMetadata});
}

final class AssetUploadEvent extends AssetEvent {
  AssetUploadEvent({required super.assets, required super.sessionMetadata});
}
