import Foundation
import UIKit

class OSInfoProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getOSInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var info: [String: Any] = [:]

            let systemVersion = UIDevice.current.systemVersion
            let parts = systemVersion.split(separator: ".")

            info["platform"] = "iOS"
            info["version"] = systemVersion
            info["majorVersion"] = parts.count > 0 ? Int(parts[0]) ?? 0 : 0
            info["minorVersion"] = parts.count > 1 ? Int(parts[1]) ?? 0 : 0
            info["patchVersion"] = parts.count > 2 ? Int(parts[2]) ?? 0 : 0
            info["buildNumber"] = Self.getBuildNumber()
            info["apiLevel"] = nil
            info["kernelVersion"] = Self.getKernelVersion()

            result(info)
        }
    }

    static func getBuildNumber() -> String? {
        var size: size_t = 0
        sysctlbyname("kern.osversion", nil, &size, nil, 0)
        var build = [CChar](repeating: 0, count: size)
        sysctlbyname("kern.osversion", &build, &size, nil, 0)
        return String(cString: build)
    }

    static func getKernelVersion() -> String? {
        var size: size_t = 0
        sysctlbyname("kern.version", nil, &size, nil, 0)
        var version = [CChar](repeating: 0, count: size)
        guard sysctlbyname("kern.version", &version, &size, nil, 0) == 0 else {
            return nil
        }
        return String(cString: version)
    }
}
