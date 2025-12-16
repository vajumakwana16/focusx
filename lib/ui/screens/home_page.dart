import 'package:flutter/material.dart';
import 'package:focusx/provider/dashboard_controller.dart';
import 'package:focusx/ui/screens/task/task_card.dart';
import 'package:focusx/ui/screens/task/tasks_page.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../models/task.dart';
import '../../services/firestore_service.dart';
import '../../utils/webservice.dart';
import '../widgets/skeleton.dart';
import 'habit/habit_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16).copyWith(bottom: 100),
        children: [
          
          /// 🔝 TODAY FOCUS
          FutureBuilder<Map<String, dynamic>>(
            future:Webservice.firebaseService.getTodayTaskStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Skeleton(height: 140);
              }
              final d = snapshot.data!;
              return _TodayFocusCard(
                planned: d['plannedToday'],
                completed: d['completedToday'],
                score: d['score'],
                status: d['status'],
              );
            },
          ),

          const SizedBox(height: 16),

          /// 📋 TODAY TASKS
          _SectionHeader(
            title: 'Today’s Tasks',
            action: 'View All',
            onTap: ()=>context.read<DashboardProvider>().setIndex(1),
          ),

          /*FutureBuilder<List<Task>>(
            future:Webservice.firebaseService.getTodayTasks(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Skeleton(height: 160);
              }

              final tasks = snapshot.data!;
              if (tasks.isEmpty) {
                return const _EmptyState(text: 'No tasks for today 🎉');
              }

              return Column(
                children: tasks.map((t) => TaskCard(task: t)).toList(),
              );
            },
          ),*/

          StreamBuilder<List<Task>>(
            stream:Webservice.firebaseService.watchTasks(isToday: true),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = snapshot.data!;
              if (tasks.isEmpty) {
                return const Center(child: Text('No tasks yet'));
              }

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (_, i) {
                  final t = tasks[i];
                  return TaskCard(task: t);
                },
              );
            },
          ),

          const SizedBox(height: 16),

          /// 🔁 TODAY HABITS
          _SectionHeader(title: 'Habits',action: 'View All',
            onTap: ()=>context.read<DashboardProvider>().setIndex(2),),

          FutureBuilder<List<Habit>>(
            future:Webservice.firebaseService.getTodayHabits(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Skeleton(height: 120);
              }

              final habits = snapshot.data!;
              if (habits.isEmpty) {
                return const _EmptyState(text: 'No habits scheduled today');
              }

              return Column(
                children: habits.map((h) => HabitCard(habit: h)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayFocusCard extends StatelessWidget {
  final int planned;
  final int completed;
  final int score;
  final String status;

  const _TodayFocusCard({
    required this.planned,
    required this.completed,
    required this.score,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        margin: EdgeInsets.all(2),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary.withAlpha(200)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const Text('Today Focus',
            //     style: TextStyle(color: Colors.white70)),
            Container(
              margin: EdgeInsets.all(0),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white)),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(status, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '$score / 10',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
                  const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MiniStat('Completed', '$completed'),
                  _MiniStat('Planned', '$planned'),
                  _MiniStat('Left', '${planned - completed}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const _SectionHeader({required this.title, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
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
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  String label;
  String value;

  _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}