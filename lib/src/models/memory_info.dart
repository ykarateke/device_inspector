import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory_info.freezed.dart';
part 'memory_info.g.dart';

/// RAM statistics for the device and the current application.
@freezed
class MemoryInfo with _$MemoryInfo {
  const factory MemoryInfo({
    /// Total device RAM in bytes.
    required int totalBytes,

    /// Available (free + cache) RAM in bytes. -1 if unknown.
    required int availableBytes,

    /// Used RAM as a percentage of total (0–100). -1 if unknown.
    required double usagePercent,

    /// RAM used by this application in bytes. -1 if unknown.
    @Default(-1) int appUsedBytes,

    /// Whether the system has issued a low-memory warning.
    @Default(false) bool isLowMemory,
  }) = _MemoryInfo;

  factory MemoryInfo.fromJson(Map<String, dynamic> json) =>
      _$MemoryInfoFromJson(json);

  const factory MemoryInfo.unknown() = _MemoryInfoUnknown;

  const MemoryInfo._();

  /// Human-readable total RAM (e.g. "8.0 GB").
  String get formattedTotal => _formatBytes(totalBytes);

  /// Human-readable available RAM (e.g. "3.2 GB").
  String get formattedAvailable => _formatBytes(availableBytes);

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return 'N/A';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    var size = bytes.toDouble();
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${units[i]}';
  }
}
