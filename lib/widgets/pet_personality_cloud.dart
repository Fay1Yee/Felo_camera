import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/nothing_theme.dart';

class PetPersonalityCloud extends StatefulWidget {
  final List<PersonalityTrait> traits;
  final VoidCallback? onTraitTap;

  const PetPersonalityCloud({
    super.key,
    required this.traits,
    this.onTraitTap,
  });

  @override
  State<PetPersonalityCloud> createState() => _PetPersonalityCloudState();
}

class _PetPersonalityCloudState extends State<PetPersonalityCloud>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NothingTheme.gray300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: NothingTheme.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '性格特征',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeLg,
                  fontWeight: NothingTheme.fontWeightSemiBold,
                  color: NothingTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'AI分析',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeSm,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 性格词云
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: _buildPersonalityCloud(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityCloud() {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: PersonalityCloudPainter(
          traits: widget.traits,
          animation: _fadeAnimation.value,
        ),
        child: Stack(
          children: widget.traits.asMap().entries.map((entry) {
            final index = entry.key;
            final trait = entry.value;
            return _buildTraitWidget(trait, index);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTraitWidget(PersonalityTrait trait, int index) {
    final positions = _calculatePositions();
    if (index >= positions.length) return const SizedBox();
    
    final position = positions[index];
    final fontSize = _getFontSize(trait.intensity);
    final color = _getTraitColor(trait.category);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: widget.onTraitTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300 + index * 100),
          curve: Curves.elasticOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              trait.name,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Offset> _calculatePositions() {
    // 使用螺旋算法分布词汇
    final positions = <Offset>[];
    final centerX = 150.0;
    final centerY = 100.0;
    
    for (int i = 0; i < widget.traits.length; i++) {
      final angle = i * 0.5;
      final radius = 20.0 + i * 15.0;
      final x = centerX + radius * math.cos(angle) - 30;
      final y = centerY + radius * math.sin(angle) - 15;
      positions.add(Offset(
        math.max(0, math.min(x, 250)),
        math.max(0, math.min(y, 170)),
      ));
    }
    
    return positions;
  }

  double _getFontSize(double intensity) {
    return 12.0 + (intensity * 8.0); // 12-20px range
  }

  Color _getTraitColor(TraitCategory category) {
    switch (category) {
      case TraitCategory.active:
        return const Color(0xFF4CAF50); // 绿色 - 活跃
      case TraitCategory.gentle:
        return const Color(0xFF2196F3); // 蓝色 - 温和
      case TraitCategory.smart:
        return const Color(0xFF9C27B0); // 紫色 - 聪明
      case TraitCategory.playful:
        return const Color(0xFFFF9800); // 橙色 - 顽皮
      case TraitCategory.loyal:
        return const Color(0xFFF44336); // 红色 - 忠诚
    }
  }
}

class PersonalityCloudPainter extends CustomPainter {
  final List<PersonalityTrait> traits;
  final double animation;

  PersonalityCloudPainter({
    required this.traits,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景渐变
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        NothingTheme.brandPrimary.withOpacity(0.05 * animation),
        Colors.transparent,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 数据模型
class PersonalityTrait {
  final String name;
  final double intensity; // 0.0 - 1.0
  final TraitCategory category;
  final String description;

  const PersonalityTrait({
    required this.name,
    required this.intensity,
    required this.category,
    required this.description,
  });

  // 预设性格特征
  static List<PersonalityTrait> getDefaultTraits() {
    return [
      PersonalityTrait(
        name: '活泼好动',
        intensity: 0.9,
        category: TraitCategory.active,
        description: '喜欢跑跳，精力充沛',
      ),
      PersonalityTrait(
        name: '温顺可爱',
        intensity: 0.8,
        category: TraitCategory.gentle,
        description: '性格温和，容易亲近',
      ),
      PersonalityTrait(
        name: '聪明机灵',
        intensity: 0.7,
        category: TraitCategory.smart,
        description: '学习能力强，反应敏捷',
      ),
      PersonalityTrait(
        name: '贪吃小鬼',
        intensity: 0.6,
        category: TraitCategory.playful,
        description: '对食物充满热情',
      ),
      PersonalityTrait(
        name: '忠诚护主',
        intensity: 0.8,
        category: TraitCategory.loyal,
        description: '对主人忠心耿耿',
      ),
      PersonalityTrait(
        name: '好奇宝宝',
        intensity: 0.5,
        category: TraitCategory.playful,
        description: '对新事物充满好奇',
      ),
      PersonalityTrait(
        name: '安静乖巧',
        intensity: 0.4,
        category: TraitCategory.gentle,
        description: '喜欢安静的环境',
      ),
    ];
  }
}

enum TraitCategory {
  active,   // 活跃
  gentle,   // 温和
  smart,    // 聪明
  playful,  // 顽皮
  loyal,    // 忠诚
}