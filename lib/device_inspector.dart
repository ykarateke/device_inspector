/// device_inspector — Flutter device analysis SDK.
///
/// Provides device, system, hardware, performance, and security information
/// through a single, consistent API.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:device_inspector/device_inspector.dart';
///
/// void main() async {
///   final snapshot = await DeviceInspector.inspect();
///   print(snapshot.device.marketName); // "iPhone 15 Pro"
///   print(snapshot.battery.level);     // 85
///   print(snapshot.security.isRooted); // false
/// }
/// ```
///
/// ## Modular Access
///
/// ```dart
/// final battery = await DeviceInspector.battery;
/// if (battery.level < 20) showLowBatteryWarning();
/// ```
library device_inspector;

export 'src/device_inspector.dart';
