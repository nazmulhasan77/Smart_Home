import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/models/schedule_model.dart';
import 'package:smart_home/providers/auth_provider.dart';
import 'package:smart_home/providers/device_provider.dart';
import 'package:smart_home/providers/schedule_provider.dart';
import 'package:smart_home/providers/theme_provider.dart';
import 'package:smart_home/widgets/device_card.dart';
import 'package:smart_home/screens/schedule/schedule_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Stream<List<Device>>? _devicesStream;
  String? _streamUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deviceProvider = context.read<DeviceProvider?>();
    if (deviceProvider != null && deviceProvider.userId != _streamUserId) {
      _streamUserId = deviceProvider.userId;
      _devicesStream = deviceProvider.getDevicesStream();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
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
                    .read<DeviceProvider?>()
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

  void _confirmLogout() {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer2<DeviceProvider?, ScheduleProvider?>(
      builder: (context, deviceProvider, scheduleProvider, _) {
        // Live device count for tab label
        return StreamBuilder<List<Device>>(
          stream: _devicesStream ?? deviceProvider?.getDevicesStream(),
          builder: (context, deviceSnapshot) {
            final devices = deviceSnapshot.data ?? deviceProvider?.devices ?? [];

            return StreamBuilder<List<Schedule>>(
              stream: scheduleProvider?.getSchedulesStream(),
              builder: (context, scheduleSnapshot) {
                final schedules =
                    scheduleSnapshot.data ?? scheduleProvider?.schedules ?? [];

                return Scaffold(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  appBar: AppBar(
                    backgroundColor:
                        isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    elevation: 0,
                    titleSpacing: 16,
                    title: Row(
                      children: [
                        // Hamburger / menu icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.menu_rounded,
                            color: Color(0xFF6C63FF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // UID display
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (user?.uid != null) {
                                Clipboard.setData(
                                    ClipboardData(text: user!.uid));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('UID copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'UID: ${user?.uid != null ? '${user!.uid.substring(0, 14)}...' : '—'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      // Add Device button in AppBar
                      IconButton(
                        onPressed: _showAddDeviceDialog,
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Color(0xFF6C63FF),
                          size: 26,
                        ),
                        tooltip: 'Add Device',
                      ),
                      // Refresh / more options
                      PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const ListTile(
                              leading: Icon(Icons.refresh_rounded),
                              title: Text('Refresh'),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap: () => deviceProvider?.loadDevices(),
                          ),
                          PopupMenuItem(
                            child: const ListTile(
                              leading: Icon(
                                Icons.logout_rounded,
                                color: Colors.red,
                              ),
                              title: Text(
                                'Sign Out',
                                style: TextStyle(color: Colors.red),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap: _confirmLogout,
                          ),
                        ],
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(56),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A3E)
                                : const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: const Color(0xFF6C63FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            labelStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            dividerColor: Colors.transparent,
                            tabs: [
                              Tab(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.person_rounded, size: 15),
                                    SizedBox(width: 5),
                                    Text('Profile'),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.devices_rounded,
                                        size: 15),
                                    const SizedBox(width: 5),
                                    Text('Devices (${devices.length})'),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.schedule_rounded,
                                        size: 15),
                                    const SizedBox(width: 5),
                                    Text('Schedules (${schedules.length})'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // ── Tab 1: Profile ──────────────────────────────
                      _ProfileTab(onLogout: _confirmLogout),

                      // ── Tab 2: Devices ──────────────────────────────
                      _DevicesTab(
                        devices: devices,
                        deviceSnapshot: deviceSnapshot,
                        onAddDevice: _showAddDeviceDialog,
                      ),

                      // ── Tab 3: Schedules ────────────────────────────
                      _SchedulesTab(schedules: schedules),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Tab
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfileTab({required this.onLogout});

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Display Name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name cannot be empty' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context
                    .read<AuthProvider>()
                    .updateDisplayName(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final deviceProvider = context.watch<DeviceProvider?>();
    final scheduleProvider = context.watch<ScheduleProvider?>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;

    final deviceCount = deviceProvider?.devices.length ?? 0;
    final scheduleCount = scheduleProvider?.schedules.length ?? 0;
    int activeSwitches = 0;
    for (final device in deviceProvider?.devices ?? []) {
      for (final entry in device.switches.entries) {
        final sw = entry.value as Map<String, dynamic>;
        if (sw['state'] == true) activeSwitches++;
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
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
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.devices_rounded,
                    value: '$deviceCount',
                    label: 'Devices',
                    color: const Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.power_rounded,
                    value: '$activeSwitches',
                    label: 'Active',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.schedule_rounded,
                    value: '$scheduleCount',
                    label: 'Schedules',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Account info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Display Name'),
                        subtitle: Text(user?.displayName ?? ''),
                        trailing:
                            const Icon(Icons.edit_outlined, size: 18),
                        onTap: () => _showEditNameDialog(
                            context, user?.displayName ?? ''),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        subtitle: Text(user?.email ?? ''),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Preferences
                Text(
                  'Preferences',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: SwitchListTile(
                    secondary: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                    ),
                    title: const Text('Dark Mode'),
                    subtitle:
                        Text(isDark ? 'Dark theme' : 'Light theme'),
                    value: isDark,
                    onChanged: (_) =>
                        context.read<ThemeProvider>().toggleTheme(),
                  ),
                ),
                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: onLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Devices Tab
// ─────────────────────────────────────────────────────────────────────────────
class _DevicesTab extends StatelessWidget {
  final List<Device> devices;
  final AsyncSnapshot<List<Device>> deviceSnapshot;
  final VoidCallback onAddDevice;

  const _DevicesTab({
    required this.devices,
    required this.deviceSnapshot,
    required this.onAddDevice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (deviceSnapshot.connectionState == ConnectionState.waiting &&
        devices.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (devices.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Devices',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                // Live indicator
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: deviceSnapshot.connectionState ==
                            ConnectionState.active
                        ? Colors.green
                        : Colors.grey,
                    shape: BoxShape.circle,
                    boxShadow: deviceSnapshot.connectionState ==
                            ConnectionState.active
                        ? [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.5),
                              blurRadius: 6,
                            )
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 12,
                    color: deviceSnapshot.connectionState ==
                            ConnectionState.active
                        ? Colors.green
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...devices.map((device) => DeviceCard(device: device)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_outlined,
                size: 56,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Devices Yet',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Add your first smart device to start\ncontrolling your home',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAddDevice,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Your First Device'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schedules Tab
// ─────────────────────────────────────────────────────────────────────────────
class _SchedulesTab extends StatelessWidget {
  final List<Schedule> schedules;
  const _SchedulesTab({required this.schedules});

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: schedules.length,
      itemBuilder: (context, index) =>
          ScheduleCard(schedule: schedules[index]),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule_rounded,
                size: 56,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Schedules Yet',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Automate your devices by creating\nschedules to turn them on or off',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/device-selector'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Stat Card
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
