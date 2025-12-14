import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../services/firestore_service.dart';
import '../../../services/notification_service.dart';
import 'task_form.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? task;
  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirestoreService();

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

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final notificationId =
    reminderEnabled ? DateTime.now().millisecondsSinceEpoch ~/ 1000 : 0;

    final task = Task(
      id: widget.task?.id,
      title: title.text.trim(),
      description: description.text.trim(),
      dueDate: selectedDate?.toIso8601String() ?? '',
      dueTime: selectedTime != null
          ? '${selectedTime!.hour}:${selectedTime!.minute}'
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
    );

    if (widget.task == null) {
      await _service.addTask(task);
    } else {
      await _service.updateTask(task);
    }

    if (reminderEnabled && selectedDate != null && selectedTime != null) {
      final dateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await NotificationService.schedule(
        id: notificationId,
        title: title.text,
        dateTime: dateTime,
      );
    }

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
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await _service.deleteTask(widget.task!.id!);
                if (mounted) Navigator.pop(context);
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
        icon: const Icon(Icons.check),
        label: const Text('Save Task'),
      ),
    );
  }
}