# Device Inspector — Geliştirme Kılavuzu

## 1. Başlangıç

### 1.1 Gereksinimler

| Araç | Minimum Sürüm | Açıklama |
|---|---|---|
| Flutter | 3.22+ | SDK |
| Dart | 3.4+ | Dil |
| Xcode | 15.0+ | iOS build ve test |
| Android Studio | Hedgehog+ | Android build ve emulator |
| CocoaPods | 1.14+ | iOS bağımlılık yönetimi |
| Git | 2.40+ | Sürüm kontrolü |

### 1.2 Depoyu Klonlama

```bash
git clone https://github.com/bearcodestudio/device_inspector.git
cd device_inspector
flutter pub get
```

### 1.3 Kod Üretimi

```bash
# Freezed ve JSON serializable sınıflarını üret
dart run build_runner build --delete-conflicting-outputs

# Geliştirme sırasında watch modu
dart run build_runner watch --delete-conflicting-outputs
```

---

## 2. Proje Yapısı

```
device_inspector/
├── lib/
│   ├── device_inspector.dart           # Public barrel export
│   └── src/
│       ├── core/                       # Çekirdek altyapı
│       │   ├── device_inspector_core.dart
│       │   ├── platform_bridge.dart
│       │   ├── configuration.dart
│       │   ├── error_handler.dart
│       │   ├── logger.dart
│       │   └── constants.dart
│       ├── models/                     # Veri modelleri (*.freezed.dart, *.g.dart)
│       │   ├── device_snapshot.dart
│       │   ├── device_info.dart
│       │   ├── os_info.dart
│       │   ├── battery_info.dart
│       │   ├── network_info.dart
│       │   ├── hardware_info.dart
│       │   ├── memory_info.dart
│       │   ├── storage_info.dart
│       │   ├── security_info.dart
│       │   ├── app_info.dart
│       │   └── performance_snapshot.dart
│       ├── services/                   # İş mantığı servisleri
│       │   ├── device_service.dart
│       │   ├── os_service.dart
│       │   ├── battery_service.dart
│       │   ├── network_service.dart
│       │   ├── hardware_service.dart
│       │   ├── memory_service.dart
│       │   ├── storage_service.dart
│       │   ├── security_service.dart
│       │   ├── app_service.dart
│       │   └── performance_service.dart
│       └── platform/                   # Platform soyutlama
│           └── platform_bridge_impl.dart
├── ios/
│   └── Classes/
│       ├── DeviceInspectorPlugin.swift
│       ├── DeviceInfoProvider.swift
│       ├── BatteryInfoProvider.swift
│       ├── NetworkInfoProvider.swift
│       ├── HardwareInfoProvider.swift
│       ├── SecurityCheckProvider.swift
│       └── PerformanceMonitorProvider.swift
├── android/
│   └── src/main/kotlin/com/bearcode/device_inspector/
│       ├── DeviceInspectorPlugin.kt
│       ├── DeviceInfoProvider.kt
│       ├── BatteryInfoProvider.kt
│       ├── NetworkInfoProvider.kt
│       ├── HardwareInfoProvider.kt
│       ├── SecurityCheckProvider.kt
│       └── PerformanceMonitorProvider.kt
├── test/
│   ├── core/
│   │   ├── platform_bridge_test.dart
│   │   ├── configuration_test.dart
│   │   └── error_handler_test.dart
│   ├── models/
│   │   ├── device_snapshot_test.dart
│   │   ├── device_info_test.dart
│   │   ├── battery_info_test.dart
│   │   └── ...
│   ├── services/
│   │   ├── device_service_test.dart
│   │   ├── battery_service_test.dart
│   │   └── ...
│   └── fixtures/
│       └── device_samples.dart
├── integration_test/
│   └── device_inspector_test.dart
├── example/
│   └── lib/
│       └── main.dart                  # Örnek Flutter uygulaması
└── docs/
    ├── PRD.md
    ├── ARCHITECTURE.md
    ├── API_SPEC.md
    ├── DATA_MODELS.md
    ├── PLATFORM_INTEGRATION.md
    ├── SECURITY_PRIVACY.md
    ├── TESTING.md
    ├── DEVELOPMENT.md
    └── CHANGELOG.md
```

---

## 3. Geliştirme İş Akışı

### 3.1 Branch Stratejisi

