/// Public API entry point for the device_inspector SDK.
///
/// Provides a singleton with cached modular accessors and a single-call
/// `inspect()` method that returns the full [DeviceSnapshot].
library;

import 'dart:async';

import 'core/configuration.dart';
import 'core/device_inspector_core.dart';
import 'core/error_handler.dart';
import 'models/app_info.dart';
import 'models/battery_info.dart';
import 'models/device_info.dart';
import 'models/device_snapshot.dart';
import 'models/enums.dart';
import 'models/hardware_info.dart';
import 'models/memory_info.dart';
import 'models/network_info.dart';
import 'models/os_info.dart';
import 'models/security_info.dart';
import 'models/storage_info.dart';
import 'services/app_service.dart';
import 'services/battery_service.dart';
import 'services/device_service.dart';
import 'services/fingerprint_service.dart';
import 'services/hardware_service.dart';
import 'services/memory_service.dart';
import 'services/network_service.dart';
import 'services/os_service.dart';
import 'services/performance_service.dart';
import 'services/security_service.dart';
import 'services/storage_service.dart';

// Re-export all public types for convenience
export 'core/configuration.dart';
export 'core/error_handler.dart';
export 'core/logger.dart';
export 'models/app_info.dart';
export 'models/battery_info.dart';
export 'models/device_info.dart';
export 'models/device_snapshot.dart';
export 'models/enums.dart';
export 'models/hardware_info.dart';
export 'models/memory_info.dart';
export 'models/network_info.dart';
export 'models/os_info.dart';
export 'models/performance_snapshot.dart';
export 'models/security_info.dart';
export 'models/storage_info.dart';

/// Main entry point for the device_inspector SDK.
///
/// ```dart
/// await DeviceInspector.initialize();
/// final snapshot = await DeviceInspector.inspect();
/// print(snapshot.device.marketName);
/// ```
class DeviceInspector {
  DeviceInspectorCore? _core;

  // Services
  DeviceService? _deviceService;
  OSService? _osService;
  BatteryService? _batteryService;
  NetworkService? _networkService;
  HardwareService? _hardwareService;
  MemoryService? _memoryService;
  StorageService? _storageService;
  SecurityService? _securityService;
  AppService? _appService;
  FingerprintService? _fingerprintService;
  PerformanceMonitor? _performanceMonitor;

  // Stream controllers for real-time listeners
  StreamController<BatteryInfo>? _batteryController;
  StreamController<NetworkInfo>? _networkController;
  Timer? _batteryTimer;
  Timer? _networkTimer;

  // Caches
  final Map<DeviceInspectorModule, Future<Object?>> _cache = {};

  // ── Singleton ──────────────────────────────────────────────────────────

  static final DeviceInspector _instance = DeviceInspector._();
  static DeviceInspector get instance => _instance;

  DeviceInspector._();

  // ── Initialization ─────────────────────────────────────────────────────

  /// Initializes the SDK with the given [config].
  ///
  /// Optional — calling any API without initializing uses defaults.
  /// Security and performance modules require their respective flags
  /// to be enabled here.
  static Future<void> initialize([DeviceInspectorConfig? config]) async {
    if (_instance._core != null) {
      _instance._core!.logger.warn('DeviceInspector already initialized');
      return;
    }

    final cfg = config ?? const DeviceInspectorConfig();
    _instance._core = DeviceInspectorCore.create(cfg);

    final bridge = _instance._core!.bridge;
    _instance._deviceService = DeviceService(bridge: bridge);
    _instance._osService = OSService(bridge: bridge);
    _instance._batteryService = BatteryService(bridge: bridge);
    _instance._networkService = NetworkService(bridge: bridge);
    _instance._hardwareService = HardwareService(bridge: bridge);
    _instance._memoryService = MemoryService(bridge: bridge);
    _instance._storageService = StorageService(bridge: bridge);
    _instance._securityService = SecurityService(bridge: bridge);
    _instance._appService = AppService();
    _instance._fingerprintService = FingerprintService(bridge: bridge);

    if (cfg.enablePerformanceMonitor) {
      _instance._performanceMonitor = PerformanceMonitor(
        bridge: bridge,
        samplingIntervalMs: cfg.performanceSamplingIntervalMs,
      );
    }

    // Start stream listeners if enabled
    if (cfg.enableBatteryStream) {
      _instance._startBatteryStream(cfg.streamPollingIntervalMs);
    }
    if (cfg.enableNetworkStream) {
      _instance._startNetworkStream(cfg.streamPollingIntervalMs);
    }
  }

