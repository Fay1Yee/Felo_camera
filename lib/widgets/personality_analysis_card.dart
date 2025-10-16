import 'package:flutter/material.dart';
import '../models/pet_mbti_personality.dart';
import '../config/nothing_theme.dart';

class PersonalityAnalysisCard extends StatelessWidget {
  final PetMBTIType personalityType;
  final double confidence;
  final List<String> traits;

  const PersonalityAnalysisCard({
    super.key,
    required this.personalityType,
    required this.confidence,
    required this.traits,
  });

  @override
  Widget build(BuildContext context) {
    final personality = PetMBTIDatabase.getPersonalityByType(personalityType);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NothingTheme.brandPrimary.withValues(alpha: 0.1),
            NothingTheme.brandPrimary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NothingTheme.brandPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部信息
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NothingTheme.brandPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  personality?.code ?? personalityType.name,
                  style: TextStyle(
                    color: NothingTheme.textInverse,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  personality?.chineseName ?? personalityType.name,
                  style: TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 英文名称
          if (personality?.englishName != null)
            Text(
              personality!.englishName,
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // 核心特征
          if (personality?.coreCharacteristics != null) ...[
            Text(
              '核心特征',
              style: TextStyle(
                color: NothingTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              personality!.coreCharacteristics,
              style: TextStyle(
                color: NothingTheme.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 关键词标签
          if (personality?.keywords.isNotEmpty == true) ...[
            Text(
              '关键词',
              style: TextStyle(
                color: NothingTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: personality!.keywords.map((keyword) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NothingTheme.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: NothingTheme.brandPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  keyword,
                  style: TextStyle(
                    color: NothingTheme.brandPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // 置信度
          Row(
            children: [
              Icon(
                Icons.analytics,
                size: 16,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '分析置信度',
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getConfidenceColor(confidence),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 置信度进度条
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: NothingTheme.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor(confidence)),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            _getConfidenceDescription(confidence),
            style: TextStyle(
              color: NothingTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return NothingTheme.success;
    } else if (confidence >= 0.6) {
      return NothingTheme.warning;
    } else {
      return NothingTheme.error;
    }
  }

  String _getConfidenceDescription(double confidence) {
    if (confidence >= 0.8) {
      return '高置信度 - 分析结果非常可靠';
    } else if (confidence >= 0.6) {
      return '中等置信度 - 分析结果较为可靠';
    } else {
      return '低置信度 - 建议收集更多数据';
    }
  }
}