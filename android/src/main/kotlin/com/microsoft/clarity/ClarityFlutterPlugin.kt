// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

package com.microsoft.clarity

import android.content.Context
import com.microsoft.clarity.api.ClarityDeviceHostApiImpl
import com.microsoft.clarity.api.ClarityGaidHostApiImpl
import com.microsoft.clarity.api.ClarityNetworkHostApiImpl
import com.microsoft.clarity.api.ConnectivityChangedStreamHandlerImpl
import com.microsoft.clarity.bridges.NetworkBridge
import com.microsoft.clarity.generated.ClarityDeviceHostApi
import com.microsoft.clarity.generated.ClarityGaidHostApi
import com.microsoft.clarity.generated.ClarityNetworkHostApi
import io.flutter.embedding.engine.plugins.FlutterPlugin

class ClarityFlutterPlugin : FlutterPlugin {
    private var networkBridge: NetworkBridge? = null
    private var connectivityStreamHandler: ConnectivityChangedStreamHandlerImpl? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context: Context = binding.applicationContext
        val messenger = binding.binaryMessenger

        ClarityDeviceHostApi.setUp(messenger, ClarityDeviceHostApiImpl(context))
        ClarityGaidHostApi.setUp(messenger, ClarityGaidHostApiImpl(context))

        val bridge = NetworkBridge(context)
        networkBridge = bridge
        ClarityNetworkHostApi.setUp(messenger, ClarityNetworkHostApiImpl(bridge))
        connectivityStreamHandler =
            ConnectivityChangedStreamHandlerImpl.register(messenger, bridge)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        ClarityDeviceHostApi.setUp(binding.binaryMessenger, null)
        ClarityGaidHostApi.setUp(binding.binaryMessenger, null)
        ClarityNetworkHostApi.setUp(binding.binaryMessenger, null)
        connectivityStreamHandler?.dispose()
        connectivityStreamHandler = null
        networkBridge = null
    }
}