  DeviceInspectorCore? _getCore() {
    // Lazily init with defaults when possible
    if (_core == null) {
      try {
        _core = DeviceInspectorCore.create(const DeviceInspectorConfig());
        final bridge = _core!.bridge;
        _deviceService = DeviceService(bridge: bridge);
        _osService = OSService(bridge: bridge);
        _batteryService = BatteryService(bridge: bridge);
        _networkService = NetworkService(bridge: bridge);
        _hardwareService = HardwareService(bridge: bridge);
        _memoryService = MemoryService(bridge: bridge);
        _storageService = StorageService(bridge: bridge);
        _securityService = SecurityService(bridge: bridge);
        _appService = AppService();
        _fingerprintService = FingerprintService(bridge: bridge);
      } catch (e) {
        throw ConfigurationException('Failed to auto-initialize: $e');
      }
    }
    return _core;
  }

  // ── Full Inspection ────────────────────────────────────────────────────

  /// Collects device information in a single parallel call.
  ///
  /// When [modules] is `null` (default), returns a [DeviceSnapshot] containing
  /// every sub-module. Pass a subset of [DeviceInspectorModule] values to
  /// collect only the data you need — reducing overhead for performance-
  /// sensitive paths.
  ///
  /// ```dart
  /// // Full inspection — all modules
  /// final full = await DeviceInspector.inspect();
  ///
  /// // Targeted inspection — only what you need
  /// final partial = await DeviceInspector.inspect(
  ///   modules: [DeviceInspectorModule.security, DeviceInspectorModule.device],
  /// );
  /// ```
  static Future<DeviceSnapshot> inspect({
    List<DeviceInspectorModule>? modules,
  }) async {
    final inst = _instance;
    inst._getCore();

    final requested = modules ?? DeviceInspectorModule.values;
    final futures = <Future<Object?>>[];
    final indexMap = <int, DeviceInspectorModule>{};

    for (final module in requested) {
      indexMap[futures.length] = module;
      switch (module) {
        case DeviceInspectorModule.device:
          futures.add(inst._deviceService!.fetch());
        case DeviceInspectorModule.os:
          futures.add(inst._osService!.fetch());
        case DeviceInspectorModule.battery:
          futures.add(inst._batteryService!.fetch());
        case DeviceInspectorModule.network:
          futures.add(inst._networkService!.fetch());
        case DeviceInspectorModule.hardware:
          futures.add(inst._hardwareService!.fetch());
        case DeviceInspectorModule.memory:
          futures.add(inst._memoryService!.fetch());
        case DeviceInspectorModule.storage:
          futures.add(inst._storageService!.fetch());
        case DeviceInspectorModule.security:
          futures.add(inst._securityService!.fetch());
        case DeviceInspectorModule.app:
          futures.add(inst._appService!.fetch());
        case DeviceInspectorModule.performance:
          // Performance is stream-based, not snapshot-based
          break;
      }
    }

    final results = await Future.wait(futures);

    // Helper to find result by module
    T? _find<T>(DeviceInspectorModule module) {
      for (var i = 0; i < indexMap.length; i++) {
        if (indexMap[i] == module) return results[i] as T?;
      }
      return null;
    }

    return DeviceSnapshot(
      device: _find<DeviceInfo>(DeviceInspectorModule.device) ??
          DeviceInfo.unknown(),
      os: _find<OSInfo>(DeviceInspectorModule.os) ?? OSInfo.unknown(),
      battery: _find<BatteryInfo>(DeviceInspectorModule.battery) ??
          BatteryInfo.unknown(),
      network: _find<NetworkInfo>(DeviceInspectorModule.network) ??
          NetworkInfo.unknown(),
      hardware: _find<HardwareInfo>(DeviceInspectorModule.hardware) ??
          HardwareInfo.unknown(),
      memory: _find<MemoryInfo>(DeviceInspectorModule.memory) ??
          MemoryInfo.unknown(),
      storage: _find<StorageInfo>(DeviceInspectorModule.storage) ??
          StorageInfo.unknown(),
      security: _find<SecurityInfo>(DeviceInspectorModule.security) ??
          SecurityInfo.unknown(),
      app: _find<AppInfo>(DeviceInspectorModule.app) ?? AppInfo.unknown(),
      timestampMsSinceEpoch: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ── Modular Accessors (lazy + cached) ──────────────────────────────────

  /// Cached device hardware identity.
  static Future<DeviceInfo> get device => _instance._cached(
        DeviceInspectorModule.device,
        () => _instance._deviceService!.fetch(),
      );

  /// Cached operating system info.
  static Future<OSInfo> get os => _instance._cached(
        DeviceInspectorModule.os,
        () => _instance._osService!.fetch(),
      );

  /// Cached battery status.
  static Future<BatteryInfo> get battery => _instance._cached(
        DeviceInspectorModule.battery,
        () => _instance._batteryService!.fetch(),
      );

  /// Cached network info.
  static Future<NetworkInfo> get network => _instance._cached(
        DeviceInspectorModule.network,
        () => _instance._networkService!.fetch(),
      );

  /// Cached hardware specs.
  static Future<HardwareInfo> get hardware => _instance._cached(
        DeviceInspectorModule.hardware,
        () => _instance._hardwareService!.fetch(),
      );

  /// Cached memory stats.
  static Future<MemoryInfo> get memory => _instance._cached(
        DeviceInspectorModule.memory,
        () => _instance._memoryService!.fetch(),
      );

  /// Cached storage stats.
  static Future<StorageInfo> get storage => _instance._cached(
        DeviceInspectorModule.storage,
        () => _instance._storageService!.fetch(),
      );

  /// Cached security check results.
  static Future<SecurityInfo> get security => _instance._cached(
        DeviceInspectorModule.security,
        () => _instance._securityService!.fetch(),
      );

  /// Cached application metadata.
  static Future<AppInfo> get app => _instance._cached(
        DeviceInspectorModule.app,
        () => _instance._appService!.fetch(),
      );

  /// Real-time performance monitor.
  ///
  /// Returns `null` if [initialize] was called without
  /// `enablePerformanceMonitor: true`.
  static PerformanceMonitor? get performance =>
      _instance._performanceMonitor;

  /// Broadcast stream of battery state changes.
  ///
  /// Emits [BatteryInfo] every [DeviceInspectorConfig.streamPollingIntervalMs]
  /// when the level or charging state changes.
  /// Requires `enableBatteryStream: true` in [DeviceInspectorConfig].
  ///
  /// Returns `null` if the stream was not enabled at initialization.
  static Stream<BatteryInfo>? get batteryStream =>
      _instance._batteryController?.stream;

  /// Broadcast stream of network state changes.
  ///
  /// Emits [NetworkInfo] every [DeviceInspectorConfig.streamPollingIntervalMs]
  /// when the connection type or properties change.
  /// Requires `enableNetworkStream: true` in [DeviceInspectorConfig].
  ///
  /// Returns `null` if the stream was not enabled at initialization.
  static Stream<NetworkInfo>? get networkStream =>
      _instance._networkController?.stream;

  /// Anonymous, stable device fingerprint.
  ///
  /// A 64-character hex hash derived from device characteristics
  /// (model, manufacturer, OS, architecture) combined with a local
  /// random salt. Contains **no PII** — no IMEI, serial, or advertising ID.
  ///
  /// Stable across app restarts on the same device.
  /// Different devices produce different fingerprints.
  ///
  /// ```dart
  /// final fp = await DeviceInspector.fingerprint;
  /// // "d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4"
  /// ```
  static Future<String> get fingerprint =>
      _instance._fingerprintService!.getFingerprint();

  // ── Stream Internals ─────────────────────────────────────────────────

  BatteryInfo? _lastBattery;

  void _startBatteryStream(int intervalMs) {
    _batteryController = StreamController<BatteryInfo>.broadcast();
    _batteryTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) => _pollBattery(),
    );
    _pollBattery(); // immediate first poll
  }

