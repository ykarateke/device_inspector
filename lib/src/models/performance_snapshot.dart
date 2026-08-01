import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_snapshot.freezed.dart';
part 'performance_snapshot.g.dart';

@freezed
class PerformanceSnapshot with _$PerformanceSnapshot {
  const factory PerformanceSnapshot({
    required double fps,
    required double cpuUsagePercent,
    required double appCpuUsagePercent,
    required double memoryUsageMB,
    required double memoryUsagePercent,
    @Default('nominal') String thermalState,
    required int timestampMsSinceEpoch,
    @Default(-1) int batteryImpactLevel,
  }) = _PerformanceSnapshot;

  factory PerformanceSnapshot.fromJson(Map<String, dynamic> json) =>
      _$PerformanceSnapshotFromJson(json);

  factory PerformanceSnapshot.empty() => const PerformanceSnapshot(
        fps: 0,
        cpuUsagePercent: 0,
        appCpuUsagePercent: 0,
        memoryUsageMB: 0,
        memoryUsagePercent: 0,
        timestampMsSinceEpoch: 0,
      );
}
