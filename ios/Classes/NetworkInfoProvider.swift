import Flutter
import Foundation
import Network
import CoreTelephony

class NetworkInfoProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getNetworkInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        let semaphore = DispatchSemaphore(value: 0)
        var info: [String: Any] = [
            "type": "unknown",
            "isVpn": false,
            "isProxy": false,
            "isAirplaneMode": false,
            "signalStrength": -1,
        ]

        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                info["type"] = "wifi"
            } else if path.usesInterfaceType(.cellular) {
                info["type"] = "cellular"
                let networkInfo = CTTelephonyNetworkInfo()
                if let carrier = networkInfo.serviceSubscriberCellularProviders?.values.first {
                    info["carrier"] = carrier.carrierName
                }
                if let tech = networkInfo.serviceCurrentRadioAccessTechnology?.values.first {
                    info["cellularGeneration"] = Self.parseRadioTechnology(tech)
                }
            } else if path.usesInterfaceType(.wiredEthernet) {
                info["type"] = "ethernet"
            } else {
                info["type"] = "offline"
            }
            info["isVpn"] = Self.isVpnActive()
            info["isProxy"] = Self.isProxyConfigured()
            semaphore.signal()
        }

        monitor.start(queue: DispatchQueue.global(qos: .userInitiated))
        _ = semaphore.wait(timeout: .now() + 3.0)
        monitor.cancel()

        result(info)
    }

    // Raw string values per Apple's CoreTelephony docs — used instead of the
    // symbolic constants so this compiles regardless of deployment target
    // (CTRadioAccessTechnologyNR requires iOS 14.1+ to reference as a symbol).
    static func parseRadioTechnology(_ tech: String) -> String {
        switch tech {
        case "CTRadioAccessTechnologyLTE": return "4G"
        case "CTRadioAccessTechnologyNR", "CTRadioAccessTechnologyNRNSA": return "5G"
        case "CTRadioAccessTechnologyWCDMA",
             "CTRadioAccessTechnologyHSDPA",
             "CTRadioAccessTechnologyHSUPA",
             "CTRadioAccessTechnologyCDMA1x",
             "CTRadioAccessTechnologyCDMAEVDORev0",
             "CTRadioAccessTechnologyCDMAEVDORevA",
             "CTRadioAccessTechnologyCDMAEVDORevB",
             "CTRadioAccessTechnologyeHRPD": return "3G"
        case "CTRadioAccessTechnologyEdge",
             "CTRadioAccessTechnologyGPRS": return "2G"
        default: return "unknown"
        }
    }

    static func isVpnActive() -> Bool {
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any]
        else { return false }
        return settings.keys.contains { $0.contains("tap") || $0.contains("tun") || $0.contains("ppp") }
    }

    static func isProxyConfigured() -> Bool {
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any]
        else { return false }
        return settings["HTTPProxy"] != nil || settings["HTTPSProxy"] != nil
    }
}
