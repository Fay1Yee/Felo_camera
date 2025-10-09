import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/ai_result.dart';
import '../../utils/pet_conversation_helper.dart';

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
    final petResult = PetConversationHelper.convertToPetTone(widget.result);
    
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
                  petResult.title, // 使用转换后的宠物语气标题
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
                      PetConversationHelper.getRandomPetEmoji(),
                      style: TextStyle(fontSize: smallFontSize),
                    ),
                    const SizedBox(width: NothingTheme.spacingSmall),
                    Text(
                      PetConversationHelper.getConfidenceExpression(petResult.confidence),
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
                    petResult.subInfo!, // 使用转换后的宠物语气子信息
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