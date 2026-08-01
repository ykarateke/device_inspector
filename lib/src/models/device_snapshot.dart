import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_info.dart';
import 'battery_info.dart';
import 'device_info.dart';
import 'hardware_info.dart';
import 'memory_info.dart';
import 'network_info.dart';
import 'os_info.dart';
import 'security_info.dart';
import 'storage_info.dart';

part 'device_snapshot.freezed.dart';
part 'device_snapshot.g.dart';

@freezed
class DeviceSnapshot with _$DeviceSnapshot {
  const factory DeviceSnapshot({
    required DeviceInfo device,
    required OSInfo os,
    required BatteryInfo battery,
    required NetworkInfo network,
    required HardwareInfo hardware,
    required MemoryInfo memory,
    required StorageInfo storage,
    required SecurityInfo security,
    required AppInfo app,
    @Default(0) int timestampMsSinceEpoch,
  }) = _DeviceSnapshot;

  factory DeviceSnapshot.fromJson(Map<String, dynamic> json) =>
      _$DeviceSnapshotFromJson(json);

  factory DeviceSnapshot.empty() => DeviceSnapshot(
        device: DeviceInfo.unknown(),
        os: OSInfo.unknown(),
        battery: BatteryInfo.unknown(),
        network: NetworkInfo.unknown(),
        hardware: HardwareInfo.unknown(),
        memory: MemoryInfo.unknown(),
        storage: StorageInfo.unknown(),
        security: SecurityInfo.unknown(),
        app: AppInfo.unknown(),
      );
}
