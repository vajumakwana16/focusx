import 'package:flutter/material.dart';

/// A monthly calendar widget that shows habit completion days.
/// Completed days are shown with a filled colored circle.
class HabitCalendarWidget extends StatefulWidget {
  final List<String> completionDates;
  final Color habitColor;
  final bool allowToggle;
  final Future<void> Function(String dateKey, bool completed)? onToggle;

  const HabitCalendarWidget({
    super.key,
    required this.completionDates,
    required this.habitColor,
    this.allowToggle = false,
    this.onToggle,
  });

  @override
  State<HabitCalendarWidget> createState() => _HabitCalendarWidgetState();
}

class _HabitCalendarWidgetState extends State<HabitCalendarWidget> {
  late DateTime _focusedMonth;
  late List<String> _completionDates;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _completionDates = List<String>.from(widget.completionDates);
  }

  @override
  void didUpdateWidget(HabitCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completionDates != widget.completionDates) {
      _completionDates = List<String>.from(widget.completionDates);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    final completedThisMonth = _completedCountForMonth(_focusedMonth);
    final totalDays = _totalScheduledDays(_focusedMonth, daysInMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                  1,
                );
              }),
            ),
            Column(
              children: [
                Text(
                  _monthName(_focusedMonth),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (totalDays > 0)
                  Text(
                    '$completedThisMonth / $totalDays days completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: _isCurrentOrFuture(_focusedMonth)
                    ? theme.colorScheme.onSurface.withOpacity(0.3)
                    : null,
              ),
              onPressed: _isCurrentOrFuture(_focusedMonth)
                  ? null
                  : () => setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1,
                          1,
                        );
                      }),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((d) {
                return SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      d,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 6),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
            mainAxisSpacing: 4,
            crossAxisSpacing: 2,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) {
              return const SizedBox.shrink();
            }
            final day = index - firstWeekday + 1;
            final date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              day,
            );
            final dateKey = _dateKey(date);
            final isCompleted = _completionDates.contains(dateKey);
            final isToday = _isToday(date);
            final isFuture = date.isAfter(DateTime.now());

            return GestureDetector(
              onTap: widget.allowToggle && !isFuture
                  ? () async {
                      final newCompleted = !isCompleted;
                      setState(() {
                        if (newCompleted) {
                          _completionDates.add(dateKey);
                        } else {
                          _completionDates.remove(dateKey);
                        }
                      });
                      await widget.onToggle?.call(dateKey, newCompleted);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? widget.habitColor
                      : isToday
                          ? widget.habitColor.withOpacity(0.12)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !isCompleted
                      ? Border.all(color: widget.habitColor, width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? Colors.white
                          : isFuture
                              ? theme.colorScheme.onSurface.withOpacity(0.25)
                              : theme.colorScheme.onSurface.withOpacity(
                                  isToday ? 1.0 : 0.85,
                                ),
                      fontWeight: isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Completion rate bar
        if (totalDays > 0) ...[
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completedThisMonth / totalDays,
                    minHeight: 6,
                    backgroundColor:
                        widget.habitColor.withOpacity(0.15),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(widget.habitColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${((completedThisMonth / totalDays) * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: widget.habitColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  int _completedCountForMonth(DateTime month) {
    return _completionDates.where((d) {
      try {
        final date = DateTime.parse(d);
        return date.year == month.year && date.month == month.month;
      } catch (_) {
        return false;
      }
    }).length;
  }

  int _totalScheduledDays(DateTime month, int daysInMonth) {
    final now = DateTime.now();
    final isCurrentMonth =
        month.year == now.year && month.month == now.month;
    final lastDay = isCurrentMonth ? now.day : daysInMonth;
    return lastDay;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isCurrentOrFuture(DateTime month) {
    final now = DateTime.now();
    return month.year > now.year ||
        (month.year == now.year && month.month >= now.month);
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _monthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
