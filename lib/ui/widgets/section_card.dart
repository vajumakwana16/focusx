import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String actionText;
  final Widget child;

  const SectionCard({
    required this.title,
    required this.actionText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(actionText,
                    style: const TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}