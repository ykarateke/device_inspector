# Device Inspector — Veri Modelleri

## 1. Model Tasarım Prensipleri

Tüm model sınıfları aşağıdaki kurallara uyar:

| Prensip | Açıklama |
|---|---|
| **Immutable** | Tüm modeller Freezed ile `@freezed` olarak tanımlanır; tüm alanlar `final` |
| **JSON serileştirilebilir** | `@JsonSerializable` ile `toJson()` / `fromJson()` otomatik üretilir |
| **Tip güvenli** | Nullable alanlar açıkça belirtilir; primitive wrapper değil, Dart tipleri kullanılır |
| **copyWith desteği** | Freezed otomatik `copyWith()` üretir |
| **Equality** | Freezed otomatik `==` ve `hashCode` override üretir |
| **toString** | Freezed otomatik debug-friendly `toString()` üretir |
| **Fallback değerler** | Her modelde `.unknown()` veya `.empty()` named constructor — platform çağrısı başarısız olduğunda kullanılır |
| **Formatlı string alanlar** | İnsan tarafından okunabilir formatlı değerler için `formatted*` getter'lar (ör: `formattedTotal`, `formattedFree`) |

---

## 2. Kök Model: `DeviceSnapshot`

Tüm alt modelleri kapsayan kök veri sınıfıdır. `DeviceInspector.inspect()` metodu bu modeli döndürür.

```dart
@freezed
class DeviceSnapshot with _$DeviceSnapshot {
  const factory DeviceSnapshot({
    required DeviceInfo device,
    required OSInfo os,
    required BatteryInfo battery,
    required NetworkInfo network,
    required HardwareInfo hardware,
    required MemoryInfo memory,
    required StorageInfo storage,
    required SecurityInfo security,
    required AppInfo app,
    @Default(0) int timestampMsSinceEpoch,
  }) = _DeviceSnapshot;

  factory DeviceSnapshot.fromJson(Map<String, dynamic> json) =>
      _$DeviceSnapshotFromJson(json);

  /// Hiçbir bilgi alınamadığında kullanılan fallback
  factory DeviceSnapshot.empty() => DeviceSnapshot(
        device: DeviceInfo.unknown(),
        os: OSInfo.unknown(),
        battery: BatteryInfo.unknown(),
        network: NetworkInfo.unknown(),
        hardware: HardwareInfo.unknown(),
        memory: MemoryInfo.unknown(),
        storage: StorageInfo.unknown(),
        security: SecurityInfo.unknown(),
        app: AppInfo.unknown(),
      );
}
```

**Alanlar:**

| Alan | Tip | Nullable | Açıklama |
|---|---|---|---|
| `device` | `DeviceInfo` | ❌ | Cihaz donanım kimlik bilgileri |
| `os` | `OSInfo` | ❌ | İşletim sistemi detayları |
| `battery` | `BatteryInfo` | ❌ | Batarya durumu |
| `network` | `NetworkInfo` | ❌ | Ağ bağlantı bilgisi |
| `hardware` | `HardwareInfo` | ❌ | Donanım bileşenleri |
| `memory` | `MemoryInfo` | ❌ | RAM durumu |
| `storage` | `StorageInfo` | ❌ | Disk depolama |
| `security` | `SecurityInfo` | ❌ | Güvenlik kontrolleri |
| `app` | `AppInfo` | ❌ | Uygulama meta bilgisi |
| `timestampMsSinceEpoch` | `int` | ❌ | Snapshot'ın alındığı epoch zamanı (ms). Varsayılan: `0` |

---

## 3. `DeviceInfo` — Cihaz Bilgisi

```dart
@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    /// Üretici firma (Apple, Samsung, Google, ...)
    required String manufacturer,

    /// Dahili model kodu (iPhone15,3, SM-S928B, ...)
    required String model,

    /// Pazarlama ismi (iPhone 15 Pro, Galaxy S24 Ultra, ...)
    required String marketName,

    /// Benzersiz cihaz tanımlayıcısı (iOS: identifierForVendor, Android: ANDROID_ID)
    /// Gizlilik nedeniyle opsiyonel
    String? identifier,

    /// Cihaz kod adı / board ismi (opsiyonel)
    String? codename,

    /// Cihaz performans sınıfı
    @Default(DeviceTier.unknown) DeviceTier tier,

    /// İlk piyasaya çıkış yılı (opsiyonel)
    int? releaseYear,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);

  factory DeviceInfo.unknown() => const DeviceInfo(
        manufacturer: 'Unknown',
        model: 'Unknown',
        marketName: 'Unknown',
      );
}
```

