import '../core/constants.dart';
import '../core/error_handler.dart';
import '../core/platform_bridge.dart';
import '../models/battery_info.dart';

/// Fetches battery status, health, and charging state.
class BatteryService {
  final PlatformBridge _bridge;

  BatteryService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Retrieves [BatteryInfo] from the native platform.
  ///
  /// Falls back to [BatteryInfo.unknown] on any error.
  Future<BatteryInfo> fetch() async {
    try {
      final result = await _bridge.invoke('battery', Methods.getBatteryInfo);
      return BatteryInfo.fromJson(result);
    } on DeviceInspectorException {
      rethrow;
    } catch (_) {
      return BatteryInfo.unknown();
    }
  }
}
