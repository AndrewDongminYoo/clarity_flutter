// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import Foundation
import Network

internal class NetworkBridge {

    private var pathMonitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "com.microsoft.clarity.network")
    private var connectivityUpdateHandler: (([ConnectivityType]) -> Void)?

    func getNetworkTypes() -> [ConnectivityType] {
        return connectivityTypes(from: ensurePathMonitor().currentPath)
    }

    func startListening(onChanged: @escaping ([ConnectivityType]) -> Void) {
        connectivityUpdateHandler = onChanged
        _ = ensurePathMonitor()
    }

    func stopListening() {
        pathMonitor?.cancel()
        pathMonitor = nil
        connectivityUpdateHandler = nil
    }

    @discardableResult
    private func ensurePathMonitor() -> NWPathMonitor {
        if let existing = pathMonitor {
            return existing
        }
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let types = self.connectivityTypes(from: path)
            DispatchQueue.main.async {
                self.connectivityUpdateHandler?(types)
            }
        }
        monitor.start(queue: queue)
        pathMonitor = monitor
        return monitor
    }

    private func connectivityTypes(from path: NWPath) -> [ConnectivityType] {
        guard path.status == .satisfied else {
            return [.none]
        }

        var types: [ConnectivityType] = []
        if path.usesInterfaceType(.wifi) {
            types.append(.wifi)
        }
        if path.usesInterfaceType(.cellular) {
            types.append(.mobile)
        }
        if path.usesInterfaceType(.wiredEthernet) {
            types.append(.ethernet)
        }
        if types.isEmpty {
            types.append(.other)
        }
        return types
    }
}