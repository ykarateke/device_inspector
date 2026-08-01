import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/core/platform_bridge.dart';
import 'package:device_inspector/src/core/logger.dart';
import 'package:device_inspector/src/services/device_service.dart';
import 'package:device_inspector/src/services/os_service.dart';
import 'package:device_inspector/src/services/battery_service.dart';
import 'package:device_inspector/src/services/network_service.dart';
import 'package:device_inspector/src/services/hardware_service.dart';
import 'package:device_inspector/src/services/memory_service.dart';
import 'package:device_inspector/src/services/storage_service.dart';
import 'package:device_inspector/src/services/security_service.dart';
import 'package:device_inspector/src/services/app_service.dart';
import 'package:device_inspector/src/models/enums.dart';
import 'package:flutter/services.dart';

/// A test double that simulates platform responses without real MethodChannels.
class FakePlatformBridge extends PlatformBridge {
  final Map<String, Map<String, dynamic>> _responses = {};
  final List<String> _calls = [];

  FakePlatformBridge() : super(logger: Logger(DeviceInspectorLogLevel.off));

  List<String> get calls => List.unmodifiable(_calls);

  void stub(String channel, String method, Map<String, dynamic> response) {
    _responses['$channel.$method'] = response;
  }

  @override
  Future<Map<String, dynamic>> invoke(
    String module,
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    _calls.add('$module.$method');
    final key = '$module.$method';
    if (_responses.containsKey(key)) return _responses[key]!;
    throw MissingPluginException('No stub for $key');
  }
}

void main() {
  late FakePlatformBridge bridge;

  setUp(() {
    bridge = FakePlatformBridge();
  });

  group('DeviceService', () {
    test('fetch returns DeviceInfo from platform response', () async {
      bridge.stub('device', 'getDeviceInfo', {
        'manufacturer': 'Apple',
        'model': 'iPhone16,1',
        'marketName': 'iPhone 15 Pro',
      });
      final service = DeviceService(bridge: bridge);
      final info = await service.fetch();
      expect(info.manufacturer, 'Apple');
      expect(info.marketName, 'iPhone 15 Pro');
      expect(bridge.calls, contains('device.getDeviceInfo'));
    });

    test('fetch returns unknown on error', () async {
      final service = DeviceService(bridge: bridge);
      final info = await service.fetch();
      expect(info.manufacturer, 'Unknown');
    });
  });

  group('OSService', () {
    test('fetch returns OSInfo from platform response', () async {
      bridge.stub('os', 'getOSInfo', {
        'platform': 'iOS',
        'version': '17.4',
        'majorVersion': 17,
        'minorVersion': 4,
      });
      final service = OSService(bridge: bridge);
      final info = await service.fetch();
      expect(info.platform, 'iOS');
      expect(info.version, '17.4');
    });
  });

  group('BatteryService', () {
    test('fetch returns BatteryInfo with charge data', () async {
      bridge.stub('battery', 'getBatteryInfo', {
        'level': 85,
        'chargingState': 'charging',
        'isCharging': true,
      });
      final service = BatteryService(bridge: bridge);
      final info = await service.fetch();
      expect(info.level, 85);
      expect(info.isCharging, true);
    });
  });

  group('NetworkService', () {
    test('fetch returns NetworkInfo for Wi-Fi', () async {
      bridge.stub('network', 'getNetworkInfo', {
        'type': 'wifi',
        'isVpn': false,
        'isProxy': false,
        'isAirplaneMode': false,
        'signalStrength': 3,
      });
      final service = NetworkService(bridge: bridge);
      final info = await service.fetch();
      expect(info.type, NetworkType.wifi);
      expect(info.signalStrength, 3);
    });
  });

  group('HardwareService', () {
    test('fetch returns HardwareInfo with CPU info', () async {
      bridge.stub('hardware', 'getHardwareInfo', {
        'cpu': {'name': 'A17 Pro', 'cores': 6, 'architecture': 'arm64'},
        'gpu': {'name': 'Apple GPU', 'supportsMetal': true, 'supportsVulkan': false},
        'display': {'widthPixels': 1179, 'heightPixels': 2556, 'density': 3.0},
      });
      final service = HardwareService(bridge: bridge);
      final info = await service.fetch();
      expect(info.cpu.name, 'A17 Pro');
      expect(info.cpu.cores, 6);
    });
  });

  group('MemoryService', () {
    test('fetch returns MemoryInfo with RAM data', () async {
      bridge.stub('memory', 'getMemoryInfo', {
        'totalBytes': 8589934592,
        'availableBytes': 3435973836,
        'usagePercent': 60.0,
      });
      final service = MemoryService(bridge: bridge);
      final info = await service.fetch();
      expect(info.totalBytes, 8589934592);
      expect(info.usagePercent, 60.0);
    });
  });

  group('StorageService', () {
    test('fetch returns StorageInfo', () async {
      bridge.stub('storage', 'getStorageInfo', {
        'totalBytes': 274877906944,
        'freeBytes': 120000000000,
        'usagePercent': 56.3,
      });
      final service = StorageService(bridge: bridge);
      final info = await service.fetch();
      expect(info.totalBytes, 274877906944);
      expect(info.usagePercent, 56.3);
    });
  });

  group('SecurityService', () {
    test('fetch returns SecurityInfo with clean result', () async {
      bridge.stub('security', 'getSecurityInfo', {
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
      });
      final service = SecurityService(bridge: bridge);
      final info = await service.fetch();
      expect(info.isRooted, false);
      expect(info.securityScore, 100);
      expect(info.isCompromised, false);
    });

    test('fetch detects compromised device', () async {
      bridge.stub('security', 'getSecurityInfo', {
        'isRooted': false,
        'isJailbroken': false,
        'isEmulator': false,
        'isDebuggerAttached': false,
        'isDeveloperMode': false,
        'hasSuspiciousApps': true,
        'hasSuspiciousPaths': false,
        'hasSuspiciousEnvVars': false,
        'hasModifiedLibraries': false,
        'detectedThreats': ['Magisk detected'],
        'securityScore': 70,
      });
      final service = SecurityService(bridge: bridge);
      final info = await service.fetch();
      expect(info.isCompromised, true);
      expect(info.detectedThreats, contains('Magisk detected'));
    });
  });

  group('AppService', () {
    test('fetch returns AppInfo stub', () async {
      final service = AppService();
      final info = await service.fetch();
      expect(info.appName, isNotEmpty);
      expect(info.bundleId, isNotEmpty);
    });
  });
}
