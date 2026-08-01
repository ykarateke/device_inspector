import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/storage_info.dart';

void main() {
  group('StorageInfo', () {
    final sampleJson = {
      'totalBytes': 274877906944, 'freeBytes': 120000000000,
      'usagePercent': 56.3, 'appUsedBytes': 1048576000,
      'appDataPath': '/data/com.example.app',
      'appCachePath': '/data/com.example.app/cache',
    };

    test('fromJson -> toJson roundtrip', () {
      final info = StorageInfo.fromJson(sampleJson);
      final json = info.toJson();
      expect(json['totalBytes'], 274877906944);
      expect(json['freeBytes'], 120000000000);
      expect(json['usagePercent'], 56.3);
      expect(json['appDataPath'], '/data/com.example.app');
    });

    test('unknown() returns safe defaults', () {
      final info = StorageInfo.unknown();
      expect(info.totalBytes, -1);
      expect(info.freeBytes, -1);
      expect(info.usagePercent, -1);
      expect(info.appDataPath, isNull);
    });

    test('formattedTotal returns N/A for unknown', () {
      expect(StorageInfo.unknown().formattedTotal, 'N/A');
    });

    test('formattedFree returns N/A for unknown', () {
      expect(StorageInfo.unknown().formattedFree, 'N/A');
    });

    test('formattedTotal handles GB range', () {
      final info = StorageInfo(totalBytes: 274877906944, freeBytes: 120000000000, usagePercent: 56.3);
      expect(info.formattedTotal, contains('GB'));
    });

    test('formattedTotal handles MB range', () {
      final info = StorageInfo(totalBytes: 500 * 1024 * 1024, freeBytes: 200 * 1024 * 1024, usagePercent: 60.0);
      expect(info.formattedTotal, contains('MB'));
    });

    test('app path fields default to null', () {
      final info = StorageInfo(totalBytes: 1000000, freeBytes: 500000, usagePercent: 50.0);
      expect(info.appDataPath, isNull);
      expect(info.appCachePath, isNull);
    });
  });
}
