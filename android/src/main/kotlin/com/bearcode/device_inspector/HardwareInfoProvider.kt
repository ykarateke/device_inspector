package com.bearcode.device_inspector

import android.content.Context
import android.os.Build
import android.util.DisplayMetrics
import android.view.WindowManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class HardwareInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getHardwareInfo") {
            result.notImplemented()
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val info = mutableMapOf<String, Any?>()

                // CPU
                val cpu = mutableMapOf<String, Any?>()
                cpu["name"] = getCPUName()
                cpu["cores"] = Runtime.getRuntime().availableProcessors()
                cpu["architecture"] = Build.SUPPORTED_ABIS.firstOrNull() ?: "unknown"
                cpu["maxFrequencyMHz"] = 0
                cpu["hasNeuralEngine"] = false

                // GPU
                val gpu = mutableMapOf<String, Any?>()
                gpu["name"] = "Android GPU"
                gpu["supportsMetal"] = false
                gpu["supportsVulkan"] = hasVulkanSupport()
                gpu["openGLESVersion"] = getGLESVersion()

                // Display
                val display = mutableMapOf<String, Any?>()
                val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                val metrics = DisplayMetrics()
                @Suppress("DEPRECATION")
                wm.defaultDisplay.getRealMetrics(metrics)
                display["widthPixels"] = metrics.widthPixels
                display["heightPixels"] = metrics.heightPixels
                display["density"] = metrics.density.toDouble()
                display["refreshRate"] = 60
                display["supportsHdr"] = false
                display["brightnessLevel"] = -1.0

                info["cpu"] = cpu
                info["gpu"] = gpu
                info["display"] = display
                info["tier"] = "medium"

                result(info)
            } catch (e: Exception) {
                result.error("HARDWARE_INFO_ERROR", e.message, null)
            }
        }
    }

    private fun getCPUName(): String {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("/system/bin/cat", "/proc/cpuinfo"))
            val reader = process.inputStream.bufferedReader()
            val text = reader.readText()
            reader.close()
            text.lines()
                .firstOrNull { it.startsWith("Hardware") }
                ?.substringAfter(":")
                ?.trim()
                ?: Build.HARDWARE
        } catch (e: Exception) {
            Build.HARDWARE
        }
    }

    private fun hasVulkanSupport(): Boolean {
        return try {
            val pm = context.packageManager
            pm.hasSystemFeature(android.content.pm.PackageManager.FEATURE_VULKAN_HARDWARE_VERSION)
        } catch (e: Exception) {
            false
        }
    }

    private fun getGLESVersion(): String? {
        return try {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            val info = am.deviceConfigurationInfo
            "${info.reqGlEsVersion shr 16}.${info.reqGlEsVersion and 0xffff}"
        } catch (e: Exception) {
            null
        }
    }
}
