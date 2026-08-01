package com.bearcode.device_inspector

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File

class SecurityCheckProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getSecurityInfo") {
            result.notImplemented()
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            val info = mutableMapOf<String, Any?>()
            val threats = mutableListOf<String>()
            var score = 100

            // 1. Root binaries
            val rootBins = listOf(
                "/system/app/Superuser.apk", "/sbin/su", "/system/bin/su",
                "/system/xbin/su", "/data/local/xbin/su", "/data/local/bin/su",
                "/system/sd/xbin/su", "/data/local/su", "/su/bin/su",
                "/magisk/.core/bin/su",
            )
            for (path in rootBins) {
                if (File(path).exists()) {
                    info["isRooted"] = true
                    threats.add("Root binary: $path")
                    score -= 40
                    break
                }
            }

            // 2. Magisk
            if (isMagiskInstalled()) {
                info["isRooted"] = true
                info["hasSuspiciousApps"] = true
                threats.add("Magisk detected")
                score -= 30
            }

            // 3. SuperUser apps
            val suApps = listOf(
                "com.noshufou.android.su", "com.thirdparty.superuser",
                "eu.chainfire.supersu", "com.koushikdutta.superuser",
                "com.topjohnwu.magisk",
            )
            val pm = context.packageManager
            for (pkg in suApps) {
                try {
                    pm.getPackageInfo(pkg, 0)
                    info["hasSuspiciousApps"] = true
                    threats.add("SuperUser app: $pkg")
                    score -= 20
                    break
                } catch (_: PackageManager.NameNotFoundException) {}
            }

            // 4. Emulator
            if (isEmulator()) {
                info["isEmulator"] = true
                threats.add("Running on emulator")
                score -= 30
            }

            // 5. Debugger
            if (Debug.isDebuggerConnected() || Debug.waitingForDebugger()) {
                info["isDebuggerAttached"] = true
                threats.add("Debugger attached")
                score -= 20
            }

            // 6. Developer mode + ADB
            val devMode = Settings.Global.getInt(
                context.contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0
            )
            info["isDeveloperMode"] = devMode == 1
            if (devMode == 1) {
                val adb = Settings.Global.getInt(
                    context.contentResolver, Settings.Global.ADB_ENABLED, 0
                )
                if (adb == 1) {
                    threats.add("USB debugging enabled")
                    score -= 10
                }
            }

            // 7. Env vars
            val envVars = listOf("LD_PRELOAD", "LD_LIBRARY_PATH")
            for (v in envVars) {
                if (!System.getenv(v).isNullOrEmpty()) {
                    info["hasSuspiciousEnvVars"] = true
                    threats.add("Suspicious env: $v")
                    score -= 10
                }
            }

            info["detectedThreats"] = threats
            info["securityScore"] = maxOf(0, score)
            info["hasSuspiciousPaths"] = info["isRooted"] == true

            if (threats.isEmpty()) {
                info["isRooted"] = false
                info["isJailbroken"] = false
                info["isEmulator"] = false
                info["hasSuspiciousApps"] = false
                info["hasSuspiciousPaths"] = false
                info["hasSuspiciousEnvVars"] = false
                info["hasModifiedLibraries"] = false
            }

            result(info)
        }
    }

    private fun isMagiskInstalled(): Boolean {
        val paths = listOf("/data/adb/magisk", "/data/adb/modules", "/sbin/.magisk")
        return paths.any { File(it).exists() }
    }

    private fun isEmulator(): Boolean =
        (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")) ||
        Build.FINGERPRINT.startsWith("generic") ||
        Build.FINGERPRINT.startsWith("unknown") ||
        Build.HARDWARE.contains("goldfish") ||
        Build.HARDWARE.contains("ranchu") ||
        Build.MODEL.contains("google_sdk") ||
        Build.MODEL.contains("Emulator") ||
        Build.MODEL.contains("Android SDK built for x86") ||
        Build.MANUFACTURER.contains("Genymotion") ||
        Build.PRODUCT.contains("sdk_google") ||
        Build.PRODUCT.contains("sdk") ||
        Build.PRODUCT.contains("sdk_x86") ||
        Build.PRODUCT.contains("vbox86p") ||
        Build.PRODUCT.contains("emulator") ||
        Build.PRODUCT.contains("simulator")
}
