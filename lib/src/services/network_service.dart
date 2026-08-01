import '../core/constants.dart';
import '../core/error_handler.dart';
import '../core/platform_bridge.dart';
import '../models/network_info.dart';

/// Fetches network connectivity, carrier, VPN, and proxy details.
class NetworkService {
  final PlatformBridge _bridge;

  NetworkService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Retrieves [NetworkInfo] from the native platform.
  ///
  /// Falls back to [NetworkInfo.unknown] on any error.
  Future<NetworkInfo> fetch() async {
    try {
      final result = await _bridge.invoke('network', Methods.getNetworkInfo);
      return NetworkInfo.fromJson(result);
    } on DeviceInspectorException {
      rethrow;
    } catch (_) {
      return NetworkInfo.unknown();
    }
  }
}
