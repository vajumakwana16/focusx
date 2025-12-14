import 'package:flutter/material.dart';
import 'package:focusx/ui/widgets/section_card.dart';

class HabitPreviewCard extends StatelessWidget {
  const HabitPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Habits',
      actionText: 'Details',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _HabitChip(label: 'Meditation'),
          _HabitChip(label: 'Reading'),
          _HabitChip(label: 'Workout'),
        ],
      ),
    );
  }
}

class _HabitChip extends StatelessWidget {
  final String label;
  const _HabitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}