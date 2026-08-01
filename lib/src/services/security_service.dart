import '../core/constants.dart';
import '../core/error_handler.dart';
import '../core/platform_bridge.dart';
import '../models/security_info.dart';

/// Orchestrates device integrity checks (root, jailbreak, emulator, debugger).
///
/// Requires [DeviceInspectorConfig.enableSecurityCheck] to be `true`.
class SecurityService {
  final PlatformBridge _bridge;

  SecurityService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Retrieves [SecurityInfo] from the native platform.
  ///
  /// Falls back to [SecurityInfo.unknown] (all-clean) on any error.
  Future<SecurityInfo> fetch() async {
    try {
      final result = await _bridge.invoke('security', Methods.getSecurityInfo);
      return SecurityInfo.fromJson(result);
    } on DeviceInspectorException {
      rethrow;
    } catch (_) {
      return SecurityInfo.unknown();
    }
  }
}
