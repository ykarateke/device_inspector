import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory_info.freezed.dart';
part 'memory_info.g.dart';

@freezed
class MemoryInfo with _$MemoryInfo {
  const factory MemoryInfo({
    required int totalBytes,
    required int availableBytes,
    required double usagePercent,
    @Default(-1) int appUsedBytes,
    @Default(false) bool isLowMemory,
  }) = _MemoryInfo;

  factory MemoryInfo.fromJson(Map<String, dynamic> json) =>
      _$MemoryInfoFromJson(json);

  factory MemoryInfo.unknown() => const MemoryInfo(
        totalBytes: -1,
        availableBytes: -1,
        usagePercent: -1,
      );

  const MemoryInfo._();

  String get formattedTotal => _formatBytes(totalBytes);
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
