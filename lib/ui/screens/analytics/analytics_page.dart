import 'package:flutter/material.dart';
import '../../../utils/webservice.dart';
import '../../widgets/skeleton.dart';
import '../habit/habit_insights.dart';


class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🔝 TODAY FOCUS
          FutureBuilder<Map<String, dynamic>>(
            future:Webservice.firebaseService.getTodayTaskStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Skeleton(height: 140);
              }

              final d = snapshot.data!;
              return _HeroAnalyticsCard(
                planned: d['plannedToday'],
                completed: d['completedToday'],
                score: d['score'],
                status: d['status'],
              );
            },
          ),


          const SizedBox(height: 16),

          /// 📊 WEEKLY CONSISTENCY
          FutureBuilder<List<Map<String, dynamic>>>(
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
          ),


          const SizedBox(height: 16),

          /// 🔥 HABITS
          HabitInsightCard()
        ],
      ),
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

class _HeroAnalyticsCard extends StatelessWidget {
  final int planned;
  final int completed;
  final int score;
  final String status;

  const _HeroAnalyticsCard({
    required this.planned,
    required this.completed,
    required this.score,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today Focus',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '$score / 10',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(
                label: 'Completed',
                value: '$completed',
              ),
              _MiniStat(
                label: 'Planned',
                value: '$planned',
              ),
              _MiniStat(
                label: 'Balance',
                value: '${planned - completed}',
              ),
            ],
          ),
        ],
      ),
    );
  }
} 

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}