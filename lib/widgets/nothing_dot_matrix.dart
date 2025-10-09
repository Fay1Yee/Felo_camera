import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/nothing_theme.dart';

/// Nothing OS风格的点阵装饰组件
class NothingDotMatrix extends StatelessWidget {
  final double width;
  final double height;
  final Color dotColor;
  final double dotSize;
  final double spacing;
  final DotPattern pattern;
  final bool animated;

  const NothingDotMatrix({
    super.key,
    required this.width,
    required this.height,
    this.dotColor = NothingTheme.nothingLightGray,
    this.dotSize = NothingTheme.dotSize,
    this.spacing = NothingTheme.dotSpacing,
    this.pattern = DotPattern.grid,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return AnimatedDotMatrix(
        width: width,
        height: height,
        dotColor: dotColor,
        dotSize: dotSize,
        spacing: spacing,
        pattern: pattern,
      );
    }

    return CustomPaint(
      size: Size(width, height),
      painter: DotMatrixPainter(
        dotColor: dotColor,
        dotSize: dotSize,
        spacing: spacing,
        pattern: pattern,
      ),
    );
  }
}

/// 动画点阵组件
class AnimatedDotMatrix extends StatefulWidget {
  final double width;
  final double height;
  final Color dotColor;
  final double dotSize;
  final double spacing;
  final DotPattern pattern;

  const AnimatedDotMatrix({
    super.key,
    required this.width,
    required this.height,
    required this.dotColor,
    required this.dotSize,
    required this.spacing,
    required this.pattern,
  });

  @override
  State<AnimatedDotMatrix> createState() => _AnimatedDotMatrixState();
}

class _AnimatedDotMatrixState extends State<AnimatedDotMatrix>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: DotMatrixPainter(
            dotColor: widget.dotColor,
            dotSize: widget.dotSize,
            spacing: widget.spacing,
            pattern: widget.pattern,
            animationValue: _animation.value,
          ),
        );
      },
    );
  }
}

/// 点阵绘制器
class DotMatrixPainter extends CustomPainter {
  final Color dotColor;
  final double dotSize;
  final double spacing;
  final DotPattern pattern;
  final double? animationValue;

  DotMatrixPainter({
    required this.dotColor,
    required this.dotSize,
    required this.spacing,
    required this.pattern,
    this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    switch (pattern) {
      case DotPattern.grid:
        _drawGridPattern(canvas, size, paint);
        break;
      case DotPattern.diagonal:
        _drawDiagonalPattern(canvas, size, paint);
        break;
      case DotPattern.circular:
        _drawCircularPattern(canvas, size, paint);
        break;
      case DotPattern.wave:
        _drawWavePattern(canvas, size, paint);
        break;
      case DotPattern.random:
        _drawRandomPattern(canvas, size, paint);
        break;
    }
  }

  void _drawGridPattern(Canvas canvas, Size size, Paint paint) {
    final cols = (size.width / spacing).floor();
    final rows = (size.height / spacing).floor();

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        final x = i * spacing + spacing / 2;
        final y = j * spacing + spacing / 2;
        
        double opacity = 1.0;
        if (animationValue != null) {
          final distance = math.sqrt(
            math.pow(x - size.width / 2, 2) + math.pow(y - size.height / 2, 2)
          );
          final maxDistance = math.sqrt(
            math.pow(size.width / 2, 2) + math.pow(size.height / 2, 2)
          );
          final normalizedDistance = distance / maxDistance;
          opacity = (math.sin(animationValue! * math.pi * 2 + normalizedDistance * math.pi * 4) + 1) / 2;
        }

        paint.color = dotColor.withValues(alpha: opacity);
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  void _drawDiagonalPattern(Canvas canvas, Size size, Paint paint) {
    final cols = (size.width / spacing).floor();
    final rows = (size.height / spacing).floor();

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if ((i + j) % 2 == 0) {
          final x = i * spacing + spacing / 2;
          final y = j * spacing + spacing / 2;
          
          double opacity = 1.0;
          if (animationValue != null) {
            opacity = (math.sin(animationValue! * math.pi * 2 + (i + j) * 0.5) + 1) / 2;
          }

          paint.color = dotColor.withValues(alpha: opacity);
          canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
        }
      }
    }
  }

  void _drawCircularPattern(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = math.min(centerX, centerY);
    
    for (double radius = spacing; radius < maxRadius; radius += spacing) {
      final circumference = 2 * math.pi * radius;
      final dotCount = (circumference / spacing).floor();
      
      for (int i = 0; i < dotCount; i++) {
        final angle = (i / dotCount) * 2 * math.pi;
        final x = centerX + radius * math.cos(angle);
        final y = centerY + radius * math.sin(angle);
        
        double opacity = 1.0;
        if (animationValue != null) {
          opacity = (math.sin(animationValue! * math.pi * 2 + angle + radius * 0.1) + 1) / 2;
        }

        paint.color = dotColor.withValues(alpha: opacity);
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  void _drawWavePattern(Canvas canvas, Size size, Paint paint) {
    final cols = (size.width / spacing).floor();
    final rows = (size.height / spacing).floor();

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        final x = i * spacing + spacing / 2;
        final y = j * spacing + spacing / 2;
        
        final waveOffset = math.sin(i * 0.5) * spacing * 0.3;
        final adjustedY = y + waveOffset;
        
        double opacity = 1.0;
        if (animationValue != null) {
          opacity = (math.sin(animationValue! * math.pi * 2 + i * 0.5) + 1) / 2;
        }

        paint.color = dotColor.withValues(alpha: opacity);
        canvas.drawCircle(Offset(x, adjustedY), dotSize / 2, paint);
      }
    }
  }

  void _drawRandomPattern(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42); // 固定种子确保一致性
    final dotCount = ((size.width * size.height) / (spacing * spacing)).floor();
    
    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      double opacity = 1.0;
      if (animationValue != null) {
        opacity = (math.sin(animationValue! * math.pi * 2 + i * 0.1) + 1) / 2;
      }

      paint.color = dotColor.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is DotMatrixPainter &&
        (oldDelegate.animationValue != animationValue ||
         oldDelegate.dotColor != dotColor ||
         oldDelegate.dotSize != dotSize ||
         oldDelegate.spacing != spacing ||
         oldDelegate.pattern != pattern);
  }
}

/// 点阵图案类型
enum DotPattern {
  grid,      // 网格
  diagonal,  // 对角线
  circular,  // 圆形
  wave,      // 波浪
  random,    // 随机
}