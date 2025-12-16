import 'package:flutter/material.dart';
import 'package:focusx/utils/webservice.dart';
import 'package:focusx/utils/webservice.dart';
import 'package:focusx/utils/webservice.dart';
import '../../../models/habit.dart';
import '../../../services/firestore_service.dart';
import '../../../services/haptic_service.dart';
import '../../../services/notification_service.dart';
import 'habit_form.dart';

class AddEditHabitPage extends StatefulWidget {
  final Habit? habit;
  const AddEditHabitPage({super.key, this.habit});

  @override
  State<AddEditHabitPage> createState() => _AddEditHabitPageState();
}

class _AddEditHabitPageState extends State<AddEditHabitPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController title;
  late TextEditingController description;

  String frequency = 'Daily';
  TimeOfDay? reminderTime;
  bool reminderEnabled = false;
  int color = Colors.blue.value;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;

    title = TextEditingController(text: h?.title ?? '');
    description = TextEditingController(text: h?.description ?? '');
    frequency = h?.frequency ?? 'Daily';
    reminderEnabled = h?.reminderTime.isNotEmpty == true;

    if (h?.reminderTime.isNotEmpty == true) {
      final parts = h!.reminderTime.split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticService.tap();
    final notificationId =
    reminderEnabled ? DateTime.now().millisecondsSinceEpoch ~/ 1000 : 0;

    final habit = Habit(
      id: widget.habit?.id,
      title: title.text.trim(),
      description: description.text.trim(),
      frequency: frequency,
      reminderTime: reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : '',
      startDate: widget.habit?.startDate ??
          DateTime.now().toIso8601String(),
      completionDates: widget.habit?.completionDates ?? [],
      notificationId: notificationId,
      color: color,
    );

    widget.habit == null
        ? await Webservice.firebaseService.addHabit(habit)
        : await Webservice.firebaseService.updateHabit(habit);

    if (reminderEnabled && reminderTime != null) {
      final now = DateTime.now();
      final scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime!.hour,
        reminderTime!.minute,
      );

      await NotificationService.schedule(
        id: notificationId,
        title: habit.title,
        dateTime: scheduled.isAfter(now)
            ? scheduled
            : scheduled.add(const Duration(days: 1)),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Habit' : 'New Habit'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                HapticService.heavy();
                await Webservice.firebaseService.deleteHabit(widget.habit!.id!);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveHabit,
        icon: const Icon(Icons.check),
        label: const Text('Save Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: HabitForm(
          formKey: _formKey,
          title: title,
          description: description,
          frequency: frequency,
          reminderEnabled: reminderEnabled,
          reminderTime: reminderTime,
          onFrequencyChanged: (v) => setState(() => frequency = v),
          onReminderChanged: (v) => setState(() => reminderEnabled = v),
          onTimeChanged: (t) => setState(() => reminderTime = t),
        ),
      ),
    );
  }
}