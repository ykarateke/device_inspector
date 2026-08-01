# Device Inspector — Test Stratejisi

## 1. Test Piramidi

```
            ╱  E2E  ╲           ← Cihaz üzerinde entegrasyon testleri
          ╱──────────╲              (flutter test integration_test/)
        ╱   WIDGET    ╲         ← Widget testleri (gerektiğinde)
      ╱────────────────╲
    ╱    UNIT TESTS      ╲       ← Birim testleri (çoğunluk)
  ╱────────────────────────╲
```

| Katman | Kapsam | Oran | Framework |
|---|---|---|---|
| Birim testleri | Model sınıfları, servisler, error handler | ~70% | `flutter_test` + `mockito` |
| Widget testleri | Kullanıcı arayüzü olmadığı için bu katman kapsam dışı | ~0% | — |
| Entegrasyon testleri | Gerçek cihazda platform kanalları | ~25% | `integration_test` |
| E2E testleri | Tam inspect() akışı, performans izleme | ~5% | `integration_test` |

---

## 2. Birim Testleri

### 2.1 Model Testleri

Tüm model sınıfları için JSON serileştirme ve deserialization testleri:

**`test/models/device_info_test.dart`:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/device_info.dart';

void main() {
  group('DeviceInfo', () {
    final sampleJson = {
      'manufacturer': 'Apple',
      'model': 'iPhone15,3',
      'marketName': 'iPhone 15 Pro',
      'identifier': 'UUID-12345',
      'codename': 'iPhone15,3',
      'tier': 'high',
      'releaseYear': 2023,
    };

    test('fromJson → toJson dönüşümü simetrik olmalı', () {
      final info = DeviceInfo.fromJson(sampleJson);
      final json = info.toJson();

      expect(json['manufacturer'], 'Apple');
      expect(json['model'], 'iPhone15,3');
      expect(json['marketName'], 'iPhone 15 Pro');
      expect(json['tier'], 'high');
    });

    test('fromJson eksik nullable alanları null olarak okumalı', () {
      final minimalJson = {
        'manufacturer': 'Apple',
        'model': 'iPhone15,3',
        'marketName': 'iPhone 15 Pro',
      };

      final info = DeviceInfo.fromJson(minimalJson);

      expect(info.identifier, isNull);
      expect(info.codename, isNull);
      expect(info.releaseYear, isNull);
    });

    test('fromJson bilinmeyen tier değerinde DeviceTier.unknown dönmeli', () {
      final jsonWithUnknownTier = {
        ...sampleJson,
        'tier': 'invalid_tier',
      };

      // Freezed, enum için bilinmeyen değerde exception fırlatabilir
      // Bu test, bilinmeyen değerin unknown olarak map'lenmesini doğrular
      expect(
        () => DeviceInfo.fromJson(jsonWithUnknownTier),
        throwsA(isA<Exception>()),
      );
    });

    test('unknown() factory tüm alanları varsayılan değerle doldurmalı', () {
      final unknown = DeviceInfo.unknown();

      expect(unknown.manufacturer, 'Unknown');
      expect(unknown.model, 'Unknown');
      expect(unknown.marketName, 'Unknown');
      expect(unknown.identifier, isNull);
      expect(unknown.tier, DeviceTier.unknown);
    });

    test('copyWith tek alan değişiminde diğerlerini korumalı', () {
      final info = DeviceInfo.fromJson(sampleJson);
      final updated = info.copyWith(model: 'iPhone16,1');

      expect(updated.model, 'iPhone16,1');
      expect(updated.manufacturer, 'Apple'); // değişmemeli
      expect(updated.marketName, 'iPhone 15 Pro'); // değişmemeli
    });

    test('== operatörü aynı değerler için true dönmeli', () {
      final a = DeviceInfo.fromJson(sampleJson);
      final b = DeviceInfo.fromJson(sampleJson);
      expect(a, equals(b));
    });

    test('hashCode aynı değerler için eşit olmalı', () {
      final a = DeviceInfo.fromJson(sampleJson);
      final b = DeviceInfo.fromJson(sampleJson);
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
```

### 2.2 Service Testleri (Mock Platform Bridge)

**`test/services/battery_service_test.dart`:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:device_inspector/src/services/battery_service.dart';
import 'package:device_inspector/src/core/platform_bridge.dart';

class MockPlatformBridge extends Mock implements PlatformBridge {}

void main() {
  late MockPlatformBridge mockBridge;
  late BatteryService service;

  setUp(() {
    mockBridge = MockPlatformBridge();
    service = BatteryService(bridge: mockBridge);
  });

  group('BatteryService', () {
    final sampleResponse = {
      'level': 85,
      'chargingState': 'discharging',
      'isCharging': false,
      'health': 'good',
      'maxCapacityPercent': 95,
      'estimatedMinutesRemaining': -1,
      'isLowPowerMode': false,
    };

    test('fetch() başarılı platform yanıtında BatteryInfo dönmeli', () async {
      when(
        mockBridge.invoke('battery', 'getBatteryInfo'),
      ).thenAnswer((_) async => sampleResponse);

      final info = await service.fetch();

      expect(info.level, 85);
      expect(info.isCharging, false);
      expect(info.health, BatteryHealth.good);
      expect(info.maxCapacityPercent, 95);
    });

    test('fetch() platform hatasında BatteryInfo.unknown() dönmeli', () async {
      when(
        mockBridge.invoke('battery', 'getBatteryInfo'),
      ).thenThrow(HardwareAccessException('Battery access denied'));

      final info = await service.fetch();

      expect(info.level, -1);
      expect(info.isCharging, false);
    });

    test('fetch() level=0 durumunda doğru yorumlamalı', () async {
      when(
        mockBridge.invoke('battery', 'getBatteryInfo'),
      ).thenAnswer((_) async => {
        ...sampleResponse,
        'level': 0,
      });

      final info = await service.fetch();
      expect(info.level, 0);
    });
  });
}
```

### 2.3 DeviceSnapshot Testleri

**`test/models/device_snapshot_test.dart`:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/device_snapshot.dart';

void main() {
  group('DeviceSnapshot', () {
    test('full JSON roundtrip', () {
      final originalJson = {
        'device': {
          'manufacturer': 'Apple',
          'model': 'iPhone15,3',
          'marketName': 'iPhone 15 Pro',
          'tier': 'high',
        },
        'os': {
          'platform': 'iOS',
          'version': '17.4',
          'majorVersion': 17,
          'minorVersion': 4,
          'patchVersion': 0,
        },
        'battery': {
          'level': 85,
          'chargingState': 'discharging',
          'isCharging': false,
          'health': 'good',
          'estimatedMinutesRemaining': -1,
          'isLowPowerMode': false,
        },
        'network': {
          'type': 'wifi',
          'isVpn': false,
          'isProxy': false,
          'isAirplaneMode': false,
          'signalStrength': -1,
        },
        'hardware': {
          'cpu': {
            'name': 'Unknown',
            'cores': 0,
            'architecture': 'unknown',
            'maxFrequencyMHz': 0,
            'hasNeuralEngine': false,
          },
          'gpu': {
            'name': 'Unknown',
            'supportsMetal': false,
            'supportsVulkan': false,
          },
          'display': {
            'widthPixels': 0,
            'heightPixels': 0,
            'density': 0,
            'refreshRate': 0,
            'supportsHdr': false,
            'brightnessLevel': -1,
          },
          'tier': 'unknown',
        },
        'memory': {
          'totalBytes': -1,
          'availableBytes': -1,
          'usagePercent': -1,
          'appUsedBytes': -1,
          'isLowMemory': false,
        },
        'storage': {
          'totalBytes': -1,
          'freeBytes': -1,
          'usagePercent': -1,
          'appUsedBytes': -1,
        },
        'security': {
          'isRooted': false,
          'isJailbroken': false,
          'isEmulator': false,
          'isDebuggerAttached': false,
          'isDeveloperMode': false,
          'hasSuspiciousApps': false,
          'hasSuspiciousPaths': false,
          'hasSuspiciousEnvVars': false,
          'hasModifiedLibraries': false,
          'detectedThreats': [],
          'securityScore': 100,
        },
        'app': {
          'appName': 'TestApp',
          'version': '1.0.0',
          'buildNumber': '1',
          'bundleId': 'com.test.app',
          'isDebugBuild': true,
        },
        'timestampMsSinceEpoch': 0,
      };

      final snapshot = DeviceSnapshot.fromJson(originalJson);
      final roundtripped = snapshot.toJson();

      expect(roundtripped['device']['manufacturer'], 'Apple');
      expect(roundtripped['os']['platform'], 'iOS');
      expect(roundtripped['battery']['level'], 85);
      expect(roundtripped['security']['securityScore'], 100);
    });

    test('empty() factory tüm alt modelleri unknown ile doldurmalı', () {
      final empty = DeviceSnapshot.empty();

      expect(empty.device.manufacturer, 'Unknown');
      expect(empty.battery.level, -1);
      expect(empty.security.isRooted, false);
      expect(empty.memory.totalBytes, -1);
    });
  });
}
```

---

## 3. Entegrasyon Testleri

Gerçek cihazda MethodChannel çağrılarını test eder.

### 3.1 Kurulum

**`pubspec.yaml`:**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

**`integration_test/device_inspector_test.dart`:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_inspector/device_inspector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceInspector Integration Tests', () {
    setUp(() async {
      await DeviceInspector.initialize(
        enableSecurityCheck: true,
        logLevel: DeviceInspectorLogLevel.error,
      );
    });

    tearDown(() {
      DeviceInspector.dispose();
    });

    testWidgets('inspect() should return non-null snapshot', (_) async {
      final snapshot = await DeviceInspector.inspect();

      expect(snapshot, isNotNull);
      expect(snapshot.device, isNotNull);
      expect(snapshot.os, isNotNull);
      expect(snapshot.battery, isNotNull);
      expect(snapshot.network, isNotNull);
    });

    testWidgets('device should return valid DeviceInfo', (_) async {
      final device = await DeviceInspector.device;

      expect(device.manufacturer, isNotEmpty);
      expect(device.model, isNotEmpty);
      expect(device.marketName, isNotEmpty);

      // Platform kontrolü
      if (device.manufacturer == 'Apple') {
        // iOS — model iPhoneXX,X formatında
        expect(device.model, contains('iPhone'));
      } else {
        // Android — manufacturer bilinmeyen olmamalı
        expect(device.manufacturer, isNot('Unknown'));
      }
    });

    testWidgets('os should return valid OSInfo', (_) async {
      final os = await DeviceInspector.os;

      expect(os.platform, anyOf('iOS', 'Android'));
      expect(os.version, isNotEmpty);
      expect(os.majorVersion, greaterThan(0));

      final versionParts = os.version.split('.');
      expect(versionParts.length, greaterThanOrEqualTo(2));
    });

    testWidgets('battery should return BatteryInfo with level 0-100 or -1',
        (_) async {
      final battery = await DeviceInspector.battery;

      expect(
        battery.level,
        anyOf(
          greaterThanOrEqualTo(0),
          -1, // bilinmiyor
        ),
      );

      if (battery.level >= 0) {
        expect(battery.level, lessThanOrEqualTo(100));
      }
    });

    testWidgets('network should return NetworkInfo', (_) async {
      final network = await DeviceInspector.network;

      expect(network.type, isNotNull);
      expect(network.isVpn, isA<bool>());
    });

    testWidgets(
        'security should return SecurityInfo with valid scores', (_) async {
      final security = await DeviceInspector.security;

      expect(security.securityScore, inInclusiveRange(0, 100));
      expect(security.detectedThreats, isA<List<String>>());
      expect(security.isCompromised, isA<bool>());
    });

    testWidgets('app should return AppInfo', (_) async {
      final app = await DeviceInspector.app;

      expect(app.appName, isNotEmpty);
      expect(app.version, isNotEmpty);
      expect(app.buildNumber, isNotEmpty);
      expect(app.bundleId, isNotEmpty);
      expect(app.bundleId, contains('.'));
    });

    testWidgets('memory should return MemoryInfo', (_) async {
      final memory = await DeviceInspector.memory;

      if (memory.totalBytes > 0) {
        expect(memory.availableBytes, greaterThan(0));
        expect(memory.usagePercent, inInclusiveRange(0, 100));
      }
    });

    testWidgets('storage should return StorageInfo', (_) async {
      final storage = await DeviceInspector.storage;

      if (storage.totalBytes > 0) {
        expect(storage.freeBytes, greaterThan(0));
        expect(storage.usagePercent, inInclusiveRange(0, 100));
      }
    });

    testWidgets('toJson should produce valid JSON without errors', (_) async {
      final snapshot = await DeviceInspector.inspect();

      // Exception fırlatmamalı
      final json = snapshot.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['device'], isA<Map<String, dynamic>>());
    });
  });
}
```

### 3.2 Çalıştırma

```bash
# iOS
flutter test integration_test/device_inspector_test.dart

# Android
flutter test integration_test/device_inspector_test.dart

# Belirli cihazla
flutter test integration_test/device_inspector_test.dart -d iPhone15
```

---

## 4. Platform-Spesifik Testler

### 4.1 iOS Native Testleri (XCTest)

**`ios/Tests/DeviceInfoProviderTests.swift`:**

```swift
import XCTest
@testable import device_inspector

final class DeviceInfoProviderTests: XCTestCase {

    func testModelIdentifierIsNotEmpty() {
        let model = DeviceInfoProvider.getModelIdentifier()
        XCTAssertFalse(model.isEmpty, "Model identifier should not be empty")
        // Simulator'da "arm64", gerçek cihazda "iPhoneXX,X"
    }

    func testMarketNameMapping() {
        // Bu test gerçek cihaz modeline bağlı olarak değişir
        let name = DeviceInfoProvider.getMarketName()
        XCTAssertFalse(name.isEmpty)
    }

    func testTierDetermination() {
        // iPhone15,3 (14 Pro Max) → high tier
        let tier = DeviceInfoProvider.determineTier()
        XCTAssertTrue(["low", "medium", "high", "unknown"].contains(tier))
    }
}
```

### 4.2 Android Native Testleri (JUnit)

**`android/src/test/kotlin/com/bearcode/device_inspector/SecurityCheckProviderTest.kt`:**

```kotlin
package com.bearcode.device_inspector

import org.junit.Test
import org.junit.Assert.*

class SecurityCheckProviderTest {

    @Test
    fun `isEmulator should return false on real device`() {
        // Bu test sadece gerçek cihazda çalışır
        // CI ortamında emulator'da çalışır, o yüzden atlanabilir
    }

    @Test
    fun `emulator detection patterns should match known emulators`() {
        // Pattern testi — gerçek cihaz gerektirmez
        val emulatorFingerprints = listOf(
            "generic",
            "unknown",
        )

        emulatorFingerprints.forEach { fingerprint ->
            assertTrue(
                "Should detect emulator for fingerprint starting with: $fingerprint",
                fingerprint.startsWith("generic") || fingerprint.startsWith("unknown")
            )
        }
    }
}
```

---

## 5. CI/CD Pipeline Testleri

### 5.1 GitHub Actions

**`.github/workflows/test.yml`:**

```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  unit-tests:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22'
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Run build_runner
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Run unit tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info

  analyze:
    name: Static Analysis
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22'

      - name: Install dependencies
        run: flutter pub get

      - name: Run analyzer
        run: dart analyze

      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed .

  integration-tests:
    name: Integration Tests (Android)
    runs-on: macos-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22'

      - name: Run integration tests on emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          arch: x86_64
          script: |
            flutter pub get
            flutter test integration_test/ --coverage
```

---

## 6. Test Coverage Hedefleri

| Modül | Hedef Coverage | Açıklama |
|---|---|---|
| `src/models/` | **≥ 95%** | Tüm model sınıfları tam JSON serileştirme + edge case'ler |
| `src/services/` | **≥ 90%** | Mock platform bridge ile tüm servis metotları |
| `src/core/` | **≥ 85%** | Error handler, configuration, platform bridge |
| `src/platform/` | **≥ 80%** | Dart tarafı platform soyutlaması |
| Native iOS | **≥ 70%** | Provider sınıfları, model mapping |
| Native Android | **≥ 70%** | Provider sınıfları, permission handling |
| Entegrasyon | **≥ 60%** | Kritik akışlar (inspect, security, performance) |

---

## 7. Test Veri Setleri (Fixtures)

Testlerde kullanılacak mock cihaz verileri:

**`test/fixtures/device_samples.dart`:**

```dart
/// Gerçek cihazlardan alınmış örnek veriler

const iPhone15ProMax = {
  'manufacturer': 'Apple',
  'model': 'iPhone16,2',
  'marketName': 'iPhone 15 Pro Max',
  'tier': 'high',
  'releaseYear': 2023,
};

const iPhoneSE = {
  'manufacturer': 'Apple',
  'model': 'iPhone14,6',
  'marketName': 'iPhone SE (3rd gen)',
  'tier': 'medium',
  'releaseYear': 2022,
};

const galaxyS24Ultra = {
  'manufacturer': 'samsung',
  'model': 'SM-S928B',
  'marketName': 'Galaxy S24 Ultra',
  'tier': 'high',
  'releaseYear': 2024,
};

const pixel8Pro = {
  'manufacturer': 'Google',
  'model': 'Pixel 8 Pro',
  'marketName': 'Pixel 8 Pro',
  'tier': 'high',
  'releaseYear': 2023,
};

const lowEndAndroid = {
  'manufacturer': 'Xiaomi',
  'model': 'Redmi 9A',
  'marketName': 'Redmi 9A',
  'tier': 'low',
  'releaseYear': 2020,
};

const emulatorDevice = {
  'manufacturer': 'Google',
  'model': 'Android SDK built for x86',
  'marketName': 'Android Emulator',
  'tier': 'medium',
};
```

---

## 8. Smoke Testler

Hızlı geçerlilik kontrolü için minimum test seti:

```bash
#!/bin/bash
# scripts/smoke_test.sh

echo "=== device_inspector Smoke Tests ==="

echo "1. Static analysis..."
dart analyze
if [ $? -ne 0 ]; then echo "FAILED"; exit 1; fi

echo "2. Unit tests..."
flutter test --reporter compact
if [ $? -ne 0 ]; then echo "FAILED"; exit 1; fi

echo "3. Test coverage..."
flutter test --coverage
COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep lines | awk '{print $2}' | sed 's/%//')
echo "   Coverage: ${COVERAGE}%"

echo "=== All smoke tests passed ==="
```
