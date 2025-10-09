import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/nothing_theme.dart';

/// Nothing OS风格的图表组件
class NothingChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  final ChartType type;
  final double height;
  final Color? primaryColor;
  final Color? secondaryColor;

  const NothingChart({
    super.key,
    required this.data,
    required this.title,
    this.type = ChartType.bar,
    this.height = 200,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: NothingTheme.nothingCardDecoration,
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeTitle,
              fontWeight: NothingTheme.fontWeightSemiBold,
              color: NothingTheme.nothingBlack,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          Expanded(
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (type) {
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.line:
        return _buildLineChart();
      case ChartType.pie:
        return _buildPieChart();
      case ChartType.donut:
        return _buildDonutChart();
    }
  }

  Widget _buildBarChart() {
    if (data.isEmpty) return const Center(child: Text('暂无数据'));

    final maxValue = data.map((e) => e.value).reduce(math.max);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.asMap().entries.map((entry) {
        final _ = entry.key;
        final item = entry.value;
        final barHeight = (item.value / maxValue) * (height - 80);
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 数值标签
                Text(
                  item.value.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeCaption,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.nothingGray,
                  ),
                ),
                const SizedBox(height: 4),
                // 柱状图
                Container(
                  width: double.infinity,
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor ?? NothingTheme.nothingYellow,
                        (primaryColor ?? NothingTheme.nothingYellow).withValues(alpha: 0.8),
                        (primaryColor ?? NothingTheme.nothingYellow).withValues(alpha: 0.6),
                        (primaryColor ?? NothingTheme.nothingYellow).withValues(alpha: 0.3),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(NothingTheme.radiusSmall),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (primaryColor ?? NothingTheme.nothingYellow).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 标签
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeCaption,
                    color: NothingTheme.nothingGray,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineChart() {
    if (data.isEmpty) return const Center(child: Text('暂无数据'));

    return CustomPaint(
      size: Size.infinite,
      painter: LineChartPainter(
        data: data,
        primaryColor: primaryColor ?? NothingTheme.nothingYellow,
      ),
    );
  }

  Widget _buildPieChart() {
    if (data.isEmpty) return const Center(child: Text('暂无数据'));

    return CustomPaint(
      size: Size.infinite,
      painter: PieChartPainter(
        data: data,
        primaryColor: primaryColor ?? NothingTheme.nothingYellow,
      ),
    );
  }

  Widget _buildDonutChart() {
    if (data.isEmpty) return const Center(child: Text('暂无数据'));

    final total = data.fold<double>(0, (sum, item) => sum + item.value);
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomPaint(
            size: Size.infinite,
            painter: DonutChartPainter(
              data: data,
              primaryColor: primaryColor ?? NothingTheme.nothingYellow,
            ),
          ),
        ),
        const SizedBox(width: NothingTheme.spacingMedium),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: data.map((item) {
              final percentage = (item.value / total * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColorForIndex(data.indexOf(item)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: NothingTheme.fontSizeCaption,
                              fontWeight: NothingTheme.fontWeightMedium,
                              color: NothingTheme.nothingBlack,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontSize: NothingTheme.fontSizeCaption,
                              color: NothingTheme.nothingGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      NothingTheme.nothingYellow,
      NothingTheme.successGreen,
      NothingTheme.infoBlue,
      NothingTheme.warningOrange,
      NothingTheme.nothingDarkGray,
      NothingTheme.nothingGray,
    ];
    return colors[index % colors.length];
  }
}

/// 图表数据模型
class ChartData {
  final String label;
  final double value;
  final Color? color;

  const ChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

/// 图表类型枚举
enum ChartType {
  bar,
  line,
  pie,
  donut,
}

/// 线性图表绘制器
class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color primaryColor;

  LineChartPainter({
    required this.data,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final maxValue = data.map((e) => e.value).reduce(math.max);
    final minValue = data.map((e) => e.value).reduce(math.min);
    final valueRange = maxValue - minValue;

    final linePath = Path();
    final fillPath = Path();
    final points = <Offset>[];

    // 创建渐变填充路径
    fillPath.moveTo(0, size.height);

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].value - minValue) / valueRange) * size.height;
      
      points.add(Offset(x, y));
      
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // 完成填充路径
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // 创建渐变填充
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withValues(alpha: 0.3),
        primaryColor.withValues(alpha: 0.1),
        primaryColor.withValues(alpha: 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // 绘制渐变填充
    canvas.drawPath(fillPath, gradientPaint);

    // 绘制阴影线条
    final shadowLinePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, shadowLinePaint);

    // 绘制主线条
    canvas.drawPath(linePath, linePaint);

    // 绘制点和光晕效果
    for (final point in points) {
      // 绘制光晕
      final glowPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 8, glowPaint);

      // 绘制外圈
      final outerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 5, outerPaint);

      // 绘制内圈
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 饼图绘制器
class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color primaryColor;

  PieChartPainter({
    required this.data,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = _getColorForIndex(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      NothingTheme.nothingYellow,
      NothingTheme.successGreen,
      NothingTheme.infoBlue,
      NothingTheme.warningOrange,
      NothingTheme.nothingDarkGray,
      NothingTheme.nothingGray,
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 环形图绘制器
class DonutChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color primaryColor;

  DonutChartPainter({
    required this.data,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2 - 10;
    final innerRadius = outerRadius * 0.6;
    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = _getColorForIndex(i)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      path.close();

      canvas.drawPath(path, paint);
      startAngle += sweepAngle;
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      NothingTheme.nothingYellow,
      NothingTheme.successGreen,
      NothingTheme.infoBlue,
      NothingTheme.warningOrange,
      NothingTheme.nothingDarkGray,
      NothingTheme.nothingGray,
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}