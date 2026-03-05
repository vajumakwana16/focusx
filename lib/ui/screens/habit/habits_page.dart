import 'package:flutter/material.dart';
import 'package:focusx/ui/screens/habit/habit_card.dart';
import '../../../models/habit.dart';
import '../../../utils/webservice.dart';
import '../../widgets/habit_calendar_widget.dart';
import 'habit_streak_utils.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

enum _ViewMode { list, calendar }

class _HabitsPageState extends State<HabitsPage> {
  _ViewMode _viewMode = _ViewMode.list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<_ViewMode>(
                    segments: const [
                      ButtonSegment(
                        value: _ViewMode.list,
                        icon: Icon(Icons.list_rounded, size: 18),
                        label: Text('List'),
                      ),
                      ButtonSegment(
                        value: _ViewMode.calendar,
                        icon: Icon(Icons.calendar_month_rounded, size: 18),
                        label: Text('Calendar'),
                      ),
                    ],
                    selected: {_viewMode},
                    onSelectionChanged: (s) =>
                        setState(() => _viewMode = s.first),
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Habit>>(
              stream: Webservice.firebaseService.watchHabits(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final habits = snapshot.data!;
                if (habits.isEmpty) {
                  return _EmptyHabits();
                }

                if (_viewMode == _ViewMode.list) {
                  return _HabitListView(habits: habits);
                } else {
                  return _HabitCalendarOverview(habits: habits);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitListView extends StatelessWidget {
  final List<Habit> habits;
  const _HabitListView({required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final doneToday =
        habits.where((h) => h.completionDates.contains(today)).length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Progress",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '$doneToday / ${habits.length} habits done',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: habits.isEmpty
                          ? 0
                          : doneToday / habits.length,
                      minHeight: 8,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...habits.map((h) => HabitCard(habit: h)),
      ],
    );
  }
}

class _HabitCalendarOverview extends StatelessWidget {
  final List<Habit> habits;
  const _HabitCalendarOverview({required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: habits.length,
      itemBuilder: (context, i) {
        final h = habits[i];
        final habitColor = Color(h.color);
        final streak = h.frequency == 'Daily'
            ? HabitStreakUtils.calculateDailyStreak(h.completionDates)
            : HabitStreakUtils.calculateWeeklyStreak(h.completionDates);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: habitColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.repeat, color: habitColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 12,
                                color: streak > 0
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$streak streak',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: streak > 0
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${h.completionDates.length} days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: habitColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                HabitCalendarWidget(
                  completionDates: h.completionDates,
                  habitColor: habitColor,
                  allowToggle: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyHabits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat_rounded,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first habit',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
