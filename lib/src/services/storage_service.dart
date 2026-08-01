import '../core/constants.dart';
import '../core/error_handler.dart';
import '../core/platform_bridge.dart';
import '../models/storage_info.dart';

/// Fetches disk storage statistics.
class StorageService {
  final PlatformBridge _bridge;

  StorageService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Retrieves [StorageInfo] from the native platform.
  ///
  /// Falls back to [StorageInfo.unknown] on any error.
  Future<StorageInfo> fetch() async {
    try {
      final result = await _bridge.invoke('storage', Methods.getStorageInfo);
      return StorageInfo.fromJson(result);
    } on DeviceInspectorException {
      rethrow;
    } catch (_) {
      return StorageInfo.unknown();
    }
  }
}
