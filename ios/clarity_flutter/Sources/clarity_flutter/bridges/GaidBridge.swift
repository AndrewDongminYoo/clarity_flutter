// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import Foundation

/// GAID is an Android-only concept. iOS uses IDFA via `AdSupport` framework
/// which the SDK does not request. Returning nil keeps the Pigeon contract
/// honored on iOS while the Dart layer guards calls with `Platform.isAndroid`.
internal enum GaidBridge {
    static func getGaid() -> String? { nil }
}
