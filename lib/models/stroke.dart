import 'package:flutter/material.dart';

enum Pane { top, bottom }

class StrokePoint {
  StrokePoint(this.offset);
  final Offset offset;
}

class Stroke {
  Stroke({required this.pointerId, required this.points});
  final int pointerId;
  final List<StrokePoint> points;

  Stroke copyWith({List<StrokePoint>? points}) {
    return Stroke(pointerId: pointerId, points: points ?? this.points);
  }
}
