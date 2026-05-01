import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/providers/auth_provider.dart';
import 'package:smart_home/providers/device_provider.dart';
import 'package:smart_home/providers/theme_provider.dart';
import 'package:smart_home/screens/home/firebase_device_inspector_screen.dart';
import 'package:smart_home/screens/profile/profile_screen.dart';
import 'package:smart_home/widgets/device_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Realtime stream — direct from Firebase, no provider cache lag
  Stream<List<Device>>? _devicesStream;
  String? _streamUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deviceProvider = context.read<DeviceProvider?>();
    if (deviceProvider != null && deviceProvider.userId != _streamUserId) {
      _streamUserId = deviceProvider.userId;
      _devicesStream = deviceProvider.getDevicesStream();
    }
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
                        stream: _devicesStream ?? deviceProvider.getDevicesStream(),
                        builder: (context, snapshot) {
                          // ConnectionState.waiting → show shimmer/loading
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                            );
                          }

                          final devices = snapshot.data ?? [];

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
                                    // Live indicator
                                    Row(
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: snapshot.connectionState ==
                                                    ConnectionState.active
                                                ? Colors.green
                                                : Colors.grey,
                                            shape: BoxShape.circle,
                                            boxShadow: snapshot
                                                        .connectionState ==
                                                    ConnectionState.active
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.green
                                                          .withValues(
                                                              alpha: 0.5),
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
                                            color: snapshot.connectionState ==
                                                    ConnectionState.active
                                                ? Colors.green
                                                : Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: _showAddDeviceDialog,
                                          icon: const Icon(Icons.add_rounded),
                                          label: const Text('Add'),
                                        ),
                                      ],
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
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Firebase Data Inspector Button
              FloatingActionButton.small(
                heroTag: 'firebase_debug',
                onPressed: () => _showFirebaseDataSheet(context),
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                tooltip: 'Firebase Data',
                child: const Icon(Icons.storage_rounded, size: 20),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.extended(
                heroTag: 'add_device',
                onPressed: _showAddDeviceDialog,
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Device'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(DeviceProvider? deviceProvider) {
    final devices = deviceProvider?.devices ?? [];

    return StreamBuilder<List<Device>>(
      stream: _devicesStream,
      builder: (context, snapshot) {
        final liveDevices = snapshot.data ?? devices;
        int total = 0;
        int active = 0;
        for (final d in liveDevices) {
          for (final entry in d.switches.entries) {
            total++;
            final sw = entry.value as Map<String, dynamic>;
            if (sw['state'] == true) active++;
          }
        }
        return Row(
          children: [
            _StatChip(
              icon: Icons.devices_rounded,
              label: '${liveDevices.length} Devices',
            ),
            const SizedBox(width: 10),
            _StatChip(
              icon: Icons.power_rounded,
              label: '$active/$total On',
            ),
          ],
        );
      },
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

  void _showFirebaseDataSheet(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FirebaseDataSheet(userId: user.uid),
      ),
    );
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

// ─────────────────────────────────────────────────────────────────────────────
// Firebase Data Inspector Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FirebaseDataSheet extends StatefulWidget {
  final String userId;
  const _FirebaseDataSheet({required this.userId});

  @override
  State<_FirebaseDataSheet> createState() => _FirebaseDataSheetState();
}

class _FirebaseDataSheetState extends State<_FirebaseDataSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Firestore data
  Map<String, dynamic>? _userProfile;

  // Realtime DB — streams
  late Stream<List<Map<String, dynamic>>> _devicesStream;
  late Stream<List<Map<String, dynamic>>> _schedulesStream;

  // Latest values (for tab count display)
  List<Map<String, dynamic>> _devices = [];
  List<Map<String, dynamic>> _schedules = [];

  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _devicesStream = _buildDevicesStream();
    _schedulesStream = _buildSchedulesStream();
    _loadProfile();
  }

  Stream<List<Map<String, dynamic>>> _buildDevicesStream() {
    return FirebaseDatabase.instance
        .ref('users/${widget.userId}/devices')
        .onValue
        .map((event) {
      final list = <Map<String, dynamic>>[];
      if (event.snapshot.exists) {
        final raw = event.snapshot.value as Map<dynamic, dynamic>;
        raw.forEach((k, v) {
          list.add(Map<String, dynamic>.from(v as Map));
        });
      }
      return list;
    });
  }

  Stream<List<Map<String, dynamic>>> _buildSchedulesStream() {
    return FirebaseDatabase.instance
        .ref('users/${widget.userId}/schedules')
        .onValue
        .map((event) {
      final list = <Map<String, dynamic>>[];
      if (event.snapshot.exists) {
        final raw = event.snapshot.value as Map<dynamic, dynamic>;
        raw.forEach((k, v) {
          list.add(Map<String, dynamic>.from(v as Map));
        });
      }
      return list;
    });
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      _userProfile = doc.data();
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F2F5);
    final surface = isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.storage_rounded,
                color: Color(0xFFFF6D00),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Firebase Data Inspector',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'UID: ${widget.userId.substring(0, 12)}...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            color: const Color(0xFF6C63FF),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_rounded, size: 14),
                        SizedBox(width: 4),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.devices_rounded, size: 14),
                        const SizedBox(width: 4),
                        Text('Devices (${_devices.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.schedule_rounded, size: 14),
                        const SizedBox(width: 4),
                        Text('Schedules (${_schedules.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  SizedBox(height: 12),
                  Text('Loading Firebase data...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Error loading data',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadProfile,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Tab 1: User Profile (Firestore) ──
                    _ProfileTab(
                        profile: _userProfile,
                        scrollController: ScrollController()),

                    // ── Tab 2: Devices (Realtime DB) — real-time stream ──
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _devicesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        final devices = snapshot.data ?? [];
                        // keep count in sync for tab label
                        if (devices.length != _devices.length) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _devices = devices);
                          });
                        }
                        return _DevicesTab(
                          devices: devices,
                          scrollController: ScrollController(),
                          userId: widget.userId,
                          onRefresh: () {},
                        );
                      },
                    ),

                    // ── Tab 3: Schedules (Realtime DB) — real-time stream ──
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _schedulesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        final schedules = snapshot.data ?? [];
                        if (schedules.length != _schedules.length) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _schedules = schedules);
                          });
                        }
                        return _SchedulesTab(
                          schedules: schedules,
                          scrollController: ScrollController(),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}

