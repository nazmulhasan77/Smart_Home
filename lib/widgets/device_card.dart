import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/providers/device_provider.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _showEditDialog(context);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
              context.read<DeviceProvider>().deleteDevice(device.deviceId);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.deviceName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${device.deviceId.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/device-detail',
                        arguments: device,
                      );
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
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
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: device.deviceName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Device Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Device Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<DeviceProvider>().updateDeviceName(
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
}

class _SwitchTile extends StatelessWidget {
  final Device device;
  final String switchId;
  final String switchName;
  final bool switchState;

  const _SwitchTile({
    required this.device,
    required this.switchId,
    required this.switchName,
    required this.switchState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onLongPress: () {
          _showEditSwitchName(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.lightbulb,
                size: 32,
                color: switchState
                    ? Colors.amber
                    : Colors.grey.withValues(alpha: 0.5),
              ),
              Text(
                switchName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
      ),
    );
  }

  void _showEditSwitchName(BuildContext context) {
    final controller = TextEditingController(text: switchName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Switch Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Switch Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<DeviceProvider>().updateSwitchName(
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
