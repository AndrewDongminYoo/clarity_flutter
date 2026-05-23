/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:io';

// 🌎 Project imports:
import 'package:clarity_flutter/src/native/device_channel.dart';
import 'package:clarity_flutter/src/native/device_info.dart';
import 'package:clarity_flutter/src/native/gaid_channel.dart';
import 'package:clarity_flutter/src/native/generated/messages.g.dart' as pigeon;
import 'package:clarity_flutter/src/native/network_channel.dart';
import 'package:clarity_flutter/src/native/package_info.dart';

class ClarityPlatform {
  ClarityPlatform._();

  static Future<DeviceInfo> getDeviceInfo() => DeviceChannel.getDeviceInfo();

  static Future<PackageInfo> getPackageInfo() => DeviceChannel.getPackageInfo();

  static Future<Directory> getCacheDirectory() async {
    final path = await DeviceChannel.getCacheDirectory();
    if (path == null) return Directory.systemTemp;
    return Directory(path);
  }

  static Future<String> getUserAgent() => DeviceChannel.getUserAgent();

  static Future<List<pigeon.ConnectivityType>> getConnectivityStatus() => NetworkChannel.getConnectivityStatus();

  static Stream<List<pigeon.ConnectivityType>> get onConnectivityChanged => NetworkChannel.onConnectivityChanged;

  static Future<String?> getGaid() => GaidChannel.getGaid();
}
