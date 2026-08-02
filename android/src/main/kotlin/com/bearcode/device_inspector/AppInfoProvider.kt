package com.bearcode.device_inspector

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class AppInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getAppInfo") {
            result.notImplemented()
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val pm = context.packageManager
                val packageInfo = pm.getPackageInfo(context.packageName, 0)
                val appInfo = context.applicationInfo

                val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    packageInfo.longVersionCode
                } else {
                    @Suppress("DEPRECATION")
                    packageInfo.versionCode.toLong()
                }

                val info = mapOf(
                    "appName" to pm.getApplicationLabel(appInfo).toString(),
                    "version" to (packageInfo.versionName ?: "0.0.0"),
                    "buildNumber" to versionCode.toString(),
                    "bundleId" to context.packageName,
                    "installTimestampMs" to packageInfo.firstInstallTime,
                    "firstLaunchTimestampMs" to null,
                    "signatureHash" to getSignatureHash(pm),
                    "isDebugBuild" to ((appInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0),
                )

                result.success(info)
            } catch (e: Exception) {
                result.error("APP_INFO_ERROR", e.message, null)
            }
        }
    }

    private fun getSignatureHash(pm: PackageManager): String? {
        return try {
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val info = pm.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
                info.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                val info = pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNATURES)
                @Suppress("DEPRECATION")
                info.signatures
            }
            val signature = signatures?.firstOrNull() ?: return null
            val digest = java.security.MessageDigest.getInstance("SHA-256")
            digest.update(signature.toByteArray())
            digest.digest().joinToString("") { "%02x".format(it) }
        } catch (e: Exception) {
            null
        }
    }
}
