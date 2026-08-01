import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_info.freezed.dart';
part 'security_info.g.dart';

/// Results of device integrity and security checks.
///
/// Requires [DeviceInspectorConfig.enableSecurityCheck] to be `true`.
@freezed
class SecurityInfo with _$SecurityInfo {
  const factory SecurityInfo({
    /// Whether root access was detected (Android).
    @Default(false) bool isRooted,

    /// Whether a jailbreak was detected (iOS).
    @Default(false) bool isJailbroken,

    /// Whether the app is running on an emulator or simulator.
    @Default(false) bool isEmulator,

    /// Whether a debugger is attached to the process.
    @Default(false) bool isDebuggerAttached,

    /// Whether developer mode / USB debugging is enabled.
    @Default(false) bool isDeveloperMode,

    /// Whether suspicious apps (Cydia, Magisk, SuperSU, …) were found.
    @Default(false) bool hasSuspiciousApps,

    /// Whether suspicious file-system paths were found.
    @Default(false) bool hasSuspiciousPaths,

    /// Whether suspicious environment variables are set.
    @Default(false) bool hasSuspiciousEnvVars,

    /// Whether system libraries show signs of modification.
    @Default(false) bool hasModifiedLibraries,

    /// Human-readable list of detected threats.
    @Default([]) List<String> detectedThreats,

    /// Security score 0–100. 100 = clean, lower = more threats detected.
    @Default(100) int securityScore,
  }) = _SecurityInfo;

  factory SecurityInfo.fromJson(Map<String, dynamic> json) =>
      _$SecurityInfoFromJson(json);

  const factory SecurityInfo.unknown() = _SecurityInfoUnknown;

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
}
