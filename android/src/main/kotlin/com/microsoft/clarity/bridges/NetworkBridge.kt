// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

package com.microsoft.clarity.bridges

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.microsoft.clarity.generated.ConnectivityType

internal class NetworkBridge(
    private val context: Context,
) {
    private val connectivityManager =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private val mainHandler = Handler(Looper.getMainLooper())
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private var broadcastReceiver: BroadcastReceiver? = null

    fun getNetworkTypes(): List<ConnectivityType> {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network =
                    connectivityManager.activeNetwork
                        ?: return listOf(ConnectivityType.NONE)
                capabilitiesList(connectivityManager.getNetworkCapabilities(network))
            } else {
                legacyNetworkTypes()
            }
        } catch (_: Throwable) {
            listOf(ConnectivityType.NONE)
        }
    }

    fun startListening(onChanged: (List<ConnectivityType>) -> Unit) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val callback =
                object : ConnectivityManager.NetworkCallback() {
                    override fun onAvailable(network: Network) {
                        val types = capabilitiesList(connectivityManager.getNetworkCapabilities(network))
                        mainHandler.post { onChanged(types) }
                    }

                    override fun onCapabilitiesChanged(
                        network: Network,
                        networkCapabilities: NetworkCapabilities,
                    ) {
                        val types = capabilitiesList(networkCapabilities)
                        mainHandler.post { onChanged(types) }
                    }

                    override fun onLost(network: Network) {
                        mainHandler.postDelayed({ onChanged(getNetworkTypes()) }, 500)
                    }
                }
            connectivityManager.registerDefaultNetworkCallback(callback)
            networkCallback = callback
        } else {
            @Suppress("DEPRECATION")
            val receiver =
                object : BroadcastReceiver() {
                    override fun onReceive(
                        ctx: Context?,
                        intent: Intent?,
                    ) {
                        onChanged(getNetworkTypes())
                    }
                }
            @Suppress("DEPRECATION")
            context.registerReceiver(
                receiver,
                IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION),
            )
            broadcastReceiver = receiver
        }

        mainHandler.post { onChanged(getNetworkTypes()) }
    }

    fun stopListening() {
        networkCallback?.let {
            try {
                connectivityManager.unregisterNetworkCallback(it)
            } catch (_: Throwable) {
            }
            networkCallback = null
        }
        broadcastReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (_: Throwable) {
            }
            broadcastReceiver = null
        }
    }

    private fun capabilitiesList(capabilities: NetworkCapabilities?): List<ConnectivityType> {
        if (capabilities == null ||
            !capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        ) {
            return listOf(ConnectivityType.NONE)
        }

        val types = mutableListOf<ConnectivityType>()
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
            types.add(ConnectivityType.WIFI)
        }
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
            types.add(ConnectivityType.MOBILE)
        }
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
            types.add(ConnectivityType.ETHERNET)
        }
        return types.ifEmpty { listOf(ConnectivityType.OTHER) }
    }

    @Suppress("DEPRECATION")
    private fun legacyNetworkTypes(): List<ConnectivityType> {
        val info =
            connectivityManager.activeNetworkInfo
                ?: return listOf(ConnectivityType.NONE)
        if (!info.isConnected) return listOf(ConnectivityType.NONE)

        return when (info.type) {
            ConnectivityManager.TYPE_WIFI -> listOf(ConnectivityType.WIFI)
            ConnectivityManager.TYPE_MOBILE -> listOf(ConnectivityType.MOBILE)
            ConnectivityManager.TYPE_ETHERNET -> listOf(ConnectivityType.ETHERNET)
            else -> listOf(ConnectivityType.OTHER)
        }
    }
}
