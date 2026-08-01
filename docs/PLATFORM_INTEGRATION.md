# Device Inspector — Platform Entegrasyonu

## 1. Method Channel Mimarisi

Flutter ile native kod arasındaki tüm iletişim `MethodChannel` üzerinden yapılır. Her modül için ayrı bir kanal kullanılır:

| Kanal | Dart Metodu | Görev |
|---|---|---|
| `com.bearcode.device_inspector/device` | `getDeviceInfo()` | Cihaz bilgisi |
| `com.bearcode.device_inspector/os` | `getOSInfo()` | İşletim sistemi bilgisi |
| `com.bearcode.device_inspector/battery` | `getBatteryInfo()` | Batarya bilgisi |
| `com.bearcode.device_inspector/network` | `getNetworkInfo()` | Ağ bilgisi |
| `com.bearcode.device_inspector/hardware` | `getHardwareInfo()` | Donanım bilgisi |
| `com.bearcode.device_inspector/memory` | `getMemoryInfo()` | RAM bilgisi |
| `com.bearcode.device_inspector/storage` | `getStorageInfo()` | Depolama bilgisi |
| `com.bearcode.device_inspector/security` | `getSecurityInfo()` | Güvenlik kontrolleri |
| `com.bearcode.device_inspector/performance` | `startPerformanceMonitor()` / `stopPerformanceMonitor()` | Performans izleme |

Tüm kanallar `Map<String, dynamic>` formatında veri döndürür. İstisnalar Dart tarafında yakalanır ve `DeviceInspectorException` türevlerine dönüştürülür.

---

## 2. iOS — Swift Implementasyonu

### 2.1 Minimum Gereksinimler

| Kriter | Değer |
|---|---|
| Minimum iOS | 14.0 |
| Swift | 5.9+ |
| Xcode | 15.0+ |
| Gerekli framework'ler | UIKit, IOKit, Network, CoreTelephony, SystemConfiguration |

### 2.2 Plugin Kaydı

**`DeviceInspectorPlugin.swift`** — Ana plugin sınıfı:

```swift
import Flutter
import UIKit

public class DeviceInspectorPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        // Device kanalı
        let deviceChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/device",
            binaryMessenger: registrar.messenger()
        )
        let deviceProvider = DeviceInfoProvider()
        deviceChannel.setMethodCallHandler(deviceProvider.handle)

        // OS kanalı
        let osChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/os",
            binaryMessenger: registrar.messenger()
        )
        let osProvider = OSInfoProvider()
        osChannel.setMethodCallHandler(osProvider.handle)

        // Battery kanalı
        let batteryChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/battery",
            binaryMessenger: registrar.messenger()
        )
        let batteryProvider = BatteryInfoProvider()
        batteryChannel.setMethodCallHandler(batteryProvider.handle)

        // Network kanalı
        let networkChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/network",
            binaryMessenger: registrar.messenger()
        )
        let networkProvider = NetworkInfoProvider()
        networkChannel.setMethodCallHandler(networkProvider.handle)

        // Hardware kanalı
        let hardwareChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/hardware",
            binaryMessenger: registrar.messenger()
        )
        let hardwareProvider = HardwareInfoProvider()
        hardwareChannel.setMethodCallHandler(hardwareProvider.handle)

        // Security kanalı
        let securityChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/security",
            binaryMessenger: registrar.messenger()
        )
        let securityProvider = SecurityCheckProvider()
        securityChannel.setMethodCallHandler(securityProvider.handle)

        // Performance kanalı
        let performanceChannel = FlutterMethodChannel(
            name: "com.bearcode.device_inspector/performance",
            binaryMessenger: registrar.messenger()
        )
        let performanceProvider = PerformanceMonitorProvider()
        performanceChannel.setMethodCallHandler(performanceProvider.handle)
    }
}
```

### 2.3 Provider Protokolü

```swift
protocol DeviceInspectorProvider {
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
}
```

---

## 3. iOS — `DeviceInfoProvider.swift`

Cihaz donanım kimlik bilgilerini toplar.

