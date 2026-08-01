import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/device_inspector.dart';

void main() {
  group('DeviceInspector', () {
    tearDown(() {
      DeviceInspector.dispose();
    });

    test('supportedModules returns all modules', () {
      final modules = DeviceInspector.supportedModules;
      expect(modules.length, greaterThan(0));
      expect(modules.contains(DeviceInspectorModule.device), true);
      expect(modules.contains(DeviceInspectorModule.battery), true);
    });

    test('isModuleSupported returns true for all modules', () {
      for (final module in DeviceInspectorModule.values) {
        expect(DeviceInspector.isModuleSupported(module), true);
      }
    });

    test('dispose clears state without throwing', () {
      DeviceInspector.dispose();
      // Should not throw when called multiple times
      DeviceInspector.dispose();
    });
  });
}
