import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/device_info.dart';
import 'package:device_inspector/src/models/enums.dart';

void main() {
  group('DeviceInfo', () {
    final sampleJson = {
      'manufacturer': 'Apple',
      'model': 'iPhone15,3',
      'marketName': 'iPhone 15 Pro',
      'identifier': 'UUID-12345',
      'codename': 'iPhone15,3',
      'tier': 'high',
      'releaseYear': 2023,
    };

    test('fromJson -> toJson roundtrip is symmetric', () {
      final info = DeviceInfo.fromJson(sampleJson);
      final json = info.toJson();

      expect(json['manufacturer'], 'Apple');
      expect(json['model'], 'iPhone15,3');
      expect(json['marketName'], 'iPhone 15 Pro');
      expect(json['tier'], 'high');
      expect(json['releaseYear'], 2023);
    });

    test('fromJson handles missing nullable fields as null', () {
      final minimal = {
        'manufacturer': 'Apple',
        'model': 'iPhone15,3',
        'marketName': 'iPhone 15 Pro',
      };

      final info = DeviceInfo.fromJson(minimal);

      expect(info.identifier, isNull);
      expect(info.codename, isNull);
      expect(info.releaseYear, isNull);
      expect(info.tier, DeviceTier.unknown);
    });

    test('unknown() factory fills all fields with defaults', () {
      final unknown = DeviceInfo.unknown();

      expect(unknown.manufacturer, 'Unknown');
      expect(unknown.model, 'Unknown');
      expect(unknown.marketName, 'Unknown');
      expect(unknown.tier, DeviceTier.unknown);
    });

    test('copyWith changes only the specified field', () {
      final info = DeviceInfo.fromJson(sampleJson);
      final updated = info.copyWith(model: 'iPhone16,1');

      expect(updated.model, 'iPhone16,1');
      expect(updated.manufacturer, 'Apple');
    });

    test('equality: same values produce equal objects', () {
      final a = DeviceInfo.fromJson(sampleJson);
      final b = DeviceInfo.fromJson(sampleJson);
      expect(a, equals(b));
    });
  });
}
