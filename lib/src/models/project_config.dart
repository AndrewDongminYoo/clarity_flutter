/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:convert';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/low_end_devices_config.dart';
import 'package:clarity_flutter/src/models/masking.dart';
import 'package:clarity_flutter/src/models/network_config.dart';
import 'package:clarity_flutter/src/models/screen_capture_config.dart';

class ProjectConfig {
  ProjectConfig({
    required this.ingestUrl,
    required this.activate,
    required this.network,
    required this.lowEndDevices,
    required this.screenCapture,
    this.reportUrl,
    this.lean = false,
    this.maskingMode = MaskingMode.strict,
  });

  factory ProjectConfig.fromJson(String json) {
    final jsonData = jsonDecode(json) as Map<String, dynamic>;
    return ProjectConfig(
      ingestUrl: jsonData['ingestUrl'] as String,
      reportUrl: jsonData['reportUrl'] is String && (jsonData['reportUrl'] as String).isNotEmpty
          ? jsonData['reportUrl'] as String
          : null,
      activate: jsonData['activate'] as bool,
      lean: jsonData['lean'] as bool? ?? false,
      maskingMode: MaskingMode.values[jsonData['maskingMode'] as int],
      network: NetworkConfig.fromJson(jsonData['network'] as Map<String, dynamic>),
      lowEndDevices: LowEndDevicesConfig.fromJson(jsonData['lowEndDevices'] as Map<String, dynamic>),
      screenCapture: ScreenCaptureConfig.fromJson(jsonData['screenCapture'] as Map<String, dynamic>),
    );
  }

  String ingestUrl;
  String? reportUrl;
  bool activate;
  bool lean;
  MaskingMode maskingMode;
  NetworkConfig network;
  LowEndDevicesConfig lowEndDevices;
  ScreenCaptureConfig screenCapture;

  @override
  String toString() {
    return 'ProjectConfig{ingestUrl: $ingestUrl, reportUrl: $reportUrl, activate: $activate, lean: $lean, maskingMode: $maskingMode}';
  }
}
