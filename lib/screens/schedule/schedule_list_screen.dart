import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/schedule_model.dart';
import 'package:smart_home/providers/schedule_provider.dart';

class ScheduleListScreen extends StatelessWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider?>(
      builder: (context, scheduleProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Schedules'),
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
          ),
          body: scheduleProvider == null || scheduleProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<Schedule>>(
                  stream: scheduleProvider.getSchedulesStream(),
                  builder: (context, snapshot) {
                    final schedules =
                        snapshot.data ?? scheduleProvider.schedules;

                    if (schedules.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        return ScheduleCard(schedule: schedules[index]);
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/device-selector'),
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Schedule'),
          ),
        );
      },
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
                color: const Color(0xFF6C63FF).withOpacity(0.1),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Automate your devices by creating\nschedules to turn them on or off',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
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

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const ScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOn = schedule.action == 'ON';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time & Action Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (isOn ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOn ? Icons.power_rounded : Icons.power_off_rounded,
                    color: isOn ? Colors.green : Colors.red,
                    size: 22,
                  ),
                  Text(
                    isOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isOn ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Schedule Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.getFormattedTime(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.getRecurringDisplay(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.power_settings_new_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.switchId,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Controls
            Column(
              children: [
                Switch(
                  value: schedule.isActive,
                  activeColor: const Color(0xFF6C63FF),
                  onChanged: (value) {
                    context.read<ScheduleProvider>()?.toggleScheduleStatus(
                      schedule.scheduleId,
                      value,
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ScheduleProvider>()?.deleteSchedule(
                schedule.scheduleId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
