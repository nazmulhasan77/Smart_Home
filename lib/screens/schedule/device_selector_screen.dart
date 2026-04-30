import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/providers/auth_provider.dart';
import 'package:smart_home/providers/device_provider.dart';

class DeviceSelectorScreen extends StatelessWidget {
  const DeviceSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Device'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Consumer<DeviceProvider?>(
        builder: (context, deviceProvider, _) {
          if (deviceProvider == null || deviceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deviceProvider.devices.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.devices_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No devices available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a device first to create a schedule',
                      style: TextStyle(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deviceProvider.devices.length,
            itemBuilder: (context, index) {
              final device = deviceProvider.devices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.router_rounded,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  title: Text(
                    device.deviceName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${device.switches.length} switches',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/add-schedule',
                      arguments: {'device': device, 'userId': userId},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