```swift
import Foundation
import UIKit

class DeviceInfoProvider: DeviceInspectorProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getDeviceInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var info: [String: Any] = [:]

            // Sabit — Apple ürünleri
            info["manufacturer"] = "Apple"

            // Model (örn: iPhone15,3)
            info["model"] = Self.getModelIdentifier()
            info["codename"] = Self.getModelIdentifier()

            // Market ismi (örn: iPhone 15 Pro)
            info["marketName"] = Self.getMarketName()

            // Identifier for vendor
            info["identifier"] = UIDevice.current.identifierForVendor?.uuidString

            // Device tier
            info["tier"] = Self.determineTier()

            // Release year
            info["releaseYear"] = Self.getReleaseYear()

            result(info)
        }
    }

    // MARK: - sysctl ile model kodu
    static func getModelIdentifier() -> String {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    // MARK: - Model → Market ismi eşleme tablosu
    static func getMarketName() -> String {
        let model = getModelIdentifier()
        let mapping: [String: String] = [
            // iPhone 15 serisi
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            // iPhone 14 serisi
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            // iPhone SE
            "iPhone14,6": "iPhone SE (3rd gen)",
            // iPad
            "iPad14,3": "iPad Pro 11-inch (4th gen)",
            "iPad14,4": "iPad Pro 11-inch (4th gen)",
            // Simulator
            "arm64": "Simulator (arm64)",
            "x86_64": "Simulator (x86_64)",
        ]
        return mapping[model] ?? model
    }

    // MARK: - Device tier hesaplama
    static func determineTier() -> String {
        let model = getModelIdentifier()

        // High tier: Pro modeller, en yeni cihazlar
        let highTier = [
            "iPhone16,1", "iPhone16,2", // 15 Pro / Pro Max
            "iPhone15,2", "iPhone15,3", // 14 Pro / Pro Max
            "iPhone14,2", "iPhone14,3", // 13 Pro / Pro Max
        ]

        // Low tier: Eski cihazlar
        let lowTier = [
            "iPhone10,1", "iPhone10,2", "iPhone10,3", "iPhone10,4", "iPhone10,5", "iPhone10,6", // iPhone 8 / X
            "iPhone9,1", "iPhone9,2", "iPhone9,3", "iPhone9,4", // iPhone 7
            "iPhone8,1", "iPhone8,2", "iPhone8,3", "iPhone8,4", // iPhone 6s / SE 1st
        ]

        if highTier.contains(model) { return "high" }
        if lowTier.contains(model) { return "low" }
        return "medium"
    }

    static func getReleaseYear() -> Int? {
        let model = getModelIdentifier()
        let years: [String: Int] = [
            "iPhone16,1": 2023, "iPhone16,2": 2023, // 15 Pro
            "iPhone15,4": 2023, "iPhone15,5": 2023, // 15
            "iPhone15,2": 2022, "iPhone15,3": 2022, // 14 Pro
            "iPhone14,7": 2022, "iPhone14,8": 2022, // 14
            "iPhone14,2": 2021, "iPhone14,3": 2021, // 13 Pro
        ]
        return years[model]
    }
}
```

---

## 4. iOS — `BatteryInfoProvider.swift`

```swift
import UIKit

class BatteryInfoProvider: DeviceInspectorProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getBatteryInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.main.async {
            let device = UIDevice.current
            device.isBatteryMonitoringEnabled = true

            var info: [String: Any] = [:]

            let level = device.batteryLevel
            info["level"] = level >= 0 ? Int(level * 100) : -1
            info["isCharging"] = device.batteryState == .charging || device.batteryState == .full

            switch device.batteryState {
            case .charging:
                info["chargingState"] = "charging"
            case .full:
                info["chargingState"] = "full"
            case .unplugged:
                info["chargingState"] = "discharging"
            default:
                info["chargingState"] = "unknown"
            }

            // Düşük güç modu
            info["isLowPowerMode"] = ProcessInfo.processInfo.isLowPowerModeEnabled

            // IOKit üzerinden batarya sağlığı (opsiyonel, private API değil)
            if let healthInfo = Self.getBatteryHealth() {
                info["maxCapacityPercent"] = healthInfo.maxCapacity
                info["health"] = healthInfo.healthStatus
            }

            result(info)
        }
    }

    // NOT: IOKit batarya sağlığı erişimi App Store review'den geçer
    // ancak IOKit public API'dir. Reddedilme riski düşüktür.
    static func getBatteryHealth() -> (maxCapacity: Int, healthStatus: String)? {
        // IOKit battery health implementation
        // Gerçek implementasyonda IOPSCopyPowerSourcesInfo vb. kullanılır
        return nil // MVP'de opsiyonel
    }
}
```

