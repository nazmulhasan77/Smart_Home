import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device_model.dart';
import 'package:smart_home/providers/schedule_provider.dart';

class AddScheduleScreen extends StatefulWidget {
  final Device device;
  final String userId;

  const AddScheduleScreen({
    super.key,
    required this.device,
    required this.userId,
  });

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  late String _selectedSwitch;
  late TimeOfDay _selectedTime;
  String _selectedAction = 'ON';
  bool _isRecurring = false;
  String _recurringPattern = 'daily';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedSwitch = widget.device.switches.keys.first;
    _selectedTime = TimeOfDay.now();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF6C63FF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _addSchedule() async {
    setState(() => _isSaving = true);

    final scheduledDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    await context.read<ScheduleProvider>()?.addSchedule(
      deviceId: widget.device.deviceId,
      switchId: _selectedSwitch,
      scheduledTime: scheduledDateTime,
      action: _selectedAction,
      isRecurring: _isRecurring,
      recurringPattern: _isRecurring ? _recurringPattern : null,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Schedule added successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _getSwitchName(String switchId) {
    final switchData =
        widget.device.switches[switchId] as Map<String, dynamic>?;
    return switchData?['name'] ?? switchId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Schedule'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
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
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          widget.device.deviceName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Select Switch
            _SectionLabel(label: 'Select Switch'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSwitch,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: widget.device.switches.entries.map((entry) {
                      final switchData = entry.value as Map<String, dynamic>;
                      final switchName = switchData['name'] ?? 'Switch';
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.power_settings_new_rounded,
                              size: 18,
                              color: Color(0xFF6C63FF),
                            ),
                            const SizedBox(width: 10),
                            Text(switchName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedSwitch = value);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action
            _SectionLabel(label: 'Action'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Turn ON',
                    icon: Icons.power_rounded,
                    isSelected: _selectedAction == 'ON',
                    color: Colors.green,
                    onTap: () => setState(() => _selectedAction = 'ON'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Turn OFF',
                    icon: Icons.power_off_rounded,
                    isSelected: _selectedAction == 'OFF',
                    color: Colors.red,
                    onTap: () => setState(() => _selectedAction = 'OFF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Time Picker
            _SectionLabel(label: 'Time'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectTime,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tap to change',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recurring
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.repeat_rounded),
                    title: const Text('Recurring Schedule'),
                    subtitle: const Text('Repeat this schedule automatically'),
                    value: _isRecurring,
                    activeColor: const Color(0xFF6C63FF),
                    onChanged: (value) => setState(() => _isRecurring = value),
                  ),
                  if (_isRecurring) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Repeat Pattern',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _PatternChip(
                                label: 'Daily',
                                isSelected: _recurringPattern == 'daily',
                                onTap: () => setState(
                                  () => _recurringPattern = 'daily',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _PatternChip(
                                label: 'Weekly',
                                isSelected: _recurringPattern == 'weekly',
                                onTap: () => setState(
                                  () => _recurringPattern = 'weekly',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _PatternChip(
                                label: 'Monthly',
                                isSelected: _recurringPattern == 'monthly',
                                onTap: () => setState(
                                  () => _recurringPattern = 'monthly',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _addSchedule,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Schedule',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PatternChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
