// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import Foundation

internal class ClarityNetworkHostApiImpl: ClarityNetworkHostApi {

    private let networkBridge: NetworkBridge

    init(networkBridge: NetworkBridge) {
        self.networkBridge = networkBridge
    }

    func getConnectivityStatus() throws -> [ConnectivityType] {
        return networkBridge.getNetworkTypes()
    }
}

internal class ConnectivityChangedStreamHandlerImpl: ConnectivityChangedStreamHandler {

    private let networkBridge: NetworkBridge

    init(networkBridge: NetworkBridge) {
        self.networkBridge = networkBridge
    }

    override func onListen(
        withArguments arguments: Any?,
        sink: PigeonEventSink<ConnectivityChangedEventData>
    ) {
        networkBridge.startListening { [weak sink] types in
            DispatchQueue.main.async {
                sink?.success(ConnectivityChangedEventData(types: types))
            }
        }
    }

    override func onCancel(withArguments arguments: Any?) {
        networkBridge.stopListening()
    }

    func dispose() {
        networkBridge.stopListening()
    }
}