---

## 5. iOS — `NetworkInfoProvider.swift`

```swift
import Foundation
import Network
import CoreTelephony
import SystemConfiguration

class NetworkInfoProvider: DeviceInspectorProvider {

    private var pathMonitor: NWPathMonitor?

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getNetworkInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        let semaphore = DispatchSemaphore(value: 0)
        var info: [String: Any] = [
            "type": "unknown",
            "isVpn": false,
            "isProxy": false,
            "isAirplaneMode": false,
            "signalStrength": -1,
        ]

        let monitor = NWPathMonitor()
        self.pathMonitor = monitor

        monitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                info["type"] = "wifi"
            } else if path.usesInterfaceType(.cellular) {
                info["type"] = "cellular"
                // Operatör bilgisi
                let networkInfo = CTTelephonyNetworkInfo()
                if let carrier = networkInfo.serviceSubscriberCellularProviders?.values.first {
                    info["carrier"] = carrier.carrierName
                    // 4G/5G bilgisi
                    if let radioTech = networkInfo.serviceCurrentRadioAccessTechnology?.values.first {
                        info["cellularGeneration"] = Self.parseRadioTechnology(radioTech)
                    }
                }
            } else if path.usesInterfaceType(.wiredEthernet) {
                info["type"] = "ethernet"
            } else {
                info["type"] = "offline"
            }

            info["isVpn"] = Self.isVpnActive()
            info["isProxy"] = Self.isProxyConfigured()

            semaphore.signal()
        }

        monitor.start(queue: DispatchQueue.global(qos: .userInitiated))
        _ = semaphore.wait(timeout: .now() + 3.0)
        monitor.cancel()

        result(info)
    }

    static func parseRadioTechnology(_ tech: String) -> String {
        switch tech {
        case CTRadioAccessTechnologyLTE: return "4G"
        case CTRadioAccessTechnologyNR: return "5G"
        case CTRadioAccessTechnologyWCDMAHSDPA,
             CTRadioAccessTechnologyWCDMAHSUPA,
             CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyHSUPA: return "3G"
        case CTRadioAccessTechnologyEdge,
             CTRadioAccessTechnologyGPRS: return "2G"
        default: return "unknown"
        }
    }

    static func isVpnActive() -> Bool {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any]
        else { return false }
        return proxySettings.keys.contains(where: { $0.contains("tap") || $0.contains("tun") || $0.contains("ppp") })
    }

    static func isProxyConfigured() -> Bool {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any]
        else { return false }
        return proxySettings["HTTPProxy"] != nil || proxySettings["HTTPSProxy"] != nil
    }
}
```

---

## 6. iOS — `SecurityCheckProvider.swift`

Jailbreak tespiti. Phase 3'te tamamlanacak.

```swift
import Foundation
import UIKit

class SecurityCheckProvider: DeviceInspectorProvider {

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getSecurityInfo" else {
            result(FlutterMethodNotImplemented)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
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

            var threats: [String] = []
            var score = 100

            // 1. Simulator kontrolü
            #if targetEnvironment(simulator)
            info["isEmulator"] = true
            threats.append("Running on simulator")
            score -= 30
            #endif

            // 2. Debugger kontrolü
            if Self.isDebuggerAttached() {
                info["isDebuggerAttached"] = true
                threats.append("Debugger attached")
                score -= 20
            }

            // 3. Şüpheli dosya yolları
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

            // 4. Cydia URL scheme kontrolü
            if UIApplication.shared.canOpenURL(URL(string: "cydia://")!) {
                info["hasSuspiciousApps"] = true
                threats.append("Cydia URL scheme available")
                score -= 20
            }

            // 5. Sandbox dışı yazma testi
            let testPath = "/private/test_jailbreak"
            do {
                try "test" .write(toFile: testPath, atomically: true, encoding: .utf8)
                try FileManager.default.removeItem(atPath: testPath)
                info["isJailbroken"] = true
                threats.append("Sandbox escape: write outside container succeeded")
                score -= 40
            } catch {
                // Beklenen — sandbox içinde yazılamaz
            }

            // 6. dylib enjeksiyonu kontrolü
            if Self.hasSuspiciousDynamicLibraries() {
                info["hasModifiedLibraries"] = true
                threats.append("Suspicious dynamic libraries detected")
                score -= 15
            }

            info["detectedThreats"] = threats
            info["securityScore"] = max(0, score)

            if !threats.isEmpty {
                info["isJailbroken"] = true
            }

            result(info)
        }
    }

    static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]

        let result = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        if result != 0 { return false }

        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

    static func hasSuspiciousDynamicLibraries() -> Bool {
        let suspiciousLibs = [
            "MobileSubstrate",
            "SubstrateLoader",
            "CydiaSubstrate",
            "libhooker",
            "libsubstitute",
        ]
        let imageCount = _dyld_image_count()
        for i in 0..<imageCount {
            if let name = _dyld_get_image_name(i) {
                let nameStr = String(cString: name)
                for lib in suspiciousLibs {
                    if nameStr.contains(lib) { return true }
                }
            }
        }
        return false
    }
}
```

