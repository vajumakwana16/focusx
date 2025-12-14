class HabitStreakUtils {
  static int calculateDailyStreak(List<String> dates) {
    if (dates.isEmpty) return 0;

    final sorted = dates
        .map(DateTime.parse)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 1;

    for (int i = 0; i < sorted.length - 1; i++) {
      final diff = sorted[i].difference(sorted[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static int calculateWeeklyStreak(List<String> dates) {
    if (dates.isEmpty) return 0;

    final weeks = dates.map((d) {
      final date = DateTime.parse(d);
      return '${date.year}-${_weekOfYear(date)}';
    }).toSet();

    return weeks.length;
  }

  static int _weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    return ((date.difference(firstDay).inDays) / 7).ceil();
  }
}