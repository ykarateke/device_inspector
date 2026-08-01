/// Configuration for the device_inspector SDK.
///
/// Passed to [DeviceInspector.initialize].
library;

import 'logger.dart';

/// Holds all initialization-time configuration for the SDK.
class DeviceInspectorConfig {
  /// Whether to enable root/jailbreak/emulator detection.
  ///
  /// Defaults to `false` because security checks have a performance cost
  /// and may trigger false positives on some devices.
  final bool enableSecurityCheck;

  /// Whether to enable real-time performance monitoring.
  ///
  /// Defaults to `false` because continuous sampling uses CPU and battery.
  final bool enablePerformanceMonitor;

  /// Interval between performance snapshots in milliseconds.
  ///
  /// Minimum value is 200ms. Default is 1000ms (1 second).
  final int performanceSamplingIntervalMs;

  /// SDK internal logging verbosity.
  ///
  /// Should be [DeviceInspectorLogLevel.off] or [DeviceInspectorLogLevel.error]
  /// in production to avoid leaking device information.
  final DeviceInspectorLogLevel logLevel;

  const DeviceInspectorConfig({
    this.enableSecurityCheck = false,
    this.enablePerformanceMonitor = false,
    this.performanceSamplingIntervalMs = 1000,
    this.logLevel = DeviceInspectorLogLevel.off,
  }) : assert(
          performanceSamplingIntervalMs >= 200,
          'performanceSamplingIntervalMs must be >= 200ms',
        );

  /// Minimal config: all optional features disabled.
  static const minimal = DeviceInspectorConfig();

  /// Debug config: security checks and verbose logging enabled.
  static const debug = DeviceInspectorConfig(
    enableSecurityCheck: true,
    enablePerformanceMonitor: true,
    performanceSamplingIntervalMs: 500,
    logLevel: DeviceInspectorLogLevel.debug,
  );
}