---

## 7. Android — Kotlin Implementasyonu

### 7.1 Minimum Gereksinimler

| Kriter | Değer |
|---|---|
| Minimum SDK | API 24 (Android 7.0) |
| Kotlin | 1.9+ |
| AGP | 8.2+ |
| Compile SDK | 34+ |
| Gerekli izinler | Manifest'te belirtilecek |

### 7.2 AndroidManifest.xml İzinleri

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.bearcode.device_inspector">

    <!-- Batarya bilgisi için -->
    <uses-permission android:name="android.permission.BATTERY_STATS"
        tools:ignore="ProtectedPermissions" />

    <!-- Ağ durumu -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

    <!-- Operatör bilgisi (opsiyonel) -->
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />

    <!-- Root tespiti için dosya sistemi okuma -->
    <!-- Ek izin gerektirmez, standart dosya sistemi erişimi kullanılır -->
</manifest>
```

### 7.3 Plugin Kaydı

**`DeviceInspectorPlugin.kt`** — Ana plugin sınıfı:

```kotlin
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
```

---

## 8. Android — `DeviceInfoProvider.kt`

```kotlin
package com.bearcode.device_inspector

import android.content.Context
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class DeviceInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getDeviceInfo") {
            result.notImplemented()
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val info = mutableMapOf<String, Any?>()

                info["manufacturer"] = Build.MANUFACTURER
                info["model"] = Build.MODEL
                info["marketName"] = getMarketName()
                info["codename"] = Build.DEVICE

                // ANDROID_ID
                try {
                    info["identifier"] = Settings.Secure.getString(
                        context.contentResolver,
                        Settings.Secure.ANDROID_ID
                    )
                } catch (e: Exception) {
                    info["identifier"] = null
                }

                info["tier"] = determineTier()
                info["releaseYear"] = getReleaseYear(Build.MODEL)

                result(info)
            } catch (e: Exception) {
                result.error("DEVICE_INFO_ERROR", e.message, null)
            }
        }
    }

    private fun getMarketName(): String {
        // Build.MODEL genelde piyasa adıdır (örn: "SM-S928B" → "Galaxy S24 Ultra")
        // Cihaz mapping tablosuyla zenginleştirilebilir
        val model = Build.MODEL
        val mapping = mapOf(
            "SM-S928B" to "Galaxy S24 Ultra",
            "SM-S921B" to "Galaxy S24",
            "SM-S926B" to "Galaxy S24+",
            "Pixel 8 Pro" to "Pixel 8 Pro",
            "Pixel 8" to "Pixel 8",
        )
        return mapping[model] ?: "${Build.MANUFACTURER} $model"
    }

    private fun determineTier(): String {
        val model = Build.MODEL
        val cores = Runtime.getRuntime().availableProcessors()
        val totalRam = getTotalRamBytes()

        // High: 8+ çekirdek, 8GB+ RAM
        if (cores >= 8 && totalRam >= 8L * 1024 * 1024 * 1024) return "high"
        // Low: <4 çekirdek, <4GB RAM
        if (cores < 4 || totalRam < 4L * 1024 * 1024 * 1024) return "low"
        return "medium"
    }

    private fun getTotalRamBytes(): Long {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
        val memoryInfo = android.app.ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)
        return memoryInfo.totalMem
    }

    private fun getReleaseYear(model: String): Int? {
        // Basitleştirilmiş mapping
        val years = mapOf(
            "SM-S928B" to 2024,
            "Pixel 8 Pro" to 2023,
        )
        return years[model]
    }
}
```

---

## 9. Android — `BatteryInfoProvider.kt`

```kotlin
package com.bearcode.device_inspector

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BatteryInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getBatteryInfo") {
            result.notImplemented()
            return
        }

        try {
            val batteryIntent = context.registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            )

            val info = mutableMapOf<String, Any?>()

            if (batteryIntent != null) {
                val level = batteryIntent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                val scale = batteryIntent.getIntExtra(BatteryManager.EXTRA_SCALE, 100)
                info["level"] = if (level >= 0 && scale > 0) (level * 100 / scale) else -1

                val status = batteryIntent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
                info["isCharging"] = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                        status == BatteryManager.BATTERY_STATUS_FULL

                info["chargingState"] = when (status) {
                    BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
                    BatteryManager.BATTERY_STATUS_FULL -> "full"
                    BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
                    BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "discharging"
                    else -> "unknown"
                }

                // Android 8+ batarya sağlığı
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    val healthStatus = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_HEALTH)
                    info["health"] = when (healthStatus) {
                        BatteryManager.BATTERY_HEALTH_GOOD -> "good"
                        BatteryManager.BATTERY_HEALTH_OVERHEAT,
                        BatteryManager.BATTERY_HEALTH_DEAD,
                        BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "service"
                        BatteryManager.BATTERY_HEALTH_COLD -> "fair"
                        else -> "unknown"
                    }

                    val capacity = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                    info["maxCapacityPercent"] = if (capacity != Int.MIN_VALUE) capacity else null
                } else {
                    info["health"] = null
                    info["maxCapacityPercent"] = null
                }

                // Düşük güç modu (Android 5+)
                val powerManager = context.getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
                info["isLowPowerMode"] = powerManager.isPowerSaveMode
            }

            info["estimatedMinutesRemaining"] = -1

            result(info)
        } catch (e: Exception) {
            result.error("BATTERY_INFO_ERROR", e.message, null)
        }
    }
}
```

---

## 10. Android — `NetworkInfoProvider.kt`

```kotlin
package com.bearcode.device_inspector

