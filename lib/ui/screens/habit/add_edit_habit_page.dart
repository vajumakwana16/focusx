import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focusx/utils/webservice.dart';
import '../../../models/habit.dart';
import '../../../services/haptic_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/widget_service.dart';
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
  int color = 0xFF6C63FF;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;

    title = TextEditingController(text: h?.title ?? '');
    description = TextEditingController(text: h?.description ?? '');
    frequency = h?.frequency ?? 'Daily';
    color = h?.color ?? 0xFF6C63FF;
    reminderEnabled = h?.reminderTime.isNotEmpty == true;

    if (h?.reminderTime.isNotEmpty == true) {
      final parts = h!.reminderTime.split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticService.tap();
    final notificationId =
        reminderEnabled ? DateTime.now().millisecondsSinceEpoch ~/ 1000 : 0;

    // Cancel previous notification if editing
    if (widget.habit != null && widget.habit!.notificationId != 0) {
      await NotificationService.cancel(widget.habit!.notificationId);
    }

    final habit = Habit(
      id: widget.habit?.id,
      title: title.text.trim(),
      description: description.text.trim(),
      frequency: frequency,
      reminderTime: reminderTime != null
          ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
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

    // Schedule notification based on frequency
    if (reminderEnabled && reminderTime != null) {
      final timeData = TimeOfDayData(
        hour: reminderTime!.hour,
        minute: reminderTime!.minute,
      );
      if (frequency.toLowerCase() == 'weekly') {
        // Fire on the same weekday as the habit's start date
        final startWeekday = DateTime.parse(habit.startDate).weekday;
        await NotificationService.scheduleHabitWeekly(
          id: notificationId,
          title: title.text.trim(),
          time: timeData,
          weekday: startWeekday,
        );
      } else {
        await NotificationService.scheduleHabitDaily(
          id: notificationId,
          title: title.text.trim(),
          time: timeData,
        );
      }
    }

    // Refresh the home-screen widget
    unawaited(WidgetService.refresh());

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
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                HapticService.heavy();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete habit?'),
                    content: const Text(
                        'This will remove all completion history.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  // Cancel notification before deleting
                  if (widget.habit!.notificationId != 0) {
                    await NotificationService.cancel(
                      widget.habit!.notificationId,
                    );
                  }
                  await Webservice.firebaseService
                      .deleteHabit(widget.habit!.id!);
                  unawaited(WidgetService.refresh());
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveHabit,
        icon: const Icon(Icons.check_rounded),
        label: Text(isEdit ? 'Update Habit' : 'Save Habit'),
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
          selectedColor: color,
          onFrequencyChanged: (v) => setState(() => frequency = v),
          onReminderChanged: (v) => setState(() => reminderEnabled = v),
          onTimeChanged: (t) => setState(() => reminderTime = t),
          onColorChanged: (c) => setState(() => color = c),
        ),
      ),
    );
  }
}
