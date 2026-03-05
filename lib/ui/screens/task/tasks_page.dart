import 'package:flutter/material.dart';
import 'package:focusx/ui/screens/task/task_card.dart';
import '../../../models/task.dart';
import '../../../utils/webservice.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

enum _FilterMode { all, today, completed, pending }

class _TasksPageState extends State<TasksPage> {
  _FilterMode _filter = _FilterMode.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _FilterMode.values.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(f)),
                    selected: _filter == f,
                    onSelected: (v) => setState(() => _filter = f),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: Webservice.firebaseService.watchTasks(isToday: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTasks = snapshot.data!;
                final tasks = _applyFilter(allTasks);

                if (tasks.isEmpty) {
                  return _EmptyTasks(filter: _filter);
                }

                // Group by completion
                final pending =
                    tasks.where((t) => !t.isCompleted).toList();
                final done =
                    tasks.where((t) => t.isCompleted).toList();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    if (pending.isNotEmpty) ...[
                      _SectionLabel(
                        label: 'Pending (${pending.length})',
                        color: theme.colorScheme.primary,
                      ),
                      ...pending.map((t) => TaskCard(task: t)),
                    ],
                    if (done.isNotEmpty) ...[
                      _SectionLabel(
                        label: 'Completed (${done.length})',
                        color: Colors.green,
                      ),
                      ...done.map((t) => TaskCard(task: t)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Task> _applyFilter(List<Task> tasks) {
    final today =
        DateTime.now().toIso8601String().substring(0, 10);
    switch (_filter) {
      case _FilterMode.all:
        return tasks;
      case _FilterMode.today:
        return tasks
            .where((t) => t.dueDate.startsWith(today))
            .toList();
      case _FilterMode.completed:
        return tasks.where((t) => t.isCompleted).toList();
      case _FilterMode.pending:
        return tasks.where((t) => !t.isCompleted).toList();
    }
  }

  String _filterLabel(_FilterMode f) {
    switch (f) {
      case _FilterMode.all:
        return 'All';
      case _FilterMode.today:
        return 'Today';
      case _FilterMode.completed:
        return 'Completed';
      case _FilterMode.pending:
        return 'Pending';
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  final _FilterMode filter;
  const _EmptyTasks({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            filter == _FilterMode.completed
                ? 'No completed tasks'
                : filter == _FilterMode.today
                    ? 'No tasks for today 🎉'
                    : 'No tasks yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first task',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