import android.content.Context
import android.net.*
import android.telephony.TelephonyManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NetworkInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getNetworkInfo") {
            result.notImplemented()
            return
        }

        try {
            val info = mutableMapOf<String, Any?>()
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

            // Android 7+ (API 24) NetworkCapabilities
            val network = connectivityManager.activeNetwork ?: run {
                info["type"] = "offline"
                info["isVpn"] = false
                info["isProxy"] = false
                info["isAirplaneMode"] = false
                info["signalStrength"] = -1
                result(info)
                return
            }

            val caps = connectivityManager.getNetworkCapabilities(network)

            info["type"] = when {
                caps == null -> "offline"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) -> "vpn"
                else -> "offline"
            }

            // VPN tespiti
            info["isVpn"] = caps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) ?: false

            // Proxy kontrolü
            info["isProxy"] = isProxyConfigured()

            // Operatör bilgisi
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            info["carrier"] = telephonyManager.networkOperatorName?.takeIf { it.isNotEmpty() }

            // Hücresel jenerasyon
            if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true) {
                info["cellularGeneration"] = getCellularGeneration(telephonyManager)
            }

            // Airplane mode
            info["isAirplaneMode"] = isAirplaneModeOn()

            // Sinyal gücü (opsiyonel)
            info["signalStrength"] = -1

            // Wi-Fi SSID (izin gerektirir)
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as android.net.wifi.WifiManager
            val wifiInfo = wifiManager.connectionInfo
            info["wifiSsid"] = wifiInfo?.ssid?.removeSurrounding("\"")

            result(info)
        } catch (e: Exception) {
            result.error("NETWORK_INFO_ERROR", e.message, null)
        }
    }

    private fun getCellularGeneration(tm: TelephonyManager): String? {
        return when (tm.dataNetworkType) {
            TelephonyManager.NETWORK_TYPE_NR -> "5G"
            TelephonyManager.NETWORK_TYPE_LTE -> "4G"
            TelephonyManager.NETWORK_TYPE_HSPAP,
            TelephonyManager.NETWORK_TYPE_HSDPA,
            TelephonyManager.NETWORK_TYPE_HSUPA -> "3G"
            TelephonyManager.NETWORK_TYPE_EDGE,
            TelephonyManager.NETWORK_TYPE_GPRS -> "2G"
            else -> null
        }
    }

    private fun isProxyConfigured(): Boolean {
        val proxyHost = System.getProperty("http.proxyHost")
        return !proxyHost.isNullOrEmpty()
    }

    private fun isAirplaneModeOn(): Boolean {
        return try {
            val contentResolver = context.contentResolver
            val result = android.provider.Settings.Global.getInt(
                contentResolver,
                android.provider.Settings.Global.AIRPLANE_MODE_ON
            )
            result == 1
        } catch (e: Exception) {
            false
        }
    }
}
```

---

## 11. Android — `SecurityCheckProvider.kt`

Root tespiti. Phase 3'te tamamlanacak.

```kotlin
package com.bearcode.device_inspector

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File

class SecurityCheckProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getSecurityInfo") {
            result.notImplemented()
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            val info = mutableMapOf<String, Any?>()
            val threats = mutableListOf<String>()
            var score = 100

            // 1. Root binary'leri
            val rootBinaries = listOf(
                "/system/app/Superuser.apk",
                "/sbin/su",
                "/system/bin/su",
                "/system/xbin/su",
                "/data/local/xbin/su",
                "/data/local/bin/su",
                "/system/sd/xbin/su",
                "/system/bin/failsafe/su",
                "/data/local/su",
                "/su/bin/su",
                "/magisk/.core/bin/su",
            )

            for (path in rootBinaries) {
                if (File(path).exists()) {
                    info["isRooted"] = true
                    threats.add("Root binary found: $path")
                    score -= 40
                    break
                }
            }

            // 2. Magisk tespiti
            if (isMagiskInstalled()) {
                info["isRooted"] = true
                info["hasSuspiciousApps"] = true
                threats.add("Magisk detected")
                score -= 30
            }

            // 3. SuperSU / SU uygulamaları
            val suApps = listOf(
                "com.noshufou.android.su",
                "com.thirdparty.superuser",
                "eu.chainfire.supersu",
                "com.koushikdutta.superuser",
                "com.topjohnwu.magisk",
            )
            val pm = context.packageManager
            for (pkg in suApps) {
                try {
                    pm.getPackageInfo(pkg, 0)
                    info["hasSuspiciousApps"] = true
                    threats.add("SuperUser app found: $pkg")
                    score -= 20
                    break
                } catch (_: PackageManager.NameNotFoundException) { }
            }

            // 4. Emulator tespiti
            if (isEmulator()) {
                info["isEmulator"] = true
                threats.add("Running on emulator")
                score -= 30
            }

            // 5. Debugger tespiti
            if (Debug.isDebuggerConnected() || Debug.waitingForDebugger()) {
                info["isDebuggerAttached"] = true
                threats.add("Debugger attached")
                score -= 20
            }

            // 6. Developer mode ve USB debugging
            val devMode = android.provider.Settings.Global.getInt(
                context.contentResolver,
                android.provider.Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                0
            )
            info["isDeveloperMode"] = devMode == 1

            if (devMode == 1) {
                val adbEnabled = android.provider.Settings.Global.getInt(
                    context.contentResolver,
                    android.provider.Settings.Global.ADB_ENABLED,
                    0
                )
                if (adbEnabled == 1) {
                    threats.add("USB debugging enabled")
                    score -= 10
                }
            }

            // 7. Şüpheli ortam değişkenleri
            val suspiciousEnvVars = listOf("LD_PRELOAD", "LD_LIBRARY_PATH")
            for (envVar in suspiciousEnvVars) {
                val value = System.getenv(envVar)
                if (!value.isNullOrEmpty()) {
                    info["hasSuspiciousEnvVars"] = true
                    threats.add("Suspicious env var: $envVar=$value")
                    score -= 10
                }
            }

            // 8. Sistem özellikleri kontrolü
            val suspiciousProps = listOf(
                "ro.debuggable" to "1",
                "ro.secure" to "0",
                "ro.build.tags" to "test-keys",
            )
            for ((prop, expectedValue) in suspiciousProps) {
                try {
                    val process = Runtime.getRuntime().exec(arrayOf("getprop", prop))
                    val value = process.inputStream.bufferedReader().readText().trim()
                    if (value == expectedValue) {
                        threats.add("Suspicious system property: $prop=$value")
                        score -= 15
                    }
                } catch (_: Exception) { }
            }

            info["detectedThreats"] = threats
            info["securityScore"] = maxOf(0, score)
            info["hasSuspiciousPaths"] = info["isRooted"] == true
            info["hasModifiedLibraries"] = false

            if (threats.isEmpty()) {
                info["isRooted"] = false
                info["isJailbroken"] = false
                info["isEmulator"] = false
                info["hasSuspiciousApps"] = false
                info["hasSuspiciousPaths"] = false
                info["hasSuspiciousEnvVars"] = false
                info["hasModifiedLibraries"] = false
            }

            result(info)
        }
    }

    private fun isMagiskInstalled(): Boolean {
        val magiskPaths = listOf(
            "/data/adb/magisk",
            "/data/adb/modules",
            "/sbin/.magisk",
            "/cache/.disable_magisk",
        )
        return magiskPaths.any { File(it).exists() }
    }

    private fun isEmulator(): Boolean {
        return (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.PRODUCT.contains("sdk_google")
                || Build.PRODUCT.contains("sdk")
                || Build.PRODUCT.contains("sdk_x86")
                || Build.PRODUCT.contains("vbox86p")
                || Build.PRODUCT.contains("emulator")
                || Build.PRODUCT.contains("simulator")
    }
}
```

---

## 12. Dart Tarafı — Platform Bridge

**`lib/src/core/platform_bridge.dart`:**

```dart
import 'package:flutter/services.dart';

