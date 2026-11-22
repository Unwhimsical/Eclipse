package com.eclipse.clash

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews
import com.eclipse.clash.common.QuickAction
import com.eclipse.clash.common.quickIntent

class ConnectWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        push(context, ServiceState.runState.value)
    }

    companion object {
        fun push(context: Context, state: RunState) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, ConnectWidgetProvider::class.java),
            )
            if (ids.isEmpty()) return
            val views = remoteViews(context, state)
            manager.updateAppWidget(ids, views)
        }

        private fun remoteViews(context: Context, state: RunState): RemoteViews {
            val active = state == RunState.STARTED
            val views = RemoteViews(context.packageName, R.layout.widget_connect)
            views.setTextViewText(
                R.id.widget_label,
                context.getString(if (active) R.string.widget_on else R.string.widget_off),
            )
            val pending = PendingIntent.getActivity(
                context,
                7,
                QuickAction.TOGGLE.quickIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            return views
        }
    }
}
