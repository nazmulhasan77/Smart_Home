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
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<DeviceProvider?>(
        builder: (context, deviceProvider, _) {
          if (deviceProvider == null || deviceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deviceProvider.devices.isEmpty) {
            return Center(
              child: Text(
                'No devices available',
                style: Theme.of(context).textTheme.bodyMedium,
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
                  leading: const Icon(Icons.device_hub),
                  title: Text(device.deviceName),
                  trailing: const Icon(Icons.arrow_forward_ios),
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