**Alan detayları:**

| Alan | Tip | Platform | Native Kaynak |
|---|---|---|---|
| `manufacturer` | `String` | iOS/Android | iOS: `"Apple"` (sabit) / Android: `Build.MANUFACTURER` |
| `model` | `String` | iOS/Android | iOS: `sysctl hw.machine` / Android: `Build.MODEL` |
| `marketName` | `String` | iOS/Android | iOS: internal mapping table / Android: `Build.MODEL` + mapping |
| `identifier` | `String?` | iOS/Android | iOS: `UIDevice.identifierForVendor` / Android: `Settings.Secure.ANDROID_ID` |
| `codename` | `String?` | Android | `Build.DEVICE` / `Build.PRODUCT` |
| `tier` | `DeviceTier` | iOS/Android | CPU cores + RAM + release year tablosundan hesaplanır |
| `releaseYear` | `int?` | iOS/Android | Dahili mapping tablosu |

---

## 4. `OSInfo` — İşletim Sistemi Bilgisi

```dart
@freezed
class OSInfo with _$OSInfo {
  const factory OSInfo({
    /// Platform adı: "iOS" veya "Android"
    required String platform,

    /// OS sürümü (17.4, 14.0, ...)
    required String version,

    /// Major sürüm numarası
    required int majorVersion,

    /// Minor sürüm numarası
    required int minorVersion,

    /// Patch sürüm numarası (varsa)
    @Default(0) int patchVersion,

    /// Build numarası (iOS: 21E236, Android: AP1A.240305.019.A1)
    String? buildNumber,

    /// API seviyesi (sadece Android)
    int? apiLevel,

    /// Kernel versiyonu (opsiyonel)
    String? kernelVersion,
  }) = _OSInfo;

  factory OSInfo.fromJson(Map<String, dynamic> json) =>
      _$OSInfoFromJson(json);

  factory OSInfo.unknown() => const OSInfo(
        platform: 'Unknown',
        version: '0.0',
        majorVersion: 0,
        minorVersion: 0,
      );
}
```

**Native kaynaklar:**
- iOS: `UIDevice.current.systemVersion` + `sysctl kern.osversion`
- Android: `Build.VERSION.RELEASE` + `Build.VERSION.SDK_INT` + `Build.DISPLAY`

---

## 5. `BatteryInfo` — Batarya Durumu

```dart
@freezed
class BatteryInfo with _$BatteryInfo {
  const factory BatteryInfo({
    /// Batarya seviyesi (0–100). -1 = bilinmiyor.
    required int level,

    /// Şarj durumu
    required BatteryChargingState chargingState,

    /// Şarjda mı (chargingState'ten türetilmiş kolay erişim)
    required bool isCharging,

    /// Batarya sağlık durumu (sadece iOS)
    BatteryHealth? health,

    /// Maksimum kapasite yüzdesi (tasarım kapasitesine göre). Sadece iOS.
    int? maxCapacityPercent,

    /// Tahmini kalan süre (dakika). -1 = bilinmiyor.
    @Default(-1) int estimatedMinutesRemaining,

    /// Düşük güç modu aktif mi?
    @Default(false) bool isLowPowerMode,
  }) = _BatteryInfo;

  factory BatteryInfo.fromJson(Map<String, dynamic> json) =>
      _$BatteryInfoFromJson(json);

  factory BatteryInfo.unknown() => const BatteryInfo(
        level: -1,
        chargingState: BatteryChargingState.unknown,
        isCharging: false,
      );
}
```

**Native kaynaklar:**
- iOS: `UIDevice.current.batteryLevel` + `UIDevice.current.batteryState` + IOKit (health)
- Android: `BatteryManager` intent + `BatteryManager.EXTRA_*` properties

---

## 6. `NetworkInfo` — Ağ Bilgisi

