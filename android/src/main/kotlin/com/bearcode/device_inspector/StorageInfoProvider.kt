package com.bearcode.device_inspector

import android.content.Context
import android.os.Environment
import android.os.StatFs
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class StorageInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getStorageInfo") {
            result.notImplemented()
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val statFs = StatFs(Environment.getDataDirectory().path)
                val totalBytes = statFs.totalBytes
                val freeBytes = statFs.availableBytes
                val usagePercent = if (totalBytes > 0) {
                    ((totalBytes - freeBytes).toDouble() / totalBytes.toDouble()) * 100.0
                } else {
                    0.0
                }

                val info = mapOf(
                    "totalBytes" to totalBytes,
                    "freeBytes" to freeBytes,
                    "usagePercent" to usagePercent,
                    "appUsedBytes" to (directorySize(context.filesDir) + directorySize(context.cacheDir)),
                    "appDataPath" to context.filesDir?.absolutePath,
                    "appCachePath" to context.cacheDir?.absolutePath,
                )

                result.success(info)
            } catch (e: Exception) {
                result.error("STORAGE_INFO_ERROR", e.message, null)
            }
        }
    }

    private fun directorySize(dir: java.io.File?): Long {
        if (dir == null || !dir.exists()) return 0L
        return try {
            dir.walkTopDown().filter { it.isFile }.map { it.length() }.sum()
        } catch (e: Exception) {
            0L
        }
    }
}
