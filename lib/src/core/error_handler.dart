/// Exception hierarchy for the device_inspector package.
///
/// All exceptions thrown by the SDK extend [DeviceInspectorException].
library;

/// Base exception for all device_inspector errors.
class DeviceInspectorException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Machine-readable error code.
  final String? code;

  const DeviceInspectorException(this.message, {this.code});

  @override
  String toString() => 'DeviceInspectorException(${code ?? 'UNKNOWN'}): $message';
}

/// Thrown when the current platform (web, desktop) is not supported.
class PlatformNotSupportedException extends DeviceInspectorException {
  const PlatformNotSupportedException(super.message, {super.code = 'PLATFORM_NOT_SUPPORTED'});
}

/// Thrown when a required platform permission is denied.
class PermissionDeniedException extends DeviceInspectorException {
  const PermissionDeniedException(super.message, {super.code = 'PERMISSION_DENIED'});
}

/// Thrown when hardware information cannot be accessed.
class HardwareAccessException extends DeviceInspectorException {
  const HardwareAccessException(super.message, {super.code = 'HARDWARE_ACCESS_DENIED'});
}

/// Thrown when a security check fails at the native level.
class SecurityCheckException extends DeviceInspectorException {
  const SecurityCheckException(super.message, {super.code = 'SECURITY_CHECK_FAILED'});
}

/// Thrown when [DeviceInspector.initialize] receives invalid parameters.
class ConfigurationException extends DeviceInspectorException {
  const ConfigurationException(super.message, {super.code = 'INVALID_CONFIGURATION'});
}

/// Thrown when a native method is not found on the platform side.
class NativeMethodNotFoundException extends DeviceInspectorException {
  const NativeMethodNotFoundException(super.message, {super.code = 'NATIVE_METHOD_NOT_FOUND'});
}

/// Error code strings used in [DeviceInspectorException.code].
abstract final class ErrorCodes {
  static const String platformNotSupported = 'PLATFORM_NOT_SUPPORTED';
  static const String notInitialized = 'NOT_INITIALIZED';
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String hardwareAccessDenied = 'HARDWARE_ACCESS_DENIED';
  static const String securityCheckFailed = 'SECURITY_CHECK_FAILED';
  static const String invalidConfiguration = 'INVALID_CONFIGURATION';
  static const String nativeMethodNotFound = 'NATIVE_METHOD_NOT_FOUND';
  static const String unknown = 'UNKNOWN';
}
