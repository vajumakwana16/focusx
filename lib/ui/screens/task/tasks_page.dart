import 'package:flutter/material.dart';
import 'package:focusx/ui/screens/task/task_card.dart';
import '../../../models/task.dart';
import '../../../services/firestore_service.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: StreamBuilder<List<Task>>(
        stream: service.watchTasks(),
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