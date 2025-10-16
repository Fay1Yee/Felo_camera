/// 行为与性格特征关联分析服务
/// 建立科学的行为-性格映射关系和分析模型

import 'dart:math';
import '../models/pet_mbti_personality.dart';
import '../models/behavior_hierarchy.dart';
import 'behavior_quantification_service.dart';

/// 行为-性格关联权重配置
class BehaviorPersonalityCorrelation {
  final String behaviorId;
  final PersonalityDimension dimension;
  final double weight; // 权重 (-1.0 到 1.0)
  final double confidence; // 关联置信度 (0.0 到 1.0)
  final String evidenceDescription; // 证据描述

  const BehaviorPersonalityCorrelation({
    required this.behaviorId,
    required this.dimension,
    required this.weight,
    required this.confidence,
    required this.evidenceDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'behaviorId': behaviorId,
      'dimension': dimension.name,
      'weight': weight,
      'confidence': confidence,
      'evidenceDescription': evidenceDescription,
    };
  }
}

/// 性格维度得分
class PersonalityDimensionScore {
  final PersonalityDimension dimension;
  final double score; // -1.0 到 1.0，负值表示倾向于第一个极端，正值表示倾向于第二个极端
  final double confidence; // 置信度
  final List<String> supportingBehaviors; // 支持证据行为
  final Map<String, double> behaviorContributions; // 各行为的贡献度

  const PersonalityDimensionScore({
    required this.dimension,
    required this.score,
    required this.confidence,
    required this.supportingBehaviors,
    required this.behaviorContributions,
  });

  /// 获取维度倾向描述
  String get tendencyDescription {
    final absScore = score.abs();
    final intensity = absScore >= 0.7 ? '强烈' : absScore >= 0.4 ? '中等' : '轻微';
    
    switch (dimension) {
      case PersonalityDimension.energyOrientation:
        return score > 0 ? '$intensity外向' : '$intensity内向';
      case PersonalityDimension.informationProcessing:
        return score > 0 ? '$intensity直觉型' : '$intensity感知型';
      case PersonalityDimension.decisionMaking:
        return score > 0 ? '$intensity情感型' : '$intensity思考型';
      case PersonalityDimension.lifestylePreference:
        return score > 0 ? '$intensity感知型' : '$intensity判断型';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'dimension': dimension.name,
      'score': score,
      'confidence': confidence,
      'tendencyDescription': tendencyDescription,
      'supportingBehaviors': supportingBehaviors,
      'behaviorContributions': behaviorContributions,
    };
  }
}

/// 性格分析结果
class PersonalityCorrelationResult {
  final Map<PersonalityDimension, PersonalityDimensionScore> dimensionScores;
  final PetMBTIType predictedType;
  final double overallConfidence;
  final List<String> keyBehaviorPatterns; // 关键行为模式
  final Map<String, double> typeConfidences; // 各类型的置信度
  final String analysisReport; // 分析报告

  const PersonalityCorrelationResult({
    required this.dimensionScores,
    required this.predictedType,
    required this.overallConfidence,
    required this.keyBehaviorPatterns,
    required this.typeConfidences,
    required this.analysisReport,
  });

  Map<String, dynamic> toJson() {
    return {
      'dimensionScores': dimensionScores.map((k, v) => MapEntry(k.name, v.toJson())),
      'predictedType': predictedType.name,
      'overallConfidence': overallConfidence,
      'keyBehaviorPatterns': keyBehaviorPatterns,
      'typeConfidences': typeConfidences,
      'analysisReport': analysisReport,
    };
  }
}

/// 行为-性格关联分析服务
class BehaviorPersonalityCorrelationService {
  static BehaviorPersonalityCorrelationService? _instance;
  static BehaviorPersonalityCorrelationService get instance {
    return _instance ??= BehaviorPersonalityCorrelationService._();
  }

  BehaviorPersonalityCorrelationService._() {
    _initializeCorrelations();
  }

  final Map<String, List<BehaviorPersonalityCorrelation>> _correlations = {};
  final PetMBTIDatabase _mbtiDatabase = PetMBTIDatabase();

