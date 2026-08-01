import '../core/constants.dart';
import '../core/error_handler.dart';
import '../core/platform_bridge.dart';
import '../models/memory_info.dart';

/// Fetches RAM statistics.
class MemoryService {
  final PlatformBridge _bridge;

  MemoryService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Retrieves [MemoryInfo] from the native platform.
  ///
  /// Falls back to [MemoryInfo.unknown] on any error.
  Future<MemoryInfo> fetch() async {
    try {
      final result = await _bridge.invoke('memory', Methods.getMemoryInfo);
      return MemoryInfo.fromJson(result);
    } on DeviceInspectorException {
      rethrow;
    } catch (_) {
      return MemoryInfo.unknown();
    }
  }
}
