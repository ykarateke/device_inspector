import 'package:flutter/material.dart';
import 'package:device_inspector/device_inspector.dart';

void main() {
  runApp(const DeviceInspectorExample());
}

class DeviceInspectorExample extends StatelessWidget {
  const DeviceInspectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(child: DeviceInfoView()),
      ),
    );
  }
}

class DeviceInfoView extends StatefulWidget {
  const DeviceInfoView({super.key});

  @override
  State<DeviceInfoView> createState() => _DeviceInfoViewState();
}

class _DeviceInfoViewState extends State<DeviceInfoView> {
  DeviceSnapshot? _snapshot;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snapshot = await DeviceInspector.inspect();
      if (mounted) setState(() { _snapshot = snapshot; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
      );
    }

    final s = _snapshot!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(s),
          const SizedBox(height: 24),
          _Section('Device', [
            _Row('Manufacturer', s.device.manufacturer),
            _Row('Model', s.device.model),
            _Row('Market Name', s.device.marketName),
            _Row('Tier', s.device.tier.name.toUpperCase()),
          ]),
          _Section('OS', [
            _Row('Platform', s.os.platform),
            _Row('Version', s.os.version),
            if (s.os.apiLevel != null) _Row('API Level', '${s.os.apiLevel}'),
          ]),
          _Section('Battery', [
            _Row('Level', '${s.battery.level}%'),
            _Row('Charging', s.battery.isCharging ? 'Yes' : 'No'),
            _Row('State', s.battery.chargingState.name),
            _Row('Low Power', s.battery.isLowPowerMode ? 'Yes' : 'No'),
          ]),
          _Section('Network', [
            _Row('Type', s.network.type.name.toUpperCase()),
            if (s.network.carrier != null) _Row('Carrier', s.network.carrier!),
            _Row('VPN', s.network.isVpn ? 'Yes' : 'No'),
            _Row('Proxy', s.network.isProxy ? 'Yes' : 'No'),
          ]),
          _Section('Hardware', [
            _Row('CPU', '${s.hardware.cpu.name} (${s.hardware.cpu.cores} cores)'),
            _Row('Architecture', s.hardware.cpu.architecture),
            _Row('GPU', s.hardware.gpu.name),
            _Row('Display', '${s.hardware.display.widthPixels}x${s.hardware.display.heightPixels}'),
            _Row('Refresh', '${s.hardware.display.refreshRate} Hz'),
          ]),
          _Section('Memory', [
            _Row('Total', s.memory.formattedTotal),
            _Row('Available', s.memory.formattedAvailable),
            _Row('Usage', '${s.memory.usagePercent.toStringAsFixed(1)}%'),
          ]),
          _Section('Storage', [
            _Row('Total', s.storage.formattedTotal),
            _Row('Free', s.storage.formattedFree),
            _Row('Usage', '${s.storage.usagePercent.toStringAsFixed(1)}%'),
          ]),
          _Section('Security', [
            _Row('Rooted', s.security.isRooted ? '⚠ Yes' : 'No'),
            _Row('Jailbroken', s.security.isJailbroken ? '⚠ Yes' : 'No'),
            _Row('Emulator', s.security.isEmulator ? '⚠ Yes' : 'No'),
            _Row('Debugger', s.security.isDebuggerAttached ? '⚠ Yes' : 'No'),
            _Row('Score', '${s.security.securityScore}/100'),
            if (s.security.detectedThreats.isNotEmpty)
              _Row('Threats', s.security.detectedThreats.join(', ')),
          ]),
          _Section('App', [
            _Row('Name', s.app.appName),
            _Row('Version', s.app.version),
            _Row('Build', s.app.buildNumber),
            _Row('Bundle ID', s.app.bundleId),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final DeviceSnapshot snapshot;
  const _Header(this.snapshot);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${snapshot.device.marketName}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${snapshot.os.platform} ${snapshot.os.version}  ·  Tier: ${snapshot.device.tier.name.toUpperCase()}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            )),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Flexible(child: Text(value, textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
