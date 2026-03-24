package com.vm.focusx

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * FocusX home-screen widget.
 *
 * Data is stored in SharedPreferences by the Flutter [home_widget] package under
 * the name "HomeWidgetPlugin".  Keys written by [WidgetService.refresh()] in the
 * Flutter layer are read here and displayed in the widget layout.
 */
class FocusXWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPlugin", Context.MODE_PRIVATE)

        val completedTasks = prefs.getInt("completedTasks", 0)
        val totalTasks     = prefs.getInt("totalTasks", 0)
        val completedHabits = prefs.getInt("completedHabits", 0)
        val totalHabits     = prefs.getInt("totalHabits", 0)

        val views = RemoteViews(context.packageName, R.layout.focusx_widget)

        // Task stat: "2 / 5 done"
        views.setTextViewText(R.id.widget_tasks_stat, "$completedTasks / $totalTasks done")
        // Habit stat: "3 / 4 done"
        views.setTextViewText(R.id.widget_habits_stat, "$completedHabits / $totalHabits done")

        // Tap anywhere on the widget to open the app
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launchIntent != null) {
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title,    pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_open_btn, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_tasks_stat,  pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_habits_stat, pendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
