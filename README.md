<p align="center">
  <img src="https://raw.githubusercontent.com/bearcodestudio/device_inspector/main/assets/logo.svg" alt="device_inspector" width="200" />
</p>

<h1 align="center">device_inspector</h1>

<p align="center">
  <strong>Datadog-style device intelligence SDK for Flutter</strong>
</p>

<p align="center">
  <a href="https://pub.dev/packages/device_inspector"><img src="https://img.shields.io/pub/v/device_inspector?color=0175C2&label=pub.dev" alt="pub.dev" /></a>
  <a href="https://github.com/bearcodestudio/device_inspector/actions"><img src="https://img.shields.io/github/actions/workflow/status/bearcodestudio/device_inspector/test.yml?branch=main&label=tests" alt="CI" /></a>
  <a href="https://codecov.io/gh/bearcodestudio/device_inspector"><img src="https://img.shields.io/codecov/c/github/bearcodestudio/device_inspector?token=CODECOV_TOKEN" alt="coverage" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="license" /></a>
  <a href="https://github.com/bearcodestudio/device_inspector/stargazers"><img src="https://img.shields.io/github/stars/bearcodestudio/device_inspector?style=social" alt="stars" /></a>
</p>

<p align="center">
  <b>iOS 14+</b> &nbsp;·&nbsp; <b>Android 7.0+</b> &nbsp;·&nbsp; <b>Swift 5.9</b> &nbsp;·&nbsp; <b>Kotlin 1.9</b>
</p>

---

**device_inspector** replaces a dozen separate packages with a single, unified API.

Instead of stitching together `device_info_plus`, `battery_plus`, `connectivity_plus`, `network_info_plus` — each with its own API quirks — you call **one method** and get the complete device picture:

```dart
final snapshot = await DeviceInspector.inspect();
```

## Why device_inspector?

| Problem | device_inspector |
|---|---|
| 🔀 Fragmented APIs across 5+ packages | ✅ One `inspect()` call |
| ❌ No root/jailbreak detection | ✅ Built-in security checks |
| ❌ No hardware performance data | ✅ CPU, GPU, RAM, storage |
| ❌ No device tier classification | ✅ low / medium / high tiers |
| ❌ Crash reports miss device context | ✅ Full snapshot → Sentry / Crashlytics |
| ❌ No real-time monitoring | ✅ Stream-based battery & network listeners |

## Quick Start

```yaml
# pubspec.yaml
dependencies:
  device_inspector: ^0.1.0
```

```dart
import 'package:device_inspector/device_inspector.dart';

void main() async {
  // Optional: enable security checks and performance monitor
  await DeviceInspector.initialize(
    const DeviceInspectorConfig(
      enableSecurityCheck: true,
      logLevel: DeviceInspectorLogLevel.error,
    ),
  );

  // Full inspection — all data in one call
  final snapshot = await DeviceInspector.inspect();

  print('Device: ${snapshot.device.marketName}');   // "iPhone 15 Pro"
  print('OS:     ${snapshot.os.platform} ${snapshot.os.version}'); // "iOS 17.4"
  print('Battery: ${snapshot.battery.level}%');      // "85%"
  print('Tier:   ${snapshot.device.tier.name}');     // "high"
  print('Secure: ${snapshot.security.isCompromised}'); // false
}
```

## Modular Access

Need just one piece of data? Use the cached, lazy-loading accessors:

```dart
final battery = await DeviceInspector.battery;
if (battery.level < 20 && !battery.isCharging) {
  showLowBatteryWarning();
}

final network = await DeviceInspector.network;
if (network.isVpn) {
  logVpnUsage();
}
```

## Real-Time Streams

```dart
// Battery changes every second
DeviceInspector.batteryStream.listen((battery) {
  print('Battery: ${battery.level}%');
});

// Network state transitions (wifi → cellular → offline)
DeviceInspector.networkStream.listen((network) {
  print('Network: ${network.type.name}');
});
```

## Device Fingerprint

Anonymous, stable device hash — no PII, survives app reinstalls:

