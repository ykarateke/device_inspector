import Flutter
import Foundation
import QuartzCore
import UIKit

class PerformanceMonitorProvider {

    private var displayLink: CADisplayLink?
    private var isRunning = false

    private var lastFrameTimestamp: CFTimeInterval = 0
    private var currentFPS: Double = 0

    private var lastCPUInfo: host_cpu_load_info?
    private var lastAppCPUTime: Double?
    private var lastAppSampleWallClock: CFTimeInterval?

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startPerformanceMonitor":
            startMonitoring()
            result(nil)
        case "stopPerformanceMonitor":
            stopMonitoring()
            result(nil)
        case "getPerformanceSnapshot":
            result(getSnapshot())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startMonitoring() {
        guard !isRunning else { return }
        isRunning = true
        DispatchQueue.main.async {
            let link = CADisplayLink(target: self, selector: #selector(self.tick(_:)))
            link.add(to: .main, forMode: .common)
            self.displayLink = link
        }
    }

    func stopMonitoring() {
        isRunning = false
        DispatchQueue.main.async {
            self.displayLink?.invalidate()
            self.displayLink = nil
            self.lastFrameTimestamp = 0
            self.currentFPS = 0
        }
    }

    @objc private func tick(_ link: CADisplayLink) {
        if lastFrameTimestamp > 0 {
            let delta = link.timestamp - lastFrameTimestamp
            if delta > 0 {
                currentFPS = 1.0 / delta
            }
        }
        lastFrameTimestamp = link.timestamp
    }

    private func getSnapshot() -> [String: Any] {
        let memoryUsageBytes = Self.getAppMemoryBytes() ?? 0
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory)

        return [
            "fps": isRunning ? currentFPS : 0.0,
            "cpuUsagePercent": getSystemCPUUsagePercent(),
            "appCpuUsagePercent": getAppCPUUsagePercent(),
            "memoryUsageMB": Double(memoryUsageBytes) / (1024.0 * 1024.0),
            "memoryUsagePercent": totalMemory > 0 ? (Double(memoryUsageBytes) / totalMemory) * 100.0 : 0.0,
            "thermalState": Self.thermalStateString(),
            "timestampMsSinceEpoch": Int(Date().timeIntervalSince1970 * 1000),
            "batteryImpactLevel": -1,
        ]
    }

    /// System-wide CPU load, sampled as a delta between calls (`host_statistics`).
    private func getSystemCPUUsagePercent() -> Double {
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride)
        var info = host_cpu_load_info()

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0.0 }
        defer { lastCPUInfo = info }

        guard let previous = lastCPUInfo else { return 0.0 }

        let userDelta = Double(info.cpu_ticks.0 &- previous.cpu_ticks.0)
        let systemDelta = Double(info.cpu_ticks.1 &- previous.cpu_ticks.1)
        let idleDelta = Double(info.cpu_ticks.2 &- previous.cpu_ticks.2)
        let niceDelta = Double(info.cpu_ticks.3 &- previous.cpu_ticks.3)

        let totalDelta = userDelta + systemDelta + idleDelta + niceDelta
        guard totalDelta > 0 else { return 0.0 }

        return ((userDelta + systemDelta + niceDelta) / totalDelta) * 100.0
    }

    /// This process's CPU usage, computed from `getrusage` deltas against wall-clock time.
    private func getAppCPUUsagePercent() -> Double {
        var usage = rusage()
        guard getrusage(RUSAGE_SELF, &usage) == 0 else { return 0.0 }

        let cpuTime = Double(usage.ru_utime.tv_sec) + Double(usage.ru_utime.tv_usec) / 1_000_000.0
            + Double(usage.ru_stime.tv_sec) + Double(usage.ru_stime.tv_usec) / 1_000_000.0
        let now = CACurrentMediaTime()

        defer {
            lastAppCPUTime = cpuTime
            lastAppSampleWallClock = now
        }

        guard let previousCPUTime = lastAppCPUTime, let previousWallClock = lastAppSampleWallClock else {
            return 0.0
        }

        let wallDelta = now - previousWallClock
        guard wallDelta > 0 else { return 0.0 }

        let cores = Double(ProcessInfo.processInfo.activeProcessorCount)
        return min(100.0, ((cpuTime - previousCPUTime) / wallDelta / cores) * 100.0)
    }

    static func getAppMemoryBytes() -> Int64? {
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

    static func thermalStateString() -> String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: return "nominal"
        case .fair: return "fair"
        case .serious: return "serious"
        case .critical: return "critical"
        @unknown default: return "nominal"
        }
    }
}
