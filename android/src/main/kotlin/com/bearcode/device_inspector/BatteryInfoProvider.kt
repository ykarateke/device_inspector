package com.bearcode.device_inspector

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BatteryInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getBatteryInfo") {
            result.notImplemented()
            return
        }

        try {
            val batteryIntent = context.registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            )

            val info = mutableMapOf<String, Any?>()

            if (batteryIntent != null) {
                val level = batteryIntent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                val scale = batteryIntent.getIntExtra(BatteryManager.EXTRA_SCALE, 100)
                info["level"] = if (level >= 0 && scale > 0) (level * 100 / scale) else -1

                val status = batteryIntent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
                info["isCharging"] = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                        status == BatteryManager.BATTERY_STATUS_FULL

                info["chargingState"] = when (status) {
                    BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
                    BatteryManager.BATTERY_STATUS_FULL -> "full"
                    BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
                    BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "discharging"
                    else -> "unknown"
                }

                val powerManager = context.getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
                info["isLowPowerMode"] = powerManager.isPowerSaveMode

                info["health"] = null
                info["maxCapacityPercent"] = null
            }

            info["estimatedMinutesRemaining"] = -1

            result(info)
        } catch (e: Exception) {
            result.error("BATTERY_INFO_ERROR", e.message, null)
        }
    }
}
