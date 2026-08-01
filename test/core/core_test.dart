import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/core/error_handler.dart';
import 'package:device_inspector/src/core/configuration.dart';
import 'package:device_inspector/src/core/logger.dart';

void main() {
  group('DeviceInspectorException', () {
    test('toString includes code and message', () {
      final ex = DeviceInspectorException('test message', code: 'TEST');
      expect(ex.toString(), contains('TEST'));
      expect(ex.toString(), contains('test message'));
    });

    test('code defaults to null', () {
      final ex = DeviceInspectorException('no code');
      expect(ex.code, isNull);
    });
  });

  group('PlatformNotSupportedException', () {
    test('has correct default code', () {
      final ex = PlatformNotSupportedException('web not supported');
      expect(ex.code, 'PLATFORM_NOT_SUPPORTED');
    });
  });

  group('PermissionDeniedException', () {
    test('has correct default code', () {
      final ex = PermissionDeniedException('no battery permission');
      expect(ex.code, 'PERMISSION_DENIED');
    });
  });

  group('HardwareAccessException', () {
    test('has correct default code', () {
      final ex = HardwareAccessException('IOKit access denied');
      expect(ex.code, 'HARDWARE_ACCESS_DENIED');
    });
  });

  group('SecurityCheckException', () {
    test('has correct default code', () {
      final ex = SecurityCheckException('check failed');
      expect(ex.code, 'SECURITY_CHECK_FAILED');
    });
  });

  group('ConfigurationException', () {
    test('has correct default code', () {
      final ex = ConfigurationException('invalid interval');
      expect(ex.code, 'INVALID_CONFIGURATION');
    });
  });

  group('ErrorCodes', () {
    test('all codes are defined', () {
      expect(ErrorCodes.platformNotSupported, 'PLATFORM_NOT_SUPPORTED');
      expect(ErrorCodes.notInitialized, 'NOT_INITIALIZED');
      expect(ErrorCodes.permissionDenied, 'PERMISSION_DENIED');
      expect(ErrorCodes.hardwareAccessDenied, 'HARDWARE_ACCESS_DENIED');
      expect(ErrorCodes.securityCheckFailed, 'SECURITY_CHECK_FAILED');
      expect(ErrorCodes.invalidConfiguration, 'INVALID_CONFIGURATION');
      expect(ErrorCodes.nativeMethodNotFound, 'NATIVE_METHOD_NOT_FOUND');
      expect(ErrorCodes.unknown, 'UNKNOWN');
    });
  });

  group('DeviceInspectorConfig', () {
    test('default config has all features disabled', () {
      const config = DeviceInspectorConfig();
      expect(config.enableSecurityCheck, false);
      expect(config.enablePerformanceMonitor, false);
      expect(config.logLevel, DeviceInspectorLogLevel.off);
    });

    test('debug config enables security and perf', () {
      const config = DeviceInspectorConfig.debug;
      expect(config.enableSecurityCheck, true);
      expect(config.enablePerformanceMonitor, true);
      expect(config.logLevel, DeviceInspectorLogLevel.debug);
    });

    test('minimal config disables everything', () {
      const config = DeviceInspectorConfig.minimal;
      expect(config.enableSecurityCheck, false);
      expect(config.enablePerformanceMonitor, false);
      expect(config.logLevel, DeviceInspectorLogLevel.off);
    });

    test('assert fails for interval < 200ms', () {
      expect(
        () => DeviceInspectorConfig(performanceSamplingIntervalMs: 100),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts interval >= 200ms', () {
      final config = DeviceInspectorConfig(performanceSamplingIntervalMs: 200);
      expect(config.performanceSamplingIntervalMs, 200);
    });

    test('custom config allows security without perf', () {
      final config = DeviceInspectorConfig(enableSecurityCheck: true);
      expect(config.enableSecurityCheck, true);
      expect(config.enablePerformanceMonitor, false);
    });
  });

  group('Logger', () {
    test('log level off suppresses output', () {
      final logger = Logger(DeviceInspectorLogLevel.off);
      // Methods should not throw
      logger.error('should not print');
      logger.warn('should not print');
      logger.info('should not print');
      logger.debug('should not print');
      logger.verbose('should not print');
      expect(logger.level, DeviceInspectorLogLevel.off);
    });

    test('log level can be changed', () {
      final logger = Logger(DeviceInspectorLogLevel.off);
      logger.level = DeviceInspectorLogLevel.debug;
      expect(logger.level, DeviceInspectorLogLevel.debug);
    });

    test('error level allows errors', () {
      final logger = Logger(DeviceInspectorLogLevel.error);
      // These should not throw
      logger.error('error msg');
      logger.warn('should be suppressed');
    });
  });
}
