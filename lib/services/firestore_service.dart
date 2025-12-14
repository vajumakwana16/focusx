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

  Stream<List<Task>> watchTasks() {
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
}