/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🐦 Flutter imports:
import 'package:flutter/rendering.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/masking.dart';

class MaskingUtils {
  MaskingUtils._();

  static const maskedCharacterPlaceholder = '•';
  static final maskedImagePaint = Paint()..style = PaintingStyle.fill;

  static String maskText(MaskingMode maskingMode, String? text, double? fontSize) {
    return switch (maskingMode) {
      MaskingMode.strict => _obfuscateText(text, fontSize),
      MaskingMode.balanced => _obfuscateTextPII(text),
      MaskingMode.relaxed => text ?? '',
    };
  }

  static MaskingMode determineMaskingMode(MaskingState? explicitMasking, MaskingMode projectDefaultMasking) {
    if (explicitMasking == MaskingState.masking) return MaskingMode.strict;
    if (explicitMasking == MaskingState.unmasking) return MaskingMode.relaxed;

    return projectDefaultMasking;
  }

  static String _obfuscateText(String? text, double? fontSize) {
    if (text == null || text.isEmpty) return '';
    final estimatedWidthEm = _estimateTextWidthInEm(text);
    const bulletWidthEm = 0.6;
    final numberOfPoints = (estimatedWidthEm / bulletWidthEm).ceil();
    return maskedCharacterPlaceholder * (numberOfPoints == 0 ? 1 : numberOfPoints);
  }

  static String _obfuscateTextPII(String? text) {
    if (text == null || text.isEmpty) return '';
    return _replaceNumbersWithMaskedCharacters(_replaceEmailsWithMaskedCharacters(text));
  }

  static double _estimateTextWidthInEm(String text) {
    var widthEm = 0.0;
    final length = text.length;
    for (var i = 0; i < length; i++) {
      final codeUnit = text.codeUnitAt(i);
      if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF && i + 1 < length) {
        final low = text.codeUnitAt(i + 1);
        if (low >= 0xDC00 && low <= 0xDFFF) {
          i++;
          widthEm += 1.0;
          continue;
        }
      }

      if (codeUnit <= 0x7F) {
        if (codeUnit == 0x20) {
          widthEm += 0.33;
        } else if (codeUnit >= 0x30 && codeUnit <= 0x39) {
          widthEm += 0.56;
        } else if (codeUnit == 0x49 ||
            codeUnit == 0x4C ||
            codeUnit == 0x69 ||
            codeUnit == 0x6C ||
            codeUnit == 0x2E ||
            codeUnit == 0x2C ||
            codeUnit == 0x27 ||
            codeUnit == 0x60) {
          widthEm += 0.3;
        } else if (codeUnit == 0x4D ||
            codeUnit == 0x57 ||
            codeUnit == 0x6D ||
            codeUnit == 0x77 ||
            codeUnit == 0x40 ||
            codeUnit == 0x23 ||
            codeUnit == 0x25 ||
            codeUnit == 0x26) {
          widthEm += 0.9;
        } else {
          widthEm += 0.6;
        }
        continue;
      }

      if (_isCjkOrFullwidth(codeUnit)) {
        widthEm += 1.0;
      } else {
        widthEm += 0.7;
      }
    }

    return widthEm;
  }

  static bool _isCjkOrFullwidth(int codeUnit) {
    return (codeUnit >= 0x1100 && codeUnit <= 0x115F) ||
        (codeUnit >= 0x2E80 && codeUnit <= 0xA4CF) ||
        (codeUnit >= 0xAC00 && codeUnit <= 0xD7A3) ||
        (codeUnit >= 0xF900 && codeUnit <= 0xFAFF) ||
        (codeUnit >= 0xFE10 && codeUnit <= 0xFE19) ||
        (codeUnit >= 0xFE30 && codeUnit <= 0xFE6F) ||
        (codeUnit >= 0xFF00 && codeUnit <= 0xFF60) ||
        (codeUnit >= 0xFFE0 && codeUnit <= 0xFFE6);
  }

  static String _replaceEmailsWithMaskedCharacters(String input) {
    // Replace any text part that contains the character `@`
    // Text part is a subset of the text that is surrounded by spaces, start or the end of the text
    final emailRegExp = RegExp(r'(?<=\s|^|\n)\S*@\S*(?=\s|$|\n)');
    return input.replaceAllMapped(emailRegExp, (match) {
      return maskedCharacterPlaceholder * match.group(0)!.length;
    });
  }

  static String _replaceNumbersWithMaskedCharacters(String input) {
    final numberRegExp = RegExp(r'\d+');
    return input.replaceAllMapped(numberRegExp, (match) {
      return maskedCharacterPlaceholder * match.group(0)!.length;
    });
  }
}
