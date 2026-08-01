import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/network_info.dart';
import 'package:device_inspector/src/models/enums.dart';

void main() {
  group('NetworkInfo', () {
    final sampleJson = {
      'type': 'wifi', 'carrier': 'Turkcell', 'cellularGeneration': '4G',
      'isVpn': false, 'isProxy': false, 'isAirplaneMode': false,
      'wifiSsid': 'MyWiFi', 'signalStrength': 4, 'localIpAddress': '192.168.1.42',
    };

    test('fromJson -> toJson roundtrip', () {
      final info = NetworkInfo.fromJson(sampleJson);
      final json = info.toJson();
      expect(json['type'], 'wifi');
      expect(json['carrier'], 'Turkcell');
      expect(json['isVpn'], false);
      expect(json['signalStrength'], 4);
    });

    test('fromJson handles VPN active', () {
      final json = {'type': 'vpn', 'isVpn': true, 'isProxy': false, 'isAirplaneMode': false, 'signalStrength': -1};
      final info = NetworkInfo.fromJson(json);
      expect(info.type, NetworkType.vpn);
      expect(info.isVpn, true);
    });

    test('fromJson handles offline/airplane', () {
      final json = {'type': 'offline', 'isVpn': false, 'isProxy': false, 'isAirplaneMode': true, 'signalStrength': -1};
      final info = NetworkInfo.fromJson(json);
      expect(info.type, NetworkType.offline);
      expect(info.isAirplaneMode, true);
    });

    test('fromJson handles 5G cellular', () {
      final json = {'type': 'cellular', 'carrier': 'Vodafone', 'cellularGeneration': '5G',
        'isVpn': false, 'isProxy': false, 'isAirplaneMode': false, 'signalStrength': 5};
      final info = NetworkInfo.fromJson(json);
      expect(info.type, NetworkType.cellular);
      expect(info.carrier, 'Vodafone');
      expect(info.cellularGeneration, '5G');
    });

    test('unknown() returns safe defaults', () {
      final info = NetworkInfo.unknown();
      expect(info.type, NetworkType.unknown);
      expect(info.isVpn, false);
      expect(info.carrier, isNull);
    });

    test('copyWith updates single field', () {
      final info = NetworkInfo.fromJson(sampleJson);
      final updated = info.copyWith(carrier: 'T-Mobile');
      expect(updated.carrier, 'T-Mobile');
      expect(updated.type, NetworkType.wifi);
    });
  });
}
