# Device Inspector — Sistem Mimarisi

## 1. Genel Bakış

`device_inspector`, Flutter uygulamalarından cihaz, sistem, donanım, performans ve güvenlik bilgilerini tek bir API üzerinden sunan, katmanlı bir mimariye sahip platform-köprülü SDK'dır.

### Temel Tasarım Prensipleri

| İlke | Açıklama |
|---|---|
| **Tek API noktası** | `DeviceInspector.inspect()` ile tüm cihaz bağlamı tek çağrıda alınır |
| **Platform soyutlama** | Platforma özel kod Method Channel üzerinden soyutlanır |
| **Immutable modeller** | Tüm veri sınıfları Freezed ile immutable üretilir |
| **Modüler erişim** | İhtiyaca göre `DeviceInspector.device`, `.battery` gibi alt modüller kullanılabilir |
| **Offline-first** | Hiçbir veri sunucuya gönderilmez; tüm bilgiler yerel olarak toplanır |
| **Lazy initialization** | Ağır modüller (performans, güvenlik) isteğe bağlı başlatılır |

---

## 2. Katmanlı Mimari

```
┌─────────────────────────────────────────────────────────────┐
│                    PUBLIC API LAYER                          │
│  DeviceInspector.inspect()  ·  .device  ·  .battery  ·  …   │
├─────────────────────────────────────────────────────────────┤
│                    SERVICE LAYER                             │
│  DeviceService · BatteryService · NetworkService ·           │
│  MemoryService · StorageService · SecurityService ·          │
│  PerformanceService                                          │
├─────────────────────────────────────────────────────────────┤
│                    CORE LAYER                                │
│  DeviceInspectorCore · PlatformBridge ·                      │
│  Configuration · ErrorHandler · Logger                       │
├─────────────────────────────────────────────────────────────┤
│                    MODEL LAYER                               │
│  DeviceInfo · OSInfo · BatteryInfo · NetworkInfo ·           │
│  HardwareInfo · MemoryInfo · StorageInfo · SecurityInfo ·    │
│  AppInfo · PerformanceSnapshot · DeviceSnapshot              │
├─────────────────────────────────────────────────────────────┤
│                    PLATFORM BRIDGE                           │
│  ┌─────────────────────┐  ┌─────────────────────┐           │
│  │   iOS (Swift)       │  │  Android (Kotlin)   │           │
│  │                     │  │                     │           │
│  │ DeviceInspector     │  │ DeviceInspector     │           │
│  │ Plugin.swift        │  │ Plugin.kt           │           │
│  │ ├─ DeviceInfo       │  │ ├─ DeviceInfo       │           │
│  │ ├─ BatteryInfo      │  │ ├─ BatteryInfo      │           │
│  │ ├─ NetworkInfo      │  │ ├─ NetworkInfo      │           │
│  │ ├─ SecurityCheck    │  │ ├─ SecurityCheck    │           │
│  │ └─ Performance      │  │ └─ Performance      │           │
│  └─────────────────────┘  └─────────────────────┘           │
├─────────────────────────────────────────────────────────────┤
│                    NATIVE HARDWARE APIs                      │
│  UIDevice · IOKit · sysctl  |  Build · ActivityManager ·    │
│  BatteryManager · WifiManager · StorageManager ·            │
│  Debug · Runtime · /proc · /sys                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Katman Detayları

### 3.1 Public API Layer

Kullanıcıya sunulan en üst katmandır. `DeviceInspector` sınıfı tek giriş noktasıdır.

```
DeviceInspector (Singleton)
├── initialize(DeviceInspectorConfig config)
├── inspect() → Future<DeviceSnapshot>
├── device → Future<DeviceInfo>
├── os → Future<OSInfo>
├── battery → Future<BatteryInfo>
├── network → Future<NetworkInfo>
├── hardware → Future<HardwareInfo>
├── memory → Future<MemoryInfo>
├── storage → Future<StorageInfo>
├── security → Future<SecurityInfo>
├── app → Future<AppInfo>
├── performance → PerformanceMonitor
└── dispose()
```

### 3.2 Service Layer

Her domain için bir service sınıfı sorumludur. Service'ler `PlatformBridge` üzerinden platform çağrılarını yapar, sonuçları model sınıflarına dönüştürür.

```dart
// Service arayüzü
abstract class DeviceServiceBase<T> {
  Future<T> fetch();
  T fromMap(Map<String, dynamic> map);
}
```

**Service listesi:**

| Service | Sorumluluk | Platform çağrısı sayısı |
|---|---|---|
| `DeviceService` | Cihaz üretici, model, isim | 1 |
| `OSService` | İşletim sistemi bilgileri | 1 |
| `BatteryService` | Batarya seviyesi, şarj durumu | 1 |
| `NetworkService` | Ağ tipi, operatör, VPN | 2 |
| `HardwareService` | CPU, GPU, RAM toplamı | 3 |
| `MemoryService` | RAM kullanımı | 1 |
| `StorageService` | Depolama toplam/boş | 1 |
| `SecurityService` | Root/Jailbreak/Emulator/Debug | 4 |
| `AppService` | Uygulama versiyon, bundle ID | 1 (Dart tarafı) |
| `PerformanceService` | FPS, CPU %, Memory % | Sürekli stream |

### 3.3 Core Layer

Çekirdek altyapı bileşenleri:

```
core/
├── device_inspector_core.dart   # Ana koordinatör
├── platform_bridge.dart         # Method Channel soyutlama
├── configuration.dart           # Yapılandırma yönetimi
├── error_handler.dart           # Hata yakalama / fallback
├── logger.dart                  # Debug loglama (opsiyonel)
└── constants.dart               # Channel isimleri, key sabitleri
```

**PlatformBridge:**

```dart
class PlatformBridge {
  static const MethodChannel _channel =
      MethodChannel('com.bearcode.device_inspector');

