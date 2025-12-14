import 'package:flutter/material.dart';
import 'package:focusx/utils/extensions.dart';
import '../../../models/task.dart';
import '../../../services/firestore_service.dart';
import 'add_edit_task_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = FirestoreService();
    final color = _priorityColor(theme, task.priority);

    return GestureDetector(
      onTap: ()=>context.next(AddEditTaskPage(task: task)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            // ✅ COMPLETE TOGGLE
            GestureDetector(
              onTap: () async {
                await service.updateTask(
                  task!.copyWith(isCompleted: !task.isCompleted),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                    task.isCompleted ? color : theme.dividerColor,
                    width: 2,
                  ),
                  color: task.isCompleted ? color : null,
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check,
                    size: 16, color: Colors.white)
                    : null,
              ),
            ),

            const SizedBox(width: 14),

            // 📝 TASK CONTENT
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskPage(task: task),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? theme.hintColor
                            : null,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        if (task.dueDate.isNotEmpty) ...[
                          Icon(Icons.calendar_today,
                              size: 14,
                              color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.dueDate),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        if (task.dueTime.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.access_time,
                              size: 14,
                              color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(
                            task.dueTime,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 🎯 PRIORITY + DELETE
            Column(
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete task?'),
                        content: const Text(
                            'This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await service.deleteTask(task.id!);
                    }
                  },
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Priority Color
  Color _priorityColor(ThemeData theme, String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Low':
        return Colors.green;
      default:
        return theme.colorScheme.primary;
    }
  }

  // 📅 Date Format
  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year}';
  }
}