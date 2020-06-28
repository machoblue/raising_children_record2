
import 'dart:math';

import 'package:flutter/material.dart';

extension CanvasExtension on Canvas {
  void drawText(String text, TextStyle style, TextAlign align, Rect rect) {
    final textSpan = TextSpan(style: style, text: text);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align, maxLines: 1);
    textPainter.layout(minWidth: rect.width, maxWidth: rect.width);
    textPainter.paint(this, rect.topLeft);
  }

  void drawLines(List<Point<double>> points, Color color, {double pointRadius, double strokeWidth = 2.5}) {
    if (points == null || points.length == 0) {
      return;
    }

    Path linePath = Path();
    final Point<double> first = points.first;
    linePath.moveTo(first.x, first.y);
    for (int i = 1; i < points.length; i++) {
      final Point<double> point = points[i];
      linePath.lineTo(point.x, point.y);
    }

    Paint linePaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    drawPath(linePath, linePaint);

    if (pointRadius == null || pointRadius == 0) {
      return;
    }

    Paint circlePaint= Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (Point<double> point in points) {
      drawCircle(Offset(point.x, point.y), pointRadius, circlePaint);
    }
  }
}