```
main          ← Production (pub.dev ile senkron)
  └── develop ← Geliştirme ana branch'i
       ├── feature/device-info
       ├── feature/battery-info
       ├── feature/hardware-intelligence
       ├── feature/security-module
       ├── feature/performance-monitor
       ├── fix/memory-leak-ios
       └── chore/update-dependencies
```

### 3.2 Commit Mesajları

Conventional Commits standardı kullanılır:

```bash
# ✅ Doğru
git commit -m "feat: add battery health detection for iOS"
git commit -m "fix: handle null battery level on Android emulator"
git commit -m "docs: update API specification for v0.2.0"
git commit -m "test: add integration tests for security module"
git commit -m "refactor: extract platform bridge to separate class"
git commit -m "chore: upgrade flutter to 3.22"

# ❌ Yanlış
git commit -m "updated stuff"
git commit -m "bug fix"
git commit -m "WIP"
```

### 3.3 Pull Request Süreci

1. **Branch oluştur:** `feature/xxx` veya `fix/xxx`
2. **Kod üret:** `dart run build_runner build --delete-conflicting-outputs`
3. **Test et:** `flutter test && flutter test integration_test/`
4. **Analiz et:** `dart analyze`
5. **Formatla:** `dart format .`
6. **PR aç:** Template doldur, reviewer ata
7. **Review geç:** En az 1 onay
8. **Merge:** Squash merge ile `develop`'a

### 3.4 PR Template

```markdown
## Açıklama
<!-- Bu PR neyi değiştiriyor? -->

## Değişiklik Tipi
- [ ] Yeni özellik (feat)
- [ ] Hata düzeltmesi (fix)
- [ ] Dokümantasyon (docs)
- [ ] Test (test)
- [ ] Refaktör (refactor)
- [ ] Bağımlılık güncelleme (chore)

## Test Edildi mi?
- [ ] Birim testleri eklendi/güncellendi
- [ ] Entegrasyon testleri çalıştı
- [ ] iOS cihazda test edildi
- [ ] Android cihazda test edildi

## Kontrol Listesi
- [ ] `dart analyze` hatasız
- [ ] `dart format .` uygulandı
- [ ] `flutter test` tüm testler geçiyor
- [ ] Dokümantasyon güncellendi
- [ ] CHANGELOG.md güncellendi

## İlgili Issue
Closes #XXX
```

---

## 4. Kod Stili

### 4.1 Dart Format

```bash
# Tüm projeyi formatla
dart format .

# Sadece değişen dosyaları kontrol et
dart format --output=none --set-exit-if-changed .
```

### 4.2 Lint Kuralları

**`analysis_options.yaml`:**

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_dynamic_calls
    - avoid_print
    - avoid_unnecessary_containers
    - cancel_subscriptions
    - close_sinks
    - directives_ordering
    - no_leading_underscores_for_library_prefixes
    - no_leading_underscores_for_local_identifiers
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_locals
    - prefer_single_quotes
    - sort_child_properties_last
    - unawaited_futures
    - use_key_in_widget_constructors

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

### 4.3 İsimlendirme

| Tür | Kural | Örnek |
|---|---|---|
| Sınıf | PascalCase | `DeviceInfo` |
| Enum | PascalCase | `DeviceTier` |
| Değişken | camelCase | `batteryLevel` |
| Sabit | camelCase | `defaultSamplingInterval` |
| Dosya | snake_case | `device_info.dart` |
| Test dosyası | `*_test.dart` | `device_info_test.dart` |
| Metot | camelCase, fiil | `fetch()`, `getMarketName()` |
| Boolean | `is*` / `has*` | `isCharging`, `hasSuspiciousApps` |

---

## 5. Yeni Bir Modül Ekleme

Yeni bir modül (ör: `thermal`) ekleme adımları:

### Adım 1: Model Sınıfı

```dart
// lib/src/models/thermal_info.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'thermal_info.freezed.dart';
part 'thermal_info.g.dart';

@freezed
class ThermalInfo with _$ThermalInfo {
  const factory ThermalInfo({
    required String state,        // nominal, fair, serious, critical
    required double temperatureCelsius,
  }) = _ThermalInfo;

  factory ThermalInfo.fromJson(Map<String, dynamic> json) =>
      _$ThermalInfoFromJson(json);

  factory ThermalInfo.unknown() =>
      const ThermalInfo(state: 'unknown', temperatureCelsius: -1);
}
```

