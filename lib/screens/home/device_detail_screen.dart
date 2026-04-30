import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/providers/auth_provider.dart';
import 'package:smart_home/providers/device_provider.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  IconData _getSwitchIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('light') || lower.contains('lamp')) {
      return Icons.lightbulb_rounded;
    }
    if (lower.contains('fan')) return Icons.air_rounded;
    if (lower.contains('ac') || lower.contains('air')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('pump') || lower.contains('water')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('tv')) return Icons.tv_rounded;
    if (lower.contains('door')) return Icons.door_front_door_rounded;
    if (lower.contains('heater')) return Icons.local_fire_department_rounded;
    return Icons.power_settings_new_rounded;
  }

  Color _getSwitchColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('light') || lower.contains('lamp')) return Colors.amber;
    if (lower.contains('fan')) return Colors.blue;
    if (lower.contains('ac') || lower.contains('air')) return Colors.cyan;
    if (lower.contains('pump') || lower.contains('water')) return Colors.teal;
    if (lower.contains('heater')) return Colors.deepOrange;
    return const Color(0xFF6C63FF);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = device.switches.values
        .where((v) => (v as Map<String, dynamic>)['state'] == true)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(device.deviceName),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule_rounded),
            tooltip: 'Add Schedule',
            onPressed: () {
              final userId =
                  context.read<AuthProvider>().currentUser?.uid ?? '';
              Navigator.pushNamed(
                context,
                '/add-schedule',
                arguments: {'device': device, 'userId': userId},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.router_rounded,
                            color: Color(0xFF6C63FF),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.deviceName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$activeCount of ${device.switches.length} switches active',
                                style: TextStyle(
                                  color: activeCount > 0
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.fingerprint_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ID: ${device.deviceId.substring(0, 12)}...',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Added: ${_formatDate(device.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Switches Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Switches',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$activeCount active',
                  style: TextStyle(
                    color: activeCount > 0 ? Colors.green : Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Switch Controls
            ...device.switches.entries.map((entry) {
              final switchId = entry.key;
              final switchData = entry.value as Map<String, dynamic>;
              final switchName = switchData['name'] ?? 'Switch';
              final switchState = switchData['state'] ?? false;

              return _SwitchControlCard(
                device: device,
                switchId: switchId,
                switchName: switchName,
                switchState: switchState,
                icon: _getSwitchIcon(switchName),
                color: _getSwitchColor(switchName),
              );
            }),

            const SizedBox(height: 20),

            // Add Schedule Button
            SizedBox(
              width: double.infinity,
              height: 52,
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
                icon: const Icon(Icons.schedule_rounded),
                label: const Text(
                  'Add Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _SwitchControlCard extends StatelessWidget {
  final Device device;
  final String switchId;
  final String switchName;
  final bool switchState;
  final IconData icon;
  final Color color;

  const _SwitchControlCard({
    required this.device,
    required this.switchId,
    required this.switchName,
    required this.switchState,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: switchState
            ? color.withOpacity(0.08)
            : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: switchState ? color.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: switchState
                    ? color.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 26,
                color: switchState ? color : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 14),

            // Name & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    switchName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: switchState ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        switchState ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          color: switchState ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Toggle
            Switch(
              value: switchState,
              activeColor: color,
              onChanged: (value) {
                context.read<DeviceProvider>()?.updateSwitchState(
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