class PlatformBridge {
  static const String _prefix = 'com.bearcode.device_inspector';

  final Map<String, MethodChannel> _channels = {};

  MethodChannel _channel(String module) {
    return _channels.putIfAbsent(
      module,
      () => MethodChannel('$_prefix/$module'),
    );
  }

  Future<Map<String, dynamic>> invoke(
    String module,
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    try {
      final result = await _channel(module).invokeMethod(method, arguments);

      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'Platform returned null for $module.$method',
        );
      }
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } on MissingPluginException {
      throw PlatformNotSupportedException(
        'Module "$module" is not supported on this platform',
      );
    }
  }

  DeviceInspectorException _mapPlatformException(PlatformException e) {
    switch (e.code) {
      case 'PERMISSION_DENIED':
        return PermissionDeniedException(e.message ?? 'Permission denied');
      case 'HARDWARE_ACCESS_DENIED':
        return HardwareAccessException(e.message ?? 'Hardware access denied');
      case 'SECURITY_CHECK_FAILED':
        return SecurityCheckException(e.message ?? 'Security check failed');
      default:
        return DeviceInspectorException(
          e.message ?? 'Unknown platform error',
          code: e.code,
        );
    }
  }
}
```

---

## 13. Hata Yönetimi Stratejisi

### Native → Dart hata iletimi:

```swift
// iOS
result(FlutterError(
    code: "HARDWARE_ACCESS_DENIED",
    message: "Unable to access IOKit",
    details: nil
))
```

```kotlin
// Android
result.error(
    "HARDWARE_ACCESS_DENIED",
    "Unable to read /proc/cpuinfo",
    null
)
```

### Dart tarafında dönüşüm:

```dart
try {
  final info = await bridge.invoke('hardware', 'getHardwareInfo');
  return HardwareInfo.fromMap(info);
} on HardwareAccessException {
  return HardwareInfo.unknown(); // Fallback
} on PlatformNotSupportedException {
  rethrow; // Üst katmana ilet
}
```

---

## 14. Eklenmesi Gereken `pubspec.yaml` Platform Yapılandırması

```yaml
flutter:
  plugin:
    platforms:
      ios:
        pluginClass: DeviceInspectorPlugin
      android:
        package: com.bearcode.device_inspector
        pluginClass: DeviceInspectorPlugin
```
