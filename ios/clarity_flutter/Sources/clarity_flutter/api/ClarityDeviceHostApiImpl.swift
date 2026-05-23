// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

internal class ClarityDeviceHostApiImpl: ClarityDeviceHostApi {

    func getDeviceInfo() throws -> DeviceInfoData { DeviceBridge.getDeviceInfo() }

    func getPackageInfo() throws -> PackageInfoData { DeviceBridge.getPackageInfo() }

    func getCacheDirectory() throws -> String? { DeviceBridge.getCacheDirectory() }

    func getUserAgent() throws -> String { DeviceBridge.getUserAgent() }
}
