/// Core coordinator for the device_inspector SDK.
///
/// Owns the [PlatformBridge], [Logger], configuration, and service registry.
/// Instantiated once by [DeviceInspector] and shared across all services.
library;

import 'configuration.dart';
import 'logger.dart';
import 'platform_bridge.dart';

/// Internal singleton that wires together the core SDK components.
///
/// Not exposed publicly — [DeviceInspector] is the public API surface.
class DeviceInspectorCore {
  final DeviceInspectorConfig config;
  final Logger logger;
  final PlatformBridge bridge;

  bool _isDisposed = false;

  DeviceInspectorCore._({
    required this.config,
    required this.logger,
    required this.bridge,
  });

  /// Creates a [DeviceInspectorCore] from the given [config].
  ///
  /// Should be called once during [DeviceInspector.initialize].
  factory DeviceInspectorCore.create(DeviceInspectorConfig config) {
    final logger = Logger(config.logLevel);
    final bridge = PlatformBridge(logger: logger);

    logger.info('DeviceInspectorCore initialized');
    logger.debug(
      'Config: security=${config.enableSecurityCheck}, '
      'perf=${config.enablePerformanceMonitor}, '
      'interval=${config.performanceSamplingIntervalMs}ms',
    );

    return DeviceInspectorCore._(
      config: config,
      logger: logger,
      bridge: bridge,
    );
  }

  /// Whether [dispose] has been called.
  bool get isDisposed => _isDisposed;

  /// Releases all resources held by the core.
  ///
  /// After calling this, create a new [DeviceInspectorCore] via [create]
  /// to use the SDK again.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    bridge.dispose();
    logger.info('DeviceInspectorCore disposed');
  }
}
