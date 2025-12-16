import 'package:flutter/material.dart';
import 'package:focusx/ui/screens/habit/habit_card.dart';
import '../../../models/habit.dart';
import '../../../services/firestore_service.dart';
import '../../../utils/webservice.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder<List<Habit>>(
        stream:Webservice.firebaseService.watchHabits(),
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
              return HabitCard(habit: habits[i]);
            },
          );
        },
      ),
    );
  }
}