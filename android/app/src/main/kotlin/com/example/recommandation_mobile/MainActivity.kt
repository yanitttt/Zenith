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
import java.io.RandomAccessFile
import java.lang.Exception

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.recommandation_mobile/perf"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryInfo") {
                result.success(getBatteryInfo())
            } else if (call.method == "getResourceInfo") {
                result.success(getResourceInfo())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryInfo(): Map<String, Any?> {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        
        // Niveau et statut via Intent sticky
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus = registerReceiver(null, intentFilter)
        
        val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val batteryPct = if (level != -1 && scale != -1) (level / scale.toFloat() * 100).toInt() else -1

        val status = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                         status == BatteryManager.BATTERY_STATUS_FULL

        val temp = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: -1
        val temperature = if (temp != -1) temp / 10.0 else -1.0

        // Courant (si dispo, API 21+)
        var currentNow = -1
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
             currentNow = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
        }

        return mapOf(
            "level" to batteryPct,
            "isCharging" to isCharging,
            "temperature" to temperature,
            "current_uA" to currentNow
        )
    }

    private fun getResourceInfo(): Map<String, Any?> {
        // Mémoire Java Heap
        val runtime = Runtime.getRuntime()
        val usedMem = (runtime.totalMemory() - runtime.freeMemory()) / 1024 / 1024 // MB

        // Native Heap
        val nativeHeap = Debug.getNativeHeapAllocatedSize() / 1024 / 1024 // MB

        // CPU Time (approx via /proc/self/stat) - champs 13 (utime) + 14 (stime)
        var cpuTimeMs: Long = -1
        try {
             val reader = RandomAccessFile("/proc/self/stat", "r")
             val line = reader.readLine()
             reader.close()
             if (line != null) {
                 val parts = line.split(" ")
                 if (parts.size > 14) {
                     val utime = parts[13].toLong()
                     val stime = parts[14].toLong()
                     // Renvoie des "ticks" bruts. C'est relatif, utile pour delta.
                     cpuTimeMs = utime + stime
                 }
             }
        } catch (e: Exception) {
            // Ignorer
        }

        return mapOf(
            "java_heap_mb" to usedMem,
            "native_heap_mb" to nativeHeap,
            "cpu_time_ticks" to cpuTimeMs
        )
    }
}

