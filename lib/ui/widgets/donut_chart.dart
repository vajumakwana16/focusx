import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutChartData {
  final String label;
  final double value;
  final Color color;

  const DonutChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class DonutChart extends StatelessWidget {
  final List<DonutChartData> data;
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;

  const DonutChart({
    super.key,
    required this.data,
    this.size = 160,
    this.strokeWidth = 22,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _DonutPainter(
                  data: data,
                  strokeWidth: strokeWidth,
                ),
              ),
              if (centerWidget != null) centerWidget!,
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: data.map((d) => _LegendItem(data: d)).toList(),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final DonutChartData data;
  const _LegendItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: data.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          data.label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutChartData> data;
  final double strokeWidth;

  _DonutPainter({required this.data, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    if (total == 0) {
      final bg = Paint()
        ..color = Colors.grey.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, bg);
      return;
    }

    double startAngle = -math.pi / 2;

    for (final item in data) {
      final sweepAngle = (item.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Separator lines between segments
    if (data.length > 1) {
      startAngle = -math.pi / 2;
      for (final item in data) {
        final sweepAngle = (item.value / total) * 2 * math.pi;
        startAngle += sweepAngle;
        // small separator
        final sepPaint = Paint()
          ..color = const Color(0x22000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(
            center.dx + (radius - strokeWidth / 2) * math.cos(startAngle),
            center.dy + (radius - strokeWidth / 2) * math.sin(startAngle),
          ),
          Offset(
            center.dx + (radius + strokeWidth / 2) * math.cos(startAngle),
            center.dy + (radius + strokeWidth / 2) * math.sin(startAngle),
          ),
          sepPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animated progress ring for single value
class ProgressRing extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;

  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 120,
    this.strokeWidth = 12,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              value: value,
              color: color,
              strokeWidth: strokeWidth,
              trackColor: color.withOpacity(0.12),
            ),
          ),
          if (centerWidget != null) centerWidget!,
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double value;
  final Color color;
  final double strokeWidth;
  final Color trackColor;

  _ProgressRingPainter({
    required this.value,
    required this.color,
    required this.strokeWidth,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    final progress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      value.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