// ── Profile Tab ──────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final ScrollController scrollController;

  const _ProfileTab(
      {required this.profile, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Center(
        child: Text('No profile data found in Firestore'),
      );
    }

    final fields = [
      _DataField('uid', profile!['uid'], Icons.fingerprint_rounded),
      _DataField('email', profile!['email'], Icons.email_rounded),
      _DataField('displayName', profile!['displayName'], Icons.person_rounded),
      _DataField(
          'isGoogleUser',
          profile!['isGoogleUser']?.toString() ?? 'false',
          Icons.g_mobiledata_rounded),
      _DataField(
          'photoUrl',
          profile!['photoUrl'] ?? '(none)',
          Icons.image_rounded),
      _DataField(
          'createdAt',
          _formatTimestamp(profile!['createdAt']),
          Icons.calendar_today_rounded),
      _DataField(
          'lastLoginAt',
          _formatTimestamp(profile!['lastLoginAt']),
          Icons.login_rounded),
    ];

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _SectionHeader(
          icon: Icons.cloud_rounded,
          title: 'Firestore → users/${profile!['uid']?.toString().substring(0, 8) ?? '...'}...',
          color: const Color(0xFF1A73E8),
        ),
        const SizedBox(height: 8),
        ...fields.map((f) => _DataRow(field: f)),
      ],
    );
  }

  String _formatTimestamp(dynamic value) {
    if (value == null) return '(none)';
    if (value is Timestamp) {
      final dt = value.toDate();
      return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}:${_p(dt.second)}';
    }
    return value.toString();
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

// ── Devices Tab ───────────────────────────────────────────────────────────────

class _DevicesTab extends StatefulWidget {
  final List<Map<String, dynamic>> devices;
  final ScrollController scrollController;
  final String userId;
  final VoidCallback onRefresh;

  const _DevicesTab({
    required this.devices,
    required this.scrollController,
    required this.userId,
    required this.onRefresh,
  });