```dart
@freezed
class NetworkInfo with _$NetworkInfo {
  const factory NetworkInfo({
    /// Ağ bağlantı tipi
    required NetworkType type,

    /// Hücresel operatör adı (Turkcell, Vodafone, ...)
    String? carrier,

    /// Hücresel ağ jenerasyonu (3G, 4G, 5G)
    String? cellularGeneration,

    /// VPN bağlantısı aktif mi?
    @Default(false) bool isVpn,

    /// Proxy kullanılıyor mu?
    @Default(false) bool isProxy,

    /// Airplane mode aktif mi?
    @Default(false) bool isAirplaneMode,

    /// Wi-Fi SSID (opsiyonel, izin gerektirir)
    String? wifiSsid,

    /// Sinyal gücü seviyesi (0–5). -1 = bilinmiyor.
    @Default(-1) int signalStrength,

    /// Cihazın yerel IP adresi
    String? localIpAddress,
  }) = _NetworkInfo;

  factory NetworkInfo.fromJson(Map<String, dynamic> json) =>
      _$NetworkInfoFromJson(json);

  factory NetworkInfo.unknown() => const NetworkInfo(
        type: NetworkType.unknown,
      );
}
```

**Native kaynaklar:**
- iOS: `NWPathMonitor` (Network framework) + `CTCarrier`
- Android: `ConnectivityManager` + `TelephonyManager` + `WifiManager`

---

## 7. `HardwareInfo` — Donanım Bileşenleri (Phase 2)

```dart
@freezed
class HardwareInfo with _$HardwareInfo {
  const factory HardwareInfo({
    /// CPU bilgisi
    required CPUInfo cpu,

    /// GPU bilgisi
    required GPUInfo gpu,

    /// Ekran bilgisi
    required DisplayInfo display,

    /// Cihaz performans sınıfı (CPU ve GPU'dan türetilir)
    @Default(DeviceTier.unknown) DeviceTier tier,
  }) = _HardwareInfo;

  factory HardwareInfo.fromJson(Map<String, dynamic> json) =>
      _$HardwareInfoFromJson(json);

  factory HardwareInfo.unknown() => const HardwareInfo(
        cpu: CPUInfo.unknown(),
        gpu: GPUInfo.unknown(),
        display: DisplayInfo.unknown(),
      );
}
```

### 7.1 `CPUInfo`

```dart
@freezed
class CPUInfo with _$CPUInfo {
  const factory CPUInfo({
    /// İşlemci markası/modeli (A17 Pro, Snapdragon 8 Gen 3, ...)
    required String name,

    /// Çekirdek sayısı
    required int cores,

    /// Mimari: arm64, armv7, x86_64
    required String architecture,

    /// Maksimum saat hızı (MHz). 0 = bilinmiyor.
    @Default(0) int maxFrequencyMHz,

    /// Performans çekirdek sayısı (big.LITTLE için)
    int? performanceCores,

    /// Verimlilik çekirdek sayısı (big.LITTLE için)
    int? efficiencyCores,

    /// Apple Neural Engine / AI hızlandırıcı var mı?
    @Default(false) bool hasNeuralEngine,
  }) = _CPUInfo;

  factory CPUInfo.fromJson(Map<String, dynamic> json) =>
      _$CPUInfoFromJson(json);

  factory CPUInfo.unknown() => const CPUInfo(
        name: 'Unknown',
        cores: 0,
        architecture: 'unknown',
      );
}
```

### 7.2 `GPUInfo`

```dart
@freezed
class GPUInfo with _$GPUInfo {
  const factory GPUInfo({
    /// GPU adı (Apple A17 Pro GPU, Adreno 750, ...)
    required String name,

    /// Metal API desteği (iOS)
    @Default(false) bool supportsMetal,

    /// Metal feature set (iOS, opsiyonel)
    String? metalFeatureSet,

    /// Vulkan API desteği (Android)
    @Default(false) bool supportsVulkan,

    /// Vulkan versiyonu
    String? vulkanVersion,

    /// OpenGL ES versiyonu
    String? openGLESVersion,
  }) = _GPUInfo;

  factory GPUInfo.fromJson(Map<String, dynamic> json) =>
      _$GPUInfoFromJson(json);

  factory GPUInfo.unknown() => const GPUInfo(
        name: 'Unknown',
      );
}
```

### 7.3 `DisplayInfo`

