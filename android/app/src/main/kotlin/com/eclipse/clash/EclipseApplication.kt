package com.eclipse.clash

import android.app.Application
import android.content.Context
import com.eclipse.clash.common.GlobalState

class EclipseApplication : Application() {
    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }
}
