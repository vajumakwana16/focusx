import 'package:flutter/material.dart';

class HabitForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController title;
  final TextEditingController description;

  final String frequency;
  final bool reminderEnabled;
  final TimeOfDay? reminderTime;

  final ValueChanged<String> onFrequencyChanged;
  final ValueChanged<bool> onReminderChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const HabitForm({
    super.key,
    required this.formKey,
    required this.title,
    required this.description,
    required this.frequency,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.onFrequencyChanged,
    required this.onReminderChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          _field(
            controller: title,
            label: 'Habit Title',
            icon: Icons.repeat,
            validator: (v) =>
            v == null || v.isEmpty ? 'Required' : null,
          ),

          _field(
            controller: description,
            label: 'Description',
            icon: Icons.notes,
            maxLines: 3,
          ),

          _dropdown(
            label: 'Frequency',
            value: frequency,
            items: const ['Daily', 'Weekly'],
            onChanged: onFrequencyChanged,
          ),

          SwitchListTile(
            title: const Text('Enable Reminder'),
            value: reminderEnabled,
            onChanged: onReminderChanged,
            secondary: const Icon(Icons.notifications),
          ),

          if (reminderEnabled)
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                reminderTime == null
                    ? 'Pick reminder time'
                    : reminderTime!.format(context),
              ),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (t != null) onTimeChanged(t);
              },
            ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) =>
            DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}