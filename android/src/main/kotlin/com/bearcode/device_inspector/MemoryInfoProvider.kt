package com.bearcode.device_inspector

import android.app.ActivityManager
import android.content.Context
import android.os.Process
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class MemoryInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getMemoryInfo") {
            result.notImplemented()
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                val memInfo = ActivityManager.MemoryInfo()
                am.getMemoryInfo(memInfo)

                val totalBytes = memInfo.totalMem
                val availableBytes = memInfo.availMem
                val usagePercent = if (totalBytes > 0) {
                    ((totalBytes - availableBytes).toDouble() / totalBytes.toDouble()) * 100.0
                } else {
                    0.0
                }

                val info = mapOf(
                    "totalBytes" to totalBytes,
                    "availableBytes" to availableBytes,
                    "usagePercent" to usagePercent,
                    "appUsedBytes" to getAppUsedBytes(am),
                    "isLowMemory" to memInfo.lowMemory,
                )

                result.success(info)
            } catch (e: Exception) {
                result.error("MEMORY_INFO_ERROR", e.message, null)
            }
        }
    }

    /// Resident set size (PSS) of this process, converted from KB to bytes.
    private fun getAppUsedBytes(am: ActivityManager): Long {
        return try {
            val pss = am.getProcessMemoryInfo(intArrayOf(Process.myPid())).firstOrNull()?.totalPss
            (pss?.toLong() ?: -1L) * 1024L
        } catch (e: Exception) {
            -1L
        }
    }
}