  /// 初始化行为-性格关联配置
  void _initializeCorrelations() {
    // 社交行为关联
    _addCorrelation('social_friendly', PersonalityDimension.energyOrientation, 0.8, 0.9,
        '友好互动行为强烈表明外向性格特征');
    _addCorrelation('social_friendly', PersonalityDimension.decisionMaking, 0.6, 0.8,
        '友好行为体现情感导向的决策方式');
    
    _addCorrelation('social_aggressive', PersonalityDimension.energyOrientation, 0.4, 0.7,
        '攻击性行为可能表明外向但缺乏社交技巧');
    _addCorrelation('social_aggressive', PersonalityDimension.decisionMaking, -0.7, 0.8,
        '攻击性行为表明理性思考优于情感考虑');
    
    _addCorrelation('social_avoidance', PersonalityDimension.energyOrientation, -0.9, 0.9,
        '回避行为强烈表明内向性格特征');
    _addCorrelation('social_avoidance', PersonalityDimension.decisionMaking, 0.3, 0.6,
        '回避可能源于对他人情感的敏感');

    // 身体行为关联
    _addCorrelation('physical_locomotion', PersonalityDimension.energyOrientation, 0.6, 0.7,
        '活跃的移动行为表明外向和活力');
    _addCorrelation('physical_locomotion', PersonalityDimension.lifestylePreference, 0.5, 0.6,
        '自由移动体现灵活和适应性');
    
    _addCorrelation('physical_posture', PersonalityDimension.lifestylePreference, -0.4, 0.6,
        '稳定姿态表明结构化和规律性偏好');
    
    _addCorrelation('physical_manipulation', PersonalityDimension.informationProcessing, -0.7, 0.8,
        '操作行为表明对具体事物的关注');
    _addCorrelation('physical_manipulation', PersonalityDimension.decisionMaking, -0.5, 0.7,
        '操作行为体现逻辑和实用性思考');

    // 情感行为关联
    _addCorrelation('emotional_positive', PersonalityDimension.energyOrientation, 0.7, 0.8,
        '积极情感表达表明外向和社交倾向');
    _addCorrelation('emotional_positive', PersonalityDimension.decisionMaking, 0.8, 0.9,
        '积极情感表明情感导向的处理方式');
    
    _addCorrelation('emotional_negative', PersonalityDimension.energyOrientation, -0.6, 0.7,
        '消极情感可能表明内向和敏感');
    _addCorrelation('emotional_negative', PersonalityDimension.decisionMaking, 0.7, 0.8,
        '情感表达表明感情优于逻辑');
    
    _addCorrelation('emotional_neutral', PersonalityDimension.decisionMaking, -0.6, 0.7,
        '情感中性表明理性和控制');
    _addCorrelation('emotional_neutral', PersonalityDimension.lifestylePreference, -0.5, 0.6,
        '稳定情感状态表明结构化倾向');

    // 认知行为关联
    _addCorrelation('cognitive_exploration', PersonalityDimension.informationProcessing, 0.8, 0.9,
        '探索行为强烈表明直觉和可能性导向');
    _addCorrelation('cognitive_exploration', PersonalityDimension.lifestylePreference, 0.7, 0.8,
        '探索体现开放性和灵活性');
    _addCorrelation('cognitive_exploration', PersonalityDimension.energyOrientation, 0.5, 0.7,
        '主动探索表明外向倾向');
    
    _addCorrelation('cognitive_learning', PersonalityDimension.informationProcessing, 0.6, 0.8,
        '学习行为表明对新概念的开放');
    _addCorrelation('cognitive_learning', PersonalityDimension.lifestylePreference, -0.4, 0.6,
        '结构化学习表明计划性');
    
    _addCorrelation('cognitive_problem_solving', PersonalityDimension.decisionMaking, -0.8, 0.9,
        '问题解决强烈表明逻辑思考能力');
    _addCorrelation('cognitive_problem_solving', PersonalityDimension.informationProcessing, 0.5, 0.7,
        '创新解决方案表明直觉思维');

    // 维护行为关联
    _addCorrelation('maintenance_feeding', PersonalityDimension.informationProcessing, -0.6, 0.7,
        '规律进食表明对具体需求的关注');
    _addCorrelation('maintenance_feeding', PersonalityDimension.lifestylePreference, -0.5, 0.6,
        '有序进食表明结构化倾向');
    
    _addCorrelation('maintenance_grooming', PersonalityDimension.lifestylePreference, -0.7, 0.8,
        '规律梳理表明秩序和计划性');
    _addCorrelation('maintenance_grooming', PersonalityDimension.informationProcessing, -0.5, 0.7,
        '细致梳理表明对细节的关注');
    
    _addCorrelation('maintenance_resting', PersonalityDimension.energyOrientation, -0.4, 0.6,
        '充足休息可能表明内向和恢复需求');
    _addCorrelation('maintenance_resting', PersonalityDimension.lifestylePreference, -0.3, 0.5,
        '规律休息表明结构化生活方式');
  }