```dart
final fingerprint = await DeviceInspector.fingerprint;
// "d4e5f6a7b8c9..." — same device, same hash, different apps
```

## Security Module

```dart
final security = await DeviceInspector.security;

if (security.isCompromised) {
  // Flag for server-side review
  print('Threats: ${security.detectedThreats.join(", ")}');

  // Check individual indicators
  if (security.isRooted) logRootDetected();
  if (security.isEmulator) logEmulatorDetected();
  if (security.isDebuggerAttached) logDebuggerAttached();
}

print('Security score: ${security.securityScore}/100');
```

## Crash Reporting Integration

### Sentry

```dart
final snapshot = await DeviceInspector.inspect();

Sentry.configureScope((scope) {
  scope.setContexts('device', snapshot.toJson());
});
```

### Firebase Crashlytics

```dart
final snapshot = await DeviceInspector.inspect();

await FirebaseCrashlytics.instance.setCustomKey(
  'device_model', snapshot.device.model,
);
await FirebaseCrashlytics.instance.setCustomKey(
  'device_tier', snapshot.device.tier.name,
);
```

## Complete Data Model

```
DeviceSnapshot
├── device     → DeviceInfo        (manufacturer, model, market name, tier, release year)
├── os         → OSInfo            (platform, version, major/minor/patch, build, API level)
├── battery    → BatteryInfo       (level, charging state, health, low-power mode)
├── network    → NetworkInfo       (type, carrier, cellular gen, VPN, proxy, airplane mode)
├── hardware   → HardwareInfo
│   ├── cpu    → CPUInfo           (name, cores, architecture, frequency, neural engine)
│   ├── gpu    → GPUInfo           (name, Metal, Vulkan, OpenGL ES)
│   └── display → DisplayInfo      (resolution, DPI, refresh rate, HDR, brightness)
├── memory     → MemoryInfo        (total, available, usage %, formatted strings)
├── storage    → StorageInfo       (total, free, usage %, data/cache paths)
├── security   → SecurityInfo      (root, jailbreak, emulator, debugger, threat list, score)
└── app        → AppInfo           (name, version, build, bundle ID, signature)
```

## Supported Platforms

| Platform | Status |
|---|---|
| iOS 14+ | ✅ Full support |
| Android 7.0+ (API 24) | ✅ Full support |
| Web | ❌ Not supported |
| macOS / Windows / Linux | ❌ Not supported |

## Documentation

| Doc | |
|---|---|
| [API Reference](docs/API_SPEC.md) | Complete API: classes, methods, parameters, enums |
| [Architecture](docs/ARCHITECTURE.md) | Layered design, platform bridge, data flow |
| [Data Models](docs/DATA_MODELS.md) | All 11 model classes with Freezed/JSON config |
| [Platform Integration](docs/PLATFORM_INTEGRATION.md) | iOS Swift + Android Kotlin native code |
| [Security & Privacy](docs/SECURITY_PRIVACY.md) | Root/jailbreak detection, privacy guarantees |
| [Testing](docs/TESTING.md) | Unit, service, core, and integration tests |
| [Development](docs/DEVELOPMENT.md) | Setup, conventions, adding modules, contributing |
| [Changelog](CHANGELOG.md) | Release history and roadmap |

## Privacy

- 🔒 **No data leaves the device** — all info is collected locally only
- 🔒 **No tracking** — no behaviour, location, or personal data
- 🔒 **No permanent IDs** — no IMEI, serial number, or advertising ID
- 🔒 **Opt-in modules** — security checks and performance monitor are off by default
- 🔒 **Transparent** — every data source is visible in the source code

## Contributing

Contributions welcome! Please read the [Development Guide](docs/DEVELOPMENT.md) and [Contributing Guide](CONTRIBUTING.md).

```bash
git clone https://github.com/bearcodestudio/device_inspector.git
cd device_inspector
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test         # 96 tests
dart analyze         # zero errors
```

## License

MIT © [Bear Code Studio](https://github.com/bearcodestudio)

---

<p align="center">
  <sub>Built with ❤️ for the Flutter community</sub>
</p>
