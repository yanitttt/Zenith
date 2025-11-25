package com.example.recommandation_mobile

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.util.Log

private const val TAG = "SessionWidgetProvider"

/**
 * Widget Android natif pour afficher la prochaine séance d'entraînement
 * sur l'écran d'accueil du téléphone.
 *
 * Ce widget récupère les données depuis SharedPreferences
 * qui communique avec l'application Flutter via home_widget.
 */
class SessionWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate called with ${appWidgetIds.size} widgets")
        for (appWidgetId in appWidgetIds) {
            Log.d(TAG, "Updating widget $appWidgetId")
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            Log.d(TAG, "=== updateAppWidget START ===")
            Log.d(TAG, "Package name: ${context.packageName}")
            Log.d(TAG, "Widget ID: $appWidgetId")

            val views = RemoteViews(context.packageName, R.layout.widget_session)

            try {
                Log.d(TAG, "Starting SharedPreferences lookup...")

                // Récupérer les données depuis SharedPreferences
                var sharedPref = context.getSharedPreferences(
                    context.packageName + "_preferences",
                    Context.MODE_PRIVATE
                )

                Log.d(TAG, "First location (${context.packageName}_preferences) has ${sharedPref.all.size} keys")

                // Si vide, essayer home_widget
                if (sharedPref.all.isEmpty()) {
                    Log.d(TAG, "First location empty, trying 'home_widget'...")
                    sharedPref = context.getSharedPreferences(
                        "home_widget",
                        Context.MODE_PRIVATE
                    )
                    Log.d(TAG, "home_widget has ${sharedPref.all.size} keys")
                }

                // Afficher tous les contenus de SharedPreferences
                Log.d(TAG, "SharedPreferences contents:")
                for ((key, value) in sharedPref.all) {
                    Log.d(TAG, "  $key = $value")
                }

                // Vérifier si on a des données réelles
                val dayNameValue = sharedPref.getString("dayName", "")
                Log.d(TAG, "dayName value: '$dayNameValue'")
                val hasRealData = sharedPref.contains("dayName") &&
                                  (sharedPref.getString("dayName", "")?.isNotEmpty() ?: false)
                Log.d(TAG, "hasRealData: $hasRealData")

                // Mettre à jour les champs texte
                views.setTextViewText(
                    R.id.widget_day_name,
                    sharedPref.getString("dayName", "Lundi") ?: "Lundi"
                )
                views.setTextViewText(
                    R.id.widget_day_number,
                    sharedPref.getString("dayNumber", "15") ?: "15"
                )
                views.setTextViewText(
                    R.id.widget_month_name,
                    sharedPref.getString("monthName", "Novembre") ?: "Novembre"
                )
                views.setTextViewText(
                    R.id.widget_duration,
                    "${sharedPref.getString("durationMinutes", "60") ?: "60"} min"
                )
                views.setTextViewText(
                    R.id.widget_session_type,
                    sharedPref.getString("sessionType", "PUSH") ?: "PUSH"
                )
                views.setTextViewText(
                    R.id.widget_exercise_1,
                    sharedPref.getString("exercise1", "Squat\n4 séries / 8 reps / 60kg de charge") ?: "Squat\n4 séries / 8 reps / 60kg de charge"
                )
                views.setTextViewText(
                    R.id.widget_exercise_2,
                    sharedPref.getString("exercise2", "Tapis\n4 séries / 8 reps / 60kg de charge") ?: "Tapis\n4 séries / 8 reps / 60kg de charge"
                )

                // Afficher/masquer le tag DEMO
                val demoTagVisibility = if (hasRealData) android.view.View.GONE else android.view.View.VISIBLE
                views.setViewVisibility(R.id.widget_demo_tag, demoTagVisibility)

            } catch (e: Exception) {
                // En cas d'erreur, afficher les données par défaut avec tag DEMO
                Log.e(TAG, "ERROR: ${e.message}", e)
                Log.e(TAG, "Stack trace:", e)

                views.setTextViewText(R.id.widget_day_name, "Lundi")
                views.setTextViewText(R.id.widget_day_number, "15")
                views.setTextViewText(R.id.widget_month_name, "Novembre")
                views.setTextViewText(R.id.widget_duration, "60 min")
                views.setTextViewText(R.id.widget_session_type, "PUSH")
                views.setTextViewText(R.id.widget_exercise_1, "Squat\n4 séries / 8 reps / 60kg de charge")
                views.setTextViewText(R.id.widget_exercise_2, "Tapis\n4 séries / 8 reps / 60kg de charge")
                views.setViewVisibility(R.id.widget_demo_tag, android.view.View.VISIBLE)
            }

            // Intent au clic du widget pour ouvrir l'app
            try {
                Log.d(TAG, "Setting up click intent...")
                val intent = Intent(context, MainActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
                Log.d(TAG, "Click intent set successfully")
            } catch (e: Exception) {
                Log.e(TAG, "ERROR setting click intent: ${e.message}", e)
            }

            try {
                Log.d(TAG, "Updating widget in AppWidgetManager...")
                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "=== updateAppWidget SUCCESS ===")
            } catch (e: Exception) {
                Log.e(TAG, "ERROR updating widget: ${e.message}", e)
                Log.d(TAG, "=== updateAppWidget FAILED ===")
            }
        }
    }
}
