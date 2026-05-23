/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:io';

// 🌎 Project imports:
import 'package:clarity_flutter/src/native/device_info.dart';

class HostInfo {
  HostInfo._({
    required this.defaultScreenName,
    required this.userAgent,
    required this.model,
    required this.applicationVersion,
    required this.applicationFramework,
    required this.platformVersion,
    required this.deviceCoreCount,
    required this.totalMemory,
    this.deviceFamily,
  });
  final String defaultScreenName;
  final String userAgent;
  final String model;
  final String applicationVersion;
  final String applicationFramework;
  final String platformVersion;
  final int deviceCoreCount;
  final int totalMemory;
  String? deviceFamily;

  static HostInfo? _instance;

  static Future<HostInfo> ensureInitialized({
    required String applicationVersion,
    required String userAgent,
    required DeviceInfo deviceInfo,
  }) async {
    if (_instance != null) return _instance!;

    String model;
    String applicationFramework;
    String defaultScreenName;
    String? deviceFamily;

    if (Platform.isAndroid) {
      model = deviceInfo.brand ?? '';
      applicationFramework = 'Flutter Android';
      defaultScreenName = 'FlutterActivity';
    } else if (Platform.isIOS) {
      model = 'Apple';
      applicationFramework = 'Flutter iOS';
      defaultScreenName = 'FlutterViewController';
      deviceFamily = deviceInfo.machine ?? '';
    } else {
      model = '';
      applicationFramework = '';
      defaultScreenName = 'Unsupported';
    }

    _instance = HostInfo._(
      defaultScreenName: defaultScreenName,
      userAgent: userAgent,
      model: model,
      applicationVersion: applicationVersion,
      applicationFramework: applicationFramework,
      platformVersion: Platform.operatingSystemVersion,
      deviceCoreCount: Platform.numberOfProcessors,
      totalMemory: deviceInfo.totalMemory,
      deviceFamily: deviceFamily,
    );

    return _instance!;
  }
}

enum ApplicationPlatform {
  web,
  android,
  ios;

  static ApplicationPlatform getCurrentPlatform() {
    if (Platform.isAndroid) {
      return ApplicationPlatform.android;
    } else if (Platform.isIOS) {
      return ApplicationPlatform.ios;
    } else {
      return ApplicationPlatform.web;
    }
  }
}
