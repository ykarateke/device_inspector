import Foundation

class HardwareInfoProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getHardwareInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var info: [String: Any] = [:]

            // CPU
            var cpu: [String: Any] = [:]
            cpu["name"] = Self.getCPUName()
            cpu["cores"] = ProcessInfo.processInfo.activeProcessorCount
            cpu["architecture"] = Self.getArchitecture()
            cpu["maxFrequencyMHz"] = 0
            cpu["hasNeuralEngine"] = false

            // GPU
            var gpu: [String: Any] = [:]
            gpu["name"] = "Apple GPU"
            gpu["supportsMetal"] = true
            gpu["supportsVulkan"] = false

            // Display
            var display: [String: Any] = [:]
            let screen = UIScreen.main
            let scale = screen.scale
            display["widthPixels"] = Int(screen.bounds.width * scale)
            display["heightPixels"] = Int(screen.bounds.height * scale)
            display["density"] = Double(scale)
            display["refreshRate"] = 60
            display["supportsHdr"] = false
            display["brightnessLevel"] = Double(screen.brightness)

            info["cpu"] = cpu
            info["gpu"] = gpu
            info["display"] = display
            info["tier"] = "medium"

            result(info)
        }
    }

    static func getCPUName() -> String {
        // Use sysctl to get the CPU brand string
        var size: size_t = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var brand = [CChar](repeating: 0, count: size)
        guard sysctlbyname("machdep.cpu.brand_string", &brand, &size, nil, 0) == 0 else {
            return "Apple"
        }
        return String(cString: brand).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func getArchitecture() -> String {
#if arch(arm64)
        return "arm64"
#elseif arch(x86_64)
        return "x86_64"
#else
        return "unknown"
#endif
    }
}
