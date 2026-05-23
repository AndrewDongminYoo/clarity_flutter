/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

class PackageInfo {
  const PackageInfo({this.packageName = '', this.version = '', this.buildNumber = ''});

  factory PackageInfo.fromMap(Map<String, dynamic> map) {
    return PackageInfo(
      packageName: (map['packageName'] as String?) ?? '',
      version: (map['version'] as String?) ?? '',
      buildNumber: (map['buildNumber'] as String?) ?? '',
    );
  }

  static const PackageInfo empty = PackageInfo();

  final String packageName;
  final String version;
  final String buildNumber;

  @override
  String toString() => 'PackageInfo(packageName: $packageName, version: $version, buildNumber: $buildNumber)';
}
