import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/battery_info.dart';
import 'package:device_inspector/src/models/enums.dart';

void main() {
  group('BatteryInfo', () {
    final sampleJson = {
      'level': 85, 'chargingState': 'charging', 'isCharging': true,
      'health': 'good', 'maxCapacityPercent': 95,
      'estimatedMinutesRemaining': 120, 'isLowPowerMode': false,
    };

    test('fromJson -> toJson roundtrip', () {
      final info = BatteryInfo.fromJson(sampleJson);
      final json = info.toJson();
      expect(json['level'], 85);
      expect(json['chargingState'], 'charging');
      expect(json['isCharging'], true);
      expect(json['health'], 'good');
    });

    test('fromJson handles discharging state', () {
      final json = {'level': 42, 'chargingState': 'discharging', 'isCharging': false};
      final info = BatteryInfo.fromJson(json);
      expect(info.level, 42);
      expect(info.chargingState, BatteryChargingState.discharging);
      expect(info.isCharging, false);
    });

    test('unknown() returns safe defaults', () {
      final info = BatteryInfo.unknown();
      expect(info.level, -1);
      expect(info.isCharging, false);
      expect(info.chargingState, BatteryChargingState.unknown);
    });

    test('wireless charging state is parsed correctly', () {
      final json = {'level': 88, 'chargingState': 'wirelessCharging', 'isCharging': true};
      final info = BatteryInfo.fromJson(json);
      expect(info.chargingState, BatteryChargingState.wirelessCharging);
    });

    test('copyWith preserves other fields', () {
      final info = BatteryInfo.fromJson(sampleJson);
      final updated = info.copyWith(level: 50, isCharging: false);
      expect(updated.level, 50);
      expect(updated.isCharging, false);
      expect(updated.health, BatteryHealth.good);
    });
  });
}
