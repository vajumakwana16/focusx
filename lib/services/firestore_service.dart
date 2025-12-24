import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../models/habit.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  // ---------- TASKS ----------
  Future<void> addTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .add(task.toMap());
  }

  Stream<List<Task>> watchTasks({bool isToday = false}) {
    if(isToday){
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          // .where('createdAt',isEqualTo: DateTime.now().toIso8601String())
          .orderBy('createdAt', descending: true)
          .snapshots(includeMetadataChanges: true)
          .map((snapshot) {
        return snapshot.docs
            .map((d) => Task.fromMap(d.data(), d.id))
            .toList();
      });
    }else{
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .snapshots(includeMetadataChanges: true)
          .map((snapshot) {
        return snapshot.docs
            .map((d) => Task.fromMap(d.data(), d.id))
            .toList();
      });
      /* return _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .where('createdAt',isEqualTo: DateTime.now().toIso8601String().substring(0,10))
          .orderBy('createdAt', descending: true)
          .snapshots(includeMetadataChanges: true)
          .map((snapshot) {
        return snapshot.docs
            .map((d) => Task.fromMap(d.data(), d.id))
            .toList();
      });*/
    }
  }

  Future<List<Task>> getTasks() async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    return snap.docs
        .map((d) => Task.fromMap(d.data(), d.id))
        .toList();
  }

  /// TODAY TASKS
  Future<List<Task>> getTodayTasks() async {
    final todayKey = _dayKey(DateTime.now());

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    return snapshot.docs
        .map((d) => Task.fromMap(d.data(), d.id))
        .where((t) => t.dueDate.substring(0,10) == todayKey)
        .toList()
      ..sort((a, b) {
        // if (a.isCompleted == b.isCompleted) return 0;
        return a.isCompleted ? 1 : -1;
      });
  }

  Future<List<Habit>> getTodayHabits() async {
    final todayKey = _dayKey(DateTime.now());

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .get();

    return snapshot.docs
        .map((d) => Habit.fromMap(d.data(), d.id))
        // .where((h) => h.isScheduledForToday(todayKey))
        .toList();
  }


  Future<void> updateTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // ---------- HABITS ----------
  Future<void> addHabit(Habit habit) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .add(habit.toMap());
  }

  Stream<List<Habit>> watchHabits() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs
          .map((d) => Habit.fromMap(d.data(), d.id))
          .toList();
    });
  }

  Future<List<Habit>> getHabits() async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .get();

    return snap.docs
        .map((d) => Habit.fromMap(d.data(), d.id))
        .toList();
  }

  Future<void> updateHabit(Habit habit) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habit.id)
        .update(habit.toMap());
  }

  Future<void> deleteHabit(String habitId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habitId)
        .delete();
  }

  // ---------- PRODUCTIVITY ----------
  Future<Map<String, dynamic>> getProductivity() async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    int totalTimeSpent = 0;
    int totalDuration = 0;
    int completedTasks = 0;

    for (var d in snap.docs) {
      final t = d.data();
      totalTimeSpent += (t['timeSpent'] ?? 0) as int;
      totalDuration += (t['timerDuration'] ?? 0) as int;
      if (t['isCompleted'] == true) completedTasks++;
    }

    double productivity =
    totalDuration > 0 ? (totalTimeSpent / totalDuration) * 100 : 0;

    return {
      'totalTimeSpent': totalTimeSpent,
      'completedTasks': completedTasks,
      'productivity': productivity,
    };
  }

  /// 🔹 TODAY'S TASK STATS
  Future<Map<String, dynamic>> getTodayTaskStats() async {
    final todayKey = _dayKey(DateTime.now());

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    int plannedToday = 0;
    int completedToday = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Planned today
      print("${data['dueDate']}  - $todayKey ");
      if (data['dueDate'].toString().substring(0,10) == todayKey) {
        plannedToday++;

        if (data['isCompleted'] == true) {
          completedToday++;
        }
      }
    }

    final double ratio = plannedToday == 0
        ? 0
        : completedToday / plannedToday;

    final int score = (ratio * 10).round();

    String status;
    if (score >= 9) {
      status = '🔥 Deep Focus';
    } else if (score >= 7) {
      status = '💪 Focused';
    } else if (score >= 5) {
      status = '🙂 Average';
    } else if (score >= 3) {
      status = '😕 Low Focus';
    } else {
      status = '😴 Distracted';
    }

    return {
      'plannedToday': plannedToday,
      'completedToday': completedToday,
      'score': score,
      'status': status,
    };
  }


  /// 🔹 WEEKLY TASK COMPLETION (LAST 7 DAYS)
  Future<List<Map<String, dynamic>>> getWeeklyCompletedTasks() async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];

    // Build last 7 days (OLD → TODAY)
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));

      result.add({
        'dateKey': _dayKey(d),
        'dayLabel': _dayLabel(d),
        'count': 0,
      });
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('isCompleted', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      final completedAt = doc.data()['completedAt'];
      if (completedAt == null) continue;

      final date = DateTime.tryParse(completedAt)?.toLocal();
      if (date == null) continue;

      final key = _dayKey(date);

      final index =
      result.indexWhere((e) => e['dateKey'] == key);

      if (index != -1) {
        result[index]['count'] =
            (result[index]['count'] as int) + 1;
      }
    }

    return result;
  }


  String _dayKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _dayLabel(DateTime d) {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return labels[d.weekday % 7];
  }



  /// 🔹 HABIT INSIGHTS
  Future<Map<String, dynamic>> getHabitInsights() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .get();

    int todayDone = 0;
    int bestStreak = 0;

    for (var doc in snapshot.docs) {
      final dates =
      List<String>.from(doc['completionDates'] ?? []);

      if (dates.contains(today)) todayDone++;

      dates.sort();
      int streak = 0;
      DateTime? prev;

      for (var d in dates.reversed) {
        final curr = DateTime.parse(d);
        if (prev == null ||
            prev.difference(curr).inDays == 1) {
          streak++;
        } else {
          break;
        }
        prev = curr;
      }

      bestStreak = bestStreak > streak ? bestStreak : streak;
    }

    return {
      'activeHabits': snapshot.docs.length,
      'todayCompleted': todayDone,
      'bestStreak': bestStreak,
    };
  }


  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}