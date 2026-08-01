import '../core/constants.dart';
import '../core/error_handler.dart';
import '../core/platform_bridge.dart';
import '../models/device_info.dart';

/// Fetches hardware identity information (manufacturer, model, market name).
class DeviceService {
  final PlatformBridge _bridge;

  DeviceService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Retrieves [DeviceInfo] from the native platform.
  ///
  /// Falls back to [DeviceInfo.unknown] on any error.
  Future<DeviceInfo> fetch() async {
    try {
      final result = await _bridge.invoke('device', Methods.getDeviceInfo);
      return DeviceInfo.fromJson(result);
    } on DeviceInspectorException {
      rethrow;
    } catch (_) {
      return DeviceInfo.unknown();
    }
  }
}
