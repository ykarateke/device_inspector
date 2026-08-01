import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'network_info.freezed.dart';
part 'network_info.g.dart';

/// Active network connection details and carrier information.
@freezed
class NetworkInfo with _$NetworkInfo {
  const factory NetworkInfo({
    /// Type of active network connection.
    required NetworkType type,

    /// Cellular carrier name (Turkcell, Vodafone, …). Null if not cellular.
    String? carrier,

    /// Cellular generation: `"2G"`, `"3G"`, `"4G"`, `"5G"`.
    String? cellularGeneration,

    /// Whether a VPN connection is active.
    @Default(false) bool isVpn,

    /// Whether an HTTP/HTTPS proxy is configured.
    @Default(false) bool isProxy,

    /// Whether airplane mode is enabled.
    @Default(false) bool isAirplaneMode,

    /// Connected Wi-Fi SSID. May require location permission on Android.
    String? wifiSsid,

    /// Signal strength level (0–5). -1 if unknown.
    @Default(-1) int signalStrength,

    /// Device local IP address, if available.
    String? localIpAddress,
  }) = _NetworkInfo;

  factory NetworkInfo.fromJson(Map<String, dynamic> json) =>
      _$NetworkInfoFromJson(json);

  /// Fallback constructor used when platform call fails.
  const factory NetworkInfo.unknown() = _NetworkInfoUnknown;

  const NetworkInfo._();
}
