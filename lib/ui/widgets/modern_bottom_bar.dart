import 'package:flutter/material.dart';

class ModernBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const ModernBottomBar({
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.08),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Item(context,Icons.dashboard_rounded, "Home", 0),
          _Item(context,Icons.checklist_rounded, "Tasks", 1),
          _Item(context,Icons.repeat_rounded, "Habit", 2),
          _Item(context,Icons.bar_chart, "Analytics", 3),
          _Item(context,Icons.settings_rounded, "Settings", 4),
        ],
      ),
    );
  }

  Widget _Item(BuildContext context, IconData icon, String label, int i) {
    final selected = index == i;
    final color = Theme.of(context).colorScheme.primary;

    return FittedBox(
      child: GestureDetector(
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : null,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? color : Colors.grey),
              if (selected) ...[
                const SizedBox(width: 6),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.12,
                  child: FittedBox(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

}