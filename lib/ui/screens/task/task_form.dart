import 'package:flutter/material.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';
import '../../theme/app_theme.dart';

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
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: ListView(
        children: [
          _field(
            controller: title,
            label: 'Task Title',
            icon: Icons.edit_rounded,
            validator: (v) =>
                v == null || v.isEmpty ? 'Title is required' : null,
          ),

          _field(
            controller: description,
            label: 'Description',
            icon: Icons.notes_rounded,
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
                  icon: Icons.calendar_today_rounded,
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
                  icon: Icons.access_time_rounded,
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
          ),

          const SizedBox(height: 16),

          // Priority selection with colored chips
          _sectionLabel(theme, 'Priority'),
          const SizedBox(height: 8),
          Row(
            children: ['Low', 'Medium', 'High'].map((p) {
              final isSelected = priority == p;
              final color = _priorityColor(p);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onPriorityChanged(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : theme.dividerColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? color
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

          // Category selection with icon grid
          _sectionLabel(theme, 'Category'),
          const SizedBox(height: 8),
          _CategoryGrid(
            selectedCategory: category,
            onCategoryChanged: onCategoryChanged,
          ),

          const SizedBox(height: 12),

          // Reminder toggle
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: SwitchListTile(
              value: reminderEnabled,
              onChanged: onReminderChanged,
              title: const Text('Enable Reminder'),
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

          // Extra spacing so content isn't hidden behind FAB
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return const Color(0xFFFF4757);
      case 'Low':
        return const Color(0xFF00D9A6);
      default:
        return const Color(0xFFFFA26B);
    }
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const _CategoryGrid({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = AppTheme.categories;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i];
        final isSelected = selectedCategory == cat;
        final color = AppTheme.getCategoryColor(cat);
        final icon = AppTheme.getCategoryIcon(cat);

        return GestureDetector(
          onTap: () => onCategoryChanged(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.15)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : theme.dividerColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isSelected ? 0.2 : 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  cat,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? color
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}