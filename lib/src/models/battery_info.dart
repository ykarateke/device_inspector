import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'battery_info.freezed.dart';
part 'battery_info.g.dart';

/// Current battery status, health, and charging state.
@freezed
class BatteryInfo with _$BatteryInfo {
  const factory BatteryInfo({
    /// Battery charge level 0–100. -1 if unknown.
    required int level,

    /// Detailed charging / discharging state.
    required BatteryChargingState chargingState,

    /// Convenience: `true` if actively charging.
    required bool isCharging,

    /// Battery health assessment. iOS provides this; Android 8+ provides
    /// a limited version.
    BatteryHealth? health,

    /// Maximum capacity as a percentage of design capacity. iOS only.
    int? maxCapacityPercent,

    /// Estimated minutes remaining on current charge. -1 if unknown.
    @Default(-1) int estimatedMinutesRemaining,

    /// Whether low-power / battery-saver mode is active.
    @Default(false) bool isLowPowerMode,
  }) = _BatteryInfo;

  factory BatteryInfo.fromJson(Map<String, dynamic> json) =>
      _$BatteryInfoFromJson(json);

  /// Fallback constructor used when platform call fails.
  const factory BatteryInfo.unknown() = _BatteryInfoUnknown;

  const BatteryInfo._();
}
