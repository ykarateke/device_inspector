Kanka `device_inspector` için sağlam bir PRD hazırladım. Bunu direkt GitHub README, issue roadmap veya geliştirme dokümanı olarak kullanabilirsiniz.

# Device Inspector Flutter Package — PRD

## 1. Proje Tanımı

**Proje Adı:** `device_inspector`

**Kısa Açıklama:**

Flutter uygulamalarında cihaz, sistem, donanım, performans ve güvenlik bilgilerini tek bir standart API üzerinden sağlayan açık kaynak cihaz analiz SDK'sı.

Amaç:

> Flutter geliştiricilerinin uygulama içinden güvenilir cihaz bilgilerine erişmesini, performans sorunlarını analiz etmesini ve kullanıcı ortamını anlamasını kolaylaştırmak.

---

# 2. Problem

Flutter ekosisteminde cihaz bilgileri farklı paketlere bölünmüş durumda:

Örnek:

* `device_info_plus`
* `package_info_plus`
* `battery_plus`
* `connectivity_plus`
* `network_info_plus`

Sorunlar:

* Her bilgi için farklı API kullanılıyor.
* Platform farkları yönetmek zor.
* Eksik bilgiler var.
* Root/Jailbreak bilgisi yok.
* Donanım performansı hakkında bilgi yok.
* Uygulama geliştiricileri crash raporlarında cihaz bağlamını kaybediyor.

---

# 3. Hedef

Tek API ile:

```dart
final info = await DeviceInspector.inspect();
```

kullanımıyla bütün cihaz bağlamını almak.

Örnek çıktı:

```json
{
 "device": {
   "manufacturer": "Apple",
   "model": "iPhone15,3",
   "name": "iPhone 15 Pro"
 },

 "os": {
   "platform": "iOS",
   "version": "26.0"
 },

 "hardware": {
   "cpu": "A17 Pro",
   "ram": "8GB",
   "storage": "256GB"
 },

 "battery": {
   "level": 87,
   "charging": true
 },

 "network": {
   "type": "wifi",
   "isVPN": false
 },

 "security": {
   "isRooted": false,
   "isJailbroken": false
 }
}
```

---

# 4. Kullanıcı Kitlesi

## Mobil geliştiriciler

Kullanım alanları:

* Crash reporting
* Analytics
* User support
* Performance monitoring

## SaaS uygulamaları

Örnek:

"Bu cihaz destekleniyor mu?"

Kontrol:

```
iPhone 8
❌ Minimum desteklenmiyor

iPhone 15
✅ Destekleniyor
```

## Oyun geliştiricileri

Kullanım:

* Grafik kalite ayarı
* FPS optimizasyonu
* Device tier sistemi

---

# 5. Core API Tasarımı

## Initialize

```dart
DeviceInspector.initialize(
  enableSecurityCheck: true,
  enablePerformanceMonitor: true,
);
```

---

## Full Inspection

```dart
final device =
    await DeviceInspector.inspect();
```

---

## Specific Modules

### Device

```dart
DeviceInspector.device
```

Döner:

```dart
DeviceInfo(
 model,
 manufacturer,
 brand,
 identifier
)
```

---

### Battery

```dart
DeviceInspector.battery
```

Çıktı:

```dart
BatteryInfo(
 level: 85,
 charging: true,
 health: "good"
)
```

---

### Memory

```dart
DeviceInspector.memory
```

Çıktı:

```dart
MemoryInfo(
 total: 8192,
 available: 3200
)
```

---

### Storage

```dart
DeviceInspector.storage
```

Çıktı:

```dart
StorageInfo(
 total: 256GB,
 free: 120GB
)
```

---

### Network

```dart
DeviceInspector.network
```

Çıktı:

```dart
NetworkInfo(
 type: wifi,
 carrier: Turkcell,
 vpn: false
)
```

---

### Security

```dart
DeviceInspector.security
```

Kontroller:

* Root
* Jailbreak
* Debug mode
* Developer mode
* Emulator

