import 'package:flutter/material.dart';
import 'package:focusx/ui/widgets/skeleton.dart';

import '../../utils/webservice.dart';
import '../screens/habit/habit_insights.dart';


class WeeklyTaskGraph extends StatelessWidget {
  const WeeklyTaskGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future:Webservice.firebaseService.getWeeklyCompletedTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Skeleton(height: 140);
        }

        return AnalyticsCard(
          title: 'Tasks Completed (Last 7 Days)',
          subtitle: 'Number of tasks you finished each day',
          child: _WeeklyTaskBar(data: snapshot.data!),
        );
      },
    );
  }
}


class _WeeklyTaskBar extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _WeeklyTaskBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counts = data.map((e) => e['count'] as int).toList();

    final maxValue =
    counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (i) {
        final count = data[i]['count'] as int;
        final label = data[i]['dayLabel'] as String;

        final double height =
        count == 0 ? 0 : 60 * (count / maxValue);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              count.toString(),
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(
              height: 60,
              width: 14,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Background track
                  Container(
                    height: 60,
                    width: 14,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (count > 0)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: height,
                      width: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        );
      }),
    );
  }


}