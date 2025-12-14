import 'package:flutter/material.dart';
import 'package:focusx/utils/extensions.dart';

import '../../../models/habit.dart';
import '../../../services/firestore_service.dart';
import 'add_edit_habit_page.dart';
import 'habit_streak_utils.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: StreamBuilder<List<Habit>>(
        stream: service.watchHabits(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final habits = snapshot.data!;
          if (habits.isEmpty) {
            return const Center(child: Text('No habits added'));
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (_, i) {
              final h = habits[i];

              final streak = h.frequency == 'Daily'
                  ? HabitStreakUtils.calculateDailyStreak(h.completionDates)
                  : HabitStreakUtils.calculateWeeklyStreak(h.completionDates);

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: ListTile(
                  onTap: () async {
                    context.next(AddEditHabitPage(habit: h));
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
                        await service.updateHabit(h);
                      }else{
                        h.completionDates.remove(today);
                        await service.updateHabit(h);
                      }
                    },
                  ),/*trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => service.deleteHabit(h.id!),
                  ),*/
                ),
              );
            },
          );
        },
      ),
    );
  }
}