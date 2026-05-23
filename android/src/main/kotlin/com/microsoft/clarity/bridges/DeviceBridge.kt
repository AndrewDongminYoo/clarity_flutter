// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

package com.microsoft.clarity.bridges

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.webkit.WebSettings
import com.microsoft.clarity.generated.DeviceInfoData
import com.microsoft.clarity.generated.PackageInfoData

internal object DeviceBridge {
    private const val BYTES_PER_MB = 1_048_576L

    fun getDeviceInfo(context: Context): DeviceInfoData =
        try {
            val activityManager =
                context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
            val totalMemoryMb =
                if (activityManager != null) {
                    val memoryInfo = ActivityManager.MemoryInfo()
                    activityManager.getMemoryInfo(memoryInfo)
                    memoryInfo.totalMem / BYTES_PER_MB
                } else {
                    0L
                }
            DeviceInfoData(brand = Build.BRAND, machine = null, totalMemory = totalMemoryMb)
        } catch (_: Throwable) {
            DeviceInfoData(brand = null, machine = null, totalMemory = 0L)
        }

    fun getPackageInfo(context: Context): PackageInfoData =
        try {
            val packageName = context.packageName
            val info = context.packageManager.getPackageInfo(packageName, 0)
            val buildNumber =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    info.longVersionCode.toString()
                } else {
                    @Suppress("DEPRECATION")
                    info.versionCode.toString()
                }
            PackageInfoData(
                packageName = packageName,
                version = info.versionName ?: "",
                buildNumber = buildNumber,
            )
        } catch (_: Throwable) {
            PackageInfoData(packageName = "", version = "", buildNumber = "")
        }

    fun getCacheDirectory(context: Context): String? =
        try {
            context.cacheDir.path
        } catch (_: Throwable) {
            null
        }

    fun getUserAgent(context: Context): String =
        try {
            WebSettings.getDefaultUserAgent(context)
        } catch (_: Throwable) {
            ""
        }
}
