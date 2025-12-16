class Task {
  String? id;
  String title;
  String description;
  String dueDate;
  String dueTime;
  String priority;
  String category;
  bool isCompleted;
  String recurrence;
  int notificationId;
  bool hasTimer;
  int timerDuration;
  int timeSpent;
  int remainingTime;
  String? completedAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.priority,
    required this.category,
    required this.isCompleted,
    required this.recurrence,
    required this.notificationId,
    required this.hasTimer,
    required this.timerDuration,
    required this.timeSpent,
    required this.remainingTime,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'dueDate': dueDate,
    'dueTime': dueTime,
    'priority': priority,
    'category': category,
    'isCompleted': isCompleted,
    'recurrence': recurrence,
    'notificationId': notificationId,
    'hasTimer': hasTimer,
    'timerDuration': timerDuration,
    'timeSpent': timeSpent,
    'remainingTime': remainingTime,
    'createdAt': DateTime.now(),
    'completedAt': completedAt,
  };

  factory Task.fromMap(Map<String, dynamic> map, String docId) {
    return Task(
      id: docId,
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'],
      dueTime: map['dueTime'],
      priority: map['priority'],
      category: map['category'],
      isCompleted: map['isCompleted'],
      recurrence: map['recurrence'],
      notificationId: map['notificationId'],
      hasTimer: map['hasTimer'],
      timerDuration: map['timerDuration'],
      timeSpent: map['timeSpent'],
      remainingTime: map['remainingTime'],
      completedAt: map['completedAt'],
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? dueDate,
    String? dueTime,
    String? priority,
    String? category,
    bool? isCompleted,
    String? recurrence,
    int? notificationId,
    bool? hasTimer,
    int? timerDuration,
    int? timeSpent,
    int? remainingTime,
    String? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      recurrence: recurrence ?? this.recurrence,
      notificationId: notificationId ?? this.notificationId,
      hasTimer: hasTimer ?? this.hasTimer,
      timerDuration: timerDuration ?? this.timerDuration,
      timeSpent: timeSpent ?? this.timeSpent,
      remainingTime: remainingTime ?? this.remainingTime,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}