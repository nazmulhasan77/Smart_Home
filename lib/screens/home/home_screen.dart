import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/providers/auth_provider.dart';
import 'package:smart_home/providers/device_provider.dart';
import 'package:smart_home/providers/theme_provider.dart';
import 'package:smart_home/screens/profile/profile_screen.dart';
import 'package:smart_home/widgets/device_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showAddDeviceDialog() {
    final deviceNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_home_rounded,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Add Device'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: deviceNameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Device Name',
              hintText: 'e.g., Living Room, Bedroom',
              prefixIcon: Icon(Icons.devices_rounded),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter a device name' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context
                    .read<DeviceProvider>()
                    ?.addDevice(deviceNameController.text.trim());
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<DeviceProvider?>(
      builder: (context, deviceProvider, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF6C63FF),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user?.displayName ?? 'User',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Theme Toggle
                                    IconButton(
                                      onPressed: themeProvider.toggleTheme,
                                      icon: Icon(
                                        isDark
                                            ? Icons.light_mode_rounded
                                            : Icons.dark_mode_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    // Profile Avatar
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ProfileScreen(),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white24,
                                        backgroundImage: user?.photoUrl != null
                                            ? NetworkImage(user!.photoUrl!)
                                            : null,
                                        child: user?.photoUrl == null
                                            ? Text(
                                                (user?.displayName ?? 'U')
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Stats Row
                            _buildStatsRow(deviceProvider),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const ListTile(
                          leading: Icon(Icons.schedule_rounded),
                          title: Text('Schedules'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, '/schedules'),
                      ),
                      PopupMenuItem(
                        child: const ListTile(
                          leading: Icon(Icons.person_rounded),
                          title: Text('Profile'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: const ListTile(
                          leading: Icon(Icons.logout_rounded, color: Colors.red),
                          title: Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                ],
              ),

              // Body Content
              SliverToBoxAdapter(
                child: deviceProvider == null
                    ? const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : StreamBuilder<List<Device>>(
                        stream: deviceProvider.getDevicesStream(),
                        builder: (context, snapshot) {
                          final devices =
                              snapshot.data ?? deviceProvider.devices;

                          if (devices.isEmpty) {
                            return _buildEmptyState();
                          }

                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'My Devices',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: _showAddDeviceDialog,
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Add'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...devices.map(
                                  (device) => DeviceCard(device: device),
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddDeviceDialog,
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Device'),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(DeviceProvider? deviceProvider) {
    final devices = deviceProvider?.devices ?? [];
    int totalSwitches = 0;
    int activeSwitches = 0;

    for (final device in devices) {
      for (final entry in device.switches.entries) {
        totalSwitches++;
        final switchData = entry.value as Map<String, dynamic>;
        if (switchData['state'] == true) activeSwitches++;
      }
    }

    return Row(
      children: [
        _StatChip(
          icon: Icons.devices_rounded,
          label: '${devices.length} Devices',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.power_rounded,
          label: '$activeSwitches/$totalSwitches On',
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_outlined,
              size: 60,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Devices Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Add your first smart device to start\ncontrolling your home',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddDeviceDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Your First Device'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
