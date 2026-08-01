import 'package:freezed_annotation/freezed_annotation.dart';

part 'storage_info.freezed.dart';
part 'storage_info.g.dart';

/// Disk storage statistics for the device and the current application.
@freezed
class StorageInfo with _$StorageInfo {
  const factory StorageInfo({
    /// Total device storage in bytes.
    required int totalBytes,

    /// Free device storage in bytes.
    required int freeBytes,

    /// Used storage as a percentage of total (0–100).
    required double usagePercent,

    /// Storage used by this application in bytes. -1 if unknown.
    @Default(-1) int appUsedBytes,

    /// Application data directory path.
    String? appDataPath,

    /// Application cache directory path.
    String? appCachePath,
  }) = _StorageInfo;

  factory StorageInfo.fromJson(Map<String, dynamic> json) =>
      _$StorageInfoFromJson(json);

  const factory StorageInfo.unknown() = _StorageInfoUnknown;

  const StorageInfo._();

  /// Human-readable total storage (e.g. "256 GB").
  String get formattedTotal => _formatBytes(totalBytes);

  /// Human-readable free storage (e.g. "120 GB").
  String get formattedFree => _formatBytes(freeBytes);

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
