import 'dart:async';

import '../core/constants.dart';
import '../core/platform_bridge.dart';
import '../models/performance_snapshot.dart';

/// Real-time performance monitor.
///
/// Emits [PerformanceSnapshot] values on [snapshotStream] at the configured
/// sampling interval. Use [start] and [stop] to control data collection.
class PerformanceMonitor {
  final PlatformBridge _bridge;
  final int _intervalMs;

  final StreamController<PerformanceSnapshot> _controller =
      StreamController<PerformanceSnapshot>.broadcast();

  Timer? _timer;
  bool _isRunning = false;
  PerformanceSnapshot? _current;

  PerformanceMonitor({
    required PlatformBridge bridge,
    required int samplingIntervalMs,
  })  : _bridge = bridge,
        _intervalMs = samplingIntervalMs;

  /// Latest captured snapshot. Null until the first sample arrives.
  PerformanceSnapshot? get currentSnapshot => _current;

  /// Broadcast stream of performance snapshots.
  Stream<PerformanceSnapshot> get snapshotStream => _controller.stream;

  /// Whether the monitor is currently sampling.
  bool get isRunning => _isRunning;

  /// Sampling interval in milliseconds.
  int get samplingIntervalMs => _intervalMs;

  /// Starts periodic sampling. No-op if already running.
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    _timer = Timer.periodic(Duration(milliseconds: _intervalMs), (_) {
      _sample();
    });

    // Take an immediate first sample
    _sample();
  }

  /// Stops sampling. The stream remains open — call [start] to resume.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// Stops sampling and closes the stream. Call [start] again after this
  /// is a no-op; create a new [PerformanceMonitor] instead.
  void dispose() {
    stop();
    _controller.close();
  }

  Future<void> _sample() async {
    try {
      final result = await _bridge.invoke(
        'performance',
        Methods.getPerformanceSnapshot,
      );
      final snapshot = PerformanceSnapshot.fromJson(result);
      _current = snapshot;
      _controller.add(snapshot);
    } catch (_) {
      // Silently skip failed samples — don't break the stream
    }
  }
}
