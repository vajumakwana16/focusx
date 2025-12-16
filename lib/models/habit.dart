class Habit {
  String? id;
  String title;
  String description;
  String frequency;
  String reminderTime;
  String startDate;
  List<String> completionDates;
  int notificationId;
  int color;

  Habit({
    this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.reminderTime,
    required this.startDate,
    required this.completionDates,
    required this.notificationId,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'frequency': frequency,
    'reminderTime': reminderTime,
    'startDate': startDate,
    'completionDates': completionDates,
    'notificationId': notificationId,
    'color': color,
    'createdAt': DateTime.now(),
  };

  factory Habit.fromMap(Map<String, dynamic> map, String docId) {
    return Habit(
      id: docId,
      title: map['title'],
      description: map['description'],
      frequency: map['frequency'],
      reminderTime: map['reminderTime'],
      startDate: map['startDate'],
      completionDates:
      List<String>.from(map['completionDates'] ?? []),
      notificationId: map['notificationId'],
      color: map['color'],
    );
  }

  bool isScheduledForToday(String todayKey) {
    final today = DateTime.parse(todayKey);
    final start = DateTime.parse(startDate);

    // Habit not started yet
    if (today.isBefore(start)) return false;

    switch (frequency) {
      case 'daily':
        return true;

      case 'weekly':
      // Same weekday as start date
        return today.weekday == start.weekday;

      // case 'custom':
      // // Example: ['mon', 'wed', 'fri']
      //   if (customDays == null || customDays!.isEmpty) return false;
      //
      //   final todayName = _weekdayName(today.weekday);
      //   return customDays!.contains(todayName);

      default:
        return false;
    }
  }

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? frequency,
    String? reminderTime,
    String? startDate,
    List<String>? completionDates,
    int? notificationId,
    int? color,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      startDate: startDate ?? this.startDate,
      completionDates:
      completionDates ?? List<String>.from(this.completionDates),
      notificationId: notificationId ?? this.notificationId,
      color: color ?? this.color,
    );
  }

}