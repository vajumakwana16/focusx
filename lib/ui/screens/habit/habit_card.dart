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
    final isDark = theme.brightness == Brightness.dark;
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.repeat_rounded, color: habitColor, size: 22),
              ),
              const SizedBox(width: 12),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: streak > 0
                              ? Colors.orange
                              : theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$streak day streak',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: streak > 0
                                ? Colors.orange
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: habitColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            h.frequency,
                            style: TextStyle(
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
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: done
                                ? habitColor
                                : habitColor.withOpacity(isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: done
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 11,
                                  color: Colors.white,
                                )
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Today completion toggle on the RIGHT
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
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: doneToday ? habitColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: doneToday
                          ? habitColor
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    doneToday ? Icons.check_rounded : Icons.add_rounded,
                    color: doneToday
                        ? Colors.white
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 18,
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