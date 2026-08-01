import 'package:freezed_annotation/freezed_annotation.dart';

part 'os_info.freezed.dart';
part 'os_info.g.dart';

/// Operating system version and build details.
@freezed
class OSInfo with _$OSInfo {
  const factory OSInfo({
    /// Platform name: `"iOS"` or `"Android"`.
    required String platform,

    /// Full version string (17.4, 14.0, …).
    required String version,

    /// Major version number.
    required int majorVersion,

    /// Minor version number.
    required int minorVersion,

    /// Patch version number. Defaults to 0 when not applicable.
    @Default(0) int patchVersion,

    /// Build identifier (iOS: 21E236, Android: AP1A.240305.019.A1).
    String? buildNumber,

    /// Android API level. Null on iOS.
    int? apiLevel,

    /// Kernel version string, if available.
    String? kernelVersion,
  }) = _OSInfo;

  factory OSInfo.fromJson(Map<String, dynamic> json) =>
      _$OSInfoFromJson(json);

  /// Fallback constructor used when platform call fails.
  const factory OSInfo.unknown() = _OSInfoUnknown;

  const OSInfo._();
}
