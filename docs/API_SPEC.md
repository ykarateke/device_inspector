# Device Inspector — API Spesifikasyonu

## 1. Giriş Noktası: `DeviceInspector`

`DeviceInspector` sınıfı, SDK'nın tüm işlevselliğine erişim sağlayan **singleton** giriş noktasıdır.

### 1.1 `DeviceInspector.instance`

```dart
static DeviceInspector get instance
```

Singleton instance'a erişim. `initialize()` çağrılmadan da kullanılabilir; bu durumda varsayılan yapılandırma ile çalışır.

---

### 1.2 `DeviceInspector.initialize()`

```dart
static Future<void> initialize({
  bool enableSecurityCheck = false,
  bool enablePerformanceMonitor = false,
  int performanceSamplingIntervalMs = 1000,
  DeviceInspectorLogLevel logLevel = DeviceInspectorLogLevel.off,
}) async
```

**Parametreler:**

| Parametre | Tip | Varsayılan | Açıklama |
|---|---|---|---|
| `enableSecurityCheck` | `bool` | `false` | Root/jailbreak/emulator tespitini etkinleştirir. Performans etkisi nedeniyle varsayılan kapalı. |
| `enablePerformanceMonitor` | `bool` | `false` | Gerçek zamanlı performans izlemeyi etkinleştirir. CPU ve batarya kullanımını artırabilir. |
| `performanceSamplingIntervalMs` | `int` | `1000` | Performans örnekleme aralığı (milisaniye). Minimum 200ms. |
| `logLevel` | `DeviceInspectorLogLevel` | `off` | SDK içi loglama seviyesi: `off`, `error`, `warn`, `info`, `debug`, `verbose`. |

**İstisnalar:**

| İstisna | Durum |
|---|---|
| `ConfigurationException` | Geçersiz `performanceSamplingIntervalMs` (< 200ms) |

**Kullanım:**

```dart
await DeviceInspector.initialize(
  enableSecurityCheck: true,
  enablePerformanceMonitor: true,
);

// veya doğrudan kullanım (initialize opsiyonel):
final snapshot = await DeviceInspector.inspect();
```

---

### 1.3 `DeviceInspector.inspect()`

```dart
Future<DeviceSnapshot> inspect() async
```

Tüm cihaz bilgilerini tek seferde toplar ve döndürür. Servisler paralel çağrılır.

**Dönüş:** `DeviceSnapshot` — Tüm alt modelleri kapsayan kök model.

**Kullanım:**

```dart
final snapshot = await DeviceInspector.inspect();
print(snapshot.device.model);      // "iPhone 15 Pro"
print(snapshot.battery.level);     // 85
print(snapshot.security.isRooted); // false
```

---

## 2. Alt Modül Erişimcileri

Her alt modül, `Future<T>` dönen bir getter'dır. İlk çağrıda cache'lenir, aynı session içinde tekrar platform çağrısı yapılmaz. Cache'i temizlemek için `DeviceInspector.refresh()` kullanılır.

### 2.1 `DeviceInspector.device`

```dart
Future<DeviceInfo> get device
```

Cihaz donanım kimlik bilgilerini döndürür.

**Dönüş:** `DeviceInfo`

**Kullanım:**

```dart
final device = await DeviceInspector.device;
print(device.manufacturer); // "Apple"
print(device.model);        // "iPhone15,3"
print(device.marketName);   // "iPhone 15 Pro"
```

---

### 2.2 `DeviceInspector.os`

```dart
Future<OSInfo> get os
```

İşletim sistemi bilgilerini döndürür.

**Dönüş:** `OSInfo`

**Kullanım:**

```dart
final os = await DeviceInspector.os;
print(os.platform);  // "iOS"
print(os.version);   // "26.0"
print(os.apiLevel);  // null on iOS, 34 on Android
```

---

### 2.3 `DeviceInspector.battery`

```dart
Future<BatteryInfo> get battery
```

Batarya durum bilgilerini döndürür.

**Dönüş:** `BatteryInfo`

**Kullanım:**

```dart
final battery = await DeviceInspector.battery;
print(battery.level);      // 85
print(battery.isCharging); // true
print(battery.health);     // "good"
```

---

### 2.4 `DeviceInspector.network`

```dart
Future<NetworkInfo> get network
```

