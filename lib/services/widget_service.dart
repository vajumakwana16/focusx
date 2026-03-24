import 'dart:math';
import 'package:home_widget/home_widget.dart';
import '../utils/webservice.dart';

/// Keeps the Android home-screen widget in sync with the latest task/habit
/// data from Firestore.  Call [refresh] after any write operation.
class WidgetService {
  static const String _androidWidgetName = 'FocusXWidgetProvider';

  /// Fetches today's stats and pushes them to the home-screen widget.
  static Future<void> refresh() async {
    try {
      final taskStats =
          await Webservice.firebaseService.getTodayTaskStats();
      final habitInsights =
          await Webservice.firebaseService.getHabitInsights();

      final completedTasks = taskStats['completedToday'] as int;
      final totalTasks = taskStats['plannedToday'] as int;
      final pendingTasks = max(0, totalTasks - completedTasks);

      final completedHabits = habitInsights['todayCompleted'] as int;
      final totalHabits = habitInsights['activeHabits'] as int;

      // Save data for the Android widget to read
      await HomeWidget.saveWidgetData<int>('pendingTasks', pendingTasks);
      await HomeWidget.saveWidgetData<int>('completedTasks', completedTasks);
      await HomeWidget.saveWidgetData<int>('totalTasks', totalTasks);
      await HomeWidget.saveWidgetData<int>('completedHabits', completedHabits);
      await HomeWidget.saveWidgetData<int>('totalHabits', totalHabits);

      // Request the widget to redraw
      await HomeWidget.updateWidget(androidName: _androidWidgetName);
    } catch (_) {
      // Widget update is best-effort; never crash the main flow
    }
  }
}
