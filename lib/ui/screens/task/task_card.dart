import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focusx/utils/extensions.dart';
import '../../../models/task.dart';
import '../../../services/haptic_service.dart';
import '../../../services/widget_service.dart';
import '../../../utils/webservice.dart';
import '../../theme/app_theme.dart';
import 'add_edit_task_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priorityCol = _priorityColor(task.priority);
    final categoryCol = AppTheme.getCategoryColor(task.category);
    final categoryIcon = AppTheme.getCategoryIcon(task.category);

    return GestureDetector(
      onTap: () => context.next(AddEditTaskPage(task: task)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 4),
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              // Left priority accent bar
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: priorityCol,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Category icon circle
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: categoryCol.withOpacity(isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(categoryIcon, color: categoryCol, size: 20),
                      ),

                      const SizedBox(width: 12),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? theme.colorScheme.onSurface.withOpacity(
                                        0.4,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                // Category chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryCol.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    task.category,
                                    style: TextStyle(
                                      color: categoryCol,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (task.dueDate.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatDate(task.dueDate),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                                if (task.dueTime.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    task.dueTime,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Completion tick on the RIGHT
                      GestureDetector(
                        onTap: () async {
                          HapticService.light();
                          await Webservice.firebaseService.updateTask(
                            task.copyWith(
                              isCompleted: !task.isCompleted,
                              completedAt: DateTime.now().toIso8601String(),
                            ),
                          );
                          unawaited(WidgetService.refresh());
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? AppTheme.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: task.isCompleted
                                  ? AppTheme.secondary
                                  : theme.colorScheme.onSurface.withOpacity(
                                      0.2,
                                    ),
                              width: 2,
                            ),
                          ),
                          child: task.isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFFF4757);
      case 'Low':
        return const Color(0xFF00D9A6);
      default:
        return const Color(0xFFFFA26B);
    }
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}