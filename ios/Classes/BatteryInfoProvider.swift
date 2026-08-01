import UIKit

class BatteryInfoProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getBatteryInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.main.async {
            let device = UIDevice.current
            device.isBatteryMonitoringEnabled = true

            var info: [String: Any] = [:]

            let level = device.batteryLevel
            info["level"] = level >= 0 ? Int(level * 100) : -1
            info["isCharging"] = device.batteryState == .charging || device.batteryState == .full

            switch device.batteryState {
            case .charging:
                info["chargingState"] = "charging"
            case .full:
                info["chargingState"] = "full"
            case .unplugged:
                info["chargingState"] = "discharging"
            default:
                info["chargingState"] = "unknown"
            }

            info["isLowPowerMode"] = ProcessInfo.processInfo.isLowPowerModeEnabled
            info["health"] = nil
            info["maxCapacityPercent"] = nil
            info["estimatedMinutesRemaining"] = -1

            result(info)
        }
    }
}
