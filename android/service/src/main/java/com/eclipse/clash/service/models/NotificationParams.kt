package com.eclipse.clash.service.models

data class NotificationParams(
    val title: String = "Eclipse",
    val stopText: String = "STOP",
    val onlyStatisticsProxy: Boolean = false,
    val showStopAction: Boolean = true,
)
