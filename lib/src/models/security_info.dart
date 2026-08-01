import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default([]) List<String> detectedThreats,
    @Default(100) int securityScore,
  }) = _SecurityInfo;

  factory SecurityInfo.fromJson(Map<String, dynamic> json) =>
      _$SecurityInfoFromJson(json);

  factory SecurityInfo.unknown() => const SecurityInfo();

  const SecurityInfo._();

  bool get isCompromised =>
      isRooted ||
      isJailbroken ||
      isEmulator ||
      hasSuspiciousApps ||
      hasSuspiciousPaths ||
      hasSuspiciousEnvVars ||
      hasModifiedLibraries;
}
