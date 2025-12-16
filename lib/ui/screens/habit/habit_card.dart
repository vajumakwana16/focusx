import 'package:flutter/material.dart';
import '../../../models/habit.dart';
import '../../../services/firestore_service.dart';
import '../../../services/haptic_service.dart';
import '../../../utils/extensions.dart';
import '../../../utils/webservice.dart';
import 'add_edit_habit_page.dart';
import 'habit_streak_utils.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

   HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final h = habit;
    final streak = h.frequency == 'Daily'
        ? HabitStreakUtils.calculateDailyStreak(h.completionDates)
        : HabitStreakUtils.calculateWeeklyStreak(h.completionDates);

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        onTap: () async {
          HapticService.tap();
          context.next(AddEditHabitPage(habit: habit));
        },
        leading: CircleAvatar(
          backgroundColor: Color(h.color),
          child: const Icon(Icons.repeat, color: Colors.white),
        ),
        title: Text(h.title),
        /*subtitle: Text(
                    '${h.frequency} • ${h.completionDates.length} days',
                  ),*/
        subtitle: Text('${h.frequency} • 🔥 $streak day streak'),
        trailing: IconButton(
          icon:  Icon(Icons.done_all,color: streak >= 1 ?  context.theme.colorScheme.primary : Colors.white),
          onPressed:() async{
            final today =
            DateTime.now().toIso8601String().substring(0, 10);

            if (!h.completionDates.contains(today)) {
              h.completionDates.add(today);
              await Webservice.firebaseService.updateHabit(h);
            }else{
              h.completionDates.remove(today);
              await Webservice.firebaseService.updateHabit(h);
            }
            HapticService.light();
          },
        ),/*trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>Webservice.firebaseService.deleteHabit(h.id!),
                  ),*/
      ),
    );
  }

  // 🔁 TOGGLE COMPLETION
  Future<void> _toggleCompletion(
      BuildContext context,
      bool isDoneToday,
      String todayKey,
      ) async {
    HapticService.tap();

    final updatedDates = List<String>.from(habit.completionDates);

    if (isDoneToday) {
      updatedDates.remove(todayKey);
    } else {
      updatedDates.add(todayKey);
    }

    await Webservice.firebaseService.updateHabit(
      habit.copyWith(completionDates: updatedDates),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}