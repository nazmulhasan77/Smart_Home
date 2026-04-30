import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/providers/auth_provider.dart';
import 'package:smart_home/providers/device_provider.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(device.deviceName), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Device ID:'),
                        Text(
                          device.deviceId,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Created:'),
                        Text(
                          device.createdAt.toString().split('.')[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Switches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...device.switches.entries.map((entry) {
              final switchId = entry.key;
              final switchData = entry.value as Map<String, dynamic>;
              final switchName = switchData['name'] ?? 'Switch';
              final switchState = switchData['state'] ?? false;

              return SwitchControlTile(
                device: device,
                switchId: switchId,
                switchName: switchName,
                switchState: switchState,
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  final userId =
                      context.read<AuthProvider>().currentUser?.uid ?? '';
                  Navigator.pushNamed(
                    context,
                    '/add-schedule',
                    arguments: {'device': device, 'userId': userId},
                  );
                },
                icon: const Icon(Icons.schedule),
                label: const Text('Add Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwitchControlTile extends StatelessWidget {
  final Device device;
  final String switchId;
  final String switchName;
  final bool switchState;

  const SwitchControlTile({
    super.key,
    required this.device,
    required this.switchId,
    required this.switchName,
    required this.switchState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switchName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  switchState ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 12,
                    color: switchState ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Switch(
              value: switchState,
              onChanged: (value) {
                context.read<DeviceProvider>().updateSwitchState(
                  device.deviceId,
                  switchId,
                  value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