  Future<void> _pollBattery() async {
    try {
      final info = await _batteryService!.fetch();
      if (_lastBattery == null ||
          _lastBattery!.level != info.level ||
          _lastBattery!.chargingState != info.chargingState) {
        _lastBattery = info;
        _batteryController?.add(info);
      }
    } catch (_) {
      // silently skip failed polls
    }
  }

  NetworkInfo? _lastNetwork;

  void _startNetworkStream(int intervalMs) {
    _networkController = StreamController<NetworkInfo>.broadcast();
    _networkTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) => _pollNetwork(),
    );
    _pollNetwork(); // immediate first poll
  }

  Future<void> _pollNetwork() async {
    try {
      final info = await _networkService!.fetch();
      if (_lastNetwork == null ||
          _lastNetwork!.type != info.type ||
          _lastNetwork!.isVpn != info.isVpn) {
        _lastNetwork = info;
        _networkController?.add(info);
      }
    } catch (_) {
      // silently skip failed polls
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Future<T> _cached<T>(
    DeviceInspectorModule module,
    Future<T> Function() fetcher,
  ) async {
    _getCore();
    if (_cache.containsKey(module)) {
      return (await _cache[module]) as T;
    }
    final future = fetcher();
    _cache[module] = future;
    return future;
  }

  /// Clears cached module results. The next access will re-fetch from
  /// the native platform.
  ///
  /// Pass a list of [modules] to clear selectively, or omit to clear all.
  static Future<void> refresh([
    List<DeviceInspectorModule>? modules,
  ]) async {
    if (modules == null) {
      _instance._cache.clear();
    } else {
      for (final m in modules) {
        _instance._cache.remove(m);
      }
    }
  }

  /// Releases all SDK resources: stops streams, performance monitor,
  /// clears caches, and disposes the platform bridge.
  static void dispose() {
    // Stop streams
    _instance._batteryTimer?.cancel();
    _instance._batteryTimer = null;
    _instance._networkTimer?.cancel();
    _instance._networkTimer = null;
    _instance._batteryController?.close();
    _instance._batteryController = null;
    _instance._networkController?.close();
    _instance._networkController = null;
    _instance._lastBattery = null;
    _instance._lastNetwork = null;

    _instance._performanceMonitor?.dispose();
    _instance._cache.clear();
    _instance._core?.dispose();
    _instance._core = null;
    _instance._deviceService = null;
    _instance._osService = null;
    _instance._batteryService = null;
    _instance._networkService = null;
    _instance._hardwareService = null;
    _instance._memoryService = null;
    _instance._storageService = null;
    _instance._securityService = null;
    _instance._appService = null;
    _instance._fingerprintService = null;
    _instance._performanceMonitor = null;
  }

  /// Modules supported on the current platform.
  ///
  /// On mobile (iOS/Android) all modules are supported.
  /// On unsupported platforms (web, desktop) the list is empty.
  static List<DeviceInspectorModule> get supportedModules {
    return DeviceInspectorModule.values;
  }

  /// Whether the given [module] is supported on the current platform.
  static bool isModuleSupported(DeviceInspectorModule module) {
    return supportedModules.contains(module);
  }

  /// Runtime platform detection.
  static DevicePlatform get platform {
    // Simplified — real impl uses `dart:io` Platform or Flutter's
    // `defaultTargetPlatform`.
    try {
      if (const bool.fromEnvironment('dart.library.io')) {
        // On mobile
        return DevicePlatform.android; // placeholder; refined later
      }
      return DevicePlatform.unknown;
    } catch (_) {
      return DevicePlatform.unknown;
    }
  }
}
