/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:io';

class FileUtils {
  FileUtils._();

  static String concat(List<String> paths) {
    return paths.join(Platform.pathSeparator);
  }
}
