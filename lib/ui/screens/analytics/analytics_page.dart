import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/dashboard_controller.dart';
import '../../../utils/webservice.dart';
import '../../theme/app_theme.dart';
import '../../widgets/donut_chart.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/weekly_task_graph.dart';
import '../habit/habit_insights.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with AutomaticKeepAliveClientMixin {
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<Map<String, dynamic>> _habitInsightsFuture;
  late Future<Map<String, dynamic>> _productivityFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Refresh data whenever analytics tab becomes visible
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
    if (index == 3 && mounted) {
      setState(() => _loadData());
    }
  }

  void _loadData() {
    _statsFuture = Webservice.firebaseService.getTodayTaskStats();
    _habitInsightsFuture = Webservice.firebaseService.getHabitInsights();
    _productivityFuture = Webservice.firebaseService.getProductivity();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          children: [
            // Today focus hero card
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Skeleton(height: 180);
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

            // Task completion donut chart — CENTERED
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Skeleton(height: 200);
                }
                final d = snapshot.data!;
                final completed = d['completedToday'] as int;
                final planned = d['plannedToday'] as int;
                final remaining = (planned - completed).clamp(0, planned);

                return _AnalyticsCard(
                  title: 'Task Completion',
                  subtitle: 'Today\'s breakdown',
                  child: Center(
                    child: DonutChart(
                      size: 140,
                      strokeWidth: 20,
                      data: planned == 0
                          ? [
                              DonutChartData(
                                label: 'No tasks',
                                value: 1,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ]
                          : [
                              DonutChartData(
                                label: 'Completed ($completed)',
                                value: completed.toDouble(),
                                color: AppTheme.secondary,
                              ),
                              DonutChartData(
                                label: 'Remaining ($remaining)',
                                value: remaining.toDouble(),
                                color: AppTheme.tertiary,
                              ),
                            ],
                      centerWidget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            planned == 0
                                ? '—'
                                : '${((completed / planned) * 100).round()}%',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'done',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Weekly consistency chart
            WeeklyTaskGraph(),

            const SizedBox(height: 16),

            // Habit insights
            HabitInsightCard(),

            const SizedBox(height: 16),

            // Habit completion donut — CENTERED
            FutureBuilder<Map<String, dynamic>>(
              future: _habitInsightsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Skeleton(height: 200);
                }
                final d = snapshot.data!;
                final active = d['activeHabits'] as int;
                final todayDone = d['todayCompleted'] as int;
                final remaining = (active - todayDone).clamp(0, active);

                return _AnalyticsCard(
                  title: 'Habit Progress',
                  subtitle: 'Today\'s habit completion',
                  child: Center(
                    child: DonutChart(
                      size: 140,
                      strokeWidth: 20,
                      data: active == 0
                          ? [
                              DonutChartData(
                                label: 'No habits',
                                value: 1,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ]
                          : [
                              DonutChartData(
                                label: 'Done ($todayDone)',
                                value: todayDone.toDouble(),
                                color: AppTheme.primary,
                              ),
                              DonutChartData(
                                label: 'Pending ($remaining)',
                                value: remaining.toDouble(),
                                color: AppTheme.accent,
                              ),
                            ],
                      centerWidget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            active == 0 ? '—' : '$todayDone/$active',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'habits',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Productivity stats
            FutureBuilder<Map<String, dynamic>>(
              future: _productivityFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Skeleton(height: 120);
                final d = snapshot.data!;
                final timeSpent = d['totalTimeSpent'] as int;
                final completed = d['completedTasks'] as int;
                final productivity = d['productivity'] as double;

                return _AnalyticsCard(
                  title: 'Overall Productivity',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProductivityStat(
                        icon: Icons.timer_outlined,
                        value: _formatMinutes(timeSpent),
                        label: 'Focus Time',
                        color: AppTheme.primary,
                      ),
                      _ProductivityStat(
                        icon: Icons.check_circle_outline,
                        value: '$completed',
                        label: 'Completed',
                        color: AppTheme.secondary,
                      ),
                      _ProductivityStat(
                        icon: Icons.speed_rounded,
                        value: '${productivity.round()}%',
                        label: 'Efficiency',
                        color: AppTheme.accent,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
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
    final ratio = planned == 0 ? 0.0 : completed / planned;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary, AppTheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Task Completion Status',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MiniStat(label: 'Done', value: '$completed'),
                    const SizedBox(width: 20),
                    _MiniStat(label: 'Planned', value: '$planned'),
                    const SizedBox(width: 20),
                    _MiniStat(label: 'Left', value: '${planned - completed}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ProgressRing(
            value: ratio,
            color: Colors.white,
            size: 90,
            strokeWidth: 10,
            centerWidget: Text(
              '${(ratio * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

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
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProductivityStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ProductivityStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
