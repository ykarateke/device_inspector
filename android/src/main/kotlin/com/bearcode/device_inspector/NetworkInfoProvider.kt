package com.bearcode.device_inspector

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.telephony.TelephonyManager
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NetworkInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getNetworkInfo") {
            result.notImplemented()
            return
        }

        try {
            val info = mutableMapOf<String, Any?>()
            val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val network = cm.activeNetwork

            if (network == null) {
                info["type"] = "offline"
                result.success(info)
                return
            }

            val caps = cm.getNetworkCapabilities(network)

            info["type"] = when {
                caps == null -> "offline"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) -> "vpn"
                else -> "offline"
            }

            info["isVpn"] = caps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) ?: false
            info["isProxy"] = isProxyConfigured()

            val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            info["carrier"] = tm.networkOperatorName?.takeIf { it.isNotEmpty() }

            if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true) {
                info["cellularGeneration"] = getCellularGeneration(tm)
            }

            info["isAirplaneMode"] = isAirplaneModeOn()
            info["signalStrength"] = -1
            info["wifiSsid"] = null
            info["localIpAddress"] = null

            result.success(info)
        } catch (e: Exception) {
            result.error("NETWORK_INFO_ERROR", e.message, null)
        }
    }

    private fun getCellularGeneration(tm: TelephonyManager): String? = when (tm.dataNetworkType) {
        TelephonyManager.NETWORK_TYPE_NR -> "5G"
        TelephonyManager.NETWORK_TYPE_LTE -> "4G"
        TelephonyManager.NETWORK_TYPE_HSPAP, TelephonyManager.NETWORK_TYPE_HSDPA,
        TelephonyManager.NETWORK_TYPE_HSUPA -> "3G"
        TelephonyManager.NETWORK_TYPE_EDGE, TelephonyManager.NETWORK_TYPE_GPRS -> "2G"
        else -> null
    }

    private fun isProxyConfigured(): Boolean {
        val host = System.getProperty("http.proxyHost")
        return !host.isNullOrEmpty()
    }

    private fun isAirplaneModeOn(): Boolean = try {
        Settings.Global.getInt(context.contentResolver, Settings.Global.AIRPLANE_MODE_ON) == 1
    } catch (e: Exception) {
        false
    }
}
