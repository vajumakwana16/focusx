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
}