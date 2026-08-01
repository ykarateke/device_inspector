/// Configuration for the device_inspector SDK.
///
/// Passed to [DeviceInspector.initialize].
library;

import 'logger.dart';

/// Holds all initialization-time configuration for the SDK.
class DeviceInspectorConfig {
  /// Whether to enable root/jailbreak/emulator detection.
  final bool enableSecurityCheck;

  /// Whether to enable real-time performance monitoring.
  final bool enablePerformanceMonitor;

  /// Interval between performance snapshots in milliseconds.
  final int performanceSamplingIntervalMs;

  /// Whether to enable the battery-level change stream.
  ///
  /// When enabled, [DeviceInspector.batteryStream] emits [BatteryInfo]
  /// at [streamPollingIntervalMs] intervals.
  final bool enableBatteryStream;

  /// Whether to enable the network-state change stream.
  ///
  /// When enabled, [DeviceInspector.networkStream] emits [NetworkInfo]
  /// at [streamPollingIntervalMs] intervals.
  final bool enableNetworkStream;

  /// Polling interval for battery and network streams in milliseconds.
  ///
  /// Minimum value is 500ms. Default is 3000ms (3 seconds).
  final int streamPollingIntervalMs;

  /// SDK internal logging verbosity.
  final DeviceInspectorLogLevel logLevel;

  const DeviceInspectorConfig({
    this.enableSecurityCheck = false,
    this.enablePerformanceMonitor = false,
    this.performanceSamplingIntervalMs = 1000,
    this.enableBatteryStream = false,
    this.enableNetworkStream = false,
    this.streamPollingIntervalMs = 3000,
    this.logLevel = DeviceInspectorLogLevel.off,
  }) : assert(
          performanceSamplingIntervalMs >= 200,
          'performanceSamplingIntervalMs must be >= 200ms',
        ),
        assert(
          streamPollingIntervalMs >= 500,
          'streamPollingIntervalMs must be >= 500ms',
        );

  /// Minimal config: all optional features disabled.
  static const minimal = DeviceInspectorConfig();

  /// Debug config: security, performance, and streams enabled.
  static const debug = DeviceInspectorConfig(
    enableSecurityCheck: true,
    enablePerformanceMonitor: true,
    performanceSamplingIntervalMs: 500,
    enableBatteryStream: true,
    enableNetworkStream: true,
    streamPollingIntervalMs: 1000,
    logLevel: DeviceInspectorLogLevel.debug,
  );
}
