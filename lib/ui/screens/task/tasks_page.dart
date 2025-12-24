import 'package:flutter/material.dart';
import 'package:focusx/ui/screens/task/task_card.dart';
import '../../../models/task.dart';
import '../../../utils/webservice.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Task>>(
        stream: Webservice.firebaseService.watchTasks(isToday: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, i) {
              final t = tasks[i];
              return TaskCard(task: t);
            },
          );
        },
      ),
    );
  }
}