// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

package com.microsoft.clarity.api

import android.content.Context
import com.microsoft.clarity.bridges.DeviceBridge
import com.microsoft.clarity.generated.ClarityDeviceHostApi
import com.microsoft.clarity.generated.DeviceInfoData
import com.microsoft.clarity.generated.PackageInfoData

internal class ClarityDeviceHostApiImpl(
    private val context: Context,
) : ClarityDeviceHostApi {
    override fun getDeviceInfo(): DeviceInfoData = DeviceBridge.getDeviceInfo(context)

    override fun getPackageInfo(): PackageInfoData = DeviceBridge.getPackageInfo(context)

    override fun getCacheDirectory(): String? = DeviceBridge.getCacheDirectory(context)

    override fun getUserAgent(): String = DeviceBridge.getUserAgent(context)
}
