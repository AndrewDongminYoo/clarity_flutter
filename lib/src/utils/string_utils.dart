/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

/// Extension on [String] providing text validation utilities.
extension StringValidation on String {
  /// The threshold ratio of strange characters to total length.
  /// If exceeded, the string is considered to have strange text.
  static const double _strangeCharThreshold = 0.3;

  /// Returns `true` if the string is empty after trimming,
  /// or if more than 30% of characters are "strange" (control characters,
  /// replacement characters, zero-width characters, or private use area).
  bool get hasStrangeText {
    final trimmed = trim();
    if (trimmed.isEmpty) return true;

    var strangeCount = 0;
    for (final codeUnit in trimmed.runes) {
      if (_isStrangeCharacter(codeUnit)) {
        strangeCount++;
      }
    }

    final ratio = strangeCount / trimmed.length;
    return ratio > _strangeCharThreshold;
  }

  /// Checks if a Unicode code point is considered "strange".
  static bool _isStrangeCharacter(int codePoint) {
    // Replacement character (encoding failure)
    if (codePoint == 0xFFFD) return true;

    // Control characters (except tab, newline, carriage return)
    if (codePoint >= 0x0000 && codePoint <= 0x001F) {
      if (codePoint != 0x09 && codePoint != 0x0A && codePoint != 0x0D) {
        return true;
      }
    }

    // Zero-width and invisible characters
    if (codePoint == 0x200B || // Zero-width space
        codePoint == 0x200C || // Zero-width non-joiner
        codePoint == 0x200D || // Zero-width joiner
        codePoint == 0xFEFF) {
      // Byte order mark
      return true;
    }

    // Private Use Area
    if (codePoint >= 0xE000 && codePoint <= 0xF8FF) return true;

    return false;
  }
}
