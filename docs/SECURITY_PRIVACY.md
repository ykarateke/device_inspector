# Device Inspector — Güvenlik ve Gizlilik

## 1. Gizlilik Taahhüdü

`device_inspector`, kullanıcı gizliliğini temel alan bir tasarıma sahiptir:

| Prensip | Açıklama |
|---|---|
| 🔒 **Veri dışarı çıkmaz** | Tüm cihaz bilgileri yalnızca yerel olarak toplanır. Hiçbir veri sunucuya gönderilmez. |
| 🔒 **Kullanıcı takibi yok** | Kullanıcı davranışı, lokasyon, kişisel veri toplanmaz. |
| 🔒 **Kalıcı ID yok** | IMEI, seri numarası, reklam ID'si gibi kalıcı tanımlayıcılar toplanmaz. |
| 🔒 **Şeffaf** | Hangi bilginin nereden alındığı kodda açıkça görülür. |
| 🔒 **Opsiyonel modüller** | Hassas modüller (güvenlik kontrolü, performans izleme) varsayılan kapalıdır. |
| 🔒 **Minimum izin** | Sadece gerekli platform izinleri istenir. |

---

## 2. Toplanan ve Toplanmayan Veriler

### 2.1 Toplanan Veriler (Yerel)

| Veri | Hassasiyet | Neden gerekli? |
|---|---|---|
| Cihaz modeli / üreticisi | Düşük | Crash analizi, cihaz uyumluluğu |
| OS sürümü | Düşük | Özellik desteği kontrolü |
| Batarya seviyesi | Düşük | Düşük pil uyarısı, optimizasyon |
| Ağ tipi (Wi-Fi / Cellular) | Düşük | İçerik kalitesi ayarı |
| RAM / Storage bilgisi | Düşük | Performans optimizasyonu |
| CPU mimarisi / çekirdek sayısı | Düşük | Device tier belirleme |
| Ekran çözünürlüğü / DPI | Düşük | UI uyarlaması |
| Uygulama sürümü / build | Düşük | Crash reporting |
| Debugger durumu | Orta | Güvenlik kontrolü |
| Root / Jailbreak durumu | Orta | Sahtekarlık tespiti |

### 2.2 **Kesinlikle Toplanmayan** Veriler

| Veri | Neden toplanmaz? |
|---|---|
| 📵 **IMEI / MEID** | Kalıcı cihaz tanımlayıcısı — gizlilik ihlali |
| 📵 **Seri numarası** | Donanım ID'si — takip riski |
| 📵 **Telefon numarası** | Kişisel veri |
| 📵 **Kişi listesi** | Tamamen kapsam dışı |
| 📵 **Lokasyon (GPS)** | İzleme riski |
| 📵 **Mikrofon / Kamera** | Tamamen kapsam dışı |
| 📵 **Reklam ID'si (IDFA / AAID)** | Kullanıcı takibi |
| 📵 **MAC adresi** | Ağ izleme riski (iOS/Android zaten kısıtlıyor) |
| 📵 **Wi-Fi ağ listesi** | Lokasyon çıkarımı riski |
| 📵 **Çalışan uygulama listesi** | Kullanıcı davranış analizi riski |
| 📵 **Klavye girişleri** | Tamamen kapsam dışı |
| 📵 **Ekran görüntüsü** | Tamamen kapsam dışı |

---

## 3. iOS Gizlilik Etiketleri (App Store)

`device_inspector` kullanan uygulamaların App Store'da beyan etmesi gereken gizlilik etiketleri:

| Veri Tipi | Kullanım | Tracking? | Linked to User? |
|---|---|---|---|
| **Cihaz ID'si** (`identifierForVendor`) | App Functionality | ❌ | Opsiyonel (uygulamaya bağlı) |
| **Tanılama** (Crash data) | Analytics | ❌ | ❌ |
| **Performans verisi** | App Functionality | ❌ | ❌ |

> **Not:** `identifierForVendor`, aynı vendor'a ait uygulamalar arasında aynıdır ancak uygulama silinip tekrar yüklenirse değişir. Kalıcı değildir. `DeviceInfo.identifier` alanı `null` yapılarak hiç toplanmaması sağlanabilir.

### Info.plist Gereksinimleri

```xml
<!-- Kullanıcıya gösterilecek gizlilik açıklamaları -->
<!-- device_inspector doğrudan bu izinleri istemez; uygulama eklerse beyan etmelidir -->

<!-- NOT: device_inspector'ın ihtiyaç duyduğu hiçbir özel izin yoktur -->
<!-- Tüm bilgiler public API'ler üzerinden alınır -->
```

---

## 4. Android İzinleri