### Adım 2: Service Sınıfı

```dart
// lib/src/services/thermal_service.dart
class ThermalService {
  final PlatformBridge _bridge;

  ThermalService({PlatformBridge? bridge})
      : _bridge = bridge ?? PlatformBridge();

  Future<ThermalInfo> fetch() async {
    try {
      final result = await _bridge.invoke('thermal', 'getThermalInfo');
      return ThermalInfo.fromJson(result);
    } catch (e) {
      return ThermalInfo.unknown();
    }
  }
}
```

### Adım 3: iOS Provider

```swift
// ios/Classes/ThermalInfoProvider.swift
class ThermalInfoProvider: DeviceInspectorProvider {
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let state = ProcessInfo.processInfo.thermalState
        var info: [String: Any] = [:]
        info["state"] = state.description
        info["temperatureCelsius"] = -1.0 // iOS doğrudan sıcaklık vermez
        result(info)
    }
}
```

### Adım 4: Plugin Kaydı

```swift
// DeviceInspectorPlugin.swift — register() içine ekle:
let thermalChannel = FlutterMethodChannel(
    name: "com.bearcode.device_inspector/thermal",
    binaryMessenger: registrar.messenger()
)
let thermalProvider = ThermalInfoProvider()
thermalChannel.setMethodCallHandler(thermalProvider.handle)
```

### Adım 5: Public API

```dart
// lib/device_inspector.dart — DeviceInspector sınıfına ekle:
Future<ThermalInfo> get thermal => _thermalService.fetch();
```

### Adım 6: DeviceSnapshot Güncelleme

```dart
// lib/src/models/device_snapshot.dart — factory ekle:
required ThermalInfo thermal,
```

### Adım 7: Testler

```dart
// test/models/thermal_info_test.dart
// test/services/thermal_service_test.dart
```

### Adım 8: Dokümantasyon Güncelleme

- `API_SPEC.md` — Thermal API'yi ekle
- `DATA_MODELS.md` — ThermalInfo modelini ekle
- `PLATFORM_INTEGRATION.md` — iOS/Android implementasyonu ekle
- `CHANGELOG.md` — Yeni modül notunu ekle

---

## 6. Versiyon Yönetimi

### 6.1 Semantic Versioning

```
MAJOR.MINOR.PATCH

MAJOR: API-breaking change (ör: DeviceSnapshot yapısı değişti)
MINOR: Yeni özellik, geriye dönük uyumlu (ör: yeni modül eklendi)
PATCH: Hata düzeltmesi (ör: null safety düzeltmesi)
```

### 6.2 pubspec.yaml Yönetimi

```yaml
name: device_inspector
description: >-
  Flutter cihaz analiz SDK'sı. Cihaz, sistem, donanım,
  performans ve güvenlik bilgilerini tek API ile sunar.
version: 0.1.0
homepage: https://github.com/bearcodestudio/device_inspector
repository: https://github.com/bearcodestudio/device_inspector
issue_tracker: https://github.com/bearcodestudio/device_inspector/issues

environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  build_runner: ^2.4.0
  mockito: ^5.4.0
  integration_test:
    sdk: flutter
```

---

## 7. Example Uygulaması

### 7.1 Yapı

```
example/
├── lib/
│   └── main.dart
├── ios/
│   └── Podfile
├── android/
│   └── app/
│       └── build.gradle
└── pubspec.yaml
```

### 7.2 Minimal Örnek