  /// 添加行为-性格关联
  void _addCorrelation(String behaviorId, PersonalityDimension dimension, 
                      double weight, double confidence, String evidence) {
    final correlation = BehaviorPersonalityCorrelation(
      behaviorId: behaviorId,
      dimension: dimension,
      weight: weight,
      confidence: confidence,
      evidenceDescription: evidence,
    );
    
    _correlations[behaviorId] = (_correlations[behaviorId] ?? [])..add(correlation);
  }

  /// 分析行为数据并推断性格特征
  Future<PersonalityCorrelationResult> analyzePersonalityFromBehaviors(
    List<BehaviorAssessmentResult> behaviorAssessments,
  ) async {
    // 1. 计算各维度得分
    final dimensionScores = await _calculateDimensionScores(behaviorAssessments);
    
    // 2. 确定MBTI类型
    final predictedType = _determineMBTIType(dimensionScores);
    
    // 3. 计算整体置信度
    final overallConfidence = _calculateOverallConfidence(dimensionScores);
    
    // 4. 提取关键行为模式
    final keyBehaviorPatterns = _extractKeyBehaviorPatterns(behaviorAssessments, dimensionScores);
    
    // 5. 计算各类型置信度
    final typeConfidences = _calculateTypeConfidences(dimensionScores);
    
    // 6. 生成分析报告
    final analysisReport = _generateAnalysisReport(
      dimensionScores, predictedType, behaviorAssessments, overallConfidence);
    
    return PersonalityCorrelationResult(
      dimensionScores: dimensionScores,
      predictedType: predictedType,
      overallConfidence: overallConfidence,
      keyBehaviorPatterns: keyBehaviorPatterns,
      typeConfidences: typeConfidences,
      analysisReport: analysisReport,
    );
  }

  /// 计算各维度得分
  Future<Map<PersonalityDimension, PersonalityDimensionScore>> _calculateDimensionScores(
    List<BehaviorAssessmentResult> behaviorAssessments,
  ) async {
    final dimensionScores = <PersonalityDimension, PersonalityDimensionScore>{};
    
    for (final dimension in PersonalityDimension.values) {
      double totalScore = 0.0;
      double totalWeight = 0.0;
      final supportingBehaviors = <String>[];
      final behaviorContributions = <String, double>{};
      
      for (final assessment in behaviorAssessments) {
        final correlations = _correlations[assessment.behaviorId] ?? [];
        
        for (final correlation in correlations) {
          if (correlation.dimension == dimension) {
            final contribution = correlation.weight * 
                               assessment.confidence * 
                               correlation.confidence *
                               assessment.quantification.overallScore;
            
            totalScore += contribution;
            totalWeight += correlation.confidence * assessment.confidence;
            
            if (contribution.abs() > 0.1) {
              supportingBehaviors.add(assessment.behaviorName);
              behaviorContributions[assessment.behaviorName] = contribution;
            }
          }
        }
      }
      
      final normalizedScore = totalWeight > 0 ? totalScore / totalWeight : 0.0;
      final confidence = min(1.0, totalWeight / behaviorAssessments.length);
      
      dimensionScores[dimension] = PersonalityDimensionScore(
        dimension: dimension,
        score: max(-1.0, min(1.0, normalizedScore)),
        confidence: confidence,
        supportingBehaviors: supportingBehaviors.toSet().toList(),
        behaviorContributions: behaviorContributions,
      );
    }
    
    return dimensionScores;
  }

