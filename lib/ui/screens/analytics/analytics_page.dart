import 'package:flutter/material.dart';
import '../../../utils/webservice.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/weekly_task_graph.dart';
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
          WeeklyTaskGraph(),


          const SizedBox(height: 16),

          /// 🔥 HABITS
          HabitInsightCard()
        ],
      ),
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