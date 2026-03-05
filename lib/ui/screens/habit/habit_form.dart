import 'package:flutter/material.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';
import '../../theme/app_theme.dart';

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
    this.selectedColor = 0xFF6C63FF,
    required this.onFrequencyChanged,
    required this.onReminderChanged,
    required this.onTimeChanged,
    this.onColorChanged,
  });

  static const List<int> _palette = [
    0xFF6C63FF, // Purple-blue
    0xFF00D9A6, // Green
    0xFFFF6B8A, // Pink
    0xFFFFA26B, // Orange
    0xFF8B5CF6, // Purple
    0xFF06B6D4, // Cyan
    0xFF3B82F6, // Blue
    0xFFF59E0B, // Amber
    0xFF10B981, // Emerald
    0xFFEC4899, // Hot Pink
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: formKey,
      child: ListView(
        children: [
          _field(
            controller: title,
            label: 'Habit Title',
            icon: Icons.repeat_rounded,
            validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
          ),

          _field(
            controller: description,
            label: 'Description',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),

          // Frequency selection with styled chips
          _sectionLabel(theme, 'Frequency'),
          const SizedBox(height: 8),
          Row(
            children: ['Daily', 'Weekly'].map((f) {
              final isSelected = frequency == f;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onFrequencyChanged(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withOpacity(0.15)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : theme.dividerColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            f == 'Daily'
                                ? Icons.today_rounded
                                : Icons.date_range_rounded,
                            size: 18,
                            color: isSelected
                                ? AppTheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            f,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppTheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Color picker
          if (onColorChanged != null) ...[
            _sectionLabel(theme, 'Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _palette.map((c) {
                final isSelected = selectedColor == c;
                return GestureDetector(
                  onTap: () => onColorChanged!(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: isDark ? Colors.white : Colors.black87,
                              width: 2.5,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(c).withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Reminder toggle
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: SwitchListTile(
              title: const Text('Enable Reminder'),
              value: reminderEnabled,
              onChanged: onReminderChanged,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          if (reminderEnabled) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: AppTheme.accent,
                    size: 20,
                  ),
                ),
                title: Text(
                  reminderTime == null
                      ? 'Pick reminder time'
                      : reminderTime!.format(context),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
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
            ),
          ],

          // Extra spacing so content isn't hidden behind FAB
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
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
}
