/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

class ScreenCaptureConfig {
  const ScreenCaptureConfig({
    required this.allowedScreens,
    required this.disallowedScreens,
  });

  factory ScreenCaptureConfig.fromJson(Map<String, dynamic> json) {
    return ScreenCaptureConfig(
      allowedScreens: (json['allowedScreens'] as List<dynamic>? ?? [])
          .map<String>((item) => (item as Map)['screenName'] as String)
          .toList(),
      disallowedScreens: (json['disallowedScreens'] as List<dynamic>? ?? [])
          .map<String>((item) => (item as Map)['screenName'] as String)
          .toList(),
    );
  }

  final List<String> allowedScreens;
  final List<String> disallowedScreens;
}
