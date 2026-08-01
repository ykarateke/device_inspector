/// Shared enum types used across the device_inspector data models.
library;

/// Platform type detected at runtime.
enum DevicePlatform { iOS, android, unknown }

/// Which SDK module to target.
enum DeviceInspectorModule {
  device,
  os,
  battery,
  network,
  hardware,
  memory,
  storage,
  security,
  app,
  performance,
}

/// Device performance classification.
enum DeviceTier {
  /// Entry-level / older devices.
  low,

  /// Mid-range devices.
  medium,

  /// Flagship / high-performance devices.
  high,

  /// Unable to determine.
  unknown,
}

/// Current battery health status.
enum BatteryHealth {
  unknown,

  /// Maximum capacity > 80% of design.
  good,

  /// Maximum capacity 60–80%.
  fair,

  /// Maximum capacity < 60%.
  poor,

  /// Service recommended (overheat, dead, over-voltage).
  service,
}

/// How the battery is currently being powered.
enum BatteryChargingState {
  /// Plugged in and actively charging.
  charging,

  /// Running on battery.
  discharging,

  /// 100% charged and still plugged in.
  full,

  /// Wireless charging (iOS 17+, Android API 29+).
  wirelessCharging,

  /// State unknown / not available.
  unknown,
}

/// Type of active network connection.
enum NetworkType {
  wifi,
  cellular,
  ethernet,
  vpn,
  offline,
  unknown,
}
