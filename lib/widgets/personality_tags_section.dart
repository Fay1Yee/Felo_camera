import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class PersonalityTagsSection extends StatelessWidget {
  final List<String> personalityTags;

  const PersonalityTagsSection({
    super.key,
    required this.personalityTags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性格特征',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: NothingTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: NothingTheme.gray200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: NothingTheme.gray900.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
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
                    '性格词云',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: NothingTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 性格标签云
              _buildPersonalityCloud(),
              
              const SizedBox(height: 16),
              
              Text(
                '基于日常行为分析生成的性格特征标签',
                style: TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityCloud() {
    if (personalityTags.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Text(
          '暂无性格标签',
          style: TextStyle(
            fontSize: 14,
            color: NothingTheme.textSecondary,
          ),
        ),
      );
    }

    return Container(
      height: 120,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: personalityTags.asMap().entries.map((entry) {
          final index = entry.key;
          final tag = entry.value;
          
          // 根据索引决定标签样式
          final isHighlight = index < 2; // 前两个标签高亮显示
          final fontSize = isHighlight ? 18.0 : 14.0;
          
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isHighlight ? 16 : 12,
              vertical: isHighlight ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: isHighlight 
                  ? NothingTheme.brandPrimary.withValues(alpha: 0.1)
                  : NothingTheme.gray100,
              borderRadius: BorderRadius.circular(20),
              border: isHighlight 
                  ? Border.all(
                      color: NothingTheme.brandPrimary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
                color: isHighlight 
                    ? NothingTheme.brandPrimary
                    : NothingTheme.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}