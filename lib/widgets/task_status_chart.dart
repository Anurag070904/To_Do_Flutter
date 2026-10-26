import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class TaskStatusChart extends StatelessWidget {
  const TaskStatusChart({
    super.key,
    required this.completed,
    required this.pending,
  });

  final int completed;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final total = completed + pending;
    final progress = total == 0 ? 0.0 : completed / total;

    return Semantics(
      label: 'Task status: $completed completed, $pending pending',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task overview',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completion status',
                style: TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size.square(96),
                          painter: _TaskStatusPainter(progress: progress),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$total',
                              style: const TextStyle(
                                color: AppTheme.ink,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'TOTAL',
                              style: TextStyle(
                                color: AppTheme.muted,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _StatusCount(
                          label: 'Completed',
                          count: completed,
                          color: const Color(0xFF54B990),
                        ),
                        const SizedBox(height: 14),
                        _StatusCount(
                          label: 'Pending',
                          count: pending,
                          color: AppTheme.accent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  const _StatusCount({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Text(
        '$count',
        style: const TextStyle(
          color: AppTheme.ink,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _TaskStatusPainter extends CustomPainter {
  const _TaskStatusPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final rect = Offset.zero & size;
    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);
    final trackPaint =
        Paint()
          ..color = AppTheme.accent.withValues(alpha: 0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, 0, math.pi * 2, false, trackPaint);
    if (progress == 0) return;

    final completedPaint =
        Paint()
          ..color = const Color(0xFF54B990)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      completedPaint,
    );
  }

  @override
  bool shouldRepaint(_TaskStatusPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
