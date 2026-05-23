// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

package com.microsoft.clarity.api

import android.content.Context
import com.microsoft.clarity.bridges.GaidBridge
import com.microsoft.clarity.generated.ClarityGaidHostApi

internal class ClarityGaidHostApiImpl(
    private val context: Context,
) : ClarityGaidHostApi {
    override fun getGaid(): String? = GaidBridge.getGaid(context)
}
