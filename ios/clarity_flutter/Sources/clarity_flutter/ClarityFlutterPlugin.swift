// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import Flutter

public class ClarityFlutterPlugin: NSObject, FlutterPlugin {

    private var networkBridge: NetworkBridge?
    private var connectivityStreamHandler: ConnectivityChangedStreamHandlerImpl?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = ClarityFlutterPlugin()
        let messenger = registrar.messenger()

        ClarityDeviceHostApiSetup.setUp(
            binaryMessenger: messenger,
            api: ClarityDeviceHostApiImpl()
        )

        ClarityGaidHostApiSetup.setUp(
            binaryMessenger: messenger,
            api: ClarityGaidHostApiImpl()
        )

        let bridge = NetworkBridge()
        instance.networkBridge = bridge
        ClarityNetworkHostApiSetup.setUp(
            binaryMessenger: messenger,
            api: ClarityNetworkHostApiImpl(networkBridge: bridge)
        )
        let streamHandler = ConnectivityChangedStreamHandlerImpl(networkBridge: bridge)
        instance.connectivityStreamHandler = streamHandler
        ConnectivityChangedStreamHandler.register(
            with: messenger,
            streamHandler: streamHandler
        )
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        ClarityDeviceHostApiSetup.setUp(binaryMessenger: messenger, api: nil)
        ClarityGaidHostApiSetup.setUp(binaryMessenger: messenger, api: nil)
        ClarityNetworkHostApiSetup.setUp(binaryMessenger: messenger, api: nil)
        connectivityStreamHandler?.dispose()
        connectivityStreamHandler = nil
        networkBridge = nil
    }
}
