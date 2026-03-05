import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusx/provider/dashboard_controller.dart';
import 'package:focusx/ui/screens/task/task_card.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../models/task.dart';
import '../../utils/webservice.dart';
import '../theme/app_theme.dart';
import '../widgets/donut_chart.dart';
import '../widgets/skeleton.dart';
import '../widgets/weekly_task_graph.dart';
import 'habit/habit_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Refresh stats whenever this tab becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.addListener(_onTabChanged);
    });
  }

  @override
  void dispose() {
    DashboardProvider.instance?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    final index = DashboardProvider.instance?.index ?? -1;
    if (index == 0 && mounted) {
      setState(() => _loadData());
    }
  }

  void _loadData() {
    _statsFuture = Webservice.firebaseService.getTodayTaskStats();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.split(' ').first ??
        (user?.isAnonymous == true ? 'Guest' : 'Friend');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          children: [
            // Greeting header
            _GreetingHeader(
              name: name,
              photoUrl: user?.photoURL,
              isGuest: user?.isAnonymous ?? true,
            ),
            const SizedBox(height: 16),

            // Today stats summary (cached)
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
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
              icon: Icons.task_alt_rounded,
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
              icon: Icons.event_repeat_rounded,
              title: 'Habits',
              action: 'View All',
              onTap: () => context.read<DashboardProvider>().setIndex(2),
            ),
            const SizedBox(height: 8),

            StreamBuilder<List<Habit>>(
              stream: Webservice.firebaseService.watchHabits(),
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
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final bool isGuest;
  const _GreetingHeader({
    required this.name,
    this.photoUrl,
    this.isGuest = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
        // Profile picture on the LEFT
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary.withOpacity(isDark ? 0.2 : 0.1),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Text(
                    isGuest ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(greetIcon,
                    size: 16,
                      color:
                          theme.colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 5),
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
                  letterSpacing: -0.3,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.12),
            AppTheme.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            dayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${now.day}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          Text(
            monthName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primary.withOpacity(0.7),
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
    final ratio = planned == 0 ? 0.0 : completed / planned;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary, AppTheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                const SizedBox(height: 6),
                const Text(
                  'Daily Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 120,
                    height: 6,
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
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
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
