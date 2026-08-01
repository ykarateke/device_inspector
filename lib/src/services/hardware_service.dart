import '../core/constants.dart';
import '../core/error_handler.dart';
import '../core/platform_bridge.dart';
import '../models/hardware_info.dart';

/// Fetches hardware specifications: CPU, GPU, display.
class HardwareService {
  final PlatformBridge _bridge;

  HardwareService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Retrieves [HardwareInfo] from the native platform.
  ///
  /// Falls back to [HardwareInfo.unknown] on any error.
  Future<HardwareInfo> fetch() async {
    try {
      final result = await _bridge.invoke('hardware', Methods.getHardwareInfo);
      return HardwareInfo.fromJson(result);
    } on DeviceInspectorException {
      rethrow;
    } catch (_) {
      return HardwareInfo.unknown();
    }
  }
}
