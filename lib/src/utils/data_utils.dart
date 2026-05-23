/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// 📦 Package imports:
import 'package:xxh3/xxh3.dart';

class DataUtils {
  DataUtils._();

  static String escape(String string) {
    return string.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\r\n', ' ').replaceAll('\n', ' ');
  }

  static String encodeBase64(List<int> bytes, {bool urlSafe = false}) {
    final encodedString = urlSafe ? base64UrlEncode(bytes) : base64Encode(bytes);

    return encodedString.trim();
  }

  static String xxHashBase64(List<int> input, {int seed = 0}) {
    final bytesToHash = input is Uint8List ? input : Uint8List.fromList(input);
    final hashValue = BigInt.from(xxh3(bytesToHash, seed: seed)).toUnsigned(64);

    final bytes = <int>[];
    for (var i = 0; i < 8; i++) {
      bytes.add(((hashValue >> (i * 8)) & BigInt.from(0xff)).toInt());
    }

    return encodeBase64(bytes, urlSafe: true);
  }
}
