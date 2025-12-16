import 'package:flutter/material.dart';

import '../../../utils/webservice.dart';
import '../../widgets/skeleton.dart';

class HabitInsightCard extends StatelessWidget   { 

  const HabitInsightCard();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future:Webservice.firebaseService.getHabitInsights(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Skeleton(height: 100);
          }

          final d = snapshot.data!;

          final active =  d['activeHabits'];
          final today =  d['todayCompleted'];
          final bestStreak =  d['bestStreak'];
          
          return AnalyticsCard(
            title: 'Habit Insights',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InsightTile(label: 'Active Habits', value: '$active'),
                _InsightTile(label: 'Best Streak', value: '$bestStreak 🔥'),
                _InsightTile(label: 'Today', value: '$today / $active'),
              ],
            ),
          );
        }
    );
  }
}

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const AnalyticsCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String label;
  final String value;

  const _InsightTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}