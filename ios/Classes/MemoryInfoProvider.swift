import Flutter
import Foundation

class MemoryInfoProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getMemoryInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let totalBytes = Int64(ProcessInfo.processInfo.physicalMemory)
            let freeBytes = Self.getFreeMemoryBytes() ?? 0
            let usedBytes = max(0, totalBytes - freeBytes)
            let usagePercent = totalBytes > 0 ? (Double(usedBytes) / Double(totalBytes)) * 100.0 : 0.0

            var info: [String: Any] = [
                "totalBytes": totalBytes,
                "availableBytes": freeBytes,
                "usagePercent": usagePercent,
                "appUsedBytes": Self.getAppUsedBytes() ?? -1,
                "isLowMemory": usagePercent >= 90.0,
            ]

            result(info)
        }
    }

    /// Free + inactive pages, converted to bytes — approximates "available" memory.
    static func getFreeMemoryBytes() -> Int64? {
        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return nil }

        let freePages = UInt64(stats.free_count) + UInt64(stats.inactive_count)
        return Int64(freePages * UInt64(pageSize))
    }

    /// Resident memory footprint of this process.
    static func getAppUsedBytes() -> Int64? {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return nil }
        return Int64(info.phys_footprint)
    }
}
