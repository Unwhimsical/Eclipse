package com.pigcat.clash.service.models

data class NotificationParams(
    val title: String = "PigCat",
    val stopText: String = "STOP",
    val onlyStatisticsProxy: Boolean = false,
    val showStopAction: Boolean = true,
)
