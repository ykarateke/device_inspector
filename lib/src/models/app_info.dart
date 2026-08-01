import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info.freezed.dart';
part 'app_info.g.dart';

/// Application metadata resolved from the host package.
///
/// Resolved on the Dart side (no platform channel required).
@freezed
class AppInfo with _$AppInfo {
  const factory AppInfo({
    /// Human-readable application name.
    required String appName,

    /// Version string (1.2.3).
    required String version,

    /// Build number (42).
    required String buildNumber,

    /// Bundle / package identifier (com.example.app).
    required String bundleId,

    /// Epoch ms when the app was first installed.
    int? installTimestampMs,

    /// Epoch ms when the app was first launched.
    int? firstLaunchTimestampMs,

    /// APK signature hash (Android only).
    String? signatureHash,

    /// Whether this is a debug build.
    @Default(false) bool isDebugBuild,
  }) = _AppInfo;

  factory AppInfo.fromJson(Map<String, dynamic> json) =>
      _$AppInfoFromJson(json);

  const factory AppInfo.unknown() = _AppInfoUnknown;

  const AppInfo._();
}