**`example/lib/main.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:device_inspector/device_inspector.dart';

void main() {
  runApp(const DeviceInspectorExample());
}

class DeviceInspectorExample extends StatelessWidget {
  const DeviceInspectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Device Inspector Example')),
        body: const Center(
          child: DeviceInfoView(),
        ),
      ),
    );
  }
}

class DeviceInfoView extends StatefulWidget {
  const DeviceInfoView({super.key});

  @override
  State<DeviceInfoView> createState() => _DeviceInfoViewState();
}

class _DeviceInfoViewState extends State<DeviceInfoView> {
  DeviceSnapshot? _snapshot;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final snapshot = await DeviceInspector.inspect();
      setState(() => _snapshot = snapshot);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text('Error: $_error', style: const TextStyle(color: Colors.red));
    }
    if (_snapshot == null) {
      return const CircularProgressIndicator();
    }

    final s = _snapshot!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: 'Device', children: [
            _Row('Manufacturer', s.device.manufacturer),
            _Row('Model', s.device.model),
            _Row('Market Name', s.device.marketName),
            _Row('Tier', s.device.tier.name),
          ]),
          _Section(title: 'OS', children: [
            _Row('Platform', s.os.platform),
            _Row('Version', s.os.version),
          ]),
          _Section(title: 'Battery', children: [
            _Row('Level', '${s.battery.level}%'),
            _Row('Charging', s.battery.isCharging.toString()),
            _Row('Health', s.battery.health?.name ?? 'N/A'),
          ]),
          _Section(title: 'Network', children: [
            _Row('Type', s.network.type.name),
            _Row('VPN', s.network.isVpn.toString()),
            _Row('Carrier', s.network.carrier ?? 'N/A'),
          ]),
          _Section(title: 'Security', children: [
            _Row('Rooted', s.security.isRooted.toString()),
            _Row('Jailbroken', s.security.isJailbroken.toString()),
            _Row('Emulator', s.security.isEmulator.toString()),
            _Row('Debugger', s.security.isDebuggerAttached.toString()),
            _Row('Score', '${s.security.securityScore}/100'),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        )),
        const Divider(),
        ...children,
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
```

---

## 8. Sık Kullanılan Komutlar

```bash
# Bağımlılıkları yükle
flutter pub get

# Freezed/JSON kod üretimi
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs

# Test
flutter test                              # Tüm birim testleri
flutter test --reporter expanded          # Detaylı çıktı
flutter test test/models/                 # Sadece model testleri
flutter test --coverage                   # Coverage raporuyla

# Entegrasyon testleri
flutter test integration_test/

# Statik analiz
dart analyze

# Format
dart format .

# iOS pod güncelleme
cd ios && pod install && cd ..

# pub.dev yayınlama (dry run)
dart pub publish --dry-run

# pub.dev yayınlama
dart pub publish
```

---

## 9. CI/CD Yapılandırması

### 9.1 GitHub Actions

**.github/workflows/ci.yml** — her PR'da çalışır:
- `dart analyze`
- `dart format --check`
- `flutter test --coverage`

**.github/workflows/publish.yml** — tag push'ta çalışır:
- Testler + analiz
- `dart pub publish --force` (otomatik veya manuel onay)

### 9.2 pub.dev Yayınlama

```bash
# 1. Version güncelle
# pubspec.yaml: version: 0.2.0

# 2. CHANGELOG.md güncelle

# 3. Tag oluştur
git tag v0.2.0
git push origin v0.2.0

# 4. Yayınla
dart pub publish
```

---

## 10. Debugging

### 10.1 SDK Loglarını Etkinleştirme

```dart
DeviceInspector.initialize(
  logLevel: DeviceInspectorLogLevel.debug,
);
// Tüm native çağrılar ve dönüş değerleri debug console'da görünür
```

### 10.2 Platform Kanalı Debug

```bash
# iOS — Xcode console'da Flutter logları
flutter run -d iPhone --verbose

# Android — logcat
flutter run -d emulator-5554
adb logcat | grep flutter
```

### 10.3 Bellek ve Performans

```dart
final monitor = DeviceInspector.performance;
monitor.snapshotStream.listen((snap) {
  debugPrint('FPS: ${snap.fps} | CPU: ${snap.cpuUsagePercent}% | MEM: ${snap.memoryUsageMB}MB');
});
monitor.start();
```

---

## 11. Katkıda Bulunanlar İçin

### 11.1 Code of Conduct

Kapsayıcı ve saygılı bir ortam. Detaylar: `CODE_OF_CONDUCT.md`

### 11.2 İlk Katkı

```bash
# 1. "good first issue" etiketli bir issue seç
# 2. Fork yap
# 3. Branch oluştur
git checkout -b feature/my-first-contribution
# 4. Geliştir
# 5. Test et
flutter test
# 6. Commit ve PR aç
```

### 11.3 İletişim

- GitHub Issues: Bug raporları ve özellik istekleri
- GitHub Discussions: Soru-cevap ve fikir alışverişi
- Discord: [davet linki]
