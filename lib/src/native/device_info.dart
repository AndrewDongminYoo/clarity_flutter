/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

class DeviceInfo {
  const DeviceInfo({this.brand, this.machine, this.totalMemory = 0});
  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      brand: map['brand'] as String?,
      machine: map['machine'] as String?,
      totalMemory: (map['totalMemory'] as num?)?.toInt() ?? 0,
    );
  }
  static const DeviceInfo empty = DeviceInfo();

  final String? brand;
  final String? machine;
  final int totalMemory;

  @override
  String toString() =>
      'DeviceInfo(brand: $brand, machine: $machine, '
      'totalMemory: $totalMemory)';
}