  /// 确定MBTI类型
  PetMBTIType _determineMBTIType(Map<PersonalityDimension, PersonalityDimensionScore> dimensionScores) {
    final ei = dimensionScores[PersonalityDimension.energyOrientation]?.score ?? 0.0;
    final sn = dimensionScores[PersonalityDimension.informationProcessing]?.score ?? 0.0;
    final tf = dimensionScores[PersonalityDimension.decisionMaking]?.score ?? 0.0;
    final jp = dimensionScores[PersonalityDimension.lifestylePreference]?.score ?? 0.0;
    
    // 根据得分确定各维度倾向
    final e = ei > 0;  // 外向
    final n = sn > 0;  // 直觉
    final f = tf > 0;  // 情感
    final p = jp > 0;  // 感知
    
    // 映射到宠物MBTI类型
    if (e && n && f && p) return PetMBTIType.EACN; // 社交好奇型
    if (e && n && f && !p) return PetMBTIType.EAWC; // 热情体贴型
    if (e && n && !f && p) return PetMBTIType.EANC; // 自由冒险型
    if (e && n && !f && !p) return PetMBTIType.EENC; // 探索主导型
    if (e && !n && f && p) return PetMBTIType.EAWC_SUNNY; // 阳光伙伴型
    if (e && !n && f && !p) return PetMBTIType.EAWN; // 温柔依赖型
    if (e && !n && !f && p) return PetMBTIType.ESCN_BALANCED; // 平衡型
    if (e && !n && !f && !p) return PetMBTIType.ESCN; // 温顺观察型
    if (!e && n && f && p) return PetMBTIType.SAWN; // 敏感依恋型
    if (!e && n && f && !p) return PetMBTIType.SACN; // 内敛温顺型
    if (!e && n && !f && p) return PetMBTIType.SANC; // 独立冷静型
    if (!e && n && !f && !p) return PetMBTIType.SANC_RATIONAL; // 理智猎手型
    if (!e && !n && f && p) return PetMBTIType.SACW; // 宅家温柔型
    if (!e && !n && f && !p) return PetMBTIType.SSWN; // 谨慎守护型
    if (!e && !n && !f && p) return PetMBTIType.ESWN; // 警觉守望型
    return PetMBTIType.EAWN_FRIENDLY; // 友好观察型
  }

  /// 计算整体置信度
  double _calculateOverallConfidence(Map<PersonalityDimension, PersonalityDimensionScore> dimensionScores) {
    final confidences = dimensionScores.values.map((score) => score.confidence).toList();
    if (confidences.isEmpty) return 0.0;
    
    return confidences.reduce((a, b) => a + b) / confidences.length;
  }

  /// 提取关键行为模式
  List<String> _extractKeyBehaviorPatterns(
    List<BehaviorAssessmentResult> behaviorAssessments,
    Map<PersonalityDimension, PersonalityDimensionScore> dimensionScores,
  ) {
    final patterns = <String>[];
    
    // 基于高置信度行为
    final highConfidenceBehaviors = behaviorAssessments
        .where((a) => a.confidence >= 0.8)
        .map((a) => a.behaviorName)
        .toSet()
        .toList();
    
    if (highConfidenceBehaviors.isNotEmpty) {
      patterns.add('高置信度行为: ${highConfidenceBehaviors.join('、')}');
    }
    
    // 基于维度得分
    for (final entry in dimensionScores.entries) {
      if (entry.value.confidence >= 0.7 && entry.value.score.abs() >= 0.5) {
        patterns.add('${entry.key.displayName}: ${entry.value.tendencyDescription}');
      }
    }
    
    // 基于行为频率
    final behaviorCounts = <String, int>{};
    for (final assessment in behaviorAssessments) {
      behaviorCounts[assessment.behaviorName] = 
          (behaviorCounts[assessment.behaviorName] ?? 0) + 1;
    }
    
    final frequentBehaviors = behaviorCounts.entries
        .where((e) => e.value >= 3)
        .map((e) => e.key)
        .toList();
    
    if (frequentBehaviors.isNotEmpty) {
      patterns.add('频繁行为: ${frequentBehaviors.join('、')}');
    }
    
    return patterns;
  }

