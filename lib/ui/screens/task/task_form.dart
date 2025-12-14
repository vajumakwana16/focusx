import 'package:flutter/material.dart';

class TaskForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController title;
  final TextEditingController description;

  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  final String priority;
  final String category;
  final bool reminderEnabled;

  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onReminderChanged;

  const TaskForm({
    super.key,
    required this.formKey,
    required this.title,
    required this.description,
    required this.selectedDate,
    required this.selectedTime,
    required this.priority,
    required this.category,
    required this.reminderEnabled,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onReminderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          _field(
            controller: title,
            label: 'Task Title',
            icon: Icons.title,
            validator: (v) =>
            v == null || v.isEmpty ? 'Title is required' : null,
          ),

          _field(
            controller: description,
            label: 'Description',
            icon: Icons.notes,
            maxLines: 3,
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _pickerTile(
                  context,
                  label: selectedDate == null
                      ? 'Pick Date'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) onDateChanged(d);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pickerTile(
                  context,
                  label: selectedTime == null
                      ? 'Pick Time'
                      : selectedTime!.format(context),
                  icon: Icons.access_time,
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t != null) onTimeChanged(t);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _dropdown(
            label: 'Priority',
            value: priority,
            items: const ['Low', 'Medium', 'High'],
            onChanged: onPriorityChanged,
          ),

          _dropdown(
            label: 'Category',
            value: category,
            items: const ['General', 'Work', 'Personal', 'Health'],
            onChanged: onCategoryChanged,
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            value: reminderEnabled,
            onChanged: onReminderChanged,
            title: const Text('Enable Reminder'),
            secondary: const Icon(Icons.notifications_active),
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
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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

  Widget _pickerTile(
      BuildContext context, {
        required String label,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}