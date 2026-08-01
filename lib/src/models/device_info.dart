import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'device_info.freezed.dart';
part 'device_info.g.dart';

/// Hardware identity information for the current device.
@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    /// Manufacturer name (Apple, Samsung, Google, …).
    required String manufacturer,

    /// Internal model identifier (iPhone15,3, SM-S928B, …).
    required String model,

    /// Consumer-facing marketing name (iPhone 15 Pro, Galaxy S24 Ultra, …).
    required String marketName,

    /// Unique device identifier.
    ///
    /// iOS: `identifierForVendor`. Android: `ANDROID_ID`.
    /// Null when unavailable or when the host app chooses not to collect it.
    String? identifier,

    /// Board / codename. Android only.
    String? codename,

    /// Device performance tier derived from hardware specs.
    @Default(DeviceTier.unknown) DeviceTier tier,

    /// Year the device model was first released, if known.
    int? releaseYear,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);

  /// Fallback constructor used when platform call fails.
  const factory DeviceInfo.unknown() = _DeviceInfoUnknown;

  const DeviceInfo._();
}
