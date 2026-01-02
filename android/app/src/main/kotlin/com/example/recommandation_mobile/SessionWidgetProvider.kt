package com.example.recommandation_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

// --- Constants (Clean Code) ---
object WidgetKeys {
    const val STATE = "widget_state"
    const val DAY_NAME = "dayName"
    const val DAY_NUMBER = "dayNumber"
    const val MONTH_NAME = "monthName"
    const val DURATION = "durationMinutes"
    const val TYPE = "sessionType"
    const val EXERCISE_1 = "exercise1"
    const val EXERCISE_2 = "exercise2"
}

object WidgetStates {
    const val NEW_USER = "new_user"
    const val SESSION = "session"
    const val EMPTY = "empty"
}

class SessionWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val renderer = WidgetRenderer(context)
        for (appWidgetId in appWidgetIds) {
            renderer.render(appWidgetManager, appWidgetId)
        }
    }
}

/**
 * SRP: Handles the logic of fetching data and rendering the view.
 */
private class WidgetRenderer(private val context: Context) {
    companion object {
        private const val TAG = "SessionWidgetRenderer"
    }

    fun render(appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val prefs = getPreferences()
        val state = prefs.getString(WidgetKeys.STATE, "") ?: ""
        
        Log.d(TAG, "Rendering widget $appWidgetId with state: '$state'")

        val views = RemoteViews(context.packageName, R.layout.widget_session)

        when (state) {
            WidgetStates.NEW_USER -> renderNewUserState(views)
            WidgetStates.SESSION -> renderSessionState(views, prefs)
            WidgetStates.EMPTY -> renderEmptyState(views, prefs)
            else -> {
                // Fallback / Initial logic
                Log.d(TAG, "Unknown state, checking data presence...")
                val dayName = prefs.getString(WidgetKeys.DAY_NAME, null)
                if (dayName == null || dayName == "Aucune") {
                     // If dayName is "Aucune" it might be the old empty state
                     // But if null, it's truly empty.
                     // Let's assume New User if completely empty
                     if (dayName == null) renderNewUserState(views) else renderSessionState(views, prefs)
                } else {
                     renderSessionState(views, prefs)
                }
            }
        }

        setupClickListener(views)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun getPreferences(): SharedPreferences {
        // Priority to internal plugin file
        var prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        if (prefs.all.isNotEmpty()) return prefs

        // Fallback checks
        prefs = context.getSharedPreferences("home_widget", Context.MODE_PRIVATE)
        if (prefs.all.isNotEmpty()) return prefs
        
        return HomeWidgetPlugin.getData(context)
    }

    private fun safelyGetString(prefs: SharedPreferences, key: String, defValue: String): String {
        return try {
            prefs.getString(key, defValue) ?: defValue
        } catch (e: ClassCastException) {
            // Fallback for when data was saved as Int/Long
             prefs.all[key]?.toString() ?: defValue
        }
    }

    private fun renderNewUserState(views: RemoteViews) {
        Log.d(TAG, "Applying NEW USER View")
        views.setViewVisibility(R.id.ll_session_content, View.GONE)
        views.setViewVisibility(R.id.ll_new_user, View.VISIBLE)
    }

    private fun renderSessionState(views: RemoteViews, prefs: SharedPreferences) {
        Log.d(TAG, "Applying SESSION View")
        views.setViewVisibility(R.id.ll_new_user, View.GONE)
        views.setViewVisibility(R.id.ll_session_content, View.VISIBLE)

        views.setTextViewText(R.id.widget_day_name, prefs.getString(WidgetKeys.DAY_NAME, "Séance"))
        views.setTextViewText(R.id.widget_day_number, safelyGetString(prefs, WidgetKeys.DAY_NUMBER, ""))
        views.setTextViewText(R.id.widget_month_name, prefs.getString(WidgetKeys.MONTH_NAME, ""))
        
        val duration = safelyGetString(prefs, WidgetKeys.DURATION, "0")
        views.setTextViewText(R.id.widget_duration, "$duration min")
        
        views.setTextViewText(R.id.widget_session_type, prefs.getString(WidgetKeys.TYPE, "SÉANCE"))
        
        views.setTextViewText(R.id.widget_exercise_1, prefs.getString(WidgetKeys.EXERCISE_1, ""))
        views.setTextViewText(R.id.widget_exercise_2, prefs.getString(WidgetKeys.EXERCISE_2, ""))
    }

    private fun renderEmptyState(views: RemoteViews, prefs: SharedPreferences) {
        Log.d(TAG, "Applying EMPTY View")
        renderSessionState(views, prefs)
    }

    private fun setupClickListener(views: RemoteViews) {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
    }
}
