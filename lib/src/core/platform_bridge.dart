/// Platform bridge — abstracts all native MethodChannel communication.
///
/// Every service uses this class to invoke platform methods. It handles
/// error mapping from native [PlatformException]s to SDK exceptions.
library;

import 'package:flutter/services.dart';

import 'constants.dart';
import 'error_handler.dart';
import 'logger.dart';

/// Central point for all native platform calls.
///
/// Each module channel is lazily created on first use. All calls
/// return [Map<String, dynamic>] and errors are translated into
/// typed [DeviceInspectorException] subclasses.
class PlatformBridge {
  final Logger _logger;
  final Map<String, MethodChannel> _channels = {};

  PlatformBridge({required Logger logger}) : _logger = logger;

  /// Returns (or creates) the [MethodChannel] for the given module.
  MethodChannel _channel(String module) {
    return _channels.putIfAbsent(
      module,
      () => MethodChannel('$kChannelPrefix/$module'),
    );
  }

  /// Invoke a method on the given module channel.
  ///
  /// [module] is the module name (e.g. `'device'`, `'battery'`).
  /// [method] is the native method name (e.g. `'getDeviceInfo'`).
  /// [arguments] is optional parameters to pass to the native side.
  ///
  /// Returns the native result as a [Map<String, dynamic>].
  ///
  /// Throws a typed [DeviceInspectorException] subclass on failure.
  Future<Map<String, dynamic>> invoke(
    String module,
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    final channelName = '$kChannelPrefix/$module';
    _logger.debug('Invoking $channelName.$method($arguments)');

    try {
      final result = await _channel(module).invokeMethod(method, arguments);

      if (result == null) {
        _logger.warn('$channelName.$method returned null');
        throw DeviceInspectorException(
          'Platform returned null for $module.$method',
          code: ErrorCodes.unknown,
        );
      }

      if (result is Map) {
        final map = Map<String, dynamic>.from(result);
        _logger.debug('$channelName.$method -> ${map.keys.toList()}');
        return map;
      }

      _logger.warn('$channelName.$method returned non-Map: ${result.runtimeType}');
      throw DeviceInspectorException(
        'Unexpected result type from $module.$method',
        code: ErrorCodes.unknown,
      );
    } on PlatformException catch (e) {
      _logger.error('$channelName.$method failed: ${e.code} — ${e.message}', e);
      throw _mapPlatformException(e);
    } on MissingPluginException {
      _logger.error('$channelName.$method: plugin not registered on this platform');
      throw PlatformNotSupportedException(
        'Module "$module" is not supported on this platform',
      );
    }
  }

  /// Maps a Flutter [PlatformException] to the appropriate SDK exception.
  DeviceInspectorException _mapPlatformException(PlatformException e) {
    switch (e.code) {
      case 'PERMISSION_DENIED':
        return PermissionDeniedException(e.message ?? 'Permission denied');
      case 'HARDWARE_ACCESS_DENIED':
        return HardwareAccessException(e.message ?? 'Hardware access denied');
      case 'SECURITY_CHECK_FAILED':
        return SecurityCheckException(e.message ?? 'Security check failed');
      case 'PLATFORM_NOT_SUPPORTED':
        return PlatformNotSupportedException(e.message ?? 'Platform not supported');
      default:
        return DeviceInspectorException(
          e.message ?? 'Unknown platform error',
          code: e.code,
        );
    }
  }

  /// Dispose all created channels. Call during [DeviceInspector.dispose].
  void dispose() {
    _channels.clear();
    _logger.debug('PlatformBridge disposed');
  }
}
