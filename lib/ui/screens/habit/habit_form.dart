import 'package:flutter/material.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';

class HabitForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController title;
  final TextEditingController description;

  final String frequency;
  final bool reminderEnabled;
  final TimeOfDay? reminderTime;
  final int selectedColor;

  final ValueChanged<String> onFrequencyChanged;
  final ValueChanged<bool> onReminderChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<int>? onColorChanged;

  const HabitForm({
    super.key,
    required this.formKey,
    required this.title,
    required this.description,
    required this.frequency,
    required this.reminderEnabled,
    required this.reminderTime,
    this.selectedColor = 0xFF5B7CFA,
    required this.onFrequencyChanged,
    required this.onReminderChanged,
    required this.onTimeChanged,
    this.onColorChanged,
  });

  static const List<int> _palette = [
    0xFF5B7CFA, // Blue
    0xFF7FD1AE, // Green
    0xFFFF7B7B, // Red
    0xFFFFC175, // Orange
    0xFFAF81FA, // Purple
    0xFF60C5E4, // Cyan
    0xFFFF85C0, // Pink
    0xFFFFD166, // Yellow
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

          // Color picker
          if (onColorChanged != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Color',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Row(
                    children: _palette.map((c) {
                      final isSelected = selectedColor == c;
                      return GestureDetector(
                        onTap: () => onColorChanged!(c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 2.5,
                                  )
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Color(c).withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

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
                final t = await showIntervalTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                  interval: 5,
                  visibleStep: VisibleStep.fifths,
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
