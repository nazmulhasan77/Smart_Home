import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FirebaseInspectorScreen extends StatefulWidget {
  final String userId;
  const FirebaseInspectorScreen({super.key, required this.userId});

  @override
  State<FirebaseInspectorScreen> createState() => _FirebaseInspectorScreenState();
}

class _FirebaseInspectorScreenState extends State<FirebaseInspectorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _devices = [];
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(widget.userId).get();
      _userProfile = doc.data();

      final devSnap = await FirebaseDatabase.instance
          .ref('users/${widget.userId}/devices').get();
      _devices = [];
      if (devSnap.exists) {
        final raw = devSnap.value as Map<dynamic, dynamic>;
        raw.forEach((k, v) => _devices.add(Map<String, dynamic>.from(v as Map)));
      }

      final schSnap = await FirebaseDatabase.instance
          .ref('users/${widget.userId}/schedules').get();
      _schedules = [];
      if (schSnap.exists) {
        final raw = schSnap.value as Map<dynamic, dynamic>;
        raw.forEach((k, v) => _schedules.add(Map<String, dynamic>.from(v as Map)));
      }
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleSwitch(String deviceId, String switchId, bool current) async {
    await FirebaseDatabase.instance
        .ref('users/${widget.userId}/devices/$deviceId/switches/$switchId/state')
        .set(!current);
    await _loadAll();
  }

  Future<void> _deleteDevice(String deviceId, String deviceName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Device'),
        content: Text('Delete "$deviceName"? This will also remove all schedules.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseDatabase.instance.ref('users/${widget.userId}/devices/$deviceId').remove();
      final schSnap = await FirebaseDatabase.instance.ref('users/${widget.userId}/schedules').get();
      if (schSnap.exists) {
        final raw = schSnap.value as Map<dynamic, dynamic>;
        for (final entry in raw.entries) {
          final val = Map<String, dynamic>.from(entry.value as Map);
          if (val['deviceId'] == deviceId) {
            await FirebaseDatabase.instance.ref('users/${widget.userId}/schedules/${entry.key}').remove();
          }
        }
      }
      await _loadAll();
    }
  }

  Future<void> _editDeviceName(String deviceId, String currentName) async {
    final ctrl = TextEditingController(text: currentName);
    final key = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Device Name'),
        content: Form(
          key: key,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Device Name', prefixIcon: Icon(Icons.devices_rounded)),
            validator: (v) => v == null || v.trim().isEmpty ? 'Cannot be empty' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { if (key.currentState!.validate()) Navigator.pop(ctx, ctrl.text.trim()); },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      await FirebaseDatabase.instance.ref('users/${widget.userId}/devices/$deviceId/deviceName').set(result);
      await _loadAll();
    }
  }

  Future<void> _editSwitchName(String deviceId, String switchId, String currentName) async {
    final ctrl = TextEditingController(text: currentName);
    final key = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Switch Name'),
        content: Form(
          key: key,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Switch Name', prefixIcon: Icon(Icons.toggle_on_rounded)),
            validator: (v) => v == null || v.trim().isEmpty ? 'Cannot be empty' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { if (key.currentState!.validate()) Navigator.pop(ctx, ctrl.text.trim()); },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      await FirebaseDatabase.instance.ref('users/${widget.userId}/devices/$deviceId/switches/$switchId/name').set(result);
      await _loadAll();
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseDatabase.instance.ref('users/${widget.userId}/schedules/$scheduleId').remove();
      await _loadAll();
    }
  }

  Future<void> _toggleSchedule(String scheduleId, bool current) async {
    await FirebaseDatabase.instance
        .ref('users/${widget.userId}/schedules/$scheduleId/isActive')
        .set(!current);
    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Firebase Inspector'),
        backgroundColor: const Color(0xFFFF6D00),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAll,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFFFF6D00),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              tabs: [
                const Tab(icon: Icon(Icons.person_rounded, size: 16), text: 'Profile'),
                Tab(icon: const Icon(Icons.devices_rounded, size: 16), text: 'Devices (${_devices.length})'),
                Tab(icon: const Icon(Icons.schedule_rounded, size: 16), text: 'Schedules (${_schedules.length})'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6D00)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(onPressed: _loadAll, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildDevicesTab(),
                    _buildSchedulesTab(),
                  ],
                ),
    );
  }

  // ── Profile Tab ──────────────────────────────────────────────────────────

  Widget _buildProfileTab() {
    if (_userProfile == null) {
      return const Center(child: Text('No profile data in Firestore'));
    }
    final p = _userProfile!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.cloud_rounded, 'Firestore → users/${(p['uid'] ?? '').toString().substring(0, 8)}...', const Color(0xFF1A73E8)),
        const SizedBox(height: 10),
        _infoTile(Icons.fingerprint_rounded, 'UID', p['uid']),
        _infoTile(Icons.email_rounded, 'Email', p['email']),
        _infoTile(Icons.person_rounded, 'Display Name', p['displayName']),
        _infoTile(Icons.g_mobiledata_rounded, 'Google User', p['isGoogleUser']?.toString()),
        _infoTile(Icons.image_rounded, 'Photo URL', p['photoUrl'] ?? '(none)'),
        _infoTile(Icons.calendar_today_rounded, 'Created At', _fmtTs(p['createdAt'])),
        _infoTile(Icons.login_rounded, 'Last Login', _fmtTs(p['lastLoginAt'])),
      ],
    );
  }

  // ── Devices Tab ──────────────────────────────────────────────────────────

  Widget _buildDevicesTab() {
    if (_devices.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.devices_other_rounded, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text('No devices in Realtime Database'),
        ]),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _devices.map((device) {
        final deviceId = device['deviceId'] as String? ?? '';
        final deviceName = device['deviceName'] as String? ?? 'Device';
        final switches = (device['switches'] as Map<dynamic, dynamic>? ?? {})
            .map((k, v) => MapEntry(k.toString(), Map<String, dynamic>.from(v as Map)));

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34A853).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.router_rounded, color: Color(0xFF34A853), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(deviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(deviceId.length > 16 ? '${deviceId.substring(0, 16)}...' : deviceId,
                              style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                    // Edit device name
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      color: const Color(0xFF6C63FF),
                      tooltip: 'Edit Name',
                      onPressed: () => _editDeviceName(deviceId, deviceName),
                    ),
                    // Delete device
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, size: 20),
                      color: Colors.red,
                      tooltip: 'Delete Device',
                      onPressed: () => _deleteDevice(deviceId, deviceName),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Switches
                const Text('Switches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF34A853))),
                const SizedBox(height: 8),
                ...switches.entries.map((entry) {
                  final switchId = entry.key;
                  final sw = entry.value;
                  final name = sw['name'] as String? ?? 'Switch';
                  final isOn = sw['state'] == true;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isOn ? Colors.green.withOpacity(0.08) : Colors.grey.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isOn ? Colors.green.withOpacity(0.3) : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: isOn ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(switchId, style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace')),
                            ],
                          ),
                        ),
                        // Edit switch name
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          color: const Color(0xFF6C63FF),
                          tooltip: 'Edit Switch Name',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () => _editSwitchName(deviceId, switchId, name),
                        ),
                        // ON/OFF toggle
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: isOn,
                            activeColor: Colors.green,
                            onChanged: (_) => _toggleSwitch(deviceId, switchId, isOn),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isOn ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isOn ? 'ON' : 'OFF',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOn ? Colors.green : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 4),
                _infoTile(Icons.calendar_today_rounded, 'Created', _fmtMs(device['createdAt'])),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Schedules Tab ────────────────────────────────────────────────────────

  Widget _buildSchedulesTab() {
    if (_schedules.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.schedule_rounded, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text('No schedules in Realtime Database'),
        ]),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _schedules.map((sch) {
        final scheduleId = sch['scheduleId'] as String? ?? '';
        final isActive = sch['isActive'] == true;
        final action = sch['action'] as String? ?? 'ON';
        final switchId = sch['switchId'] as String? ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6D00).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action == 'ON' ? Icons.power_rounded : Icons.power_off_rounded,
                        color: action == 'ON' ? Colors.green : Colors.red,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$action — $switchId',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(_fmtMs(sch['scheduledTime']),
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    // Active toggle
                    Column(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: isActive,
                            activeColor: Colors.green,
                            onChanged: (_) => _toggleSchedule(scheduleId, isActive),
                          ),
                        ),
                        Text(isActive ? 'Active' : 'Off',
                            style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.grey)),
                      ],
                    ),
                    // Delete
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, size: 20),
                      color: Colors.red,
                      tooltip: 'Delete Schedule',
                      onPressed: () => _deleteSchedule(scheduleId),
                    ),
                  ],
                ),
                const Divider(height: 16),
                _infoTile(Icons.tag_rounded, 'Schedule ID', scheduleId.length > 16 ? '${scheduleId.substring(0, 16)}...' : scheduleId),
                _infoTile(Icons.router_rounded, 'Device ID', (sch['deviceId'] as String? ?? '').length > 16 ? '${(sch['deviceId'] as String).substring(0, 16)}...' : sch['deviceId']),
                _infoTile(Icons.toggle_on_rounded, 'Switch', switchId),
                _infoTile(Icons.repeat_rounded, 'Recurring', sch['isRecurring']?.toString() ?? 'false'),
                if (sch['recurringPattern'] != null)
                  _infoTile(Icons.loop_rounded, 'Pattern', sch['recurringPattern']),
                _infoTile(Icons.calendar_today_rounded, 'Created', _fmtMs(sch['createdAt'])),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title, Color color) {
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
          Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, dynamic value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFFF6D00)),
          const SizedBox(width: 8),
          SizedBox(width: 90, child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600))),
          Expanded(child: Text(value?.toString() ?? '(null)', style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
        ],
      ),
    );
  }

  String _fmtTs(dynamic value) {
    if (value == null) return '(none)';
    if (value is Timestamp) {
      final dt = value.toDate();
      return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}:${_p(dt.second)}';
    }
    return value.toString();
  }

  String _fmtMs(dynamic ms) {
    if (ms == null) return '(none)';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(ms as int);
      return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}';
    } catch (_) { return ms.toString(); }
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}
