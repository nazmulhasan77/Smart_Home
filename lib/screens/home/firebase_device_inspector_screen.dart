import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirebaseDeviceInspectorScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> deviceData;

  const FirebaseDeviceInspectorScreen({
    super.key,
    required this.userId,
    required this.deviceData,
  });

  @override
  State<FirebaseDeviceInspectorScreen> createState() =>
      _FirebaseDeviceInspectorScreenState();
}

class _FirebaseDeviceInspectorScreenState
    extends State<FirebaseDeviceInspectorScreen>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> _device;
  late Map<String, Map<String, dynamic>> _switches;
  bool _isSaving = false;
  late AnimationController _headerAnim;
  late Animation<double> _fadeAnim;

  // Realtime stream
  late Stream<Map<String, dynamic>> _deviceStream;

  static const _green = Color(0xFF34A853);
  static const _purple = Color(0xFF6C63FF);
  static const _red = Color(0xFFE53935);
  static const _orange = Color(0xFFFF6D00);
  static const _darkBg = Color(0xFF0F0F1A);
  static const _cardDark = Color(0xFF1C1C2E);
  static const _cardLight = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _device = Map<String, dynamic>.from(widget.deviceData);
    _switches = _parseSwitches(_device['switches']);
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerAnim.forward();

    // Subscribe to realtime updates for this device
    _deviceStream = FirebaseDatabase.instance
        .ref('users/${widget.userId}/devices/$_deviceId')
        .onValue
        .map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return <String, dynamic>{};
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Map<String, Map<String, dynamic>> _parseSwitches(dynamic raw) {
    if (raw == null) return {};
    final m = raw as Map<dynamic, dynamic>;
    return m.map(
      (k, v) => MapEntry(k.toString(), Map<String, dynamic>.from(v as Map)),
    );
  }

  String get _deviceId => _device['deviceId'] as String? ?? '';
  String get _deviceName => _device['deviceName'] as String? ?? 'Device';

  DatabaseReference get _deviceRef =>
      FirebaseDatabase.instance.ref('users/${widget.userId}/devices/$_deviceId');

  // ── Firebase writes ────────────────────────────────────────────────────────
  Future<void> _toggleSwitch(String switchId, bool newState) async {
    setState(() => _switches[switchId]!['state'] = newState);
    try {
      await _deviceRef.child('switches/$switchId/state').set(newState);
    } catch (e) {
      // revert on error
      setState(() => _switches[switchId]!['state'] = !newState);
      _showSnack('Failed to update switch: $e', isError: true);
    }
  }

  Future<void> _renameDevice(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _isSaving = true;
      _device['deviceName'] = trimmed;
    });
    try {
      await _deviceRef.child('deviceName').set(trimmed);
      _showSnack('Device renamed to "$trimmed"');
    } catch (e) {
      _showSnack('Failed to rename: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteDevice() async {
    final confirmed = await _showDeleteConfirm();
    if (!confirmed) return;
    setState(() => _isSaving = true);
    try {
      await _deviceRef.remove();
      if (mounted) Navigator.pop(context, 'deleted');
    } catch (e) {
      setState(() => _isSaving = false);
      _showSnack('Failed to delete: $e', isError: true);
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────
  void _showEditNameDialog() {
    final ctrl = TextEditingController(text: _deviceName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _purple, width: 2),
            ),
          ),
          onSubmitted: (v) {
            Navigator.pop(ctx);
            _renameDevice(v);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _renameDevice(ctrl.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirm() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.delete_rounded, color: _red, size: 20),
                SizedBox(width: 8),
                Text('Delete Device', style: TextStyle(fontSize: 16)),
              ],
            ),
            content: Text(
              'Delete "$_deviceName" from Firebase?\nThis cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
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
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _red : _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _darkBg : const Color(0xFFF0F2F5);

    return StreamBuilder<Map<String, dynamic>>(
      stream: _deviceStream,
      builder: (context, snapshot) {
        // Apply live data when available (but don't override during a save)
        if (snapshot.hasData && snapshot.data!.isNotEmpty && !_isSaving) {
          final live = snapshot.data!;
          _device = live;
          _switches = _parseSwitches(live['switches']);
        }

        final onCount =
            _switches.values.where((s) => s['state'] == true).length;

        return Scaffold(
          backgroundColor: bg,
          body: CustomScrollView(
            slivers: [
              // ── Hero SliverAppBar ────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? _cardDark : _purple,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  // Live indicator
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: snapshot.connectionState ==
                                      ConnectionState.active
                                  ? Colors.greenAccent
                                  : Colors.grey,
                              shape: BoxShape.circle,
                              boxShadow: snapshot.connectionState ==
                                      ConnectionState.active
                                  ? [
                                      BoxShadow(
                                        color: Colors.greenAccent
                                            .withValues(alpha: 0.7),
                                        blurRadius: 6,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            snapshot.connectionState ==
                                    ConnectionState.active
                                ? 'LIVE'
                                : '...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isSaving)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        ),
                      ),
                    )
                  else ...[
                    IconButton(
                      icon: const Icon(Icons.edit_rounded,
                          color: Colors.white),
                      tooltip: 'Edit name',
                      onPressed: _showEditNameDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          color: Colors.white),
                      tooltip: 'Delete device',
                      onPressed: _deleteDevice,
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: _buildHeroHeader(isDark, onCount),
                ),
              ),

              // ── Body content ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(isDark),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.toggle_on_rounded,
                              color: _green, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Switches',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          _Chip(label: '$onCount ON', color: _green),
                          const SizedBox(width: 6),
                          _Chip(
                            label: '${_switches.length - onCount} OFF',
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // ── Switch cards ──────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry =
                          _switches.entries.elementAt(index);
                      return _buildSwitchCard(
                          entry.key, entry.value, isDark);
                    },
                    childCount: _switches.length,
                  ),
                ),
              ),

              // ── Bottom action buttons ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BigButton(
                          icon: Icons.edit_rounded,
                          label: 'Edit Name',
                          color: _purple,
                          onTap: _isSaving ? null : _showEditNameDialog,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigButton(
                          icon: Icons.delete_rounded,
                          label: 'Delete',
                          color: _red,
                          onTap: _isSaving ? null : _deleteDevice,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Firebase path footer ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  child: GestureDetector(
                    onTap: () {
                      final path =
                          'users/${widget.userId}/devices/$_deviceId';
                      Clipboard.setData(ClipboardData(text: path));
                      _showSnack('Path copied to clipboard');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _orange.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storage_rounded,
                              color: _orange, size: 15),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'users/${widget.userId}/devices/$_deviceId',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: _orange,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.copy_rounded,
                              color: _orange, size: 13),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Hero header widget ─────────────────────────────────────────────────────
  Widget _buildHeroHeader(bool isDark, int onCount) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
                ]
              : [
                  const Color(0xFF6C63FF),
                  const Color(0xFF4CAF50),
                ],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Device icon + status
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.router_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _deviceName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: onCount > 0
                                      ? Colors.greenAccent
                                      : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                  boxShadow: onCount > 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.greenAccent
                                                .withValues(alpha: 0.6),
                                            blurRadius: 6,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                onCount > 0
                                    ? '$onCount switch${onCount > 1 ? 'es' : ''} active'
                                    : 'All switches off',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Big ON count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$onCount/${_switches.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ON',
                            style: TextStyle(
                              color:
                                  Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Device info card ───────────────────────────────────────────────────────
  Widget _buildInfoCard(bool isDark) {
    final card = isDark ? _cardDark : _cardLight;
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.tag_rounded,
            label: 'Device ID',
            value: _deviceId,
            color: _purple,
            isFirst: true,
          ),
          _Divider(),
          _InfoTile(
            icon: Icons.person_rounded,
            label: 'User ID',
            value: _device['userId']?.toString() ?? '—',
            color: _orange,
          ),
          _Divider(),
          _InfoTile(
            icon: Icons.calendar_today_rounded,
            label: 'Created At',
            value: _formatMs(_device['createdAt']),
            color: _green,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Switch card ────────────────────────────────────────────────────────────
  Widget _buildSwitchCard(
      String switchId, Map<String, dynamic> sw, bool isDark) {
    final isOn = sw['state'] == true;
    final name = sw['name']?.toString() ?? switchId;
    final card = isDark ? _cardDark : _cardLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOn
              ? _green.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isOn
                ? _green.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: isOn ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isOn
                    ? _green.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _switchIcon(name),
                color: isOn ? _green : Colors.grey.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Name + id
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isOn ? _green : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    switchId,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // ON/OFF badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isOn
                    ? _green.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOn ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isOn ? _green : Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Toggle
            Transform.scale(
              scale: 1.1,
              child: Switch(
                value: isOn,
                activeColor: Colors.white,
                activeTrackColor: _green,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (v) => _toggleSwitch(switchId, v),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _switchIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('light') || n.contains('lamp') || n.contains('bulb')) {
      return Icons.lightbulb_rounded;
    }
    if (n.contains('fan')) return Icons.air_rounded;
    if (n.contains('ac') || n.contains('air')) {
      return Icons.ac_unit_rounded;
    }
    if (n.contains('pump') || n.contains('water')) {
      return Icons.water_drop_rounded;
    }
    if (n.contains('tv') || n.contains('television')) {
      return Icons.tv_rounded;
    }
    if (n.contains('door') || n.contains('gate')) {
      return Icons.door_front_door_rounded;
    }
    return Icons.power_settings_new_rounded;
  }

  String _formatMs(dynamic ms) {
    if (ms == null) return '—';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(ms as int);
      String p(int n) => n.toString().padLeft(2, '0');
      return '${dt.year}-${p(dt.month)}-${p(dt.day)}  ${p(dt.hour)}:${p(dt.minute)}:${p(dt.second)}';
    } catch (_) {
      return ms.toString();
    }
  }

}

// ── Reusable sub-widgets ───────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isFirst;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 16 : 10,
        16,
        isLast ? 16 : 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 62,
      endIndent: 16,
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }
}

class _BigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _BigButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
