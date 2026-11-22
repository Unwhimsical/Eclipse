package com.eclipse.clash

import android.app.Application
import android.content.Context
import com.eclipse.clash.common.GlobalState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class EclipseApplication : Application() {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }

    override fun onCreate() {
        super.onCreate()
        scope.launch {
            ServiceState.runState.collect { state ->
                ConnectWidgetProvider.push(this@EclipseApplication, state)
            }
        }
    }
}
