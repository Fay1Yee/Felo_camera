import 'package:flutter/material.dart';
import 'dart:math' as math;

class PersonalityDimensionChart extends StatelessWidget {
  final Map<String, double> dimensions;
  final double size;

  const PersonalityDimensionChart({
    Key? key,
    required this.dimensions,
    this.size = 200.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RadarChartPainter(dimensions),
        child: Container(),
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final Map<String, double> dimensions;
  
  RadarChartPainter(this.dimensions);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    
    // 绘制背景网格
    _drawGrid(canvas, center, radius);
    
    // 绘制维度标签
    _drawLabels(canvas, center, radius);
    
    // 绘制数据区域
    _drawDataArea(canvas, center, radius);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 绘制同心圆
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * i / 5, gridPaint);
    }

    // 绘制轴线
    final dimensionKeys = dimensions.keys.toList();
    for (int i = 0; i < dimensionKeys.length; i++) {
      final angle = (i * 2 * math.pi / dimensionKeys.length) - math.pi / 2;
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, gridPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final dimensionKeys = dimensions.keys.toList();
    final labelMap = {
      'E_I': 'E/I',
      'S_N': 'S/N', 
      'T_F': 'T/F',
      'J_P': 'J/P',
    };

    for (int i = 0; i < dimensionKeys.length; i++) {
      final angle = (i * 2 * math.pi / dimensionKeys.length) - math.pi / 2;
      final labelRadius = radius + 25;
      final labelPoint = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: labelMap[dimensionKeys[i]] ?? dimensionKeys[i],
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - textPainter.width / 2,
          labelPoint.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawDataArea(Canvas canvas, Offset center, double radius) {
    final dimensionKeys = dimensions.keys.toList();
    final path = Path();
    final points = <Offset>[];

    // 计算数据点
    for (int i = 0; i < dimensionKeys.length; i++) {
      final angle = (i * 2 * math.pi / dimensionKeys.length) - math.pi / 2;
      final value = dimensions[dimensionKeys[i]] ?? 0.0;
      final pointRadius = radius * (value / 100.0);
      
      final point = Offset(
        center.dx + pointRadius * math.cos(angle),
        center.dy + pointRadius * math.sin(angle),
      );
      points.add(point);
      
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // 绘制填充区域
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 绘制边框
    final strokePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, strokePaint);

    // 绘制数据点
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DimensionScoreCard extends StatelessWidget {
  final String dimension;
  final double score;
  final String description;

  const DimensionScoreCard({
    Key? key,
    required this.dimension,
    required this.score,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimensionNames = {
      'E_I': '外向性 (E/I)',
      'S_N': '感知方式 (S/N)',
      'T_F': '决策方式 (T/F)',
      'J_P': '生活方式 (J/P)',
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dimensionNames[dimension] ?? dimension,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _getScoreColor(score),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}