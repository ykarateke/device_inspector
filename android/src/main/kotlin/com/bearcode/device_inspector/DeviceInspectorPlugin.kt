package com.bearcode.device_inspector

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class DeviceInspectorPlugin : FlutterPlugin {

    private lateinit var deviceProvider: DeviceInfoProvider
    private lateinit var osProvider: OSInfoProvider
    private lateinit var batteryProvider: BatteryInfoProvider
    private lateinit var networkProvider: NetworkInfoProvider
    private lateinit var hardwareProvider: HardwareInfoProvider
    private lateinit var securityProvider: SecurityCheckProvider
    private lateinit var performanceProvider: PerformanceMonitorProvider

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext

        // Device
        deviceProvider = DeviceInfoProvider(context)
        val deviceChannel = MethodChannel(binding.binaryMessenger, "com.bearcode.device_inspector/device")
        deviceChannel.setMethodCallHandler(deviceProvider)

        // OS
        osProvider = OSInfoProvider(context)
        val osChannel = MethodChannel(binding.binaryMessenger, "com.bearcode.device_inspector/os")
        osChannel.setMethodCallHandler(osProvider)

        // Battery
        batteryProvider = BatteryInfoProvider(context)
        val batteryChannel = MethodChannel(binding.binaryMessenger, "com.bearcode.device_inspector/battery")
        batteryChannel.setMethodCallHandler(batteryProvider)

        // Network
        networkProvider = NetworkInfoProvider(context)
        val networkChannel = MethodChannel(binding.binaryMessenger, "com.bearcode.device_inspector/network")
        networkChannel.setMethodCallHandler(networkProvider)

        // Hardware
        hardwareProvider = HardwareInfoProvider(context)
        val hardwareChannel = MethodChannel(binding.binaryMessenger, "com.bearcode.device_inspector/hardware")
        hardwareChannel.setMethodCallHandler(hardwareProvider)

        // Security
        securityProvider = SecurityCheckProvider(context)
        val securityChannel = MethodChannel(binding.binaryMessenger, "com.bearcode.device_inspector/security")
        securityChannel.setMethodCallHandler(securityProvider)

        // Performance
        performanceProvider = PerformanceMonitorProvider(context)
        val performanceChannel = MethodChannel(binding.binaryMessenger, "com.bearcode.device_inspector/performance")
        performanceChannel.setMethodCallHandler(performanceProvider)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        performanceProvider.stopMonitoring()
    }
}
