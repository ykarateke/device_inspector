import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'hardware_info.freezed.dart';
part 'hardware_info.g.dart';

@freezed
class CPUInfo with _$CPUInfo {
  const factory CPUInfo({
    required String name,
    required int cores,
    required String architecture,
    @Default(0) int maxFrequencyMHz,
    int? performanceCores,
    int? efficiencyCores,
    @Default(false) bool hasNeuralEngine,
  }) = _CPUInfo;

  factory CPUInfo.fromJson(Map<String, dynamic> json) =>
      _$CPUInfoFromJson(json);

  factory CPUInfo.unknown() => const CPUInfo(
        name: 'Unknown',
        cores: 0,
        architecture: 'unknown',
      );
}

@freezed
class GPUInfo with _$GPUInfo {
  const factory GPUInfo({
    required String name,
    @Default(false) bool supportsMetal,
    String? metalFeatureSet,
    @Default(false) bool supportsVulkan,
    String? vulkanVersion,
    String? openGLESVersion,
  }) = _GPUInfo;

  factory GPUInfo.fromJson(Map<String, dynamic> json) =>
      _$GPUInfoFromJson(json);

  factory GPUInfo.unknown() => const GPUInfo(
        name: 'Unknown',
      );
}

@freezed
class DisplayInfo with _$DisplayInfo {
  const factory DisplayInfo({
    required int widthPixels,
    required int heightPixels,
    required double density,
    @Default(0) int refreshRate,
    @Default(false) bool supportsHdr,
    @Default(-1.0) double brightnessLevel,
  }) = _DisplayInfo;

  factory DisplayInfo.fromJson(Map<String, dynamic> json) =>
      _$DisplayInfoFromJson(json);

  factory DisplayInfo.unknown() => const DisplayInfo(
        widthPixels: 0,
        heightPixels: 0,
        density: 0,
      );
}

@freezed
class HardwareInfo with _$HardwareInfo {
  const factory HardwareInfo({
    required CPUInfo cpu,
    required GPUInfo gpu,
    required DisplayInfo display,
    @Default(DeviceTier.unknown) DeviceTier tier,
  }) = _HardwareInfo;

  factory HardwareInfo.fromJson(Map<String, dynamic> json) =>
      _$HardwareInfoFromJson(json);

  factory HardwareInfo.unknown() => HardwareInfo(
        cpu: CPUInfo.unknown(),
        gpu: GPUInfo.unknown(),
        display: DisplayInfo.unknown(),
      );
}
