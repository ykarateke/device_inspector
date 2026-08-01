import 'package:flutter_test/flutter_test.dart';
import 'package:device_inspector/src/models/hardware_info.dart';

void main() {
  group('CPUInfo', () {
    final sampleJson = {
      'name': 'A17 Pro', 'cores': 6, 'architecture': 'arm64',
      'maxFrequencyMHz': 3780, 'performanceCores': 4,
      'efficiencyCores': 2, 'hasNeuralEngine': true,
    };
    test('fromJson -> toJson roundtrip', () {
      final info = CPUInfo.fromJson(sampleJson);
      final json = info.toJson();
      expect(json['name'], 'A17 Pro');
      expect(json['cores'], 6);
      expect(json['hasNeuralEngine'], true);
    });
    test('unknown() returns safe defaults', () {
      final info = CPUInfo.unknown();
      expect(info.name, 'Unknown');
      expect(info.cores, 0);
      expect(info.architecture, 'unknown');
    });
  });

  group('GPUInfo', () {
    test('fromJson with Metal support', () {
      final json = {'name': 'Apple GPU', 'supportsMetal': true, 'metalFeatureSet': 'MTLGPUFamilyApple9', 'supportsVulkan': false};
      final info = GPUInfo.fromJson(json);
      expect(info.name, 'Apple GPU');
      expect(info.supportsMetal, true);
      expect(info.supportsVulkan, false);
    });
    test('unknown() returns safe defaults', () {
      final info = GPUInfo.unknown();
      expect(info.name, 'Unknown');
      expect(info.supportsMetal, false);
    });
  });

  group('DisplayInfo', () {
    test('fromJson with 120Hz HDR display', () {
      final json = {'widthPixels': 1179, 'heightPixels': 2556, 'density': 3.0, 'refreshRate': 120, 'supportsHdr': true, 'brightnessLevel': 0.85};
      final info = DisplayInfo.fromJson(json);
      expect(info.widthPixels, 1179);
      expect(info.refreshRate, 120);
      expect(info.supportsHdr, true);
    });
    test('unknown() returns zero defaults', () {
      final info = DisplayInfo.unknown();
      expect(info.widthPixels, 0);
      expect(info.heightPixels, 0);
      expect(info.density, 0);
    });
  });

  group('HardwareInfo', () {
    test('aggregates CPU, GPU, and Display', () {
      final json = {
        'cpu': {'name': 'A17 Pro', 'cores': 6, 'architecture': 'arm64'},
        'gpu': {'name': 'Apple GPU', 'supportsMetal': true, 'supportsVulkan': false},
        'display': {'widthPixels': 1179, 'heightPixels': 2556, 'density': 3.0},
        'tier': 'high',
      };
      final info = HardwareInfo.fromJson(json);
      expect(info.cpu.name, 'A17 Pro');
      expect(info.gpu.name, 'Apple GPU');
      expect(info.display.widthPixels, 1179);
    });
    test('unknown() returns all sub-unknowns', () {
      final info = HardwareInfo.unknown();
      expect(info.cpu.name, 'Unknown');
      expect(info.gpu.name, 'Unknown');
      expect(info.display.widthPixels, 0);
    });
  });
}
