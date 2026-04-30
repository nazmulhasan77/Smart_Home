import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/providers/device_provider.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  // Icon mapping for switch names
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
    if (lower.contains('tv') || lower.contains('television')) {
      return Icons.tv_rounded;
    }
    if (lower.contains('door') || lower.contains('gate')) {
      return Icons.door_front_door_rounded;
    }
    if (lower.contains('camera') || lower.contains('cctv')) {
      return Icons.videocam_rounded;
    }
    if (lower.contains('heater') || lower.contains('heat')) {
      return Icons.local_fire_department_rounded;
    }
    return Icons.power_settings_new_rounded;
  }

  Color _getSwitchColor(String name, bool isOn) {
    if (!isOn) return Colors.grey.shade400;
    final lower = name.toLowerCase();
    if (lower.contains('light') || lower.contains('lamp')) {
      return Colors.amber;
    }
    if (lower.contains('fan')) return Colors.blue;
    if (lower.contains('ac') || lower.contains('air')) {
      return Colors.cyan;
    }
    if (lower.contains('pump') || lower.contains('water')) {
      return Colors.teal;
    }
    if (lower.contains('heater') || lower.contains('heat')) {
      return Colors.deepOrange;
    }
    return const Color(0xFF6C63FF);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = device.switches.values
        .where((v) => (v as Map<String, dynamic>)['state'] == true)
        .length;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _showEditDialog(context),
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          SlidableAction(
            onPressed: (context) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/device-detail',
            arguments: device,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.router_rounded,
                        color: Color(0xFF6C63FF),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.deviceName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$activeCount/${device.switches.length} switches on',
                            style: TextStyle(
                              fontSize: 12,
                              color: activeCount > 0
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Switches Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: device.switches.entries.map((entry) {
                    final switchId = entry.key;
                    final switchData = entry.value as Map<String, dynamic>;
                    final switchName = switchData['name'] ?? 'Switch';
                    final switchState = switchData['state'] ?? false;

                    return _SwitchTile(
                      device: device,
                      switchId: switchId,
                      switchName: switchName,
                      switchState: switchState,
                      icon: _getSwitchIcon(switchName),
                      activeColor: _getSwitchColor(switchName, true),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: device.deviceName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Device Name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Device Name',
              prefixIcon: Icon(Icons.devices_rounded),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name cannot be empty' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<DeviceProvider>()?.updateDeviceName(
                  device.deviceId,
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Device'),
        content: Text(
          'Delete "${device.deviceName}"? This will also remove all associated schedules.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DeviceProvider>()?.deleteDevice(device.deviceId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final Device device;
  final String switchId;
  final String switchName;
  final bool switchState;
  final IconData icon;
  final Color activeColor;

  const _SwitchTile({
    required this.device,
    required this.switchId,
    required this.switchName,
    required this.switchState,
    required this.icon,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () => _showEditSwitchName(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: switchState
              ? activeColor.withOpacity(0.12)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: switchState
                ? activeColor.withOpacity(0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: () {
            context.read<DeviceProvider>()?.updateSwitchState(
              device.deviceId,
              switchId,
              !switchState,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: switchState ? activeColor : Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        switchName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: switchState
                              ? activeColor
                              : Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        switchState ? 'ON' : 'OFF',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: switchState ? activeColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: switchState,
                    activeColor: activeColor,
                    onChanged: (value) {
                      context.read<DeviceProvider>()?.updateSwitchState(
                        device.deviceId,
                        switchId,
                        value,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSwitchName(BuildContext context) {
    final controller = TextEditingController(text: switchName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Switch Name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Switch Name',
              prefixIcon: Icon(Icons.power_settings_new_rounded),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name cannot be empty' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<DeviceProvider>()?.updateSwitchName(
                  device.deviceId,
                  switchId,
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
