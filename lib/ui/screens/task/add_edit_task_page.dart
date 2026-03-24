import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focusx/utils/webservice.dart';
import '../../../models/task.dart';
import '../../../services/haptic_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/widget_service.dart';
import 'task_form.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? task;
  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController title;
  late TextEditingController description;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String priority = 'Medium';
  String category = 'General';
  bool reminderEnabled = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;

    title = TextEditingController(text: t?.title ?? '');
    description = TextEditingController(text: t?.description ?? '');

    if (t?.dueDate.isNotEmpty == true) {
      selectedDate = DateTime.tryParse(t!.dueDate);
    }
    if (t?.dueTime.isNotEmpty == true) {
      final parts = t!.dueTime.split(':');
      selectedTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    priority = t?.priority ?? 'Medium';
    category = t?.category ?? 'General';
    reminderEnabled = (t?.notificationId ?? 0) != 0;
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final notificationId =
        reminderEnabled
        ? DateTime.now().millisecondsSinceEpoch ~/ 1000
        : 0;

    // Cancel previous notification if editing
    if (widget.task != null && widget.task!.notificationId != 0) {
      await NotificationService.cancel(widget.task!.notificationId);
    }

    final task = Task(
      id: widget.task?.id,
      title: title.text.trim(),
      description: description.text.trim(),
      dueDate: selectedDate?.toIso8601String() ?? '',
      dueTime: selectedTime != null
          ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
          : '',
      priority: priority,
      category: category,
      isCompleted: widget.task?.isCompleted ?? false,
      recurrence: '',
      notificationId: notificationId,
      hasTimer: false,
      timerDuration: 0,
      timeSpent: 0,
      remainingTime: 0,
      completedAt: widget.task?.completedAt,
    );

    if (widget.task == null) {
      await Webservice.firebaseService.addTask(task);
    } else {
      await Webservice.firebaseService.updateTask(task);
    }

    // Schedule notification
    if (reminderEnabled && selectedDate != null && selectedTime != null) {
      final dateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await NotificationService.scheduleTask(
        id: notificationId,
        title: title.text,
        description: description.text.isNotEmpty ? description.text : null,
        dateTime: dateTime,
      );
    }

    // Refresh the home-screen widget
    unawaited(WidgetService.refresh());

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'New Task'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                HapticService.heavy();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete task?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  // Cancel notification before deleting
                  if (widget.task!.notificationId != 0) {
                    await NotificationService.cancel(
                      widget.task!.notificationId,
                    );
                  }
                  await Webservice.firebaseService.deleteTask(widget.task!.id!);
                  unawaited(WidgetService.refresh());
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TaskForm(
          formKey: _formKey,
          title: title,
          description: description,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          priority: priority,
          category: category,
          reminderEnabled: reminderEnabled,
          onDateChanged: (d) => setState(() => selectedDate = d),
          onTimeChanged: (t) => setState(() => selectedTime = t),
          onPriorityChanged: (p) => setState(() => priority = p),
          onCategoryChanged: (c) => setState(() => category = c),
          onReminderChanged: (v) => setState(() => reminderEnabled = v),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTask,
        icon: const Icon(Icons.check_rounded),
        label: Text(isEdit ? 'Update Task' : 'Save Task'),
      ),
    );
  }
}