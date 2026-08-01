import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'hardware_info.freezed.dart';
part 'hardware_info.g.dart';

// ---------------------------------------------------------------------------
// CPUInfo
// ---------------------------------------------------------------------------

/// Processor details: model, cores, architecture, and capabilities.
@freezed
class CPUInfo with _$CPUInfo {
  const factory CPUInfo({
    /// Processor brand / model name (A17 Pro, Snapdragon 8 Gen 3, …).
    required String name,

    /// Total number of cores.
    required int cores,

    /// Instruction set architecture: `arm64`, `armv7`, `x86_64`.
    required String architecture,

    /// Maximum clock frequency in MHz. 0 = unknown.
    @Default(0) int maxFrequencyMHz,

    /// Number of performance (big) cores on big.LITTLE architectures.
    int? performanceCores,

    /// Number of efficiency (LITTLE) cores on big.LITTLE architectures.
    int? efficiencyCores,

    /// Whether an Apple Neural Engine or equivalent AI accelerator is present.
    @Default(false) bool hasNeuralEngine,
  }) = _CPUInfo;

  factory CPUInfo.fromJson(Map<String, dynamic> json) =>
      _$CPUInfoFromJson(json);

  const factory CPUInfo.unknown() = _CPUInfoUnknown;
  const CPUInfo._();
}

// ---------------------------------------------------------------------------
// GPUInfo
// ---------------------------------------------------------------------------

/// Graphics processor details and API support.
@freezed
class GPUInfo with _$GPUInfo {
  const factory GPUInfo({
    /// GPU name (Apple A17 Pro GPU, Adreno 750, Mali-G78, …).
    required String name,

    /// Whether Metal API is supported (iOS/macOS).
    @Default(false) bool supportsMetal,

    /// Metal feature set identifier, if available.
    String? metalFeatureSet,

    /// Whether Vulkan API is supported (Android).
    @Default(false) bool supportsVulkan,

    /// Vulkan version string, if available.
    String? vulkanVersion,

    /// OpenGL ES version string, if available.
    String? openGLESVersion,
  }) = _GPUInfo;

  factory GPUInfo.fromJson(Map<String, dynamic> json) =>
      _$GPUInfoFromJson(json);

  const factory GPUInfo.unknown() = _GPUInfoUnknown;
  const GPUInfo._();
}

// ---------------------------------------------------------------------------
// DisplayInfo
// ---------------------------------------------------------------------------

/// Screen dimensions, density, and capabilities.
@freezed
class DisplayInfo with _$DisplayInfo {
  const factory DisplayInfo({
    /// Physical width in pixels.
    required int widthPixels,

    /// Physical height in pixels.
    required int heightPixels,

    /// Pixel density (logical pixels per inch).
    required double density,

    /// Refresh rate in Hz. 0 = unknown.
    @Default(0) int refreshRate,

    /// Whether HDR content is supported.
    @Default(false) bool supportsHdr,

    /// Current screen brightness (0.0–1.0). -1.0 = unknown.
    @Default(-1.0) double brightnessLevel,
  }) = _DisplayInfo;

  factory DisplayInfo.fromJson(Map<String, dynamic> json) =>
      _$DisplayInfoFromJson(json);

  const factory DisplayInfo.unknown() = _DisplayInfoUnknown;
  const DisplayInfo._();
}

// ---------------------------------------------------------------------------
// HardwareInfo
// ---------------------------------------------------------------------------

/// Aggregated hardware information: CPU, GPU, display, and performance tier.
@freezed
class HardwareInfo with _$HardwareInfo {
  const factory HardwareInfo({
    required CPUInfo cpu,
    required GPUInfo gpu,
    required DisplayInfo display,

    /// Device performance tier derived from CPU + GPU specs.
    @Default(DeviceTier.unknown) DeviceTier tier,
  }) = _HardwareInfo;

  factory HardwareInfo.fromJson(Map<String, dynamic> json) =>
      _$HardwareInfoFromJson(json);

  const factory HardwareInfo.unknown() = _HardwareInfoUnknown;
  const HardwareInfo._();
}
