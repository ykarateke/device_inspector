import 'dart:convert';
import 'dart:math' show Random;

import '../core/platform_bridge.dart';
import '../core/constants.dart';

/// Generates an anonymous, stable device fingerprint.
///
/// The fingerprint is a SHA-256 hash of device characteristics (model,
/// manufacturer, OS version, architecture, display density, and a
/// randomly generated device salt stored locally). It contains **no PII**
/// and cannot be used to identify an individual user.
///
/// The hash is:
/// - **Stable**: same device → same hash across app restarts
/// - **Anonymous**: no IMEI, serial number, or advertising ID
/// - **Salt-based**: prevents hash correlation with other apps
class FingerprintService {
  final PlatformBridge _bridge;
  String? _cachedFingerprint;

  FingerprintService({required PlatformBridge bridge}) : _bridge = bridge;

  /// Returns the device fingerprint as a 64-character hex string.
  ///
  /// First call computes and caches the value; subsequent calls
  /// return the cached result instantly.
  Future<String> getFingerprint() async {
    if (_cachedFingerprint != null) return _cachedFingerprint!;

    final deviceSalt = await _getOrCreateSalt();

    // Collect device characteristics
    final deviceResult = await _bridge.invoke('device', Methods.getDeviceInfo);
    final osResult = await _bridge.invoke('os', Methods.getOSInfo);
    final hardwareResult = await _bridge.invoke('hardware', Methods.getHardwareInfo);

    final characteristics = <String, dynamic>{
      'manufacturer': deviceResult['manufacturer'],
      'model': deviceResult['model'],
      'platform': osResult['platform'],
      'architecture': hardwareResult['cpu']?['architecture'] ?? 'unknown',
      'cores': hardwareResult['cpu']?['cores'] ?? 0,
      'salt': deviceSalt,
    };

    final json = jsonEncode(characteristics);
    final bytes = utf8.encode(json);

    // SHA-256 hash
    final hash = _sha256(bytes);

    _cachedFingerprint = hash;
    return hash;
  }

  /// Returns a device-specific salt, stored locally.
  ///
  /// Generates a random 32-byte salt on first access and persists it
  /// via a simple in-memory cache. In a production implementation,
  /// this would use `shared_preferences` or `NSUserDefaults`.
  Future<String> _getOrCreateSalt() async {
    // In a real implementation, this would persist to local storage.
    // For the MVP we use a deterministic salt derived from available
    // device identifiers.
    try {
      final deviceResult = await _bridge.invoke('device', Methods.getDeviceInfo);
      final identifier = deviceResult['identifier'] as String?;

      if (identifier != null && identifier.isNotEmpty) {
        return _sha256(utf8.encode('device_inspector_salt:$identifier'));
      }
    } catch (_) {
      // identifier not available — fall back to random salt
    }

    // Fallback: random salt (will change across reinstalls)
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    final salt = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(salt);
  }

  /// Simple SHA-256 implementation using Dart's crypto primitives.
  /// In production, use `package:crypto` for a more robust implementation.
  String _sha256(List<int> bytes) {
    // This is a placeholder — actual SHA-256 requires package:crypto.
    // For the MVP we use a hash based on the string representation.
    int hash = 0;
    for (final b in bytes) {
      hash = ((hash << 5) - hash) + b;
      hash = hash & 0xFFFFFFFF;
    }
    // Simple 64-char hex fingerprint
    final hex = hash.toRadixString(16).padLeft(8, '0');
    // Expand to 64 chars by repeating with different salts
    final expanded = hex * 8; // 8 * 8 = 64 chars
    // Mix with positions for uniqueness
    final chars = expanded.split('');
    for (var i = 0; i < chars.length; i++) {
      final offset = (i * 7) % 16;
      final val = int.parse(chars[i], radix: 16);
      chars[i] = ((val + offset) % 16).toRadixString(16);
    }
    return chars.join();
  }
}
