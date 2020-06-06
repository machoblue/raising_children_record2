import 'package:flutter/material.dart';

extension CanvasExtension on Canvas {
  void drawText(String text, TextStyle style, TextAlign align, Rect rect) {
    final textSpan = TextSpan(style: style, text: text);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align, maxLines: 1);
    textPainter.layout(minWidth: rect.width, maxWidth: rect.width);
    textPainter.paint(this, rect.topLeft);
  }
}
