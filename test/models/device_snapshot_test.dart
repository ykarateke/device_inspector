import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/device_snapshot.dart';
import 'package:device_inspector/src/models/device_info.dart';
import 'package:device_inspector/src/models/os_info.dart';
import 'package:device_inspector/src/models/battery_info.dart';
import 'package:device_inspector/src/models/network_info.dart';
import 'package:device_inspector/src/models/hardware_info.dart';
import 'package:device_inspector/src/models/memory_info.dart';
import 'package:device_inspector/src/models/storage_info.dart';
import 'package:device_inspector/src/models/security_info.dart';
import 'package:device_inspector/src/models/app_info.dart';
void main() {
  group('DeviceSnapshot', () {
    test('fromJson constructs all sub-models correctly', () {
      final json = <String, dynamic>{
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
            'name': 'A17 Pro',
            'cores': 6,
            'architecture': 'arm64',
            'maxFrequencyMHz': 0,
            'hasNeuralEngine': true,
          },
          'gpu': {
            'name': 'Apple GPU',
            'supportsMetal': true,
            'supportsVulkan': false,
          },
          'display': {
            'widthPixels': 1179,
            'heightPixels': 2556,
            'density': 3.0,
            'refreshRate': 120,
            'supportsHdr': true,
            'brightnessLevel': 0.8,
          },
          'tier': 'high',
        },
        'memory': {
          'totalBytes': 8589934592,
          'availableBytes': 3200000000,
          'usagePercent': 62.7,
          'appUsedBytes': -1,
          'isLowMemory': false,
        },
        'storage': {
          'totalBytes': 274877906944,
          'freeBytes': 120000000000,
          'usagePercent': 56.3,
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
          'detectedThreats': <String>[],
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

      final snapshot = DeviceSnapshot.fromJson(json);

      expect(snapshot.device.marketName, 'iPhone 15 Pro');
      expect(snapshot.os.platform, 'iOS');
      expect(snapshot.battery.level, 85);
      expect(snapshot.hardware.cpu.name, 'A17 Pro');
      expect(snapshot.security.isRooted, false);
      expect(snapshot.security.securityScore, 100);
      expect(snapshot.app.bundleId, 'com.test.app');
    });

    test('toJson produces a complete map', () {
      final snapshot = DeviceSnapshot(
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

      final json = snapshot.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['device']['manufacturer'], 'Unknown');
    });

    test('empty() factory fills all sub-models with unknowns', () {
      final empty = DeviceSnapshot.empty();

      expect(empty.device.manufacturer, 'Unknown');
      expect(empty.os.platform, 'Unknown');
      expect(empty.battery.level, -1);
      expect(empty.security.isRooted, false);
    });

    test('memory formatted getters return N/A for negative values', () {
      final mem = MemoryInfo.unknown();
      expect(mem.formattedTotal, 'N/A');
      expect(mem.formattedAvailable, 'N/A');
    });
  });
}
