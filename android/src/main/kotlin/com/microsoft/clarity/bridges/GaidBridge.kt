// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

package com.microsoft.clarity.bridges

import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build

internal object GaidBridge {
    @SuppressLint("PrivateApi")
    fun getGaid(context: Context): String? {
        try {
            // On Android 13+ (API 33+) require the AD_ID permission.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                val granted =
                    try {
                        context.checkSelfPermission("com.google.android.gms.permission.AD_ID") ==
                            PackageManager.PERMISSION_GRANTED
                    } catch (_: Throwable) {
                        false
                    }
                if (!granted) return null
            }

            val clientClass =
                Class.forName(
                    "com.google.android.gms.ads.identifier.AdvertisingIdClient",
                )
            val getInfoMethod =
                clientClass.getDeclaredMethod(
                    "getAdvertisingIdInfo",
                    Context::class.java,
                )
            val info = getInfoMethod.invoke(null, context) ?: return null

            val infoClass =
                Class.forName(
                    "com.google.android.gms.ads.identifier.AdvertisingIdClient\$Info",
                )

            val isLatMethod = infoClass.getDeclaredMethod("isLimitAdTrackingEnabled")
            val limitAdTracking = (isLatMethod.invoke(info) as? Boolean) == true
            if (limitAdTracking) return null

            val getIdMethod = infoClass.getDeclaredMethod("getId")
            val rawId = (getIdMethod.invoke(info) as? String)?.trim().orEmpty()
            if (rawId.isEmpty()) return null

            val normalized = rawId.replace("-", "").lowercase()
            val zeroed = normalized.isNotEmpty() && normalized.all { it == '0' }
            if (zeroed) return null

            return rawId
        } catch (_: Throwable) {
            return null
        }
    }
}
