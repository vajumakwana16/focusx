import 'package:flutter/material.dart';
import '../../../models/habit.dart';
import '../../../services/haptic_service.dart';
import '../../../utils/webservice.dart';
import '../../widgets/habit_calendar_widget.dart';
import 'add_edit_habit_page.dart';
import 'habit_streak_utils.dart';

class HabitDetailPage extends StatefulWidget {
  final Habit habit;
  const HabitDetailPage({super.key, required this.habit});

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  late Habit _habit;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
  }

  Future<void> _toggleDate(String dateKey, bool completed) async {
    final updated = List<String>.from(_habit.completionDates);
    if (completed) {
      if (!updated.contains(dateKey)) updated.add(dateKey);
    } else {
      updated.remove(dateKey);
    }
    final updatedHabit = _habit.copyWith(completionDates: updated);
    await Webservice.firebaseService.updateHabit(updatedHabit);
    if (mounted) {
      setState(() => _habit = updatedHabit);
    }
    HapticService.light();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitColor = Color(_habit.color);
    final streak = _habit.frequency == 'Daily'
        ? HabitStreakUtils.calculateDailyStreak(_habit.completionDates)
        : HabitStreakUtils.calculateWeeklyStreak(_habit.completionDates);
    final totalCompleted = _habit.completionDates.length;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final doneToday = _habit.completionDates.contains(today);

    return Scaffold(
      appBar: AppBar(
        title: Text(_habit.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditHabitPage(habit: _habit),
                ),
              );
              // Refresh page after edit - pop back so parent rebuilds
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16).copyWith(bottom: 100),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  habitColor,
                  habitColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      radius: 24,
                      child: const Icon(
                        Icons.repeat,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _habit.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_habit.description.isNotEmpty)
                            Text(
                              _habit.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge(
                      icon: Icons.local_fire_department,
                      value: '$streak',
                      label: 'Day Streak',
                    ),
                    _StatBadge(
                      icon: Icons.check_circle_outline,
                      value: '$totalCompleted',
                      label: 'Total Done',
                    ),
                    _StatBadge(
                      icon: Icons.repeat,
                      value: _habit.frequency,
                      label: 'Frequency',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Today toggle
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: doneToday
                      ? habitColor
                      : habitColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  doneToday ? Icons.check : Icons.circle_outlined,
                  color: doneToday ? Colors.white : habitColor,
                ),
              ),
              title: Text(
                doneToday ? 'Done Today! 🎉' : 'Mark Today as Done',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                doneToday
                    ? 'You\'ve completed this habit today'
                    : 'Keep your streak going!',
              ),
              trailing: Switch(
                value: doneToday,
                activeColor: habitColor,
                onChanged: (v) async {
                  await _toggleDate(today, v);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Calendar view
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completion Calendar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a day to toggle completion',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  HabitCalendarWidget(
                    completionDates: _habit.completionDates,
                    habitColor: habitColor,
                    allowToggle: true,
                    onToggle: _toggleDate,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Streak visualization - last 30 days
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last 30 Days',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Last30DaysGrid(
                    completionDates: _habit.completionDates,
                    habitColor: habitColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _toggleDate(today, !doneToday);
        },
        backgroundColor: doneToday ? Colors.grey : habitColor,
        icon: Icon(doneToday ? Icons.close : Icons.check),
        label: Text(doneToday ? 'Undo Today' : 'Complete Today'),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Last30DaysGrid extends StatelessWidget {
  final List<String> completionDates;
  final Color habitColor;

  const _Last30DaysGrid({
    required this.completionDates,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        childAspectRatio: 1,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 30,
      itemBuilder: (context, i) {
        final date = days[i];
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final isCompleted = completionDates.contains(dateKey);
        final isToday = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        return Tooltip(
          message:
              '${date.day}/${date.month}${isCompleted ? ' ✓' : ''}',
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? habitColor
                  : habitColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
              border: isToday
                  ? Border.all(color: habitColor, width: 1.5)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
