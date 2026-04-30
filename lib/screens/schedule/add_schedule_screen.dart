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

  @override
  void initState() {
    super.initState();
    _selectedSwitch = widget.device.switches.keys.first;
    _selectedTime = TimeOfDay.now();
  }

  void _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addSchedule() {
    final scheduledDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    context.read<ScheduleProvider>().addSchedule(
      deviceId: widget.device.deviceId,
      switchId: _selectedSwitch,
      scheduledTime: scheduledDateTime,
      action: _selectedAction,
      isRecurring: _isRecurring,
      recurringPattern: _isRecurring ? _recurringPattern : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule added successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Schedule'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.device.deviceName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Switch',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSwitch,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: widget.device.switches.entries.map((entry) {
                final switchData = entry.value as Map<String, dynamic>;
                final switchName = switchData['name'] ?? 'Switch';
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(switchName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSwitch = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Action',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'ON',
                  label: Text('ON'),
                  icon: Icon(Icons.lightbulb),
                ),
                ButtonSegment(
                  value: 'OFF',
                  label: Text('OFF'),
                  icon: Icon(Icons.lightbulb_outline),
                ),
              ],
              selected: {_selectedAction},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedAction = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Time',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CheckboxListTile(
              title: const Text('Recurring Schedule'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _recurringPattern,
                decoration: InputDecoration(
                  labelText: 'Repeat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _recurringPattern = value;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addSchedule,
                child: const Text('Add Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
