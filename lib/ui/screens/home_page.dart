import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusx/provider/dashboard_controller.dart';
import 'package:focusx/ui/screens/task/task_card.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../models/task.dart';
import '../../utils/webservice.dart';
import '../widgets/donut_chart.dart';
import '../widgets/skeleton.dart';
import '../widgets/weekly_task_graph.dart';
import 'habit/habit_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.split(' ').first ??
        (user?.isAnonymous == true ? 'Guest' : 'Friend');

    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16).copyWith(bottom: 100),
        children: [
          // Greeting header
          _GreetingHeader(name: name),
          const SizedBox(height: 16),

          // Today stats summary
          FutureBuilder<Map<String, dynamic>>(
            future: Webservice.firebaseService.getTodayTaskStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Skeleton(height: 100);
              final d = snapshot.data!;
              return _TodayStatsBanner(
                planned: d['plannedToday'],
                completed: d['completedToday'],
                score: d['score'],
                status: d['status'],
              );
            },
          ),
          const SizedBox(height: 16),

          // Weekly chart
          WeeklyTaskGraph(),
          const SizedBox(height: 16),

          // Today tasks section
          _SectionHeader(
            icon: Icons.task_alt_sharp,
            title: "Today's Tasks",
            action: 'View All',
            onTap: () => context.read<DashboardProvider>().setIndex(1),
          ),
          const SizedBox(height: 8),

          StreamBuilder<List<Task>>(
            initialData: const [],
            stream: Webservice.firebaseService.watchTasks(isToday: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Skeleton(height: 160);
              }
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return const _EmptyState(text: 'No tasks for today 🎉');
              }
              final shown = tasks.take(4).toList();
              return Column(
                children: shown.map((t) => TaskCard(task: t)).toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          // Habits section
          _SectionHeader(
            icon: Icons.event_repeat,
            title: 'Habits',
            action: 'View All',
            onTap: () => context.read<DashboardProvider>().setIndex(2),
          ),
          const SizedBox(height: 8),

          FutureBuilder<List<Habit>>(
            future: Webservice.firebaseService.getTodayHabits(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Skeleton(height: 120);
              final habits = snapshot.data!;
              if (habits.isEmpty) {
                return const _EmptyState(text: 'No habits scheduled today');
              }
              final shown = habits.take(3).toList();
              return Column(
                children: shown.map((h) => HabitCard(habit: h)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String name;
  const _GreetingHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final String greeting;
    final IconData greetIcon;

    if (hour < 12) {
      greeting = 'Good morning';
      greetIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good afternoon';
      greetIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Good evening';
      greetIcon = Icons.nights_stay_rounded;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(greetIcon,
                      size: 18,
                      color:
                          theme.colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 6),
                  Text(
                    greeting,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const _DateChip(),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            dayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${now.day}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          Text(
            monthName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayStatsBanner extends StatelessWidget {
  final int planned;
  final int completed;
  final int score;
  final String status;

  const _TodayStatsBanner({
    required this.planned,
    required this.completed,
    required this.score,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = planned == 0 ? 0.0 : completed / planned;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Focus Score: $score/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatPill(
                        icon: Icons.check_circle,
                        value: '$completed',
                        label: 'done'),
                    const SizedBox(width: 10),
                    _StatPill(
                        icon: Icons.circle_outlined,
                        value: '$planned',
                        label: 'planned'),
                  ],
                ),
              ],
            ),
          ),
          ProgressRing(
            value: ratio,
            color: Colors.white,
            size: 76,
            strokeWidth: 8,
            centerWidget: Text(
              '${(ratio * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatPill(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              action!,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ),
    );
  }
}
