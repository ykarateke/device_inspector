import '../core/constants.dart';
import '../core/error_handler.dart';
import '../core/platform_bridge.dart';
import '../models/app_info.dart';

/// Fetches application metadata (name, version, bundle ID) via the native
/// `app` channel — reads the real app bundle/package info on each platform.
class AppService {
  final PlatformBridge _bridge;

  AppService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Retrieves [AppInfo] from the native platform.
  ///
  /// Falls back to [AppInfo.unknown] on any error.
  Future<AppInfo> fetch() async {
    try {
      final result = await _bridge.invoke('app', Methods.getAppInfo);
      return AppInfo.fromJson(result);
    } on DeviceInspectorException {
      rethrow;
    } catch (_) {
      return AppInfo.unknown();
    }
  }
}