Ağ bağlantı bilgilerini döndürür.

**Dönüş:** `NetworkInfo`

**Kullanım:**

```dart
final network = await DeviceInspector.network;
print(network.type);     // "wifi"
print(network.carrier);  // "Turkcell"
print(network.isVpn);    // false
```

---

### 2.5 `DeviceInspector.hardware`

```dart
Future<HardwareInfo> get hardware
```

Donanım bileşenleri hakkında detaylı bilgi döndürür. **Phase 2**.

**Dönüş:** `HardwareInfo`

**Kullanım:**

```dart
final hardware = await DeviceInspector.hardware;
print(hardware.cpu.cores);         // 6
print(hardware.cpu.architecture);  // "arm64"
print(hardware.gpu.supportsMetal); // true
```

---

### 2.6 `DeviceInspector.memory`

```dart
Future<MemoryInfo> get memory
```

RAM kullanım bilgilerini döndürür. **Phase 2**.

**Dönüş:** `MemoryInfo`

**Kullanım:**

```dart
final memory = await DeviceInspector.memory;
print(memory.totalBytes);     // 8589934592 (8GB)
print(memory.availableBytes); // 3435973836 (~3.2GB)
print(memory.usagePercent);   // 60.0
```

---

### 2.7 `DeviceInspector.storage`

```dart
Future<StorageInfo> get storage
```

Depolama alanı bilgilerini döndürür. **Phase 2**.

**Dönüş:** `StorageInfo`

**Kullanım:**

```dart
final storage = await DeviceInspector.storage;
print(storage.totalBytes); // 274877906944 (256GB)
print(storage.freeBytes);  // 128849018880 (~120GB)
print(storage.usagePercent); // 53.1
```

---

### 2.8 `DeviceInspector.security`

```dart
Future<SecurityInfo> get security
```

Güvenlik durumu bilgilerini döndürür. **Phase 3**. `initialize(enableSecurityCheck: true)` ile etkinleştirilmelidir.

**Dönüş:** `SecurityInfo`

**Kullanım:**

```dart
final security = await DeviceInspector.security;
print(security.isRooted);         // false
print(security.isJailbroken);     // false
print(security.isDebuggerAttached); // false
print(security.isEmulator);       // false
print(security.isDeveloperMode);  // true
```

---

### 2.9 `DeviceInspector.app`

```dart
Future<AppInfo> get app
```

Uygulama meta bilgilerini döndürür. Platform çağrısı yapmaz, Dart tarafında `package_info_plus` (veya manuel) ile çözülür.

**Dönüş:** `AppInfo`

**Kullanım:**

```dart
final app = await DeviceInspector.app;
print(app.version);     // "1.2.3"
print(app.buildNumber); // "42"
print(app.bundleId);    // "com.example.app"
print(app.appName);     // "MyApp"
```

---

### 2.10 `DeviceInspector.performance`

```dart
PerformanceMonitor get performance
```

Gerçek zamanlı performans izleme stream'i. **Phase 4**. `initialize(enablePerformanceMonitor: true)` ile etkinleştirilmelidir. Getter (async değil) — hemen döner, stream üzerinden veri akışı sağlar.

**Dönüş:** `PerformanceMonitor`

**Kullanım:**

```dart
final monitor = DeviceInspector.performance;

monitor.snapshotStream.listen((snapshot) {
  print('FPS: ${snapshot.fps}');
  print('CPU: ${snapshot.cpuUsagePercent}%');
  print('Memory: ${snapshot.memoryUsageMB}MB');
});

monitor.start();
// ...
monitor.stop();
```

---

## 3. `PerformanceMonitor` Sınıfı

### 3.1 Özellikler

```dart
class PerformanceMonitor {
  /// Anlık son snapshot (null = henüz örneklenmedi)
  PerformanceSnapshot? get currentSnapshot;

  /// Performans verisi stream'i
  Stream<PerformanceSnapshot> get snapshotStream;

  /// Monitor aktif mi?
  bool get isRunning;

  /// Örnekleme aralığı (ms)
  int get samplingIntervalMs;
}
```

### 3.2 Metotlar

```dart
/// İzlemeyi başlatır. Zaten çalışıyorsa no-op.
void start();

/// İzlemeyi durdurur. Stream kapanmaz, `start()` ile devam eder.
void stop();

/// Mevcut stream'i ve timer'ı temizler. Yeni snapshot almak için tekrar `start()` gerekir.
void dispose();
```

