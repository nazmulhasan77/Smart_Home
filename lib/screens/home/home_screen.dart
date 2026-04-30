import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/providers/auth_provider.dart';
import 'package:smart_home/providers/device_provider.dart';
import 'package:smart_home/widgets/device_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // 🔥 SAFE UID injection (multi-user support)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();

      if (auth.currentUser != null) {
        context.read<DeviceProvider>().setUser(auth.currentUser!.uid);
      }
    });
  }

  void _showAddDeviceDialog() {
    final deviceNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Device'),
        content: TextField(
          controller: deviceNameController,
          decoration: const InputDecoration(
            labelText: 'Device Name',
            hintText: 'e.g., Living Room',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = deviceNameController.text.trim();

              if (name.isNotEmpty) {
                context.read<DeviceProvider>().addDevice(name);
              }

              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Schedules'),
                onTap: () {
                  Navigator.pushNamed(context, '/schedules');
                },
              ),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  context.read<AuthProvider>().signOut();
                },
              ),
            ],
          ),
        ],
      ),

      body: deviceProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : deviceProvider.devices.isEmpty
          ? _buildEmptyState()
          : StreamBuilder<List<Device>>(
              stream: deviceProvider.getDevicesStream(),
              builder: (context, snapshot) {
                final devices = snapshot.data ?? deviceProvider.devices;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...devices.map((device) => DeviceCard(device: device)),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _showAddDeviceDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Device'),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 90,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No devices found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first smart device',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddDeviceDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Device'),
          ),
        ],
      ),
    );
  }
}
