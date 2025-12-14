import 'package:flutter/material.dart';
import 'package:focusx/ui/widgets/section_card.dart';

class TaskPreviewCard extends StatelessWidget {
  const TaskPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Today’s Tasks',
      actionText: 'View All',
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Finish UI redesign'),
            subtitle: Text('10:00 AM'),
          ),
          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Workout'),
            subtitle: Text('6:00 PM'),
          ),
        ],
      ),
    );
  }
}