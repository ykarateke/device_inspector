import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'battery_info.freezed.dart';
part 'battery_info.g.dart';

@freezed
class BatteryInfo with _$BatteryInfo {
  const factory BatteryInfo({
    required int level,
    required BatteryChargingState chargingState,
    required bool isCharging,
    BatteryHealth? health,
    int? maxCapacityPercent,
    @Default(-1) int estimatedMinutesRemaining,
    @Default(false) bool isLowPowerMode,
  }) = _BatteryInfo;

  factory BatteryInfo.fromJson(Map<String, dynamic> json) =>
      _$BatteryInfoFromJson(json);

  factory BatteryInfo.unknown() => const BatteryInfo(
        level: -1,
        chargingState: BatteryChargingState.unknown,
        isCharging: false,
      );
}
