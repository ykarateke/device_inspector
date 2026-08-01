import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/memory_info.dart';

void main() {
  group('MemoryInfo', () {
    final sampleJson = {
      'totalBytes': 8589934592, 'availableBytes': 3435973836,
      'usagePercent': 60.0, 'appUsedBytes': 524288000, 'isLowMemory': false,
    };

    test('fromJson -> toJson roundtrip', () {
      final info = MemoryInfo.fromJson(sampleJson);
      final json = info.toJson();
      expect(json['totalBytes'], 8589934592);
      expect(json['usagePercent'], 60.0);
      expect(json['isLowMemory'], false);
    });

    test('unknown() returns safe defaults', () {
      final info = MemoryInfo.unknown();
      expect(info.totalBytes, -1);
      expect(info.availableBytes, -1);
      expect(info.usagePercent, -1);
    });

    test('formattedTotal returns N/A for unknown', () {
      expect(MemoryInfo.unknown().formattedTotal, 'N/A');
    });

    test('formattedTotal formats GB correctly', () {
      final info = MemoryInfo(totalBytes: 8589934592, availableBytes: 3435973836, usagePercent: 60.0);
      expect(info.formattedTotal, contains('GB'));
    });

    test('formattedTotal handles KB range', () {
      final info = MemoryInfo(totalBytes: 512000, availableBytes: 256000, usagePercent: 50.0);
      expect(info.formattedTotal, contains('KB'));
    });

    test('isLowMemory flag is preserved', () {
      final info = MemoryInfo(totalBytes: 8589934592, availableBytes: 500000000, usagePercent: 94.2, isLowMemory: true);
      expect(info.isLowMemory, true);
    });

    test('copyWith modifies single field', () {
      final info = MemoryInfo.fromJson(sampleJson);
      final updated = info.copyWith(usagePercent: 75.0);
      expect(updated.usagePercent, 75.0);
      expect(updated.totalBytes, 8589934592);
    });
  });
}
