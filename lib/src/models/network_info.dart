import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'network_info.freezed.dart';
part 'network_info.g.dart';

@freezed
class NetworkInfo with _$NetworkInfo {
  const factory NetworkInfo({
    required NetworkType type,
    String? carrier,
    String? cellularGeneration,
    @Default(false) bool isVpn,
    @Default(false) bool isProxy,
    @Default(false) bool isAirplaneMode,
    String? wifiSsid,
    @Default(-1) int signalStrength,
    String? localIpAddress,
  }) = _NetworkInfo;

  factory NetworkInfo.fromJson(Map<String, dynamic> json) =>
      _$NetworkInfoFromJson(json);

  factory NetworkInfo.unknown() => const NetworkInfo(
        type: NetworkType.unknown,
      );
}
