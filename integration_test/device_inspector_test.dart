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

    testWidgets('inspect returns non-null snapshot', (_) async {
      final snapshot = await DeviceInspector.inspect();

      expect(snapshot, isNotNull);
      expect(snapshot.device, isNotNull);
      expect(snapshot.os, isNotNull);
      expect(snapshot.battery, isNotNull);
      expect(snapshot.network, isNotNull);
    });

    testWidgets('device returns valid DeviceInfo', (_) async {
      final device = await DeviceInspector.device;

      expect(device.manufacturer, isNotEmpty);
      expect(device.model, isNotEmpty);
      expect(device.marketName, isNotEmpty);
    });

    testWidgets('os returns valid OSInfo', (_) async {
      final os = await DeviceInspector.os;

      expect(os.platform, anyOf('iOS', 'Android'));
      expect(os.version, isNotEmpty);
      expect(os.majorVersion, greaterThan(0));
    });

    testWidgets('battery returns valid BatteryInfo', (_) async {
      final battery = await DeviceInspector.battery;

      if (battery.level >= 0) {
        expect(battery.level, lessThanOrEqualTo(100));
      }
    });

    testWidgets('network returns NetworkInfo', (_) async {
      final network = await DeviceInspector.network;

      expect(network.type, isNotNull);
      expect(network.isVpn, isA<bool>());
    });

    testWidgets('security returns SecurityInfo with valid scores', (_) async {
      final security = await DeviceInspector.security;

      expect(security.securityScore, inInclusiveRange(0, 100));
      expect(security.detectedThreats, isA<List<String>>());
      expect(security.isCompromised, isA<bool>());
    });

    testWidgets('app returns AppInfo', (_) async {
      final app = await DeviceInspector.app;

      expect(app.appName, isNotEmpty);
      expect(app.version, isNotEmpty);
      expect(app.buildNumber, isNotEmpty);
      expect(app.bundleId, isNotEmpty);
      expect(app.bundleId, contains('.'));
    });

    testWidgets('memory returns MemoryInfo', (_) async {
      final memory = await DeviceInspector.memory;

      if (memory.totalBytes > 0) {
        expect(memory.availableBytes, greaterThan(0));
        expect(memory.usagePercent, inInclusiveRange(0, 100));
      }
    });

    testWidgets('storage returns StorageInfo', (_) async {
      final storage = await DeviceInspector.storage;

      if (storage.totalBytes > 0) {
        expect(storage.freeBytes, greaterThan(0));
        expect(storage.usagePercent, inInclusiveRange(0, 100));
      }
    });

    testWidgets('toJson produces valid JSON without errors', (_) async {
      final snapshot = await DeviceInspector.inspect();
      final json = snapshot.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['device'], isA<Map<String, dynamic>>());
    });

    testWidgets('refresh clears cache and re-fetches', (_) async {
      await DeviceInspector.refresh();
      // Should not throw
      final device = await DeviceInspector.device;
      expect(device, isNotNull);
    });

    testWidgets('supportedModules returns all modules', (_) async {
      final modules = DeviceInspector.supportedModules;
      expect(modules, contains(DeviceInspectorModule.device));
      expect(modules, contains(DeviceInspectorModule.battery));
      expect(modules, contains(DeviceInspectorModule.security));
    });
  });
}