  @override
  State<_DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<_DevicesTab> {
  static const _green = Color(0xFF34A853);
  static const _purple = Color(0xFF6C63FF);
  static const _red = Color(0xFFE53935);

  // Local optimistic switch states: deviceId → switchId → bool
  final Map<String, Map<String, bool>> _localStates = {};

  bool _switchState(String deviceId, String switchId, bool fallback) {
    return _localStates[deviceId]?[switchId] ?? fallback;
  }

  Future<void> _toggleSwitch(
      String deviceId, String switchId, bool newState) async {
    setState(() {
      _localStates.putIfAbsent(deviceId, () => {})[switchId] = newState;
    });
    try {
      await FirebaseDatabase.instance
          .ref('users/${widget.userId}/devices/$deviceId/switches/$switchId/state')
          .set(newState);
    } catch (e) {
      setState(() {
        _localStates[deviceId]![switchId] = !newState;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update switch: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _renameDevice(
      String deviceId, String currentName) async {
    final ctrl = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_rounded, color: _purple, size: 20),
            SizedBox(width: 8),
            Text('Edit Device Name', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter device name',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _purple, width: 2),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName == null || newName.trim().isEmpty) return;
    try {
      await FirebaseDatabase.instance
          .ref('users/${widget.userId}/devices/$deviceId/deviceName')
          .set(newName.trim());
      widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Renamed to "${newName.trim()}"'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to rename: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _deleteDevice(String deviceId, String deviceName) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.delete_rounded, color: _red, size: 20),
                SizedBox(width: 8),
                Text('Delete Device', style: TextStyle(fontSize: 16)),
              ],
            ),
            content: Text(
                'Delete "$deviceName" from Firebase?\nThis cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await FirebaseDatabase.instance
          .ref('users/${widget.userId}/devices/$deviceId')
          .remove();
      widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"$deviceName" deleted'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  void _openFullPage(Map<String, dynamic> device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirebaseDeviceInspectorScreen(
          userId: widget.userId,
          deviceData: device,
        ),
      ),
    ).then((result) {
      if (result == 'deleted') widget.onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.devices_other_rounded, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No devices saved in Realtime Database'),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF8F8F8);

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: widget.devices.map((device) {
        final deviceId = device['deviceId']?.toString() ?? '';
        final deviceName = device['deviceName']?.toString() ?? 'Device';
        final switches =
            (device['switches'] as Map<dynamic, dynamic>? ?? {}).map(
          (k, v) => MapEntry(
              k.toString(), Map<String, dynamic>.from(v as Map)),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _green.withOpacity(0.18), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Device header row ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.router_rounded,
                          color: _green, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        deviceName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _green,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Edit name
                    IconButton(
                      icon: const Icon(Icons.edit_rounded,
                          size: 18, color: _purple),
                      tooltip: 'Edit name',
                      onPressed: () =>
                          _renameDevice(deviceId, deviceName),
                      visualDensity: VisualDensity.compact,
                    ),
                    // Delete
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          size: 18, color: _red),
                      tooltip: 'Delete device',
                      onPressed: () =>
                          _deleteDevice(deviceId, deviceName),
                      visualDensity: VisualDensity.compact,
                    ),
                    // Open full page
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded,
                          size: 18, color: Color(0xFFFF6D00)),
                      tooltip: 'Open full page',
                      onPressed: () => _openFullPage(device),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // ── Meta info ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: Text(
                  deviceId,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const Divider(height: 16, indent: 14, endIndent: 14),

              // ── Switches ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  children: switches.entries.map((entry) {
                    final switchId = entry.key;
                    final sw = entry.value;
                    final isOn = _switchState(
                        deviceId, switchId, sw['state'] == true);
                    final name =
                        sw['name']?.toString() ?? switchId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 250),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOn
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$switchId: $name',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace'),
                            ),
                          ),
                          // ON/OFF badge
                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOn
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(
                              isOn ? 'ON' : 'OFF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isOn
                                    ? Colors.green
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Toggle
                          Transform.scale(
                            scale: 0.8,
                            child: Switch.adaptive(
                              value: isOn,
                              activeColor: _green,
                              onChanged: (v) =>
                                  _toggleSwitch(deviceId, switchId, v),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Schedules Tab ─────────────────────────────────────────────────────────────
class _SchedulesTab extends StatelessWidget {
  final List<Map<String, dynamic>> schedules;
  final ScrollController scrollController;

  const _SchedulesTab(
      {required this.schedules, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No schedules saved in Realtime Database'),
          ],
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: schedules.map((sch) {
        final isActive = sch['isActive'] == true;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.alarm_rounded,
              title:
                  '${sch['action'] ?? 'Action'} — ${sch['switchId'] ?? ''}',
              color: const Color(0xFFFF6D00),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _DataRow(
                field: _DataField(
                    'scheduleId', sch['scheduleId'], Icons.tag_rounded)),
            _DataRow(
                field: _DataField(
                    'deviceId', sch['deviceId'], Icons.router_rounded)),
            _DataRow(
                field: _DataField(
                    'switchId', sch['switchId'], Icons.toggle_on_rounded)),
            _DataRow(
                field: _DataField('action', sch['action'],
                    Icons.power_settings_new_rounded)),
            _DataRow(
                field: _DataField('scheduledTime',
                    _formatMs(sch['scheduledTime']), Icons.access_time_rounded)),
            _DataRow(
                field: _DataField(
                    'isRecurring',
                    sch['isRecurring']?.toString() ?? 'false',
                    Icons.repeat_rounded)),
            if (sch['recurringPattern'] != null)
              _DataRow(
                  field: _DataField('recurringPattern',
                      sch['recurringPattern'], Icons.loop_rounded)),
            _DataRow(
                field: _DataField('createdAt', _formatMs(sch['createdAt']),
                    Icons.calendar_today_rounded)),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  String _formatMs(dynamic ms) {
    if (ms == null) return '(none)';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(ms as int);
      return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}';
    } catch (_) {
      return ms.toString();
    }
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _DataField {
  final String key;
  final dynamic value;
  final IconData icon;
  const _DataField(this.key, this.value, this.icon);
}

class _DataRow extends StatelessWidget {
  final _DataField field;
  const _DataRow({required this.field});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF8F8F8);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(field.icon, size: 15, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              field.key,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              field.value?.toString() ?? '(null)',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
