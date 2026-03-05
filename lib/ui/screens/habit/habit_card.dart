import 'package:flutter/material.dart';
import '../../../models/habit.dart';
import '../../../services/haptic_service.dart';
import '../../../utils/webservice.dart';
import 'habit_detail_page.dart';
import 'habit_streak_utils.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final h = habit;
    final theme = Theme.of(context);
    final habitColor = Color(h.color);
    final streak = h.frequency == 'Daily'
        ? HabitStreakUtils.calculateDailyStreak(h.completionDates)
        : HabitStreakUtils.calculateWeeklyStreak(h.completionDates);

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final doneToday = h.completionDates.contains(today);

    // Last 7 days mini heatmap
    final now = DateTime.now();
    final last7 = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return h.completionDates.contains(key);
    });

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticService.tap();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HabitDetailPage(habit: h),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Color indicator + icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.repeat, color: habitColor, size: 24),
              ),
              const SizedBox(width: 12),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: streak > 0
                              ? Colors.orange
                              : theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streak day streak',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: streak > 0
                                ? Colors.orange
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: habitColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            h.frequency,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: habitColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Mini 7-day heatmap
                    Row(
                      children: last7.map((done) {
                        return Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: done
                                ? habitColor
                                : habitColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: done
                              ? Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Today toggle button
              GestureDetector(
                onTap: () async {
                  HapticService.light();
                  final updatedDates = List<String>.from(h.completionDates);
                  if (doneToday) {
                    updatedDates.remove(today);
                  } else {
                    updatedDates.add(today);
                  }
                  await Webservice.firebaseService
                      .updateHabit(h.copyWith(completionDates: updatedDates));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: doneToday ? habitColor : habitColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    doneToday ? Icons.check : Icons.add,
                    color: doneToday ? Colors.white : habitColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}