`device_inspector` minimum izinle çalışır. Gereken izinler:

```xml
<!-- ============================= -->
<!-- ZORUNLU İZİNLER               -->
<!-- ============================= -->

<!-- Ağ durumu — NetworkInfo için -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<!-- Normal permission, kullanıcı onayı gerekmez -->

<!-- ============================= -->
<!-- OPSİYONEL İZİNLER             -->
<!-- ============================= -->

<!-- Operatör ismi için (normal permission, onay gerekmez) -->
<uses-permission android:name="android.permission.READ_PHONE_STATE" />

<!-- ============================= -->
<!-- ASLA İSTENMEYECEK İZİNLER     -->
<!-- ============================= -->
<!-- READ_PRECISE_PHONE_STATE — IMEI için, ASLA -->
<!-- ACCESS_FINE_LOCATION — GPS, ASLA -->
<!-- READ_CONTACTS — ASLA -->
<!-- CAMERA — ASLA -->
<!-- RECORD_AUDIO — ASLA -->
```

### İzin Kontrolü

```dart
// Dart tarafında izin kontrolü (opsiyonel)
final networkInfo = await DeviceInspector.network;
// carrier alanı READ_PHONE_STATE izni olmadan null döner
// → SERVICE_ERROR değil, sadece null — uygulama çökmez
```

---

## 5. Güvenlik Modülü — Tehdit Modeli

### 5.1 Saldırı Vektörleri

| Tehdit | Risk Seviyesi | Tespit Yöntemi |
|---|---|---|
| **Root (Android)** | 🔴 Yüksek | Binary kontrolü, Magisk tespiti, sistem özellikleri |
| **Jailbreak (iOS)** | 🔴 Yüksek | Dosya sistemi kontrolü, sandbox escape testi, Cydia URL scheme |
| **Emulator** | 🟡 Orta | Build parmak izi, donanım özellikleri |
| **Debugger** | 🟡 Orta | sysctl (iOS), Debug.isDebuggerConnected (Android) |
| **Repackaging** | 🟡 Orta | İmza hash kontrolü (Android) |
| **Hook / Injection** | 🟡 Orta | dylib kontrolü (iOS), LD_PRELOAD (Android) |
| **Developer mode** | 🟢 Düşük | ADB/USB debugging durumu |
| **VPN / Proxy** | 🟢 Düşük | Ağ yapılandırması |

### 5.2 Tespit Güvenilirliği

```
Tamamen güvenilir ──────────────────────────────────────► Tamamen atlatılabilir

Debugger tespiti    Root binary     Emulator       Magisk tespiti
    (yüksek)        (yüksek)       (yüksek)         (orta)
     ████████        ████████       ████████         ██████░░

Jailbreak dosya     Sandbox         Cydia URL        dylib kontrolü
    (yüksek)        testi (yüksek)  scheme (orta)      (düşük-orta)
     ████████        ████████       ██████░░          ████░░░░
```

> **Uyarı:** Hiçbir root/jailbreak tespit yöntemi %100 güvenilir değildir. Gelişmiş saldırganlar tüm kontrolleri atlatabilir. `device_inspector` derinlikli savunma (defense-in-depth) yaklaşımıyla birden fazla kontrol katmanı uygular, ancak mutlak güvenlik garantisi vermez.

### 5.3 Yanlış Pozitif Riski

| Senaryo | Risk | Önlem |
|---|---|---|
| Geliştirici root'lu test cihazı | `isRooted=true` — beklenen | Gerçek kullanıcıda false olmalı |
| Custom ROM (LineageOS vb.) | `isRooted` yanlışlıkla true olabilir | `securityScore` ile ağırlıklandırma |
| Kurumsal MDM cihazları | Bazı kontroller tetiklenebilir | `detectedThreats` listesi incelenmeli |
| Çin OEM cihazları | Sistem özellikleri farklı olabilir | Sadece binary kontrolü değil, çoklu test |
| Geliştirici seçenekleri açık | `isDeveloperMode=true` | Her zaman tehdit değil — skora düşük etki |

---

## 6. iOS Jailbreak Tespit Detayları

### 6.1 Kontrol Listesi

