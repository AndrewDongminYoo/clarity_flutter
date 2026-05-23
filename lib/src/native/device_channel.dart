/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/native/device_info.dart';
import 'package:clarity_flutter/src/native/generated/messages.g.dart';
import 'package:clarity_flutter/src/native/package_info.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class DeviceChannel {
  DeviceChannel._();

  static final ClarityDeviceHostApi _api = ClarityDeviceHostApi();

  static Future<DeviceInfo> getDeviceInfo() async {
    try {
      final data = await _api.getDeviceInfo();
      return DeviceInfo(brand: data.brand, machine: data.machine, totalMemory: data.totalMemory);
    } catch (e, st) {
      Logger.error?.out('Failed to get device info: $e', stackTrace: st);
      return DeviceInfo.empty;
    }
  }

  static Future<PackageInfo> getPackageInfo() async {
    try {
      final data = await _api.getPackageInfo();
      return PackageInfo(packageName: data.packageName, version: data.version, buildNumber: data.buildNumber);
    } catch (e, st) {
      Logger.error?.out('Failed to get package info: $e', stackTrace: st);
      return PackageInfo.empty;
    }
  }

  static Future<String?> getCacheDirectory() async {
    try {
      return await _api.getCacheDirectory();
    } catch (e, st) {
      Logger.error?.out('Failed to get cache directory: $e', stackTrace: st);
      return null;
    }
  }

  static Future<String> getUserAgent() async {
    try {
      return await _api.getUserAgent();
    } catch (e, st) {
      Logger.error?.out('Failed to get user agent: $e', stackTrace: st);
      return '';
    }
  }
}