  /// 计算各类型置信度
  Map<String, double> _calculateTypeConfidences(
    Map<PersonalityDimension, PersonalityDimensionScore> dimensionScores,
  ) {
    final typeConfidences = <String, double>{};
    
    for (final type in PetMBTIType.values) {
      double confidence = 1.0;
      
      // 根据各维度得分计算类型匹配度
      final typeProfile = PetMBTIDatabase.getPersonality(type);
      
      for (final dimension in PersonalityDimension.values) {
        final score = dimensionScores[dimension];
        if (score != null) {
          // 计算维度匹配度
          final expectedDirection = _getExpectedDirection(type, dimension);
          final actualDirection = score.score > 0 ? 1 : -1;
          final match = expectedDirection == actualDirection ? 1.0 : 0.0;
          
          confidence *= (match * score.confidence + (1 - score.confidence) * 0.5);
        }
      }
      
      typeConfidences[type.name] = confidence;
    }
    
    return typeConfidences;
  }

  /// 获取类型在特定维度的期望方向
  int _getExpectedDirection(PetMBTIType type, PersonalityDimension dimension) {
    final typeName = type.name;
    
    switch (dimension) {
      case PersonalityDimension.energyOrientation:
        return typeName.startsWith('E') ? 1 : -1;
      case PersonalityDimension.informationProcessing:
        return typeName.contains('N') ? 1 : -1;
      case PersonalityDimension.decisionMaking:
        return typeName.contains('F') ? 1 : -1;
      case PersonalityDimension.lifestylePreference:
        return typeName.endsWith('P') ? 1 : -1;
    }
  }

  /// 生成分析报告
  String _generateAnalysisReport(
    Map<PersonalityDimension, PersonalityDimensionScore> dimensionScores,
    PetMBTIType predictedType,
    List<BehaviorAssessmentResult> behaviorAssessments,
    double overallConfidence,
  ) {
    final report = StringBuffer();
    
    report.writeln('## 宠物性格分析报告');
    report.writeln();
    
    // 基本信息
    report.writeln('**预测性格类型**: ${predictedType.name}');
    report.writeln('**整体置信度**: ${(overallConfidence * 100).toStringAsFixed(1)}%');
    report.writeln('**分析样本**: ${behaviorAssessments.length}个行为实例');
    report.writeln();
    
    // 维度分析
    report.writeln('### 性格维度分析');
    for (final entry in dimensionScores.entries) {
      final dimension = entry.key;
      final score = entry.value;
      
      report.writeln('**${dimension.displayName}**');
      report.writeln('- 倾向: ${score.tendencyDescription}');
      report.writeln('- 置信度: ${(score.confidence * 100).toStringAsFixed(1)}%');
      if (score.supportingBehaviors.isNotEmpty) {
        report.writeln('- 支持行为: ${score.supportingBehaviors.join('、')}');
      }
      report.writeln();
    }
    
    // 行为特征总结
    report.writeln('### 行为特征总结');
    final behaviorCategories = <String, List<String>>{};
    for (final assessment in behaviorAssessments) {
      final category = assessment.behaviorId.split('_')[0];
      behaviorCategories[category] = (behaviorCategories[category] ?? [])
          ..add(assessment.behaviorName);
    }
    
    for (final entry in behaviorCategories.entries) {
      final categoryName = _getCategoryDisplayName(entry.key);
      report.writeln('- **$categoryName**: ${entry.value.toSet().join('、')}');
    }
    
    report.writeln();
    report.writeln('### 性格特征描述');
    final personality = PetMBTIDatabase.getPersonality(predictedType);
    if (personality != null) {
      report.writeln(personality.detailedDescription);
    }
    
    return report.toString();
  }

  /// 获取类别显示名称
  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'social': return '社交行为';
      case 'physical': return '身体行为';
      case 'emotional': return '情感行为';
      case 'cognitive': return '认知行为';
      case 'maintenance': return '维护行为';
      default: return category;
    }
  }

  /// 获取行为的性格关联
  List<BehaviorPersonalityCorrelation> getBehaviorCorrelations(String behaviorId) {
    return _correlations[behaviorId] ?? [];
  }

  /// 获取所有关联配置
  Map<String, List<BehaviorPersonalityCorrelation>> getAllCorrelations() {
    return Map.unmodifiable(_correlations);
  }
}