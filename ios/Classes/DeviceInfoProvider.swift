import Foundation
import UIKit

class DeviceInfoProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getDeviceInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var info: [String: Any] = [:]

            info["manufacturer"] = "Apple"
            info["model"] = Self.getModelIdentifier()
            info["codename"] = Self.getModelIdentifier()
            info["marketName"] = Self.getMarketName()
            info["identifier"] = UIDevice.current.identifierForVendor?.uuidString
            info["tier"] = Self.determineTier()
            info["releaseYear"] = Self.getReleaseYear()

            result(info)
        }
    }

    static func getModelIdentifier() -> String {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    static func getMarketName() -> String {
        let model = getModelIdentifier()
        let mapping: [String: String] = [
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone14,6": "iPhone SE (3rd gen)",
            "iPad14,3": "iPad Pro 11-inch (4th gen)",
            "arm64": "Simulator (arm64)",
            "x86_64": "Simulator (x86_64)",
        ]
        return mapping[model] ?? model
    }

    static func determineTier() -> String {
        let model = getModelIdentifier()
        let highTier = ["iPhone16,1", "iPhone16,2", "iPhone15,2", "iPhone15,3"]
        let lowTier = [
            "iPhone10,1", "iPhone10,2", "iPhone10,3", "iPhone10,4",
            "iPhone10,5", "iPhone10,6", "iPhone9,1", "iPhone9,2",
            "iPhone9,3", "iPhone9,4", "iPhone8,1", "iPhone8,4",
        ]
        if highTier.contains(model) { return "high" }
        if lowTier.contains(model) { return "low" }
        return "medium"
    }

    static func getReleaseYear() -> Int? {
        let years: [String: Int] = [
            "iPhone16,1": 2023, "iPhone16,2": 2023,
            "iPhone15,4": 2023, "iPhone15,5": 2023,
            "iPhone15,2": 2022, "iPhone15,3": 2022,
            "iPhone14,7": 2022, "iPhone14,8": 2022,
            "iPhone14,2": 2021, "iPhone14,3": 2021,
        ]
        return years[getModelIdentifier()]
    }
}