  Future<Map<String, dynamic>> invoke(String method, [Map? args]) async {
    final result = await _channel.invokeMethod(method, args);
    return Map<String, dynamic>.from(result);
  }
}
```

### 3.4 Model Layer

Tüm modeller immutable'dır. Freezed + JsonSerializable ile üretilir.

```
models/
├── device_info.dart
├── os_info.dart
├── battery_info.dart
├── network_info.dart
├── hardware_info.dart
├── memory_info.dart
├── storage_info.dart
├── security_info.dart
├── app_info.dart
├── performance_snapshot.dart
└── device_snapshot.dart          # Tüm modelleri kapsayan kök model
```

### 3.5 Platform Bridge Layer

Flutter ile native kod arasındaki iletişim `MethodChannel` ile sağlanır:

```
Flutter (Dart)                     Native (Swift/Kotlin)
     │                                      │
     │  MethodChannel.invokeMethod()        │
     │ ──────────────────────────────────>  │
     │                                      │── Native API çağrıları
     │                                      │── Sonuç map'e dönüştürülür
     │  Map<String, dynamic> döner          │
     │ <──────────────────────────────────  │
     │                                      │
     ▼                                      ▼
  Model sınıfına parse edilir           Sonraki çağrıya hazır
```

**Channel isimlendirme kuralı:** `com.bearcode.device_inspector/{modül}`

Örnek kanallar:
- `com.bearcode.device_inspector/device` → DeviceInfo
- `com.bearcode.device_inspector/battery` → BatteryInfo
- `com.bearcode.device_inspector/security` → SecurityInfo

---

## 4. Veri Akışı

### 4.1 Full Inspection (`DeviceInspector.inspect()`)

```
Kullanıcı
  │
  ▼
DeviceInspector.inspect()
  │
  ├─► DeviceService.fetch()     ──► PlatformBridge ──► iOS/Android ──► DeviceInfo
  ├─► OSService.fetch()         ──► PlatformBridge ──► iOS/Android ──► OSInfo
  ├─► BatteryService.fetch()    ──► PlatformBridge ──► iOS/Android ──► BatteryInfo
  ├─► NetworkService.fetch()    ──► PlatformBridge ──► iOS/Android ──► NetworkInfo
  ├─► HardwareService.fetch()   ──► PlatformBridge ──► iOS/Android ──► HardwareInfo
  ├─► MemoryService.fetch()     ──► PlatformBridge ──► iOS/Android ──► MemoryInfo
  ├─► StorageService.fetch()    ──► PlatformBridge ──► iOS/Android ──► StorageInfo
  ├─► SecurityService.fetch()   ──► PlatformBridge ──► iOS/Android ──► SecurityInfo
  ├─► AppService.fetch()        ──► (Dart PackageInfo) ───────────────► AppInfo
  │
  ▼
DeviceSnapshot.fromParts(...)  // Tüm modeller birleştirilir
  │
  ▼