---

## 4. Yardımcı Metotlar

### 4.1 `DeviceInspector.refresh()`

```dart
Future<void> refresh([List<DeviceInspectorModule>? modules])
```

Cache'lenmiş modül verilerini temizler. Bir sonraki erişimde taze veri çekilir.

**Parametreler:**

| Parametre | Tip | Açıklama |
|---|---|---|
| `modules` | `List<DeviceInspectorModule>?` | Temizlenecek modüller. `null` = tüm modüller. |

**Kullanım:**

```dart
await DeviceInspector.refresh(); // Tüm cache temizlenir

await DeviceInspector.refresh([
  DeviceInspectorModule.battery,
  DeviceInspectorModule.network,
]); // Sadece belirtilenler
```

---

### 4.2 `DeviceInspector.dispose()`

```dart
void dispose()
```

SDK kaynaklarını serbest bırakır: performans izleyici durdurulur, cache temizlenir. `initialize()` ile tekrar kullanılabilir.

---

### 4.3 `DeviceInspector.supportedModules`

```dart
static List<DeviceInspectorModule> get supportedModules
```

Mevcut platformda desteklenen modüllerin listesini döndürür.

**Kullanım:**

```dart
final supported = DeviceInspector.supportedModules;
// iOS: [device, os, battery, network, hardware, memory, storage, security, app, performance]
// Android: [device, os, battery, network, hardware, memory, storage, security, app, performance]
// Web: [] — desteklenmez (PlatformNotSupportedException)
```

---

### 4.4 `DeviceInspector.isModuleSupported()`

```dart
static bool isModuleSupported(DeviceInspectorModule module)
```

Belirtilen modülün mevcut platformda desteklenip desteklenmediğini kontrol eder.

---

### 4.5 `DeviceInspector.platform`

```dart
static DevicePlatform get platform
```

Çalışma zamanında tespit edilen platform bilgisi.

```dart
enum DevicePlatform { iOS, android, unknown }
```

---

## 5. Enum Tanımları

### 5.1 `DeviceInspectorModule`

```dart
enum DeviceInspectorModule {
  device,
  os,
  battery,
  network,
  hardware,
  memory,
  storage,
  security,
  app,
  performance,
}
```

### 5.2 `DeviceInspectorLogLevel`

```dart
enum DeviceInspectorLogLevel {
  off,      // Hiç log yok
  error,    // Sadece hatalar
  warn,     // Hata + uyarılar
  info,     // + bilgi mesajları
  debug,    // + debug detayları
  verbose,  // + tüm iç mesajlar
}
```

### 5.3 `NetworkType`

```dart
enum NetworkType {
  wifi,
  cellular,
  ethernet,
  vpn,
  offline,
  unknown,
}
```

### 5.4 `BatteryHealth`

```dart
enum BatteryHealth {
  unknown,
  good,       // > 80% maksimum kapasite
  fair,       // %60-80
  poor,       // < 60%
  service,    // Servis önerilir
}
```

### 5.5 `BatteryChargingState`

```dart
enum BatteryChargingState {
  charging,         // AC/USB şarj
  discharging,      // Şarjda değil
  full,             // %100 dolu, takılı
  wirelessCharging, // Kablosuz şarj (iOS: iOS 17+, Android: API 29+)
  unknown,
}
```

### 5.6 `DeviceTier`

```dart
enum DeviceTier {
  low,     // Düşük performans sınıfı (eski cihazlar)
  medium,  // Orta sınıf
  high,    // Üst sınıf / flagship
  unknown,
}
```

---

## 6. JSON Serileştirme

Tüm model sınıfları `toJson()` ve `fromJson()` metotlarını destekler:

```dart
// Serileştirme
final snapshot = await DeviceInspector.inspect();
final json = snapshot.toJson(); // Map<String, dynamic>

// Deserialization (test/offline senaryoları için)
final snapshot2 = DeviceSnapshot.fromJson(json);
```

---

## 7. Analytics Entegrasyonu

### 7.1 Sentry

```dart
final snapshot = await DeviceInspector.inspect();

Sentry.configureScope((scope) {
  scope.setContexts('device', snapshot.toJson());
});
```

