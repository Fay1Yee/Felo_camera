import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';

class YellowFramePainter extends CustomPainter {
  final Rect mainRect; // relative coords; convert externally
  final Rect? subRect; // optional

  YellowFramePainter({required this.mainRect, this.subRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Nothing Phone OS 特有的精细点阵网格
    final gridPaint = Paint()
      ..color = NothingTheme.whiteAlpha20
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // 更精细的网格间距，体现Nothing OS的精密感
    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Nothing OS 风格的线性装饰点
    _drawLinearDots(canvas, size);

    // 中心十字线 - Nothing OS 特色
    final crossPaint = Paint()
      ..color = NothingTheme.yellowAlpha30
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), crossPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), crossPaint);

    // 主取景框 - 采用Nothing OS的线性设计
    final rectPaint = Paint()
      ..color = NothingTheme.nothingYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final absMain = Rect.fromLTWH(
      mainRect.left * size.width,
      mainRect.top * size.height,
      mainRect.width * size.width,
      mainRect.height * size.height,
    );
    
    // Nothing OS 特有的圆角设计
    final rrect = RRect.fromRectAndRadius(absMain, const Radius.circular(16));
    canvas.drawRRect(rrect, rectPaint);

    // Nothing OS 风格的角落线性装饰
    _drawNothingCornerDecorations(canvas, absMain);

    // 线性扫描效果 - Nothing OS 特色
    _drawLinearScanEffect(canvas, absMain);

    // 可选的子框架
    if (subRect != null) {
      final absSub = Rect.fromLTWH(
        subRect!.left * size.width,
        subRect!.top * size.height,
        subRect!.width * size.width,
        subRect!.height * size.height,
      );
      final subPaint = Paint()
        ..color = NothingTheme.yellowAlpha70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawRRect(RRect.fromRectAndRadius(absSub, const Radius.circular(12)), subPaint);
    }
  }

  /// Nothing OS 风格的线性装饰点
  void _drawLinearDots(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = NothingTheme.yellowAlpha20
      ..style = PaintingStyle.fill;

    const dotSize = 2.0;
    const spacing = 40.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        // 创建线性排列的点阵效果
        if ((x / spacing + y / spacing) % 3 == 0) {
          canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
        }
      }
    }
  }

  /// Nothing OS 特有的角落线性装饰
  void _drawNothingCornerDecorations(Canvas canvas, Rect rect) {
    final cornerPaint = Paint()
      ..color = NothingTheme.nothingYellow
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const cornerLen = 28.0;
    const offset = 8.0;

    // 顶左角 - L形线性装饰
    canvas.drawLine(
      rect.topLeft + const Offset(-offset, 0), 
      rect.topLeft + const Offset(cornerLen, 0), 
      cornerPaint
    );
    canvas.drawLine(
      rect.topLeft + const Offset(0, -offset), 
      rect.topLeft + const Offset(0, cornerLen), 
      cornerPaint
    );

    // 顶右角
    canvas.drawLine(
      rect.topRight + const Offset(offset, 0), 
      rect.topRight + const Offset(-cornerLen, 0), 
      cornerPaint
    );
    canvas.drawLine(
      rect.topRight + const Offset(0, -offset), 
      rect.topRight + const Offset(0, cornerLen), 
      cornerPaint
    );

    // 底左角
    canvas.drawLine(
      rect.bottomLeft + const Offset(-offset, 0), 
      rect.bottomLeft + const Offset(cornerLen, 0), 
      cornerPaint
    );
    canvas.drawLine(
      rect.bottomLeft + const Offset(0, offset), 
      rect.bottomLeft + const Offset(0, -cornerLen), 
      cornerPaint
    );

    // 底右角
    canvas.drawLine(
      rect.bottomRight + const Offset(offset, 0), 
      rect.bottomRight + const Offset(-cornerLen, 0), 
      cornerPaint
    );
    canvas.drawLine(
      rect.bottomRight + const Offset(0, offset), 
      rect.bottomRight + const Offset(0, -cornerLen), 
      cornerPaint
    );
  }

  /// Nothing OS 特色的线性扫描效果
  void _drawLinearScanEffect(Canvas canvas, Rect rect) {
    final scanPaint = Paint()
      ..color = NothingTheme.yellowAlpha10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 水平扫描线
    for (double y = rect.top + 10; y < rect.bottom; y += 15) {
      canvas.drawLine(
        Offset(rect.left + 10, y),
        Offset(rect.right - 10, y),
        scanPaint,
      );
    }

    // 垂直扫描线
    for (double x = rect.left + 10; x < rect.right; x += 15) {
      canvas.drawLine(
        Offset(x, rect.top + 10),
        Offset(x, rect.bottom - 10),
        scanPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant YellowFramePainter oldDelegate) {
    return oldDelegate.mainRect != mainRect || oldDelegate.subRect != subRect;
  }
}