Kullanıcıya döner
```

**Paralelleştirme:** `inspect()` içinde birbirinden bağımsız servisler `Future.wait()` ile paralel çağrılır:

```dart
final results = await Future.wait([
  deviceService.fetch(),
  osService.fetch(),
  batteryService.fetch(),
  networkService.fetch(),
  hardwareService.fetch(),
  memoryService.fetch(),
  storageService.fetch(),
  securityService.fetch(),
  appService.fetch(),
]);
```

### 4.2 Modüler Erişim (`DeviceInspector.device`)

```
Kullanıcı
  │
  ▼
DeviceInspector.device
  │
  ▼
DeviceService.fetch()
  │
  ▼
PlatformBridge.invoke('getDeviceInfo')
  │
  ▼
iOS: UIDevice.current → model, systemVersion, ...
Android: Build.MANUFACTURER, Build.MODEL, ...
  │
  ▼
DeviceInfo.fromMap(result)
```

### 4.3 Performance Monitor (Stream)

```
PerformanceMonitor.start()
  │
  ▼
Timer.periodic(Duration(seconds: 1))
  │
  ▼
PlatformBridge.invoke('getPerformanceSnapshot')
  │
  ▼
iOS: CADisplayLink (FPS) + host_statistics (CPU) + task_info (Memory)
Android: Choreographer (FPS) + /proc/stat (CPU) + ActivityManager (Memory)
  │
  ▼
StreamController<PerformanceSnapshot>.add(snapshot)
  │
  ▼
Kullanıcı stream'i dinler
```

---

## 5. Hata Yönetimi

### 5.1 Hata Tipleri

```dart
sealed class DeviceInspectorException implements Exception {
  final String message;
  final String? code;
}

class PlatformNotSupportedException extends DeviceInspectorException {
  // Web/Desktop desteği yoksa
}

class PermissionDeniedException extends DeviceInspectorException {
  // Kullanıcı izin vermediyse (ör: batarya optimizasyonu)
}

class HardwareAccessException extends DeviceInspectorException {
  // Donanım bilgisine erişilemediyse
}

class SecurityCheckException extends DeviceInspectorException {
  // Güvenlik kontrolü sırasında hata
}

class ConfigurationException extends DeviceInspectorException {
  // initialize() çağrılmadan kullanım
}
```

### 5.2 Fallback Stratejisi

Her service, platform çağrısı başarısız olduğunda `null` veya varsayılan değer dönecek şekilde tasarlanır:

```dart
Future<BatteryInfo> fetch() async {
  try {
    final result = await bridge.invoke('getBatteryInfo');
    return BatteryInfo.fromMap(result);
  } catch (e) {
    logger.warn('Battery info unavailable: $e');
    return BatteryInfo.unknown(); // Fallback
  }
}
```

---

## 6. Bağımlılık Grafiği

```
device_inspector
├── freezed_annotation     # Immutable model üretimi
├── json_annotation        # JSON serileştirme
├── flutter                # Framework
│   └── services           # MethodChannel, vs.
├── dev_dependencies:
│   ├── freezed            # Kod üretimi
│   ├── json_serializable  # Kod üretimi
│   ├── build_runner       # Kod üretim koordinatörü
│   ├── flutter_test       # Test framework
│   └── mockito            # Mock oluşturma
└── (opsiyonel)
    └── package_info_plus  # AppInfo için (Dart tarafı)
