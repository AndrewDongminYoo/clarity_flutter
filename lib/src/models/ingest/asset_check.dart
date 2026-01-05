/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:convert';

class AssetCheck {
  AssetCheck({required this.type, this.hash, this.path, this.version});

  final String? hash;
  final String? path;
  final String? version;
  final int type;

  Map<String, dynamic> toJsonObject() {
    return {
      'hash': hash,
      'path': path,
      'version': version,
      'type': type,
    };
  }

  String toJson() {
    return jsonEncode(toJsonObject());
  }
}