---

# 6. Feature Roadmap

# Phase 1 — MVP

## Device Information

Destek:

iOS:

* model
* OS version
* identifier
* architecture

Android:

* manufacturer
* model
* API level
* ABI

## App Information

```dart
AppInfo(
 version,
 buildNumber,
 bundleId
)
```

---

## Battery

* percentage
* charging status

## Network

* wifi
* cellular
* offline

---

# Phase 2

## Hardware Intelligence

### CPU

```dart
CPUInfo(
 cores: 6,
 architecture: arm64
)
```

### RAM

```dart
RAMInfo(
 total,
 available
)
```

### GPU

iOS:

Metal capability

Android:

Vulkan/OpenGL support

---

# Phase 3

## Security Module

Kontroller:

### iOS

* Jailbreak detection
* Cydia detection
* suspicious paths
* debugger detection

### Android

* Root detection
* Magisk detection
* emulator detection

---

# Phase 4

## Performance Monitor

Gerçek zamanlı:

```dart
PerformanceMonitor.start();
```

Takip:

* FPS
* Memory usage
* CPU usage
* Thermal state

Örnek:

```json
{
 "fps":58,
 "memory":"430MB",
 "cpu":"32%"
}
```

---

# 7. Platform Architecture

```
              Flutter API

                  |
                  |

          device_inspector

                  |

      ----------------------

      iOS Native       Android Native

      Swift            Kotlin

      ----------------------

           Hardware APIs
```

---

# 8. Paket Yapısı

```
device_inspector/

lib/

 ├── device_inspector.dart

 ├── src/

 │    ├── core/

 │    ├── models/

 │    ├── services/

 │    ├── platform/

 │
 └── exceptions/


ios/

Classes/

DeviceInspectorPlugin.swift


android/

DeviceInspectorPlugin.kt
```

---

# 9. Model Tasarımı

Örnek:

```dart
class DeviceSnapshot {

 final DeviceInfo device;

 final OSInfo os;

 final BatteryInfo battery;

 final NetworkInfo network;

 final SecurityInfo security;

}
```

Immutable olacak:

* Freezed
* JsonSerializable

---

# 10. Privacy Tasarımı

Önemli nokta.

Package:

❌ Kullanıcı takibi yapmaz.

❌ ID toplamaz.

❌ Server'a veri göndermez.

Sadece:

```dart
local information
```

sağlar.

---

# 11. Analytics Entegrasyonu

Opsiyonel:

```dart
DeviceSnapshot.toJson();
```

Sentry:

```dart
Sentry.configureScope(
(scope){
 scope.setContexts(
 "device",
 snapshot.toJson()
 );
});
```

Firebase:

```dart
Crashlytics.setCustomKeys(snapshot);
```

---

# 12. Lisans

Öneri:

MIT License

Sebep:

* Kurumsal kullanım kolaylığı
* Fork engeli yok
* Flutter ekosistemine uygun

---

# 13. Başarı Kriterleri

İlk 6 ay:

* ⭐ 500 GitHub star
* 📦 10.000 pub.dev download
* 20+ contributor

---

# 14. Gelecek Versiyonlar

## v1.0

Temel device info

## v1.5

Security module

## v2.0

Performance monitoring

## v3.0

Cloud dashboard:

```
device_inspector_cloud

              |
        Device Reports

              |
          Dashboard
```

---

# 15. Bear Code Studio için farklılaştırıcı özellik

Bence paketi sıradan `device_info_plus` alternatifi yapmayın.

Asıl değer:

**"Flutter için Datadog tarzı cihaz intelligence SDK"**

olması.

Yani sadece:

> "Telefon modeli nedir?"

değil:

> "Bu kullanıcı neden crash aldı, cihazı uygulamayı kaldırıyor mu, performansı kötü mü?"

sorusunu cevaplamalı.

Bu şekilde `device_inspector` uzun vadede şirketlerin kullandığı bir developer tool olabilir.
