package com.pigcat.clash

import android.app.Application
import android.content.Context
import com.pigcat.clash.common.GlobalState

class PigCatApplication : Application() {
    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }
}
