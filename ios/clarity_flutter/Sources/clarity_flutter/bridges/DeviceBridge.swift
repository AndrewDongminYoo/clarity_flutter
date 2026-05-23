// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import Foundation
import UIKit

internal struct DeviceBridge {

    private static let bytesPerMb: UInt64 = 1_048_576

    static func getDeviceInfo() -> DeviceInfoData {
        #if targetEnvironment(simulator)
        let machine = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "unknown"
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        #endif

        let totalMemoryMb = Int64(clamping: ProcessInfo.processInfo.physicalMemory / bytesPerMb)
        return DeviceInfoData(brand: nil, machine: machine, totalMemory: totalMemoryMb)
    }

    static func getPackageInfo() -> PackageInfoData {
        let bundle = Bundle.main
        let infoDictionary = bundle.infoDictionary ?? [:]
        return PackageInfoData(
            packageName: bundle.bundleIdentifier ?? "",
            version: (infoDictionary["CFBundleShortVersionString"] as? String) ?? "",
            buildNumber: (infoDictionary["CFBundleVersion"] as? String) ?? ""
        )
    }

    static func getCacheDirectory() -> String? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.path
    }

    static func getUserAgent() -> String {
        let device = UIDevice.current
        let osString = device.systemVersion.replacingOccurrences(of: ".", with: "_")
        return "Mozilla/5.0 (\(device.model); CPU iPhone OS \(osString) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
    }
}
