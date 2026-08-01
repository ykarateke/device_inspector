import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info.freezed.dart';
part 'app_info.g.dart';

@freezed
class AppInfo with _$AppInfo {
  const factory AppInfo({
    required String appName,
    required String version,
    required String buildNumber,
    required String bundleId,
    int? installTimestampMs,
    int? firstLaunchTimestampMs,
    String? signatureHash,
    @Default(false) bool isDebugBuild,
  }) = _AppInfo;

  factory AppInfo.fromJson(Map<String, dynamic> json) =>
      _$AppInfoFromJson(json);

  factory AppInfo.unknown() => const AppInfo(
        appName: 'Unknown',
        version: '0.0.0',
        buildNumber: '0',
        bundleId: 'unknown',
      );
}
