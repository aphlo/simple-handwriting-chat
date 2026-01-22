import 'package:flutter/material.dart';

import '../models/stroke.dart';

class MirrorPainter extends CustomPainter {
  MirrorPainter({
    required this.strokes,
    required this.flipBothXY,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final List<Stroke> strokes;
  final bool flipBothXY;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();

    if (flipBothXY) {
      canvas.translate(size.width, size.height);
      canvas.scale(-1, -1);
    }

    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;

      final path = Path()
        ..moveTo(stroke.points.first.offset.dx, stroke.points.first.offset.dy);

      for (int i = 1; i < stroke.points.length; i++) {
        final p = stroke.points[i].offset;
        path.lineTo(p.dx, p.dy);
      }

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MirrorPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.flipBothXY != flipBothXY ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
