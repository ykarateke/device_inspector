import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/security_info.dart';

void main() {
  group('SecurityInfo', () {
    test('isCompromised: false when all indicators are clean', () {
      final info = SecurityInfo.unknown();
      expect(info.isCompromised, false);
    });

    test('isCompromised: true when isRooted', () {
      final info = SecurityInfo.unknown().copyWith(isRooted: true);
      expect(info.isCompromised, true);
    });

    test('isCompromised: true when isJailbroken', () {
      final info = SecurityInfo.unknown().copyWith(isJailbroken: true);
      expect(info.isCompromised, true);
    });

    test('isCompromised: true when isEmulator', () {
      final info = SecurityInfo.unknown().copyWith(isEmulator: true);
      expect(info.isCompromised, true);
    });

    test('isCompromised: true when hasSuspiciousApps', () {
      final info = SecurityInfo.unknown().copyWith(hasSuspiciousApps: true);
      expect(info.isCompromised, true);
    });

    test('detectedThreats is initialized as empty list', () {
      final info = SecurityInfo.unknown();
      expect(info.detectedThreats, isEmpty);
    });

    test('securityScore defaults to 100', () {
      final info = SecurityInfo.unknown();
      expect(info.securityScore, 100);
    });
  });
}
