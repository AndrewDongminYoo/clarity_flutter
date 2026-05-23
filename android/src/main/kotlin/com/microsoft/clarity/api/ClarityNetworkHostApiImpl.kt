// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

package com.microsoft.clarity.api

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.microsoft.clarity.bridges.NetworkBridge
import com.microsoft.clarity.generated.ClarityNetworkHostApi
import com.microsoft.clarity.generated.ConnectivityChangedEventData
import com.microsoft.clarity.generated.ConnectivityChangedStreamHandler
import com.microsoft.clarity.generated.ConnectivityType
import com.microsoft.clarity.generated.PigeonEventSink
import io.flutter.plugin.common.BinaryMessenger

internal class ClarityNetworkHostApiImpl(
    private val networkBridge: NetworkBridge,
) : ClarityNetworkHostApi {
    override fun getConnectivityStatus(): List<ConnectivityType> = networkBridge.getNetworkTypes()
}

internal class ConnectivityChangedStreamHandlerImpl(
    private val networkBridge: NetworkBridge,
) : ConnectivityChangedStreamHandler() {
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(
        p0: Any?,
        sink: PigeonEventSink<ConnectivityChangedEventData>,
    ) {
        networkBridge.startListening { types ->
            mainHandler.post {
                sink.success(ConnectivityChangedEventData(types = types))
            }
        }
    }

    override fun onCancel(p0: Any?) {
        networkBridge.stopListening()
    }

    fun dispose() {
        networkBridge.stopListening()
    }

    companion object {
        fun register(
            messenger: BinaryMessenger,
            networkBridge: NetworkBridge,
        ): ConnectivityChangedStreamHandlerImpl {
            val handler = ConnectivityChangedStreamHandlerImpl(networkBridge)
            ConnectivityChangedStreamHandler.register(messenger, handler)
            return handler
        }
    }
}