```
1. SIMULATOR KONTROLÜ
   #if targetEnvironment(simulator)
   → Evet → isEmulator = true

2. DEBUGGER KONTROLÜ
   sysctl KERN_PROC → P_TRACED flag
   → Varsa → isDebuggerAttached = true

3. DOSYA SİSTEMİ KONTROLLERİ
   /Applications/Cydia.app        var mı?
   /Applications/Sileo.app        var mı?
   /usr/sbin/sshd                 var mı?
   /bin/bash                      var mı?
   /etc/apt                       var mı?
   /Library/MobileSubstrate/      var mı?
   /private/var/lib/apt           var mı?
   → Herhangi biri varsa → hasSuspiciousPaths = true

4. SANDBOX ESCAPE TESTİ
   /private/test_jailbreak dosyasına yazma dene
   → Başarılı olursa → isJailbroken = true (sandbox dışı!)

5. CYDIA URL SCHEME
   UIApplication.canOpenURL("cydia://")
   → true → hasSuspiciousApps = true

6. DYNAMIC LIBRARY KONTROLÜ
   _dyld_image_count / _dyld_get_image_name
   MobileSubstrate, SubstrateLoader, CydiaSubstrate ara
   → Varsa → hasModifiedLibraries = true

7. FORK KONTROLÜ
   fork() çağrısı yapılabiliyor mu?
   (Sandbox'lu iOS uygulaması fork yapamaz)
   → Yapabiliyorsa → isJailbroken = true
```

### 6.2 iOS Security Score Hesaplama

```
Başlangıç: 100

-30  Simulator tespiti
-40  Sandbox escape başarılı
-20  Cydia URL scheme
-20  Debugger bağlı
-15  Şüpheli dosya yolu (her tespit)
-15  Şüpheli dylib tespiti

Minimum: 0
Skor < 50   → YÜKSEK risk
Skor 50-79  → ORTA risk
Skor 80-100 → DÜŞÜK risk
```

---

## 7. Android Root Tespit Detayları

### 7.1 Kontrol Listesi

```
1. ROOT BINARY KONTROLÜ
   /system/app/Superuser.apk
   /sbin/su, /system/bin/su, /system/xbin/su
   /data/local/xbin/su, /data/local/bin/su
   → Herhangi biri varsa → isRooted = true

2. MAGISK TESPİTİ
   /data/adb/magisk               var mı?
   /data/adb/modules              var mı?
   /sbin/.magisk                  var mı?
   → Varsa → isRooted = true + hasSuspiciousApps = true

3. SUPERUSER UYGULAMALARI
   PackageManager ile kontrol:
   com.noshufou.android.su
   eu.chainfire.supersu
   com.topjohnwu.magisk
   → Yüklüyse → hasSuspiciousApps = true

4. EMULATOR TESPİTİ
   Build.FINGERPRINT "generic" ile mi başlıyor?
   Build.HARDWARE "goldfish" / "ranchu" içeriyor mu?
   Build.MODEL "Emulator" / "Android SDK built for x86" mi?
   Build.MANUFACTURER "Genymotion" mu?
   Build.PRODUCT "sdk" / "sdk_google" / "vbox86p" mi?
   → Herhangi biri → isEmulator = true

5. DEBUGGER KONTROLÜ
   Debug.isDebuggerConnected() || Debug.waitingForDebugger()
   → true → isDebuggerAttached = true

6. DEVELOPER MODE / ADB
   Settings.Global.DEVELOPMENT_SETTINGS_ENABLED
   Settings.Global.ADB_ENABLED
   → isDeveloperMode = true

7. SİSTEM ÖZELLİKLERİ (getprop)
   ro.debuggable = 1   → debug build
   ro.secure = 0       → root erişimi
   ro.build.tags içinde "test-keys" → engineering build
   → hasSuspiciousEnvVars = true

8. ORTAM DEĞİŞKENLERİ
   System.getenv("LD_PRELOAD")
   System.getenv("LD_LIBRARY_PATH")
   → Boş değilse → şüpheli

9. BUSYBOX KONTROLÜ
   which busybox → varsa root göstergesi
```

### 7.2 Android Security Score Hesaplama

```
Başlangıç: 100

-40  Root binary bulundu
-30  Magisk tespit edildi
-30  Emulator tespiti
-20  SuperUser uygulaması
-20  Debugger bağlı
-15  Şüpheli sistem özelliği (her biri)
-10  USB debugging açık
-10  LD_PRELOAD set edilmiş

Minimum: 0
```

---

## 8. Geliştiriciler İçin Güvenlik Önerileri

### 8.1 Sunucu Tarafı Doğrulama

```dart
// ❌ SADECE client-side güvenme
final security = await DeviceInspector.security;
if (security.isRooted) {
  showBlockScreen(); // Kolayca atlatılabilir
}

// ✅ Client + server doğrulama
final security = await DeviceInspector.security;
await api.verifyDeviceIntegrity({
  'isRooted': security.isRooted,
  'isEmulator': security.isEmulator,
  'securityScore': security.securityScore,
  'detectedThreats': security.detectedThreats,
  'deviceModel': device.model,
  'osVersion': os.version,
  'appSignature': appInfo.signatureHash, // Android
});
// Sunucu tarafında ek kontroller:
// - Apple DeviceCheck / Android SafetyNet (Play Integrity)
// - Anomali tespiti (aynı cihazdan çok sayıda istek)
// - Risk skorlama
```

