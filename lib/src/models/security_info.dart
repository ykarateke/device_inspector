import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'security_info.freezed.dart';
part 'security_info.g.dart';

@freezed
class SecurityInfo with _$SecurityInfo {
  const factory SecurityInfo({
    @Default(false) bool isRooted,
    @Default(false) bool isJailbroken,
    @Default(false) bool isEmulator,
    @Default(false) bool isDebuggerAttached,
    @Default(false) bool isDeveloperMode,
    @Default(false) bool hasSuspiciousApps,
    @Default(false) bool hasSuspiciousPaths,
    @Default(false) bool hasSuspiciousEnvVars,
    @Default(false) bool hasModifiedLibraries,
    @Default(<String>[]) List<String> detectedThreats,
    @Default(100) int securityScore,
  }) = _SecurityInfo;

  factory SecurityInfo.fromJson(Map<String, dynamic> json) =>
      _$SecurityInfoFromJson(json);

  factory SecurityInfo.unknown() => const SecurityInfo();

  const SecurityInfo._();

  /// `true` when any threat indicator is positive.
  bool get isCompromised =>
      isRooted ||
      isJailbroken ||
      isEmulator ||
      hasSuspiciousApps ||
      hasSuspiciousPaths ||
      hasSuspiciousEnvVars ||
      hasModifiedLibraries;

  /// Risk level derived from [securityScore] and threat severity.
  ///
  /// Unlike [isCompromised] which is binary, this provides proportional
  /// risk assessment:
  /// - [SecurityRiskLevel.low]: score ≥ 90, clean
  /// - [SecurityRiskLevel.medium]: developer mode, USB debugging
  /// - [SecurityRiskLevel.high]: emulator, debugger attached
  /// - [SecurityRiskLevel.critical]: root, jailbreak, injection, score < 50
  SecurityRiskLevel get riskLevel {
    if (securityScore == 100 && detectedThreats.isEmpty) {
      return SecurityRiskLevel.low;
    }
    if (isRooted || isJailbroken || hasModifiedLibraries) {
      return SecurityRiskLevel.critical;
    }
    if (isEmulator || isDebuggerAttached) {
      return SecurityRiskLevel.high;
    }
    if (securityScore <= 50) {
      return SecurityRiskLevel.critical;
    }
    if (securityScore <= 79) {
      return SecurityRiskLevel.high;
    }
    if (isDeveloperMode || hasSuspiciousApps ||
        hasSuspiciousPaths || hasSuspiciousEnvVars) {
      return SecurityRiskLevel.medium;
    }
    return SecurityRiskLevel.low;
  }
}
