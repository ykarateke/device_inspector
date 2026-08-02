import Foundation

class AppInfoProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getAppInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let bundle = Bundle.main
            let infoDict = bundle.infoDictionary ?? [:]

            let appName = (infoDict["CFBundleDisplayName"] as? String)
                ?? (infoDict["CFBundleName"] as? String)
                ?? "Unknown"
            let version = (infoDict["CFBundleShortVersionString"] as? String) ?? "0.0.0"
            let buildNumber = (infoDict["CFBundleVersion"] as? String) ?? "0"
            let bundleId = bundle.bundleIdentifier ?? "unknown"

            var installTimestampMs: Int64?
            if let bundlePath = bundle.bundleURL.path as String?,
               let attrs = try? FileManager.default.attributesOfItem(atPath: bundlePath),
               let creationDate = attrs[.creationDate] as? Date {
                installTimestampMs = Int64(creationDate.timeIntervalSince1970 * 1000)
            }

            let info: [String: Any] = [
                "appName": appName,
                "version": version,
                "buildNumber": buildNumber,
                "bundleId": bundleId,
                "installTimestampMs": installTimestampMs as Any,
                "firstLaunchTimestampMs": NSNull(),
                "signatureHash": NSNull(),
                "isDebugBuild": Self.isDebugBuild,
            ]

            result(info)
        }
    }

    static var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
