import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/os_info.dart';

void main() {
  group('OSInfo', () {
    final sampleJson = {
      'platform': 'iOS',
      'version': '17.4',
      'majorVersion': 17,
      'minorVersion': 4,
      'patchVersion': 0,
      'buildNumber': '21E236',
      'apiLevel': null,
      'kernelVersion': 'Darwin 23.4.0',
    };

    test('fromJson -> toJson roundtrip', () {
      final info = OSInfo.fromJson(sampleJson);
      final json = info.toJson();
      expect(json['platform'], 'iOS');
      expect(json['version'], '17.4');
      expect(json['majorVersion'], 17);
      expect(json['minorVersion'], 4);
      expect(json['buildNumber'], '21E236');
    });

    test('fromJson handles missing optional fields', () {
      final minimal = {
        'platform': 'Android',
        'version': '14.0',
        'majorVersion': 14,
        'minorVersion': 0,
      };
      final info = OSInfo.fromJson(minimal);
      expect(info.platform, 'Android');
      expect(info.patchVersion, 0);
      expect(info.buildNumber, isNull);
      expect(info.apiLevel, isNull);
    });

    test('unknown() returns safe defaults', () {
      final info = OSInfo.unknown();
      expect(info.platform, 'Unknown');
      expect(info.version, '0.0');
      expect(info.majorVersion, 0);
      expect(info.minorVersion, 0);
    });

    test('Android API level is preserved', () {
      final json = {...sampleJson, 'platform': 'Android', 'apiLevel': 34};
      final info = OSInfo.fromJson(json);
      expect(info.apiLevel, 34);
    });

    test('copyWith modifies only specified field', () {
      final info = OSInfo.fromJson(sampleJson);
      final updated = info.copyWith(version: '18.0', majorVersion: 18);
      expect(updated.version, '18.0');
      expect(updated.majorVersion, 18);
      expect(updated.platform, 'iOS');
    });

    test('equality: same fields produce equal objects', () {
      final a = OSInfo.fromJson(sampleJson);
      final b = OSInfo.fromJson(sampleJson);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
