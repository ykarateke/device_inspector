import Flutter
import UIKit

public class DeviceInspectorPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()

        // Device
        let deviceChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/device",
            binaryMessenger: messenger
        )
        deviceChannel.setMethodCallHandler(DeviceInfoProvider().handle)

        // OS
        let osChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/os",
            binaryMessenger: messenger
        )
        osChannel.setMethodCallHandler(OSInfoProvider().handle)

        // Battery
        let batteryChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/battery",
            binaryMessenger: messenger
        )
        batteryChannel.setMethodCallHandler(BatteryInfoProvider().handle)

        // Network
        let networkChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/network",
            binaryMessenger: messenger
        )
        networkChannel.setMethodCallHandler(NetworkInfoProvider().handle)

        // Hardware
        let hardwareChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/hardware",
            binaryMessenger: messenger
        )
        hardwareChannel.setMethodCallHandler(HardwareInfoProvider().handle)

        // Memory
        let memoryChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/memory",
            binaryMessenger: messenger
        )
        memoryChannel.setMethodCallHandler(MemoryInfoProvider().handle)

        // Storage
        let storageChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/storage",
            binaryMessenger: messenger
        )
        storageChannel.setMethodCallHandler(StorageInfoProvider().handle)

        // Security
        let securityChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/security",
            binaryMessenger: messenger
        )
        securityChannel.setMethodCallHandler(SecurityCheckProvider().handle)

        // Performance
        let performanceChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/performance",
            binaryMessenger: messenger
        )
        performanceChannel.setMethodCallHandler(PerformanceMonitorProvider().handle)

        // App
        let appChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/app",
            binaryMessenger: messenger
        )
        appChannel.setMethodCallHandler(AppInfoProvider().handle)
    }
}
