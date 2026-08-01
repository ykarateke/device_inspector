/// Simple structured logger for the device_inspector SDK.
///
/// Controlled via [DeviceInspectorLogLevel] in [DeviceInspectorConfig].
library;

/// Log verbosity levels.
enum DeviceInspectorLogLevel {
  /// No logging at all.
  off,

  /// Only errors.
  error,

  /// Errors and warnings.
  warn,

  /// Errors, warnings, and informational messages.
  info,

  /// All messages including debug details.
  debug,

  /// All messages including internal verbose traces.
  verbose,
}

/// Internal logger that respects the configured [DeviceInspectorLogLevel].
///
/// In production, log level should be [DeviceInspectorLogLevel.off]
/// or [DeviceInspectorLogLevel.error] to avoid leaking device data.
class Logger {
  /// Current log level. Setting to [DeviceInspectorLogLevel.off] suppresses all output.
  DeviceInspectorLogLevel level;

  Logger(this.level);

  /// Log an error message.
  void error(String message, [Object? error, StackTrace? stack]) {
    if (level.index >= DeviceInspectorLogLevel.error.index) {
      // ignore: avoid_print
      print('[device_inspector][ERROR] $message ${error ?? ''}');
    }
  }

  /// Log a warning message.
  void warn(String message) {
    if (level.index >= DeviceInspectorLogLevel.warn.index) {
      // ignore: avoid_print
      print('[device_inspector][WARN] $message');
    }
  }

  /// Log an informational message.
  void info(String message) {
    if (level.index >= DeviceInspectorLogLevel.info.index) {
      // ignore: avoid_print
      print('[device_inspector][INFO] $message');
    }
  }

  /// Log a debug message. Includes detailed platform call information.
  void debug(String message) {
    if (level.index >= DeviceInspectorLogLevel.debug.index) {
      // ignore: avoid_print
      print('[device_inspector][DEBUG] $message');
    }
  }

  /// Log a verbose trace message (internal details).
  void verbose(String message) {
    if (level.index >= DeviceInspectorLogLevel.verbose.index) {
      // ignore: avoid_print
      print('[device_inspector][VERBOSE] $message');
    }
  }
}
