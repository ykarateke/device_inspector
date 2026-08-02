package com.bearcode.device_inspector

import android.content.Context
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class DeviceInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getDeviceInfo") {
            result.notImplemented()
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val info = mutableMapOf<String, Any?>()

                info["manufacturer"] = Build.MANUFACTURER
                info["model"] = Build.MODEL
                info["marketName"] = getMarketName()
                info["codename"] = Build.DEVICE

                try {
                    info["identifier"] = Settings.Secure.getString(
                        context.contentResolver,
                        Settings.Secure.ANDROID_ID
                    )
                } catch (e: Exception) {
                    info["identifier"] = null
                }

                info["tier"] = determineTier()
                info["releaseYear"] = getReleaseYear()

                result.success(info)
            } catch (e: Exception) {
                result.error("DEVICE_INFO_ERROR", e.message, null)
            }
        }
    }

    private fun getMarketName(): String {
        val model = Build.MODEL
        val mapping = mapOf(
            "SM-S928B" to "Galaxy S24 Ultra",
            "SM-S921B" to "Galaxy S24",
            "SM-S926B" to "Galaxy S24+",
            "Pixel 8 Pro" to "Pixel 8 Pro",
            "Pixel 8" to "Pixel 8",
        )
        return mapping[model] ?: "${Build.MANUFACTURER} $model"
    }

    private fun determineTier(): String {
        val cores = Runtime.getRuntime().availableProcessors()
        val totalRam = getTotalRamBytes()
        if (cores >= 8 && totalRam >= 8L * 1024 * 1024 * 1024) return "high"
        if (cores < 4 || totalRam < 4L * 1024 * 1024 * 1024) return "low"
        return "medium"
    }

    private fun getTotalRamBytes(): Long {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
        val memInfo = android.app.ActivityManager.MemoryInfo()
        am.getMemoryInfo(memInfo)
        return memInfo.totalMem
    }

    private fun getReleaseYear(): Int? = null
}
