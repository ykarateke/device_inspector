import 'package:freezed_annotation/freezed_annotation.dart';

part 'storage_info.freezed.dart';
part 'storage_info.g.dart';

@freezed
class StorageInfo with _$StorageInfo {
  const factory StorageInfo({
    required int totalBytes,
    required int freeBytes,
    required double usagePercent,
    @Default(-1) int appUsedBytes,
    String? appDataPath,
    String? appCachePath,
  }) = _StorageInfo;

  factory StorageInfo.fromJson(Map<String, dynamic> json) =>
      _$StorageInfoFromJson(json);

  factory StorageInfo.unknown() => const StorageInfo(
        totalBytes: -1,
        freeBytes: -1,
        usagePercent: -1,
      );

  const StorageInfo._();

  String get formattedTotal => _formatBytes(totalBytes);
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