### 7.2 Firebase Crashlytics

```dart
final snapshot = await DeviceInspector.inspect();

await FirebaseCrashlytics.instance.setCustomKey(
  'device_model', snapshot.device.model,
);
await FirebaseCrashlytics.instance.setCustomKey(
  'os_version', snapshot.os.version,
);
await FirebaseCrashlytics.instance.setCustomKey(
  'battery_level', snapshot.battery.level,
);
```

### 7.3 Özel Analytics

```dart
final snapshot = await DeviceInspector.inspect();

// Herhangi bir analytics servisi ile
analytics.track('device_context', snapshot.toJson());

// Veya belirli alanlar
analytics.setUserProperty('device_tier', snapshot.hardware.tier.name);
analytics.setUserProperty('network_type', snapshot.network.type.name);
```

---

## 8. Web/Desktop Desteği

`device_inspector` yalnızca iOS ve Android platformlarını destekler. Web veya masaüstünde (Windows, macOS, Linux) kullanıldığında:

```dart
try {
  final info = await DeviceInspector.inspect();
} on PlatformNotSupportedException catch (e) {
  print('device_inspector bu platformu desteklemiyor: ${e.message}');
}
```

**Desteklenen platformlar:**
- ✅ iOS 14+
- ✅ Android 7.0+ (API 24+)
- ❌ Web
- ❌ macOS (desktop)
- ❌ Windows
- ❌ Linux

---

## 9. Hata Kodları

| Kod | Açıklama |
|---|---|
| `PLATFORM_NOT_SUPPORTED` | Web/Desktop'ta kullanım |
| `NOT_INITIALIZED` | Security/Performance `initialize()` olmadan kullanıldı |
| `PERMISSION_DENIED` | Platform izni reddedildi |
| `HARDWARE_ACCESS_DENIED` | Donanım bilgisine erişilemedi |
| `SECURITY_CHECK_FAILED` | Güvenlik kontrolü hatası |
| `INVALID_CONFIGURATION` | Geçersiz initialize parametresi |
| `NATIVE_METHOD_NOT_FOUND` | Platform tarafında metod bulunamadı |
| `UNKNOWN` | Beklenmeyen hata |

---

## 10. Tam Kullanım Örneği

```dart
import 'package:device_inspector/device_inspector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize (opsiyonel — security ve performance için gerekli)
  await DeviceInspector.initialize(
    enableSecurityCheck: true,
    enablePerformanceMonitor: true,
    performanceSamplingIntervalMs: 500,
    logLevel: DeviceInspectorLogLevel.info,
  );

  // 2. Full inspection
  final snapshot = await DeviceInspector.inspect();
  print('''
    Cihaz: ${snapshot.device.marketName} (${snapshot.device.model})
    OS: ${snapshot.os.platform} ${snapshot.os.version}
    Batarya: %${snapshot.battery.level} — ${snapshot.battery.chargingState.name}
    Ağ: ${snapshot.network.type.name} — VPN: ${snapshot.network.isVpn}
    RAM: ${snapshot.memory.formattedAvailable} / ${snapshot.memory.formattedTotal}
    Storage: ${snapshot.storage.formattedFree} / ${snapshot.storage.formattedTotal}
    Root: ${snapshot.security.isRooted}
    Emulator: ${snapshot.security.isEmulator}
    App: ${snapshot.app.appName} v${snapshot.app.version} (${snapshot.app.buildNumber})
  ''');

  // 3. Modüler erişim
  final battery = await DeviceInspector.battery;
  if (battery.level < 20 && !battery.isCharging) {
    print('⚠️ Düşük batarya uyarısı!');
  }

  // 4. Performans izleme
  final monitor = DeviceInspector.performance;
  monitor.snapshotStream.listen((snap) {
    if (snap.fps < 30) {
      print('⚠️ Düşük FPS: ${snap.fps}');
    }
  });
  monitor.start();

  // 5. Device tier kontrolü
  if (snapshot.hardware.tier == DeviceTier.low) {
    // Düşük grafik ayarları uygula
  }

  // 6. JSON serileştirme (analytics/logging için)
  final json = snapshot.toJson();
  await saveToLog(json);

  // 7. Temizlik
  monitor.stop();
  DeviceInspector.dispose();
}
```
