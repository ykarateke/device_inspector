import Foundation

class StorageInfoProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getStorageInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first

            var totalBytes: Int64 = -1
            var freeBytes: Int64 = -1

            if let homePath = documentsPath,
               let attrs = try? fileManager.attributesOfFileSystem(forPath: homePath) {
                totalBytes = (attrs[.systemSize] as? NSNumber)?.int64Value ?? -1
                freeBytes = (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? -1
            }

            let usagePercent: Double
            if totalBytes > 0 && freeBytes >= 0 {
                usagePercent = (Double(totalBytes - freeBytes) / Double(totalBytes)) * 100.0
            } else {
                usagePercent = -1
            }

            let info: [String: Any] = [
                "totalBytes": totalBytes,
                "freeBytes": freeBytes,
                "usagePercent": usagePercent,
                "appUsedBytes": Self.directorySize(documentsPath) ?? -1,
                "appDataPath": documentsPath as Any,
                "appCachePath": cachesPath as Any,
            ]

            result(info)
        }
    }

    /// Recursively sums file sizes under [path]. Best-effort — returns nil on failure.
    static func directorySize(_ path: String?) -> Int64? {
        guard let path = path else { return nil }
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: path) else { return nil }

        var total: Int64 = 0
        for case let file as String in enumerator {
            let fullPath = (path as NSString).appendingPathComponent(file)
            if let attrs = try? fileManager.attributesOfItem(atPath: fullPath),
               let size = attrs[.size] as? NSNumber {
                total += size.int64Value
            }
        }
        return total
    }
}