```

**Dış bağımlılık politikası:**
- Minimum bağımlılık — mümkün olan her yerde doğrudan platform API kullanılır
- `package_info_plus` sadece AppInfo modülünde kullanılır; alternatif olarak manuel `PackageInfo.fromPlatform()` da yazılabilir
- `device_info_plus` gibi üçüncü parti paketlere bağımlılık kurulmaz — tüm bilgiler doğrudan native API'lerden toplanır

---

## 7. Paket Yapısı

```
device_inspector/
├── lib/
│   ├── device_inspector.dart              # Public API barrel export
│   └── src/
│       ├── core/
│       │   ├── device_inspector_core.dart  # Ana koordinatör singleton
│       │   ├── platform_bridge.dart        # MethodChannel soyutlama
│       │   ├── configuration.dart          # DeviceInspectorConfig
│       │   ├── error_handler.dart          # Exception sınıfları
│       │   ├── logger.dart                 # Opsiyonel loglama
│       │   └── constants.dart              # Sabitler
│       ├── models/
│       │   ├── device_snapshot.dart        # Kök model
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
│       ├── services/
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
│       └── platform/
│           └── platform_bridge_impl.dart   # Platforma özel bridge detayları
├── ios/
│   └── Classes/
│       ├── DeviceInspectorPlugin.swift     # Ana plugin sınıfı
│       ├── DeviceInfoProvider.swift        # Cihaz bilgisi
│       ├── BatteryInfoProvider.swift       # Batarya
│       ├── NetworkInfoProvider.swift       # Ağ
│       ├── HardwareInfoProvider.swift      # Donanım
│       ├── SecurityCheckProvider.swift     # Jailbreak/security
│       └── PerformanceMonitorProvider.swift # Performans
├── android/
│   └── src/main/kotlin/com/bearcode/device_inspector/
│       ├── DeviceInspectorPlugin.kt        # Ana plugin sınıfı
│       ├── DeviceInfoProvider.kt           # Cihaz bilgisi
│       ├── BatteryInfoProvider.kt          # Batarya
│       ├── NetworkInfoProvider.kt          # Ağ
│       ├── HardwareInfoProvider.kt         # Donanım
│       ├── SecurityCheckProvider.kt        # Root/security
│       └── PerformanceMonitorProvider.kt   # Performans
├── test/
│   ├── core/
│   ├── models/
│   ├── services/
│   └── platform/
├── docs/
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   ├── API_SPEC.md
│   ├── DATA_MODELS.md
│   ├── PLATFORM_INTEGRATION.md
│   ├── SECURITY_PRIVACY.md
│   ├── TESTING.md
│   ├── DEVELOPMENT.md
│   └── CHANGELOG.md
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## 8. Fazlar ve Mimari Gelişimi

### Phase 1 — MVP (v0.1.0)
- Public API katmanı (sadece `inspect()`, `device`, `os`, `battery`, `network`, `app`)
- Temel service'ler
- iOS/Android platform bridge (Swift/Kotlin)
- Temel model sınıfları

### Phase 2 — Hardware Intelligence (v0.2.0)
- `hardware`, `memory`, `storage` servisleri
- Donanım model sınıfları (CPUInfo, GPUInfo, RAMInfo)
- Platform provider'ların genişletilmesi

### Phase 3 — Security Module (v0.3.0)
- `SecurityService` + `SecurityInfo` modeli
- iOS: Jailbreak, Cydia, suspicious paths, debugger detection
- Android: Root, Magisk, emulator detection
- `SecurityCheckProvider` sınıfları

### Phase 4 — Performance Monitor (v1.0.0)
- `PerformanceService` stream tabanlı
- FPS, CPU, Memory, Thermal monitoring
- `PerformanceSnapshot` modeli
- iOS: CADisplayLink + host_statistics
- Android: Choreographer + /proc/stat + ActivityManager

### v2.0+ — Cloud (gelecek)
- `device_inspector_cloud` paketi (ayrı paket)
- Cihaz raporlarının opsiyonel buluta gönderilmesi
- Dashboard ve analytics

---

## 9. Tasarım Kararları

| Karar | Gerekçe |
|---|---|
| **Freezed kullanımı** | Immutable modeller, copyWith, == operatörü, JSON serileştirme tek araçla |
| **MethodChannel (EventChannel değil)** | Basit istek-cevap modeli yeterli; stream sadece Performance modülünde |
| **Her bilgi için ayrı service** | Single Responsibility; test edilebilirlik; isteğe bağlı yükleme |
| **Singleton DeviceInspector** | Tek bir başlatma noktası; state yönetimi kolaylığı |
| **initialize() zorunlu değil** | Basit kullanımda doğrudan `inspect()` çağrılabilir; `initialize()` sadece konfigürasyon için |
| **Platform provider pattern** | iOS/Android yeni bilgi eklemesi kolay; testlerde mocklanabilir |
| **Minimum dış bağımlılık** | Paket boyutunu küçük tutma; çakışma riskini azaltma; `device_info_plus` gibi paketlere bağımlı olmama |

---

## 10. Performans Hususları

- `inspect()` çağrısı tüm servisleri paralel çalıştırır; tipik tamamlanma süresi **< 100ms** (cihaza bağlı)
- Modüler erişim (`DeviceInspector.battery` vb.) sadece ilgili platform çağrısını yapar; **< 10ms**
- Model sınıfları `const` constructor destekler; sık oluşturulan nesneler için optimize edilmiştir
- `PerformanceMonitor` stream'i varsayılan 1 saniye interval ile çalışır; CPU etkisi minimal
- Tüm ağır native çağrılar background thread'de çalışır (iOS: `DispatchQueue`, Android: `Coroutines`)
