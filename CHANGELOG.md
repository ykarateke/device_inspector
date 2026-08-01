# Changelog

All notable changes to the `device_inspector` project are documented in this file.

This project adheres to [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned — v0.1.0 MVP (Q1 2025)

#### Dart Package — Core (`lib/src/core/`)
- [x] `DeviceInspectorCore` singleton — central coordinator
- [x] `PlatformBridge` — `MethodChannel` abstraction layer
- [x] `DeviceInspectorConfig` — configuration with `initialize()`
- [x] `DeviceInspectorLogLevel` — configurable logging (`off`, `error`, `warn`, `info`, `debug`, `verbose`)
- [x] Exception hierarchy: `DeviceInspectorException`, `PlatformNotSupportedException`, `PermissionDeniedException`, `HardwareAccessException`, `SecurityCheckException`, `ConfigurationException`
- [x] Error handler with graceful fallback strategy (`unknown()` / `empty()` factories)
- [x] Constants: channel names, module identifiers, platform keys

#### Dart Package — Models (`lib/src/models/`)
- [x] `DeviceSnapshot` — root aggregate model wrapping all sub-modules
- [x] `DeviceInfo` — manufacturer, model, market name, identifier, codename, tier, release year
- [x] `OSInfo` — platform, version (major/minor/patch), build number, API level, kernel version
- [x] `BatteryInfo` — level, charging state, health, max capacity percent, low-power mode
- [x] `NetworkInfo` — type (wifi/cellular/ethernet/vpn/offline), carrier, cellular generation, VPN/proxy/airplane detection, Wi-Fi SSID, signal strength, local IP
- [x] `HardwareInfo` — CPU (name, cores, architecture, max frequency, neural engine), GPU (Metal/Vulkan/OpenGL support), Display (resolution, DPI, refresh rate, HDR, brightness)
- [x] `MemoryInfo` — total/available bytes, usage percent, per-app usage, low-memory flag, formatted getters
- [x] `StorageInfo` — total/free bytes, usage percent, per-app usage, data/cache paths, formatted getters
- [x] `SecurityInfo` — root/jailbreak/emulator/debugger detection, developer mode, suspicious apps/paths/env-vars/libraries, detected threats list, security score (0–100), `isCompromised` getter
- [x] `AppInfo` — app name, version, build number, bundle ID, install/first-launch timestamps, signature hash, debug build flag
- [x] `PerformanceSnapshot` — FPS, CPU usage (total + app), memory usage (MB + %), thermal state, battery impact level
- [x] All models generated via Freezed (`@freezed`) + JsonSerializable (`@JsonSerializable`)
- [x] `toJson()` / `fromJson()` on every model
- [x] `copyWith()` on every model (Freezed)
- [x] `==` / `hashCode` / `toString()` on every model (Freezed)
- [x] `unknown()` / `empty()` fallback factories on every model
- [x] Enum types: `DeviceTier`, `DevicePlatform`, `DeviceInspectorModule`, `BatteryHealth`, `BatteryChargingState`, `NetworkType`

#### Dart Package — Services (`lib/src/services/`)
- [x] `DeviceService` — fetches device identity via platform bridge
- [x] `OSService` — fetches operating system details
- [x] `BatteryService` — fetches battery status and health
- [x] `NetworkService` — fetches connectivity and carrier info
- [x] `HardwareService` — fetches CPU, GPU, and display specs
- [x] `MemoryService` — fetches RAM statistics
- [x] `StorageService` — fetches disk storage statistics
- [x] `SecurityService` — orchestrates security checks (root/jailbreak/emulator/debugger)
- [x] `AppService` — resolves application metadata (Dart-side, no platform channel)
- [x] `PerformanceService` — stream-based real-time performance monitoring

#### Dart Package — Public API (`lib/device_inspector.dart`)
- [x] `DeviceInspector.instance` — singleton accessor
- [x] `DeviceInspector.initialize()` — async configuration bootstrap
- [x] `DeviceInspector.inspect()` — parallel full-device snapshot (`Future<DeviceSnapshot>`)
- [x] `DeviceInspector.device`, `.os`, `.battery`, `.network`, `.hardware`, `.memory`, `.storage`, `.security`, `.app` — modular lazy accessors with caching
- [x] `DeviceInspector.performance` — real-time `PerformanceMonitor` getter
- [x] `DeviceInspector.refresh()` — cache invalidation (all modules or selective)
- [x] `DeviceInspector.dispose()` — resource cleanup
- [x] `DeviceInspector.supportedModules` — platform capability discovery
- [x] `DeviceInspector.isModuleSupported()` — per-module support check
- [x] `DeviceInspector.platform` — runtime platform detection

#### iOS Native (`ios/Classes/`)
- [x] `DeviceInspectorPlugin.swift` — main plugin registration with 7 `FlutterMethodChannel` instances
- [x] `DeviceInspectorProvider` protocol — standardized `handle(_:result:)` interface
- [x] `DeviceInfoProvider.swift` — `UIDevice`, `sysctl hw.machine`, model-to-market-name mapping table, tier determination, release year lookup
- [x] `OSInfoProvider.swift` — `UIDevice.current.systemVersion`, `sysctl kern.osversion`
- [x] `BatteryInfoProvider.swift` — `UIDevice.batteryLevel`/`batteryState`, `ProcessInfo.isLowPowerModeEnabled`, IOKit battery health (optional)
- [x] `NetworkInfoProvider.swift` — `NWPathMonitor`, `CTTelephonyNetworkInfo`, `CFNetworkCopySystemProxySettings`, VPN detection
- [x] `HardwareInfoProvider.swift` — CPU core count (`sysctl hw.ncpu`), architecture detection
- [x] `SecurityCheckProvider.swift` — simulator check (`#if targetEnvironment(simulator)`), debugger check (`sysctl P_TRACED`), suspicious file paths (`Cydia.app`, `MobileSubstrate.dylib`, etc.), Cydia URL scheme, sandbox escape write test, dylib injection scan (`_dyld_image_count`)
- [x] `PerformanceMonitorProvider.swift` — `CADisplayLink` for FPS, `host_statistics` for CPU, `task_info` for memory
- [x] All providers use `DispatchQueue.global(qos: .userInitiated)` for background execution
- [x] Minimum iOS 14.0, Swift 5.9+, Xcode 15.0+

#### Android Native (`android/src/main/kotlin/com/bearcode/device_inspector/`)
- [x] `DeviceInspectorPlugin.kt` — main plugin registration with 7 `MethodChannel` instances, `FlutterPlugin` interface
- [x] `DeviceInfoProvider.kt` — `Build.MANUFACTURER`/`MODEL`/`DEVICE`, `Settings.Secure.ANDROID_ID`, model-to-market-name mapping, tier determination (cores + RAM heuristic)
- [x] `OSInfoProvider.kt` — `Build.VERSION.RELEASE`/`SDK_INT`/`DISPLAY`
- [x] `BatteryInfoProvider.kt` — `Intent.ACTION_BATTERY_CHANGED`, `BatteryManager` properties (level, scale, status, health, capacity), `PowerManager.isPowerSaveMode`
- [x] `NetworkInfoProvider.kt` — `ConnectivityManager` + `NetworkCapabilities`, `TelephonyManager` (carrier, data network type), VPN transport detection, proxy check, airplane mode via `Settings.Global`, Wi-Fi SSID via `WifiManager`
- [x] `HardwareInfoProvider.kt` — CPU cores (`Runtime.availableProcessors`), architecture (`Build.SUPPORTED_ABIS`), GPU detection (Vulkan/OpenGL ES via `PackageManager`)
- [x] `MemoryInfoProvider.kt` — `ActivityManager.MemoryInfo` (total/available), `/proc/meminfo` parsing, per-app memory via `Debug.MemoryInfo`
- [x] `StorageInfoProvider.kt` — `StatFs` for total/free bytes, `Environment.getDataDirectory()`
- [x] `SecurityCheckProvider.kt` — root binary scan (`/sbin/su`, `/system/bin/su`, etc.), Magisk detection (`/data/adb/magisk`), SuperUser app scan via `PackageManager`, emulator detection (Build fingerprint/hardware/model/manufacturer/product heuristics), debugger check (`Debug.isDebuggerConnected`), developer mode + ADB detection (`Settings.Global`), suspicious environment variables (`LD_PRELOAD`, `LD_LIBRARY_PATH`), system property checks via `getprop`
- [x] `PerformanceMonitorProvider.kt` — `Choreographer.FrameCallback` for FPS, `/proc/stat` for CPU, `ActivityManager` for memory
- [x] All providers use `CoroutineScope(Dispatchers.IO)` for background execution
- [x] Minimum SDK 24 (Android 7.0), Kotlin 1.9+, AGP 8.2+, compile SDK 34+
- [x] Android manifest permissions: `ACCESS_NETWORK_STATE` (required), `READ_PHONE_STATE` (optional), `ACCESS_WIFI_STATE` (optional)

#### Package Configuration
- [x] `pubspec.yaml` — Flutter plugin definition with iOS/Android platform classes
- [x] `build.yaml` — Freezed + `json_serializable` builder options (explicit `toJson`, checked mode)
- [x] `analysis_options.yaml` — `flutter_lints` extended with strict rules
- [x] MIT License

#### Testing (`test/`, `integration_test/`)
- [x] Unit tests for all model classes — JSON roundtrip, null handling, equality, `copyWith`, `unknown()` factories
- [x] Unit tests for all service classes — mock `PlatformBridge`, success/error/edge cases
- [x] `DeviceSnapshot` integration tests — full `fromJson` → `toJson` symmetry
- [x] Test fixtures — real device sample data (`iPhone15ProMax`, `galaxyS24Ultra`, `pixel8Pro`, `lowEndAndroid`, `emulatorDevice`)
- [x] Integration tests — all platform channels on real device/emulator
- [x] Smoke test script (`scripts/smoke_test.sh`) — `dart analyze` + `flutter test` + coverage

#### CI/CD (`.github/workflows/`)
- [x] `test.yml` — unit tests on every push/PR (Flutter 3.22, coverage via `codecov`)
- [x] Static analysis — `dart analyze` + `dart format --check`
- [x] Android emulator integration tests on macOS runner

#### Documentation (`docs/`)
- [x] `PRD.md` — product requirements: problem, goal, audience, API design, feature phases, privacy, analytics, license, success criteria
- [x] `ARCHITECTURE.md` — layered architecture, data flow, platform bridge, package structure, phase evolution, design decisions, performance considerations
- [x] `API_SPEC.md` — complete public API: all classes, methods, parameters, return types, enums, error codes, analytics integration, platform support matrix
- [x] `DATA_MODELS.md` — all 11 model classes with field types, Freezed/JSON config, `build.yaml`, model relationship tree
- [x] `PLATFORM_INTEGRATION.md` — full iOS (Swift) and Android (Kotlin) native implementation with code samples, MethodChannel mapping, error handling, provider pattern
- [x] `SECURITY_PRIVACY.md` — privacy commitment, collected vs excluded data, App Store/Play Store compliance, jailbreak/root detection algorithms, security scoring, defence-in-depth strategy, OWASP MASVS comparison, vulnerability disclosure policy
- [x] `TESTING.md` — test pyramid, unit/integration/E2E tests with code samples, CI/CD pipeline, coverage targets, smoke tests, fixtures
- [x] `DEVELOPMENT.md` — setup, branch strategy, commit conventions, PR template, code style, adding a new module walkthrough, versioning, example app, debugging, contribution guide

#### Example App (`example/`)
- [x] `example/lib/main.dart` — full demo Flutter app exercising all modules: device, OS, battery, network, security
- [x] `example/pubspec.yaml`, `example/ios/`, `example/android/` — standard Flutter example scaffolding

---

### Planned — v0.2.0 Hardware Intelligence (Q2 2025)
- [ ] `HardwareInfo` fully implemented: CPU, GPU, Display with real native values
- [ ] `CPUInfo`: model name detection via sysctl (iOS) and `/proc/cpuinfo` (Android)
- [ ] `GPUInfo`: Metal feature set detection (iOS), Vulkan version + extensions (Android)
- [ ] `DisplayInfo`: HDR capability detection, actual refresh rate query
- [ ] `MemoryInfo`: real total/available RAM from platform APIs
- [ ] `StorageInfo`: real total/free storage from platform APIs
- [ ] `DeviceTier` auto-calculation based on CPU cores, RAM, and release year
- [ ] `formattedTotal` / `formattedFree` human-readable getters on `MemoryInfo` and `StorageInfo`

### Planned — v0.3.0 Security Module (Q3 2025)
- [ ] `SecurityInfo` fully implemented with production-grade detection
- [ ] iOS: `fork()` sandbox escape test, comprehensive dylib scan, system library integrity check
- [ ] Android: `which su` runtime test, BusyBox detection, `/proc/mounts` analysis, SELinux status
- [ ] `detectedThreats` — detailed human-readable threat descriptions
- [ ] `securityScore` — weighted scoring algorithm with configurable thresholds
- [ ] `isCompromised` — convenience getter aggregating all checks
- [ ] Tamper detection: app signature verification (Android), code integrity hash

### Planned — v1.0.0 Performance Monitor (Q4 2025)
- [ ] `PerformanceMonitor` stream-based class
- [ ] FPS tracking: `CADisplayLink` (iOS), `Choreographer.FrameCallback` (Android)
- [ ] CPU usage: `host_statistics` (iOS), `/proc/stat` parsing (Android)
- [ ] Memory tracking: `task_info` (iOS), `ActivityManager` + `Debug.MemoryInfo` (Android)
- [ ] Thermal state: `NSProcessInfoThermalState` (iOS), `PowerManager` thermal service (Android)
- [ ] Configurable sampling interval (minimum 200ms)
- [ ] `start()`, `stop()`, `dispose()` lifecycle methods
- [ ] Low-FPS / high-CPU warning callbacks
- [ ] `PerformanceSnapshot` with timestamp, FPS, CPU %, memory MB, thermal state, battery impact

### Planned — v2.0.0 Cloud Dashboard (TBD)
- [ ] Separate `device_inspector_cloud` package
- [ ] Optional opt-in device report upload to cloud
- [ ] Dashboard: device distribution, crash correlation, performance trends
- [ ] GDPR/CCPA compliant data collection
- [ ] Team-based access control
- [ ] Real-time device health alerts

---

## [0.1.0] — 2025-Q1 (Planned)

### Added
- Initial MVP release
- **Public API:** `DeviceInspector` singleton with `inspect()`, modular accessors, `initialize()`, `refresh()`, `dispose()`
- **Models:** `DeviceSnapshot`, `DeviceInfo`, `OSInfo`, `BatteryInfo`, `NetworkInfo`, `HardwareInfo`, `MemoryInfo`, `StorageInfo`, `SecurityInfo`, `AppInfo`, `PerformanceSnapshot`
- **iOS native:** Swift 5.9+ implementation with 7 providers, `sysctl`, `UIDevice`, `NWPathMonitor`, IOKit, security checks
- **Android native:** Kotlin 1.9+ implementation with 7 providers, `Build`, `ConnectivityManager`, `BatteryManager`, root/emulator detection
- **Code generation:** Freezed + `json_serializable` with `build_runner`
- **Testing:** Unit tests for all models and services, integration tests on device/emulator
- **CI/CD:** GitHub Actions for unit tests, static analysis, and Android emulator integration tests
- **Documentation:** 9 comprehensive docs covering PRD, architecture, API spec, data models, platform integration, security & privacy, testing, development guide, and changelog
- **Example app:** Full Flutter demo exercising all modules
- **License:** MIT

---

## Version History Template

The following template is the reference for future releases:

```markdown
## [X.Y.Z] — YYYY-MM-DD

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Vulnerability fixes
```

---

## Phase Timeline

```
2025
├── Q1  v0.1.0  MVP
│    ├── Device, OS, Battery, Network, App info
│    ├── inspect() + modular accessors
│    ├── iOS 14+ (Swift) + Android 7+ (Kotlin)
│    ├── Full documentation suite
│    └── pub.dev publication
│
├── Q2  v0.2.0  Hardware Intelligence
│    ├── CPU, GPU, Display, Memory, Storage info
│    └── DeviceTier calculation
│
├── Q3  v0.3.0  Security Module
│    ├── Root, Jailbreak, Emulator, Debugger detection
│    └── securityScore, detectedThreats, isCompromised
│
└── Q4  v1.0.0  Performance Monitor
     ├── FPS, CPU, Memory, Thermal monitoring
     └── Stream-based real-time tracking

2026
└── v2.0.0  Cloud Dashboard (planned)
```

---

## Success Metrics Tracking

| Metric | Target | Status |
|---|---|---|
| ⭐ GitHub stars | 500 (first 6 months) | 🔜 Pending |
| 📦 pub.dev downloads | 10,000 (first 6 months) | 🔜 Pending |
| 👥 Contributors | 20+ (first 6 months) | 🔜 Pending |
| 🧪 Test coverage | ≥ 80% | 🔜 Pending |
| 📱 Supported platforms | iOS 14+, Android 7.0+ | ✅ Ready |
| 🔒 Security detection accuracy | ≥ 70/100 score benchmark | 🔜 Pending |
| 📖 Documentation | All modules documented | ✅ Complete |

---

## Contributors

| Name | Role | Contributions |
|---|---|---|
| Bear Code Studio | Core Team | Project ownership, architecture design, all modules |

*(This list will be updated as new contributors join.)*
