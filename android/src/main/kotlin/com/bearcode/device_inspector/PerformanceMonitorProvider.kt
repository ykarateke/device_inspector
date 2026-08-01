package com.bearcode.device_inspector

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PerformanceMonitorProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    private var isRunning = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startPerformanceMonitor" -> {
                isRunning = true
                result.success(null)
            }
            "stopPerformanceMonitor" -> {
                stopMonitoring()
                result.success(null)
            }
            "getPerformanceSnapshot" -> {
                result.success(getSnapshot())
            }
            else -> result.notImplemented()
        }
    }

    fun stopMonitoring() {
        isRunning = false
    }

    private fun getSnapshot(): Map<String, Any> = mapOf(
        "fps" to 60.0,
        "cpuUsagePercent" to 0.0,
        "appCpuUsagePercent" to 0.0,
        "memoryUsageMB" to 0.0,
        "memoryUsagePercent" to 0.0,
        "thermalState" to "nominal",
        "timestampMsSinceEpoch" to System.currentTimeMillis(),
        "batteryImpactLevel" to -1,
    )
}
