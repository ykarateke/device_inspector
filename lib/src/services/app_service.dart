import 'dart:io' show Platform;

import '../models/app_info.dart';

/// Resolves application metadata on the Dart side (no platform channel needed).
///
/// Uses `dart:io` [Platform] for environment detection and
/// compile-time constants for debug vs release.
class AppService {
  /// Returns [AppInfo] from the running application environment.
  ///
  /// In a real implementation this would use `package_info_plus` or
  /// manual resolution from the native embedding. For the MVP we
  /// return a minimal stub that can be enriched per-platform.
  Future<AppInfo> fetch() async {
    try {
      // Placeholder — in production this reads from the native embedding
      // or package_info_plus. SDK consumers can override this service.
      return AppInfo(
        appName: 'Unknown',
        version: '0.0.0',
        buildNumber: '0',
        bundleId: 'unknown',
        isDebugBuild: _isDebugBuild,
      );
    } catch (_) {
      return AppInfo.unknown();
    }
  }

  /// Heuristic for detecting a debug build.
  /// In Flutter, `kReleaseMode` / `kDebugMode` from `foundation.dart`
  /// should be used, but this service keeps a minimal `dart:io` footprint.
  static bool get _isDebugBuild {
    try {
      // ignore: avoid_dynamic_calls
      return const bool.fromEnvironment('dart.vm.product') == false;
    } catch (_) {
      return false;
    }
  }
}
