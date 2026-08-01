import '../core/constants.dart';
import '../core/error_handler.dart';
import '../core/platform_bridge.dart';
import '../models/os_info.dart';

/// Fetches operating system version and build details.
class OSService {
  final PlatformBridge _bridge;

  OSService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Retrieves [OSInfo] from the native platform.
  ///
  /// Falls back to [OSInfo.unknown] on any error.
  Future<OSInfo> fetch() async {
    try {
      final result = await _bridge.invoke('os', Methods.getOSInfo);
      return OSInfo.fromJson(result);
    } on DeviceInspectorException {
      rethrow;
    } catch (_) {
      return OSInfo.unknown();
    }
  }
}
