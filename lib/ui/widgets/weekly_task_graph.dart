import 'package:flutter/material.dart';
import '../../utils/webservice.dart';
import '../theme/app_theme.dart';
import 'skeleton.dart';

class WeeklyTaskGraph extends StatelessWidget {
  const WeeklyTaskGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Webservice.firebaseService.getWeeklyCompletedTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Skeleton(height: 160);
        }

        return _WeeklyGraphCard(data: snapshot.data!);
      },
    );
  }
}

class _WeeklyGraphCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _WeeklyGraphCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final counts = data.map((e) => e['count'] as int).toList();
    final maxValue =
        counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b);
    final totalCompleted = counts.fold<int>(0, (sum, c) => sum + c);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                      'Weekly Completion',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalCompleted tasks in 7 days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 14,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$totalCompleted done',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Bar chart
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(data.length, (i) {
                  final count = data[i]['count'] as int;
                  final label = data[i]['dayLabel'] as String;
                  final isToday = i == data.length - 1;
                  final double barHeight =
                      maxValue == 0
                      ? 0
                      : 56 * (count / maxValue);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text(
                              '$count',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isToday
                                    ? AppTheme.primary
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Track
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppTheme.primary
                                          .withOpacity(0.08)
                                      : theme.colorScheme.onSurface
                                          .withOpacity(
                                          0.04,
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // Fill
                              AnimatedContainer(
                                duration: Duration(
                                    milliseconds: 300 + (i * 50)),
                                curve: Curves.easeOut,
                                height: barHeight.clamp(0, 56),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: isToday
                                        ? [
                                            AppTheme.primary,
                                            AppTheme.primary
                                                .withOpacity(0.6),
                                          ]
                                        : [
                                            AppTheme.secondary,
                                            AppTheme.secondary
                                                .withOpacity(0.6),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isToday
                                  ? AppTheme.primary
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
