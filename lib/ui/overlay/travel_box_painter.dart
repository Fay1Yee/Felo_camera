import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';

class TravelBoxPainter extends CustomPainter {
  final Rect mainRect; // normalized [0..1]

  TravelBoxPainter({required this.mainRect});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      mainRect.left * size.width,
      mainRect.top * size.height,
      mainRect.width * size.width,
      mainRect.height * size.height,
    );

    // Border paint (Nothing OS style: clean white with slight glow)
    final borderPaint = Paint()
      ..color = NothingTheme.nothingWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw border
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

    // Inner grid (subtle)
    final gridPaint = Paint()
      ..color = NothingTheme.nothingWhite.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const gridCount = 3; // draw 2 inner lines each direction
    for (int i = 1; i < gridCount; i++) {
      final dx = rect.left + rect.width * i / gridCount;
      final dy = rect.top + rect.height * i / gridCount;
      // vertical
      canvas.drawLine(Offset(dx, rect.top + 6), Offset(dx, rect.bottom - 6), gridPaint);
      // horizontal
      canvas.drawLine(Offset(rect.left + 6, dy), Offset(rect.right - 6, dy), gridPaint);
    }

    // Corner markers
    final cornerPaint = Paint()
      ..color = NothingTheme.nothingWhite.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    const radius = 3.0;
    canvas.drawCircle(rect.topLeft + const Offset(8, 8), radius, cornerPaint);
    canvas.drawCircle(rect.topRight + const Offset(-8, 8), radius, cornerPaint);
    canvas.drawCircle(rect.bottomLeft + const Offset(8, -8), radius, cornerPaint);
    canvas.drawCircle(rect.bottomRight + const Offset(-8, -8), radius, cornerPaint);

    // Center crosshair
    final center = rect.center;
    final crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    const crossLen = 10.0;
    canvas.drawLine(Offset(center.dx - crossLen, center.dy), Offset(center.dx + crossLen, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - crossLen), Offset(center.dx, center.dy + crossLen), crossPaint);
  }

  @override
  bool shouldRepaint(covariant TravelBoxPainter oldDelegate) {
    return oldDelegate.mainRect != mainRect;
  }
}