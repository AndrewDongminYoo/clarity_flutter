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
    final effectiveFontSize = fontSize ?? 14;
    final width = text.length * effectiveFontSize;
    const bulletWidthFactor = 1.4;
    final numberOfPoints = (width * bulletWidthFactor) ~/ effectiveFontSize;
    return maskedCharacterPlaceholder * numberOfPoints;
  }

  static String _obfuscateTextPII(String? text) {
    if (text == null || text.isEmpty) return '';
    return _replaceNumbersWithMaskedCharacters(_replaceEmailsWithMaskedCharacters(text));
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
