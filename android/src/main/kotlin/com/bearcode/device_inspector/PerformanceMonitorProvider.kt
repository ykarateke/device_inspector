package com.bearcode.device_inspector

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.os.SystemClock
import android.view.Choreographer
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.RandomAccessFile

class PerformanceMonitorProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    private var isRunning = false
    private var currentFps = 0.0
    private var lastFrameTimeNanos = 0L

    private var prevIdle = 0L
    private var prevTotal = 0L
    private var prevAppCpuTimeMs = -1L
    private var prevAppWallClockMs = -1L

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (lastFrameTimeNanos != 0L) {
                val deltaNanos = frameTimeNanos - lastFrameTimeNanos
                if (deltaNanos > 0) {
                    currentFps = 1_000_000_000.0 / deltaNanos
                }
            }
            lastFrameTimeNanos = frameTimeNanos
            if (isRunning) {
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startPerformanceMonitor" -> {
                startMonitoring()
                result.success(null)
            }
            "stopPerformanceMonitor" -> {
                stopMonitoring()
                result.success(null)
            }
            "getPerformanceSnapshot" -> {
                CoroutineScope(Dispatchers.IO).launch {
                    result.success(getSnapshot())
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun startMonitoring() {
        if (isRunning) return
        isRunning = true
        lastFrameTimeNanos = 0L
        Choreographer.getInstance().postFrameCallback(frameCallback)
    }

    fun stopMonitoring() {
        isRunning = false
        currentFps = 0.0
    }

    private fun getSnapshot(): Map<String, Any?> {
        val appMemoryMB = getAppMemoryInfo()
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val systemMem = ActivityManager.MemoryInfo()
        am.getMemoryInfo(systemMem)

        return mapOf(
            "fps" to (if (isRunning) currentFps else 0.0),
            "cpuUsagePercent" to getSystemCpuUsagePercent(),
            "appCpuUsagePercent" to getAppCpuUsagePercent(),
            "memoryUsageMB" to appMemoryMB,
            "memoryUsagePercent" to if (systemMem.totalMem > 0) {
                (appMemoryMB * 1024.0 * 1024.0 / systemMem.totalMem) * 100.0
            } else {
                0.0
            },
            "thermalState" to getThermalState(),
            "timestampMsSinceEpoch" to System.currentTimeMillis(),
            "batteryImpactLevel" to -1,
        )
    }

    /// System-wide CPU usage from /proc/stat, sampled as a delta between calls.
    private fun getSystemCpuUsagePercent(): Double {
        return try {
            val reader = RandomAccessFile("/proc/stat", "r")
            val line = reader.readLine()
            reader.close()

            val parts = line.split(Regex("\\s+")).drop(1).mapNotNull { it.toLongOrNull() }
            if (parts.size < 4) return 0.0

            val idle = parts[3]
            val total = parts.sum()

            val result = if (prevTotal > 0) {
                val totalDelta = total - prevTotal
                val idleDelta = idle - prevIdle
                if (totalDelta > 0) ((totalDelta - idleDelta).toDouble() / totalDelta.toDouble()) * 100.0 else 0.0
            } else {
                0.0
            }

            prevIdle = idle
            prevTotal = total
            result
        } catch (e: Exception) {
            0.0
        }
    }

    /// This process's CPU usage: cumulative process CPU time delta over wall-clock delta.
    private fun getAppCpuUsagePercent(): Double {
        val cpuTimeMs = Process.getElapsedCpuTime()
        val wallClockMs = SystemClock.elapsedRealtime()

        val result = if (prevAppCpuTimeMs >= 0 && wallClockMs > prevAppWallClockMs) {
            val cpuDelta = cpuTimeMs - prevAppCpuTimeMs
            val wallDelta = wallClockMs - prevAppWallClockMs
            val cores = Runtime.getRuntime().availableProcessors().coerceAtLeast(1)
            (cpuDelta.toDouble() / wallDelta.toDouble() / cores * 100.0).coerceIn(0.0, 100.0)
        } else {
            0.0
        }

        prevAppCpuTimeMs = cpuTimeMs
        prevAppWallClockMs = wallClockMs
        return result
    }

    /// This process's resident memory (PSS) in MB.
    private fun getAppMemoryInfo(): Double {
        return try {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val pss = am.getProcessMemoryInfo(intArrayOf(Process.myPid())).firstOrNull()?.totalPss ?: 0
            pss / 1024.0
        } catch (e: Exception) {
            0.0
        }
    }

    private fun getThermalState(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return "nominal"
        return try {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            when (pm.currentThermalStatus) {
                PowerManager.THERMAL_STATUS_NONE, PowerManager.THERMAL_STATUS_LIGHT -> "nominal"
                PowerManager.THERMAL_STATUS_MODERATE -> "fair"
                PowerManager.THERMAL_STATUS_SEVERE -> "serious"
                PowerManager.THERMAL_STATUS_CRITICAL,
                PowerManager.THERMAL_STATUS_EMERGENCY,
                PowerManager.THERMAL_STATUS_SHUTDOWN -> "critical"
                else -> "nominal"
            }
        } catch (e: Exception) {
            "nominal"
        }
    }
}
