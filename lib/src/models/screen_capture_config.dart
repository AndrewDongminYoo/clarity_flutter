/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

class ScreenCaptureConfig {
  const ScreenCaptureConfig({required this.allowedScreens, required this.disallowedScreens});
  factory ScreenCaptureConfig.fromJson(Map<String, dynamic> json) {
    return ScreenCaptureConfig(
      allowedScreens: _screenNamesFromJson(json['allowedScreens']),
      disallowedScreens: _screenNamesFromJson(json['disallowedScreens']),
    );
  }

  final List<String> allowedScreens;
  final List<String> disallowedScreens;

  static List<String> _screenNamesFromJson(Object? value) {
    return (value as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map<String>((item) => item['screenName'] as String)
        .toList();
  }
}
