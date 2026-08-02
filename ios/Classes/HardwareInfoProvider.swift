import Foundation
import Metal
import UIKit

class HardwareInfoProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getHardwareInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let modelIdentifier = DeviceInfoProvider.getModelIdentifier()

            // CPU
            var cpu: [String: Any] = [:]
            cpu["name"] = Self.getCPUName()
            cpu["cores"] = ProcessInfo.processInfo.activeProcessorCount
            cpu["architecture"] = Self.getArchitecture()
            // Apple silicon does not expose clock speed via a public API.
            cpu["maxFrequencyMHz"] = 0
            cpu["hasNeuralEngine"] = Self.hasNeuralEngine(modelIdentifier: modelIdentifier)

            // GPU — MTLDevice exposes the real chip-specific GPU name (e.g. "Apple A17 Pro GPU").
            let mtlDevice = MTLCreateSystemDefaultDevice()
            var gpu: [String: Any] = [:]
            gpu["name"] = mtlDevice?.name ?? "Unknown"
            gpu["supportsMetal"] = mtlDevice != nil
            gpu["metalFeatureSet"] = Self.highestMetalGPUFamily(mtlDevice)
            gpu["supportsVulkan"] = false

            // Display
            var display: [String: Any] = [:]
            let screen = UIScreen.main
            let scale = screen.scale
            display["widthPixels"] = Int(screen.bounds.width * scale)
            display["heightPixels"] = Int(screen.bounds.height * scale)
            display["density"] = Double(scale)
            display["refreshRate"] = screen.maximumFramesPerSecond
            display["supportsHdr"] = Self.supportsHdr(screen)
            display["brightnessLevel"] = Double(screen.brightness)

            var info: [String: Any] = [:]
            info["cpu"] = cpu
            info["gpu"] = gpu
            info["display"] = display
            info["tier"] = DeviceInfoProvider.determineTier()

            result(info)
        }
    }

    static func getCPUName() -> String {
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

    /// Apple's Neural Engine debuted with the A11 Bionic (iPhone 8/8 Plus/X, "iPhoneN,M"
    /// generation 10+). No public API reports NPU presence directly, so this infers it
    /// from the numeric device generation encoded in the model identifier.
    static func hasNeuralEngine(modelIdentifier: String) -> Bool {
        guard modelIdentifier.hasPrefix("iPhone") else {
            // Simulators and iPads use different numbering; assume modern hardware.
            return modelIdentifier.hasPrefix("iPad") || modelIdentifier.contains("64")
        }
        let digits = modelIdentifier
            .dropFirst("iPhone".count)
            .prefix { $0.isNumber }
        guard let generation = Int(digits) else { return false }
        return generation >= 10
    }

    static func supportsHdr(_ screen: UIScreen) -> Bool {
        if #available(iOS 16.0, *) {
            return screen.potentialEDRHeadroom > 1.0
        }
        return false
    }

    static func highestMetalGPUFamily(_ device: MTLDevice?) -> String? {
        guard let device = device else { return nil }
        let families: [(MTLGPUFamily, String)] = [
            (.apple9, "Apple9"), (.apple8, "Apple8"), (.apple7, "Apple7"),
            (.apple6, "Apple6"), (.apple5, "Apple5"), (.apple4, "Apple4"),
            (.apple3, "Apple3"), (.apple2, "Apple2"), (.apple1, "Apple1"),
        ]
        for (family, name) in families where device.supportsFamily(family) {
            return name
        }
        return nil
    }
}