```dart
@freezed
class DisplayInfo with _$DisplayInfo {
  const factory DisplayInfo({
    /// Piksel genişliği
    required int widthPixels,

    /// Piksel yüksekliği
    required int heightPixels,

    /// DPI yoğunluğu
    required double density,

    /// Yenileme hızı (Hz). 0 = bilinmiyor.
    @Default(0) int refreshRate,

    /// HDR desteği var mı?
    @Default(false) bool supportsHdr,

    /// Ekran parlaklık seviyesi (0.0 – 1.0). -1 = bilinmiyor.
    @Default(-1.0) double brightnessLevel,
  }) = _DisplayInfo;

  factory DisplayInfo.fromJson(Map<String, dynamic> json) =>
      _$DisplayInfoFromJson(json);

  factory DisplayInfo.unknown() => const DisplayInfo(
        widthPixels: 0,
        heightPixels: 0,
        density: 0,
      );
}
```

---

## 8. `MemoryInfo` — RAM Bilgisi (Phase 2)

```dart
@freezed
class MemoryInfo with _$MemoryInfo {
  const factory MemoryInfo({
    /// Toplam RAM (byte)
    required int totalBytes,

    /// Kullanılabilir RAM (byte). -1 = bilinmiyor.
    required int availableBytes,

    /// Kullanılan RAM yüzdesi (0–100). -1 = bilinmiyor.
    required double usagePercent,

    /// Uygulamanın kullandığı RAM (byte). -1 = bilinmiyor.
    @Default(-1) int appUsedBytes,

    /// Düşük bellek uyarısı aktif mi? (iOS: didReceiveMemoryWarning)
    @Default(false) bool isLowMemory,
  }) = _MemoryInfo;

  factory MemoryInfo.fromJson(Map<String, dynamic> json) =>
      _$MemoryInfoFromJson(json);

  factory MemoryInfo.unknown() => const MemoryInfo(
        totalBytes: -1,
        availableBytes: -1,
        usagePercent: -1,
      );

  /// Formatlı toplam RAM (örn: "8.0 GB")
  String get formattedTotal => _formatBytes(totalBytes);

  /// Formatlı kullanılabilir RAM (örn: "3.2 GB")
  String get formattedAvailable => _formatBytes(availableBytes);
}
```

---

## 9. `StorageInfo` — Depolama Bilgisi (Phase 2)

```dart
@freezed
class StorageInfo with _$StorageInfo {
  const factory StorageInfo({
    /// Toplam depolama (byte)
    required int totalBytes,

    /// Boş depolama (byte)
    required int freeBytes,

    /// Kullanılan depolama yüzdesi (0–100)
    required double usagePercent,

    /// Uygulamanın kullandığı alan (byte). -1 = bilinmiyor.
    @Default(-1) int appUsedBytes,

    /// Uygulama veri dizini yolu (opsiyonel)
    String? appDataPath,

    /// Uygulama cache dizini yolu (opsiyonel)
    String? appCachePath,
  }) = _StorageInfo;

  factory StorageInfo.fromJson(Map<String, dynamic> json) =>
      _$StorageInfoFromJson(json);

  factory StorageInfo.unknown() => const StorageInfo(
        totalBytes: -1,
        freeBytes: -1,
        usagePercent: -1,
      );

  /// Formatlı toplam depolama (örn: "256 GB")
  String get formattedTotal => _formatBytes(totalBytes);

  /// Formatlı boş depolama (örn: "120 GB")
  String get formattedFree => _formatBytes(freeBytes);
}
```

---

## 10. `SecurityInfo` — Güvenlik Kontrolleri (Phase 3)

