package com.example.recommandation_mobile

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Debug
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.recommandation_mobile/perf"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryInfo" -> {
                    result.success(getBatteryInfo())
                }
                "getMemoryInfo" -> {
                    result.success(getMemoryInfo())
                }
                "getCpuInfo" -> {
                    // CPU info est difficile à obtenir de manière fiable sans root sur les Android récents
                    // On retourne juste le nombre de cœurs pour l'instant
                    val cpuInfo = mapOf(
                        "available_processors" to Runtime.getRuntime().availableProcessors()
                    )
                    result.success(cpuInfo)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getBatteryInfo(): Map<String, Any> {
        val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
            context.registerReceiver(null, ifilter)
        }

        val level: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val batteryPct = if (level != -1 && scale != -1) level * 100 / scale.toFloat() else -1.0f

        val status: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL

        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        
        // Tentative de récupération des propriétés avancées (courant)
        // Note: Cela dépend fortement du matériel et peut ne pas fonctionner sur tous les appareils
        var currentMicroAmps = 0
        var energyCounter = 0L
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
             currentMicroAmps = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
             energyCounter = batteryManager.getLongProperty(BatteryManager.BATTERY_PROPERTY_ENERGY_COUNTER)
        }

        return mapOf(
            "level_percent" to batteryPct,
            "is_charging" to isCharging,
            "current_now_ua" to currentMicroAmps, // MicroAmpères
            "energy_counter_nwh" to energyCounter // NanoWattHeures
        )
    }

    private fun getMemoryInfo(): Map<String, Any> {
        val memInfo = Debug.MemoryInfo()
        Debug.getMemoryInfo(memInfo)
        
        // Total PSS (Proportional Set Size) en KB
        val totalPss = memInfo.totalPss
        // Total Private Dirty en KB
        val totalPrivateDirty = memInfo.totalPrivateDirty
        
        return mapOf(
            "total_pss_kb" to totalPss,
            "total_private_dirty_kb" to totalPrivateDirty
        )
    }
}
