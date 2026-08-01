/// Platform channel name constants for the device_inspector plugin.
///
/// All native communication uses the [MethodChannel] names defined here.
library;

/// Root channel prefix used by all module channels.
const String kChannelPrefix = 'com.bearcode.device_inspector';

/// Per-module channel names.
abstract final class Channels {
  static const String device = '$kChannelPrefix/device';
  static const String os = '$kChannelPrefix/os';
  static const String battery = '$kChannelPrefix/battery';
  static const String network = '$kChannelPrefix/network';
  static const String hardware = '$kChannelPrefix/hardware';
  static const String memory = '$kChannelPrefix/memory';
  static const String storage = '$kChannelPrefix/storage';
  static const String security = '$kChannelPrefix/security';
  static const String performance = '$kChannelPrefix/performance';

  /// All registered channel names.
  static const List<String> all = [
    device,
    os,
    battery,
    network,
    hardware,
    memory,
    storage,
    security,
    performance,
  ];
}

/// Method names invoked on each channel.
abstract final class Methods {
  static const String getDeviceInfo = 'getDeviceInfo';
  static const String getOSInfo = 'getOSInfo';
  static const String getBatteryInfo = 'getBatteryInfo';
  static const String getNetworkInfo = 'getNetworkInfo';
  static const String getHardwareInfo = 'getHardwareInfo';
  static const String getMemoryInfo = 'getMemoryInfo';
  static const String getStorageInfo = 'getStorageInfo';
  static const String getSecurityInfo = 'getSecurityInfo';

  // Performance monitor methods
  static const String getPerformanceSnapshot = 'getPerformanceSnapshot';
  static const String startPerformanceMonitor = 'startPerformanceMonitor';
  static const String stopPerformanceMonitor = 'stopPerformanceMonitor';
}