```dart
@freezed
class SecurityInfo with _$SecurityInfo {
  const factory SecurityInfo({
    /// Root erişimi tespit edildi mi? (Android)
    @Default(false) bool isRooted,

    /// Jailbreak tespit edildi mi? (iOS)
    @Default(false) bool isJailbroken,

    /// Emulator/simulator üzerinde mi çalışıyor?
    @Default(false) bool isEmulator,

    /// Debugger bağlı mı?
    @Default(false) bool isDebuggerAttached,

    /// Developer mode aktif mi?
    @Default(false) bool isDeveloperMode,

    /// Şüpheli uygulamalar tespit edildi mi? (Cydia, Magisk, ...)
    @Default(false) bool hasSuspiciousApps,

    /// Şüpheli dosya yolları tespit edildi mi?
    @Default(false) bool hasSuspiciousPaths,

    /// Şüpheli ortam değişkenleri var mı?
    @Default(false) bool hasSuspiciousEnvVars,

    /// Sistem kütüphanelerinde değişiklik var mı?
    @Default(false) bool hasModifiedLibraries,

    /// Tespit edilen tehdit listesi (detaylı)
    @Default([]) List<String> detectedThreats,

    /// Güvenlik skoru (0–100). 100 = en güvenli.
    @Default(100) int securityScore,
  }) = _SecurityInfo;

  factory SecurityInfo.fromJson(Map<String, dynamic> json) =>
      _$SecurityInfoFromJson(json);

  factory SecurityInfo.unknown() => const SecurityInfo();

  /// Herhangi bir tehdit var mı?
  bool get isCompromised =>
      isRooted ||
      isJailbroken ||
      isEmulator ||
      hasSuspiciousApps ||
      hasSuspiciousPaths ||
      hasSuspiciousEnvVars ||
      hasModifiedLibraries;
}
```

---

## 11. `AppInfo` — Uygulama Bilgisi

```dart
@freezed
class AppInfo with _$AppInfo {
  const factory AppInfo({
    /// Uygulama adı
    required String appName,

    /// Sürüm (1.2.3)
    required String version,

    /// Build numarası (42)
    required String buildNumber,

    /// Bundle / Package ID (com.example.app)
    required String bundleId,

    /// Kurulum tarihi epoch ms (opsiyonel)
    int? installTimestampMs,

    /// İlk başlatma tarihi epoch ms (opsiyonel)
    int? firstLaunchTimestampMs,

    /// Uygulama imza bilgisi hash (opsiyonel, Android)
    String? signatureHash,

    /// Debug build mi?
    @Default(false) bool isDebugBuild,
  }) = _AppInfo;

  factory AppInfo.fromJson(Map<String, dynamic> json) =>
      _$AppInfoFromJson(json);

  factory AppInfo.unknown() => const AppInfo(
        appName: 'Unknown',
        version: '0.0.0',
        buildNumber: '0',
        bundleId: 'unknown',
      );
}
```

---

## 12. `PerformanceSnapshot` — Performans Anlık Görüntüsü (Phase 4)

```dart
@freezed
class PerformanceSnapshot with _$PerformanceSnapshot {
  const factory PerformanceSnapshot({
    /// Kare hızı (FPS)
    required double fps,

    /// Toplam CPU kullanımı yüzdesi (0–100)
    required double cpuUsagePercent,

    /// Uygulama CPU kullanımı yüzdesi (0–100)
    required double appCpuUsagePercent,

    /// Uygulama bellek kullanımı (MB)
    required double memoryUsageMB,

    /// Toplam bellek kullanımı yüzdesi (0–100)
    required double memoryUsagePercent,

    /// Termal durum (iOS: NSProcessInfoThermalState)
    @Default('nominal') String thermalState,

    /// Epoch timestamp (ms)
    required int timestampMsSinceEpoch,

    /// Pil tüketim seviyesi (iOS: 1=low, ..., 5=high)
    @Default(-1) int batteryImpactLevel,
  }) = _PerformanceSnapshot;

  factory PerformanceSnapshot.fromJson(Map<String, dynamic> json) =>
      _$PerformanceSnapshotFromJson(json);

  factory PerformanceSnapshot.empty() => PerformanceSnapshot(
        fps: 0,
        cpuUsagePercent: 0,
        appCpuUsagePercent: 0,
        memoryUsageMB: 0,
        memoryUsagePercent: 0,
        timestampMsSinceEpoch: 0,
      );
}
```

---

## 13. Freezed & JSON Yapılandırması

### 13.1 `build.yaml`

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          any_map: false
          checked: true
          create_to_json: true
          disallow_unrecognized_keys: false
          explicit_to_json: true
      freezed:
        options:
          union_key: type
          union_value_case: pascal
