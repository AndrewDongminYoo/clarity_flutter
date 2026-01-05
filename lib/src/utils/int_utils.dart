/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

class IntUtils {
  IntUtils._();

  static int safeToInt(double value) {
    if (value.isNaN || value.isInfinite) {
      return 0;
    }
    return value.toInt();
  }
}