### 8.2 Önerilen Güvenlik Katmanları

```
Katman 1: device_inspector (client)
   → Root/Jailbreak tespiti
   → Emulator tespiti
   → Debugger tespiti

Katman 2: Platform güvenlik API'leri
   → iOS: DeviceCheck (App Attest)
   → Android: Play Integrity API

Katman 3: Sunucu tarafı
   → Anomali tespiti
   → Rate limiting
   → Cihaz fingerprint analizi

Katman 4: İş mantığı
   → Hassas işlemler için ek doğrulama
   → Manuel inceleme queue
```

### 8.3 OWASP MASVS Karşılaştırması

| MASVS Gereksinimi | device_inspector Desteği |
|---|---|
| MSTG-RESILIENCE-1: Root tespiti | ✅ Android root + iOS jailbreak |
| MSTG-RESILIENCE-2: Debugger tespiti | ✅ Her iki platform |
| MSTG-RESILIENCE-3: Emulator tespiti | ✅ Her iki platform |
| MSTG-RESILIENCE-6: Tersine mühendislik araçları | ⚠️ Kısmen (dylib/LD_PRELOAD) |
| MSTG-RESILIENCE-8: Kod bütünlüğü | ❌ Kapsam dışı (sunucu tarafı) |
| MSTG-RESILIENCE-9: Cihaz binding | ❌ Kapsam dışı (DeviceCheck/SafetyNet ile) |

---

## 9. Veri Sızıntısı Önleme

### 9.1 Log Temizliği

```dart
// Varsayılan: logLevel = off
// Development sırasında debug modunda:
DeviceInspector.initialize(logLevel: DeviceInspectorLogLevel.debug);

// Production'da ASLA debug/verbose seviyesi kullanılmamalı:
DeviceInspector.initialize(logLevel: DeviceInspectorLogLevel.off);

// Veya sadece hataları logla:
DeviceInspector.initialize(logLevel: DeviceInspectorLogLevel.error);
```

### 9.2 JSON Çıktı sansürleme

```dart
// Hassas alanları hariç tutmak için:
final safeJson = {
  ...snapshot.toJson(),
  'device': {
    ...snapshot.device.toJson(),
    'identifier': null, // Vendor ID'yi dışarı verme
  },
};
```

### 9.3 Network üzerinden veri gönderimi

```dart
// ✅ SDK'nın toJSON çıktısını gönderirken:
// - HTTPS kullan
// - Veriyi şifrele (zaten HTTPS yapıyor)
// - Minimum gerekli alanı gönder

final minimalReport = {
  'model': snapshot.device.model,
  'os': snapshot.os.version,
  'tier': snapshot.hardware.tier.name,
  // battery.level, network.carrier gibi alanları
  // GEREKMİYORSA gönderme
};
```

---

## 10. Uyumluluk

### 10.1 GDPR

`device_inspector`:
- Kişisel veri toplamaz (IMEI, lokasyon, kişiler vb.)
- `identifierForVendor` / `ANDROID_ID` kalıcı değildir, pseudonymous kabul edilir
- GDPR kapsamında "meşru menfaat" ile kullanılabilir
- Uygulama geliştiricisi yine de kendi gizlilik politikasında beyan etmelidir

### 10.2 Apple App Store Review

- IOKit kullanımı: Public API, review'de sorun olmaz
- `sysctl`: Approved API
- Cihaz bilgisi toplama: App Store kurallarına uygun (tanılama amaçlı)

### 10.3 Google Play Store

- `READ_PHONE_STATE`: Normal permission, özel onay gerekmez
- `BATTERY_STATS`: Protected permission; normal uygulama `Intent.ACTION_BATTERY_CHANGED` ile alır, manifest'te `tools:ignore` eklenir
- Root tespiti: Play Store politikalarına aykırı değil

---

## 11. Güvenlik Açığı Bildirimi

Güvenlik açığı tespit eden araştırmacılar için iletişim:

```
📧 E-posta: security@bearcode.dev
🔒 PGP: [Key ID]
⏱️ Yanıt süresi: 48 saat
💰 Bug bounty: Var (HackerOne üzerinden)
```

**Sorumlu açıklama politikası:**
1. Açığı private olarak bildirin
2. 90 gün düzeltme süresi tanıyın
3. Düzeltme sonrası koordineli açıklama
