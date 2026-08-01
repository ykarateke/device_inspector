import Foundation
import UIKit

class SecurityCheckProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getSecurityInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var threats: [String] = []
            var info: [String: Any] = [
                "isRooted": false,
                "isJailbroken": false,
                "isEmulator": false,
                "isDebuggerAttached": false,
                "isDeveloperMode": false,
                "hasSuspiciousApps": false,
                "hasSuspiciousPaths": false,
                "hasSuspiciousEnvVars": false,
                "hasModifiedLibraries": false,
                "detectedThreats": [],
                "securityScore": 100,
            ]

            var score = 100

            // 1. Simulator check
#if targetEnvironment(simulator)
            info["isEmulator"] = true
            threats.append("Running on simulator")
            score -= 30
#endif

            // 2. Debugger check
            if Self.isDebuggerAttached() {
                info["isDebuggerAttached"] = true
                threats.append("Debugger attached")
                score -= 20
            }

            // 3. Suspicious file paths
            let suspiciousPaths = [
                "/Applications/Cydia.app",
                "/Applications/Sileo.app",
                "/usr/sbin/sshd",
                "/bin/bash",
                "/etc/apt",
                "/private/var/lib/apt",
                "/private/var/stash",
                "/Library/MobileSubstrate/MobileSubstrate.dylib",
            ]
            for path in suspiciousPaths {
                if FileManager.default.fileExists(atPath: path) {
                    info["hasSuspiciousPaths"] = true
                    threats.append("Suspicious path: \(path)")
                    score -= 15
                    break
                }
            }

            // 4. Cydia URL scheme
            if UIApplication.shared.canOpenURL(URL(string: "cydia://")!) {
                info["hasSuspiciousApps"] = true
                threats.append("Cydia URL scheme available")
                score -= 20
            }

            // 5. Sandbox escape test
            let testPath = "/private/test_jailbreak_\(UUID().uuidString)"
            do {
                try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
                try FileManager.default.removeItem(atPath: testPath)
                info["isJailbroken"] = true
                threats.append("Sandbox escape: write outside container succeeded")
                score -= 40
            } catch {
                // Expected — sandbox prevents writing outside container
            }

            // 6. Suspicious dylibs
            if Self.hasSuspiciousDynamicLibraries() {
                info["hasModifiedLibraries"] = true
                threats.append("Suspicious dynamic libraries detected")
                score -= 15
            }

            if !threats.isEmpty {
                info["isJailbroken"] = true
            }

            info["detectedThreats"] = threats
            info["securityScore"] = max(0, score)
            result(info)
        }
    }

    static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        guard sysctl(&mib, u_int(mib.count), &info, &size, nil, 0) == 0 else {
            return false
        }
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

    static func hasSuspiciousDynamicLibraries() -> Bool {
        let suspicious = ["MobileSubstrate", "SubstrateLoader", "CydiaSubstrate", "libhooker", "libsubstitute"]
        let count = _dyld_image_count()
        for i in 0..<count {
            guard let name = _dyld_get_image_name(i) else { continue }
            let nameStr = String(cString: name)
            for lib in suspicious where nameStr.contains(lib) {
                return true
            }
        }
        return false
    }
}
