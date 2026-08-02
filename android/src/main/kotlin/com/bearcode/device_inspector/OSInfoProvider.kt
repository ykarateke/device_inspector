package com.bearcode.device_inspector

import android.content.Context
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class OSInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getOSInfo") {
            result.notImplemented()
            return
        }

        try {
            val info = mutableMapOf<String, Any?>()
            val version = Build.VERSION.RELEASE
            val parts = version.split(".")

            info["platform"] = "Android"
            info["version"] = version
            info["majorVersion"] = parts.getOrNull(0)?.toIntOrNull() ?: 0
            info["minorVersion"] = parts.getOrNull(1)?.toIntOrNull() ?: 0
            info["patchVersion"] = parts.getOrNull(2)?.toIntOrNull() ?: 0
            info["buildNumber"] = Build.DISPLAY
            info["apiLevel"] = Build.VERSION.SDK_INT
            info["kernelVersion"] = System.getProperty("os.version")

            result.success(info)
        } catch (e: Exception) {
            result.error("OS_INFO_ERROR", e.message, null)
        }
    }
}
