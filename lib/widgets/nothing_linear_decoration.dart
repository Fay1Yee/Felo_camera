import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/nothing_theme.dart';

/// Nothing OS风格的线性装饰组件
class NothingLinearDecoration extends StatelessWidget {
  final Widget child;
  final LinearDecorationType type;
  final Color lineColor;
  final double lineWidth;
  final bool animated;
  final EdgeInsets padding;

  const NothingLinearDecoration({
    super.key,
    required this.child,
    this.type = LinearDecorationType.border,
    this.lineColor = NothingTheme.nothingYellow,
    this.lineWidth = 1.5,
    this.animated = false,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: CustomPaint(
        painter: LinearDecorationPainter(
          type: type,
          lineColor: lineColor,
          lineWidth: lineWidth,
          animated: animated,
        ),
        child: child,
      ),
    );
  }
}

/// 动画线性装饰组件
class AnimatedNothingLinearDecoration extends StatefulWidget {
  final Widget child;
  final LinearDecorationType type;
  final Color lineColor;
  final double lineWidth;
  final EdgeInsets padding;
  final Duration duration;

  const AnimatedNothingLinearDecoration({
    super.key,
    required this.child,
    this.type = LinearDecorationType.border,
    this.lineColor = NothingTheme.nothingYellow,
    this.lineWidth = 1.5,
    this.padding = const EdgeInsets.all(16.0),
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AnimatedNothingLinearDecoration> createState() =>
      _AnimatedNothingLinearDecorationState();
}

class _AnimatedNothingLinearDecorationState
    extends State<AnimatedNothingLinearDecoration>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: LinearDecorationPainter(
              type: widget.type,
              lineColor: widget.lineColor,
              lineWidth: widget.lineWidth,
              animated: true,
              animationValue: _animation.value,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 线性装饰绘制器
class LinearDecorationPainter extends CustomPainter {
  final LinearDecorationType type;
  final Color lineColor;
  final double lineWidth;
  final bool animated;
  final double? animationValue;

  LinearDecorationPainter({
    required this.type,
    required this.lineColor,
    required this.lineWidth,
    this.animated = false,
    this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case LinearDecorationType.border:
        _drawBorder(canvas, size, paint);
        break;
      case LinearDecorationType.corners:
        _drawCorners(canvas, size, paint);
        break;
      case LinearDecorationType.grid:
        _drawGrid(canvas, size, paint);
        break;
      case LinearDecorationType.diagonal:
        _drawDiagonal(canvas, size, paint);
        break;
      case LinearDecorationType.circuit:
        _drawCircuit(canvas, size, paint);
        break;
      case LinearDecorationType.geometric:
        _drawGeometric(canvas, size, paint);
        break;
    }
  }

  void _drawBorder(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    if (animated && animationValue != null) {
      // 动画边框效果
      final progress = animationValue!;
      final perimeter = 2 * (size.width + size.height);
      final currentLength = perimeter * progress;
      
      _drawAnimatedBorder(canvas, rect, paint, currentLength);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  void _drawAnimatedBorder(Canvas canvas, Rect rect, Paint paint, double length) {
    final path = Path();
    double currentLength = 0;
    
    // 顶边
    if (length > currentLength) {
      final segmentLength = math.min(length - currentLength, rect.width);
      path.moveTo(rect.left, rect.top);
      path.lineTo(rect.left + segmentLength, rect.top);
      currentLength += segmentLength;
    }
    
    // 右边
    if (length > currentLength) {
      final segmentLength = math.min(length - currentLength, rect.height);
      if (path.getBounds().isEmpty) {
        path.moveTo(rect.right, rect.top);
      }
      path.lineTo(rect.right, rect.top + segmentLength);
      currentLength += segmentLength;
    }
    
    // 底边
    if (length > currentLength) {
      final segmentLength = math.min(length - currentLength, rect.width);
      if (path.getBounds().isEmpty) {
        path.moveTo(rect.right, rect.bottom);
      }
      path.lineTo(rect.right - segmentLength, rect.bottom);
      currentLength += segmentLength;
    }
    
    // 左边
    if (length > currentLength) {
      final segmentLength = math.min(length - currentLength, rect.height);
      if (path.getBounds().isEmpty) {
        path.moveTo(rect.left, rect.bottom);
      }
      path.lineTo(rect.left, rect.bottom - segmentLength);
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawCorners(Canvas canvas, Size size, Paint paint) {
    final cornerLength = math.min(size.width, size.height) * 0.2;
    
    // 左上角
    canvas.drawLine(
      const Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, cornerLength),
      paint,
    );
    
    // 右上角
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );
    
    // 右下角
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
    
    // 左下角
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    final spacing = 20.0;
    paint.color = lineColor.withValues(alpha: 0.3);
    
    // 垂直线
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // 水平线
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawDiagonal(Canvas canvas, Size size, Paint paint) {
    paint.color = lineColor.withValues(alpha: 0.2);
    
    // 对角线网格
    final spacing = 30.0;
    
    // 从左上到右下的对角线
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
    
    // 从右上到左下的对角线
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }
  }

  void _drawCircuit(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // 电路板风格的线条
    path.moveTo(0, centerY);
    path.lineTo(centerX * 0.3, centerY);
    path.lineTo(centerX * 0.3, centerY * 0.5);
    path.lineTo(centerX * 0.7, centerY * 0.5);
    path.lineTo(centerX * 0.7, centerY * 1.5);
    path.lineTo(centerX * 1.3, centerY * 1.5);
    path.lineTo(centerX * 1.3, centerY);
    path.lineTo(size.width, centerY);
    
    canvas.drawPath(path, paint);
    
    // 添加连接点
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX * 0.3, centerY), 3, pointPaint);
    canvas.drawCircle(Offset(centerX * 0.7, centerY * 0.5), 3, pointPaint);
    canvas.drawCircle(Offset(centerX * 1.3, centerY * 1.5), 3, pointPaint);
  }

  void _drawGeometric(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) * 0.3;
    
    // 绘制几何图形组合
    final path = Path();
    
    // 外圆
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    ));
    
    // 内部正六边形
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final x = centerX + radius * 0.7 * math.cos(angle);
      final y = centerY + radius * 0.7 * math.sin(angle);
      
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    path.addPath(hexPath, Offset.zero);
    
    // 中心十字
    path.moveTo(centerX - radius * 0.3, centerY);
    path.lineTo(centerX + radius * 0.3, centerY);
    path.moveTo(centerX, centerY - radius * 0.3);
    path.lineTo(centerX, centerY + radius * 0.3);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is LinearDecorationPainter &&
        (oldDelegate.animationValue != animationValue ||
         oldDelegate.lineColor != lineColor ||
         oldDelegate.lineWidth != lineWidth ||
         oldDelegate.type != type);
  }
}

/// 线性装饰类型
enum LinearDecorationType {
  border,     // 边框
  corners,    // 角落
  grid,       // 网格
  diagonal,   // 对角线
  circuit,    // 电路
  geometric,  // 几何
}