```

### 13.2 Örnek Model Dosyası (`battery_info.dart`)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'battery_info.freezed.dart';
part 'battery_info.g.dart';

@freezed
class BatteryInfo with _$BatteryInfo {
  const factory BatteryInfo({
    required int level,
    required BatteryChargingState chargingState,
    required bool isCharging,
    BatteryHealth? health,
    int? maxCapacityPercent,
    @Default(-1) int estimatedMinutesRemaining,
    @Default(false) bool isLowPowerMode,
  }) = _BatteryInfo;

  factory BatteryInfo.fromJson(Map<String, dynamic> json) =>
      _$BatteryInfoFromJson(json);

  factory BatteryInfo.unknown() => const BatteryInfo(
        level: -1,
        chargingState: BatteryChargingState.unknown,
        isCharging: false,
      );
}
```

### 13.3 Kod Üretimi

```bash
# Tek seferlik
dart run build_runner build --delete-conflicting-outputs

# Watch modu (geliştirme sırasında)
dart run build_runner watch --delete-conflicting-outputs
```

---

## 14. Model İlişkileri

```
DeviceSnapshot (kök)
├── DeviceInfo
│   ├── manufacturer: String
│   ├── model: String
│   ├── marketName: String
│   ├── identifier: String?
│   ├── codename: String?
│   ├── tier: DeviceTier
│   └── releaseYear: int?
├── OSInfo
│   ├── platform: String
│   ├── version: String
│   ├── majorVersion: int
│   ├── minorVersion: int
│   ├── patchVersion: int
│   ├── buildNumber: String?
│   ├── apiLevel: int?
│   └── kernelVersion: String?
├── BatteryInfo
│   ├── level: int
│   ├── chargingState: BatteryChargingState
│   ├── isCharging: bool
│   ├── health: BatteryHealth?
│   ├── maxCapacityPercent: int?
│   ├── estimatedMinutesRemaining: int
│   └── isLowPowerMode: bool
├── NetworkInfo
│   ├── type: NetworkType
│   ├── carrier: String?
│   ├── cellularGeneration: String?
│   ├── isVpn: bool
│   ├── isProxy: bool
│   ├── isAirplaneMode: bool
│   ├── wifiSsid: String?
│   ├── signalStrength: int
│   └── localIpAddress: String?
├── HardwareInfo
│   ├── cpu: CPUInfo
│   │   ├── name: String
│   │   ├── cores: int
│   │   ├── architecture: String
│   │   ├── maxFrequencyMHz: int
│   │   ├── performanceCores: int?
│   │   ├── efficiencyCores: int?
│   │   └── hasNeuralEngine: bool
│   ├── gpu: GPUInfo
│   │   ├── name: String
│   │   ├── supportsMetal: bool
│   │   ├── metalFeatureSet: String?
│   │   ├── supportsVulkan: bool
│   │   ├── vulkanVersion: String?
│   │   └── openGLESVersion: String?
│   ├── display: DisplayInfo
│   │   ├── widthPixels: int
│   │   ├── heightPixels: int
│   │   ├── density: double
│   │   ├── refreshRate: int
│   │   ├── supportsHdr: bool
│   │   └── brightnessLevel: double
│   └── tier: DeviceTier
├── MemoryInfo
│   ├── totalBytes: int
│   ├── availableBytes: int
│   ├── usagePercent: double
│   ├── appUsedBytes: int
│   └── isLowMemory: bool
├── StorageInfo
│   ├── totalBytes: int
│   ├── freeBytes: int
│   ├── usagePercent: double
│   ├── appUsedBytes: int
│   ├── appDataPath: String?
│   └── appCachePath: String?
├── SecurityInfo
│   ├── isRooted: bool
│   ├── isJailbroken: bool
│   ├── isEmulator: bool
│   ├── isDebuggerAttached: bool
│   ├── isDeveloperMode: bool
│   ├── hasSuspiciousApps: bool
│   ├── hasSuspiciousPaths: bool
│   ├── hasSuspiciousEnvVars: bool
│   ├── hasModifiedLibraries: bool
│   ├── detectedThreats: List<String>
│   └── securityScore: int
├── AppInfo
│   ├── appName: String
│   ├── version: String
│   ├── buildNumber: String
│   ├── bundleId: String
│   ├── installTimestampMs: int?
│   ├── firstLaunchTimestampMs: int?
│   ├── signatureHash: String?
│   └── isDebugBuild: bool
└── timestampMsSinceEpoch: int
```
