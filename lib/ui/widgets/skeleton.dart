import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  final double height;

  const Skeleton({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _line(width: 120),
            const SizedBox(height: 12),
            _line(width: double.infinity, height: 20),
            const SizedBox(height: 12),
            _line(width: 180),
          ],
        ),
      ),
    );
  }

  Widget _line({double width = 100, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}