import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/performance_snapshot.dart';

void main() {
  group('PerformanceSnapshot', () {
    final sampleJson = {
      'fps': 58.0, 'cpuUsagePercent': 32.5, 'appCpuUsagePercent': 12.0,
      'memoryUsageMB': 430.0, 'memoryUsagePercent': 45.2,
      'thermalState': 'nominal', 'timestampMsSinceEpoch': 1700000000000,
      'batteryImpactLevel': 2,
    };

    test('fromJson -> toJson roundtrip', () {
      final info = PerformanceSnapshot.fromJson(sampleJson);
      final json = info.toJson();
      expect(json['fps'], 58.0);
      expect(json['cpuUsagePercent'], 32.5);
      expect(json['memoryUsageMB'], 430.0);
      expect(json['thermalState'], 'nominal');
    });

    test('empty() factory returns all zeros', () {
      final info = PerformanceSnapshot.empty();
      expect(info.fps, 0);
      expect(info.cpuUsagePercent, 0);
      expect(info.memoryUsageMB, 0);
    });

    test('thermal states: nominal, fair, serious, critical', () {
      for (final state in ['nominal', 'fair', 'serious', 'critical']) {
        final info = PerformanceSnapshot.fromJson({...sampleJson, 'thermalState': state});
        expect(info.thermalState, state);
      }
    });

    test('default thermalState is nominal', () {
      final json = {'fps': 60.0, 'cpuUsagePercent': 10.0, 'appCpuUsagePercent': 5.0,
        'memoryUsageMB': 200.0, 'memoryUsagePercent': 25.0,
        'timestampMsSinceEpoch': 1700000000000};
      final info = PerformanceSnapshot.fromJson(json);
      expect(info.thermalState, 'nominal');
      expect(info.batteryImpactLevel, -1);
    });

    test('copyWith creates new instance with overrides', () {
      final info = PerformanceSnapshot.fromJson(sampleJson);
      final updated = info.copyWith(fps: 30.0, cpuUsagePercent: 80.0);
      expect(updated.fps, 30.0);
      expect(updated.cpuUsagePercent, 80.0);
      expect(updated.memoryUsageMB, 430.0);
    });
  });
}
