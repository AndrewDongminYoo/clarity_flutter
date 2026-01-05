/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

class LowEndDevicesConfig {
  const LowEndDevicesConfig({required this.disableRecordings});
  factory LowEndDevicesConfig.fromJson(Map<String, dynamic> json) {
    return LowEndDevicesConfig(disableRecordings: json['disableRecordings'] as bool);
  }

  final bool disableRecordings;
}
