import 'package:freezed_annotation/freezed_annotation.dart';

part 'os_info.freezed.dart';
part 'os_info.g.dart';

@freezed
class OSInfo with _$OSInfo {
  const factory OSInfo({
    required String platform,
    required String version,
    required int majorVersion,
    required int minorVersion,
    @Default(0) int patchVersion,
    String? buildNumber,
    int? apiLevel,
    String? kernelVersion,
  }) = _OSInfo;

  factory OSInfo.fromJson(Map<String, dynamic> json) =>
      _$OSInfoFromJson(json);

  factory OSInfo.unknown() => const OSInfo(
        platform: 'Unknown',
        version: '0.0',
        majorVersion: 0,
        minorVersion: 0,
      );
}
