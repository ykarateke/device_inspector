import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'device_info.freezed.dart';
part 'device_info.g.dart';

@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    required String manufacturer,
    required String model,
    required String marketName,
    String? identifier,
    String? codename,
    @Default(DeviceTier.unknown) DeviceTier tier,
    int? releaseYear,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);

  factory DeviceInfo.unknown() => const DeviceInfo(
        manufacturer: 'Unknown',
        model: 'Unknown',
        marketName: 'Unknown',
      );
}
