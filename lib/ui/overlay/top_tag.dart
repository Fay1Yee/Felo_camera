import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/ai_result.dart';
// 已移除宠物语气助手导入，TopTag 直接展示原始分析结果，风格简洁专业

class TopTag extends StatefulWidget {
  final AIResult result;
  final double? fontSize;

  const TopTag({
    super.key, 
    required this.result,
    this.fontSize,
  });

  @override
  State<TopTag> createState() => _TopTagState();
}

class _TopTagState extends State<TopTag> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 转换为宠物对话语气
    final petResult = widget.result; // 使用专业、亲和且自然的原始风格，不再进行“宠物对主人”式转换
    
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = widget.fontSize ?? (screenWidth < 400 ? 14.0 : 16.0);
    final smallFontSize = fontSize - 2;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: screenWidth < 400 ? NothingTheme.spacingSmall : NothingTheme.spacingMedium,
              vertical: NothingTheme.spacingSmall,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 400 ? 10 : NothingTheme.spacingMedium,
              vertical: screenWidth < 400 ? 6 : NothingTheme.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: NothingTheme.nothingBlack.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              border: Border.all(
                color: NothingTheme.nothingYellow.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: NothingTheme.nothingBlack.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 主标题
                Text(
                  petResult.title,
                  style: TextStyle(
                    color: NothingTheme.nothingYellow,
                    fontSize: fontSize,
                    fontWeight: NothingTheme.fontWeightBold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // 置信度
                const SizedBox(height: NothingTheme.spacingSmall),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '', // 移除过度拟人化的宠物表情符号
                      style: TextStyle(fontSize: smallFontSize),
                    ),
                    const SizedBox(width: NothingTheme.spacingSmall),
                    Text(
                      '置信度：${petResult.confidence}%', // 改为清晰专业表达
                      style: TextStyle(
                        color: NothingTheme.nothingWhite,
                        fontSize: smallFontSize,
                        fontWeight: NothingTheme.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
                
                // 子信息
                if (petResult.subInfo != null && petResult.subInfo!.isNotEmpty) ...[
                  const SizedBox(height: NothingTheme.spacingSmall),
                  Text(
                    petResult.subInfo ?? '',
                    style: TextStyle(
                      color: NothingTheme.nothingWhite.withValues(alpha: 0.8),
                      fontSize: smallFontSize,
                    ),
                    maxLines: screenWidth < 400 ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}