/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

class NetworkConfig {
  const NetworkConfig({
    required this.allowMeteredNetwork,
    this.maxDataVolume,
  });

  factory NetworkConfig.fromJson(Map<String, dynamic> json) {
    return NetworkConfig(
      allowMeteredNetwork: json['allowMeteredNetwork'] as bool,
      maxDataVolume: json['maxDataVolume'] as int?,
    );
  }

  final bool allowMeteredNetwork;
  final int? maxDataVolume;
}
