import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/native/generated/messages.g.dart',
    kotlinOut: 'android/src/main/kotlin/com/microsoft/clarity/generated/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.microsoft.clarity.generated'),
    swiftOut: 'ios/clarity_flutter/Sources/clarity_flutter/generated/Messages.g.swift',
    dartPackageName: 'clarity_flutter',
  ),
)
class DeviceInfoData {
  DeviceInfoData({this.brand, this.machine, this.totalMemory = 0});

  String? brand;
  String? machine;
  int totalMemory;
}

class PackageInfoData {
  PackageInfoData({this.packageName = '', this.version = '', this.buildNumber = ''});

  String packageName;
  String version;
  String buildNumber;
}

enum ConnectivityType { wifi, mobile, ethernet, other, none }

/// Wraps the connectivity list because Pigeon's event-channel Dart generator
/// strips generic type arguments and would emit `Stream<List>` instead of
/// `Stream<List<ConnectivityType>>`.
class ConnectivityChangedEventData {
  ConnectivityChangedEventData({this.types = const <ConnectivityType>[]});

  List<ConnectivityType> types;
}

@HostApi()
abstract class ClarityDeviceHostApi {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  DeviceInfoData getDeviceInfo();

  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  PackageInfoData getPackageInfo();

  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  String? getCacheDirectory();

  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  String getUserAgent();
}

@HostApi()
abstract class ClarityNetworkHostApi {
  List<ConnectivityType> getConnectivityStatus();
}

@EventChannelApi()
abstract class ClarityNetworkEvents {
  ConnectivityChangedEventData connectivityChanged();
}

@HostApi()
abstract class ClarityGaidHostApi {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  String? getGaid();
}
