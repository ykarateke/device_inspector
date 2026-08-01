import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_snapshot.freezed.dart';
part 'performance_snapshot.g.dart';

/// A single real-time performance measurement.
///
/// Emitted by [PerformanceMonitor] at the configured sampling interval.
@freezed
class PerformanceSnapshot with _$PerformanceSnapshot {
  const factory PerformanceSnapshot({
    /// Current frames per second.
    required double fps,

    /// Total CPU usage percentage (0–100).
    required double cpuUsagePercent,

    /// CPU usage by this application (0–100).
    required double appCpuUsagePercent,

    /// Memory used by this application in MB.
    required double memoryUsageMB,

    /// Total memory usage as a percentage (0–100).
    required double memoryUsagePercent,

    /// Thermal state: `nominal`, `fair`, `serious`, `critical`.
    @Default('nominal') String thermalState,

    /// Epoch ms when this snapshot was captured.
    required int timestampMsSinceEpoch,

    /// Estimated battery impact level: 1 (low) – 5 (high). -1 if unknown.
    @Default(-1) int batteryImpactLevel,
  }) = _PerformanceSnapshot;

  factory PerformanceSnapshot.fromJson(Map<String, dynamic> json) =>
      _$PerformanceSnapshotFromJson(json);

  static const empty = PerformanceSnapshot(
    fps: 0,
    cpuUsagePercent: 0,
    appCpuUsagePercent: 0,
    memoryUsageMB: 0,
    memoryUsagePercent: 0,
    timestampMsSinceEpoch: 0,
  );

  const PerformanceSnapshot._();
}
