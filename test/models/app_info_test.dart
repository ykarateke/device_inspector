import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/app_info.dart';

void main() {
  group('AppInfo', () {
    final sampleJson = {
      'appName': 'MyApp', 'version': '1.2.3', 'buildNumber': '42',
      'bundleId': 'com.example.app', 'installTimestampMs': 1700000000000,
      'firstLaunchTimestampMs': 1700000001000,
      'signatureHash': 'abc123def456', 'isDebugBuild': false,
    };

    test('fromJson -> toJson roundtrip', () {
      final info = AppInfo.fromJson(sampleJson);
      final json = info.toJson();
      expect(json['appName'], 'MyApp');
      expect(json['version'], '1.2.3');
      expect(json['bundleId'], 'com.example.app');
    });

    test('unknown() returns safe defaults', () {
      final info = AppInfo.unknown();
      expect(info.appName, 'Unknown');
      expect(info.version, '0.0.0');
      expect(info.buildNumber, '0');
      expect(info.bundleId, 'unknown');
    });

    test('nullable fields default to null', () {
      final json = {'appName': 'Test', 'version': '1.0.0', 'buildNumber': '1', 'bundleId': 'com.test'};
      final info = AppInfo.fromJson(json);
      expect(info.installTimestampMs, isNull);
      expect(info.signatureHash, isNull);
    });

    test('copyWith updates version', () {
      final info = AppInfo.fromJson(sampleJson);
      final updated = info.copyWith(version: '2.0.0', buildNumber: '99');
      expect(updated.version, '2.0.0');
      expect(updated.buildNumber, '99');
      expect(updated.appName, 'MyApp');
    });

    test('debug build flag', () {
      final info = AppInfo.fromJson({...sampleJson, 'isDebugBuild': true});
      expect(info.isDebugBuild, true);
    });
  });
}
