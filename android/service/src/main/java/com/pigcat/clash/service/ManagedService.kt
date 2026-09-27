package com.pigcat.clash.service

import android.app.Service
import com.pigcat.clash.common.BroadcastAction
import com.pigcat.clash.common.GlobalState
import com.pigcat.clash.common.sendBroadcast

interface ManagedService {
    fun start()

    fun stop()
}

internal fun Service.notifyVpnStartRequested() {
    GlobalState.log("VPN start requested")
    BroadcastAction.VPN_START_REQUESTED.sendBroadcast()
}

internal fun Service.notifyVpnRevoked() {
    GlobalState.log("VPN permission revoked")
    BroadcastAction.VPN_REVOKED.sendBroadcast()
}
