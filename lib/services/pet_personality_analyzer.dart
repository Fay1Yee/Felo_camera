/// 宠物性格分析服务
/// 基于行为数据分析宠物的MBTI性格类型

import 'dart:math';
import '../models/pet_mbti_personality.dart';
import '../models/behavior_analytics.dart';
import '../models/analysis_history.dart';
import '../models/ai_result.dart';
import 'behavior_analyzer.dart';

/// 行为-性格关联权重配置
class BehaviorPersonalityWeights {
  // 外向性 (E vs I) 权重
  static const Map<String, double> extroversionWeights = {
    '社交': 0.8,
    '玩耍': 0.7,
    '探索': 0.6,
    '发声': 0.5,
    '运动': 0.4,
    '休息': -0.6,
    '睡觉': -0.7,
    '静止': -0.5,
    '梳理': -0.3,
  };

  // 直觉性 (N vs S) 权重
  static const Map<String, double> intuitionWeights = {
    '探索': 0.8,
    '好奇': 0.7,
    '新环境': 0.6,
    '变化': 0.5,
    '进食': -0.4,
    '休息': -0.5,
    '规律': -0.6,
  };

  // 情感性 (F vs T) 权重
  static const Map<String, double> feelingWeights = {
    '亲人': 0.8,
    '社交': 0.7,
    '依恋': 0.6,
    '温柔': 0.5,
    '攻击': -0.7,
    '独立': -0.5,
    '冷漠': -0.6,
  };

  // 感知性 (P vs J) 权重
  static const Map<String, double> perceivingWeights = {
    '随机': 0.7,
    '灵活': 0.6,
    '变化': 0.5,
    '规律': -0.8,
    '固定': -0.6,
    '计划': -0.5,
  };
}

/// 性格分析结果
class PersonalityAnalysisResult {
  final PetMBTIPersonality personality;
  final Map<PersonalityDimension, double> dimensionScores;
  final double overallConfidence;
  final List<String> evidenceBehaviors;
  final Map<String, double> behaviorInfluence;
  final DateTime analysisDate;
  final int totalBehaviorRecords;

  const PersonalityAnalysisResult({
    required this.personality,
    required this.dimensionScores,
    required this.overallConfidence,
    required this.evidenceBehaviors,
    required this.behaviorInfluence,
    required this.analysisDate,
    required this.totalBehaviorRecords,
  });

  Map<String, dynamic> toJson() {
    return {
      'personality': personality.toJson(),
      'dimensionScores': dimensionScores.map((k, v) => MapEntry(k.name, v)),
      'overallConfidence': overallConfidence,
      'evidenceBehaviors': evidenceBehaviors,
      'behaviorInfluence': behaviorInfluence,
      'analysisDate': analysisDate.toIso8601String(),
      'totalBehaviorRecords': totalBehaviorRecords,
    };
  }
}

/// 宠物性格分析器
class PetPersonalityAnalyzer {
  static PetPersonalityAnalyzer? _instance;
  static PetPersonalityAnalyzer get instance {
    return _instance ??= PetPersonalityAnalyzer._();
  }

  PetPersonalityAnalyzer._();

  /// 基于行为历史分析宠物性格
  PersonalityAnalysisResult analyzePersonality(List<AnalysisHistory> histories) {
    if (histories.isEmpty) {
      throw ArgumentError('行为历史数据不能为空');
    }

    // 1. 提取行为特征
    final behaviorFeatures = _extractBehaviorFeatures(histories);
    
    // 2. 计算MBTI维度得分
    final dimensionScores = _calculateDimensionScores(behaviorFeatures);
    
    // 3. 确定最匹配的性格类型
    final personality = _determinePersonalityType(dimensionScores);
    
    // 4. 计算置信度
    final confidence = _calculateConfidence(dimensionScores, behaviorFeatures);
    
    // 5. 提取证据行为
    final evidenceBehaviors = _extractEvidenceBehaviors(histories, personality);
    
    // 6. 计算行为影响权重
    final behaviorInfluence = _calculateBehaviorInfluence(behaviorFeatures);

    return PersonalityAnalysisResult(
      personality: personality,
      dimensionScores: dimensionScores,
      overallConfidence: confidence,
      evidenceBehaviors: evidenceBehaviors,
      behaviorInfluence: behaviorInfluence,
      analysisDate: DateTime.now(),
      totalBehaviorRecords: histories.length,
    );
  }

  /// 提取行为特征
  Map<String, double> _extractBehaviorFeatures(List<AnalysisHistory> histories) {
    final features = <String, double>{};
    final behaviorCounts = <String, int>{};
    final totalRecords = histories.length;

    // 统计行为频率
    for (final history in histories) {
      final analyzer = BehaviorAnalyzer.instance;
      final tags = analyzer.inferBehaviorTags(history.result, 'pet');
      
      for (final tag in tags) {
        behaviorCounts[tag] = (behaviorCounts[tag] ?? 0) + 1;
      }
    }

    // 计算行为特征权重（频率 + 时间权重）
    for (final entry in behaviorCounts.entries) {
      final behavior = entry.key;
      final count = entry.value;
      final frequency = count / totalRecords;
      
      // 添加时间衰减权重（最近的行为权重更高）
      final timeWeight = _calculateTimeWeight(histories, behavior);
      
      features[behavior] = frequency * 0.7 + timeWeight * 0.3;
    }

    return features;
  }

  /// 计算时间权重
  double _calculateTimeWeight(List<AnalysisHistory> histories, String behavior) {
    final now = DateTime.now();
    double totalWeight = 0.0;
    int matchCount = 0;

    for (final history in histories) {
      final analyzer = BehaviorAnalyzer.instance;
      final tags = analyzer.inferBehaviorTags(history.result, 'pet');
      
      if (tags.contains(behavior)) {
        final daysDiff = now.difference(history.timestamp).inDays;
        final weight = exp(-daysDiff / 30.0); // 30天衰减
        totalWeight += weight;
        matchCount++;
      }
    }

    return matchCount > 0 ? totalWeight / matchCount : 0.0;
  }

  /// 计算MBTI维度得分
  Map<PersonalityDimension, double> _calculateDimensionScores(
    Map<String, double> behaviorFeatures,
  ) {
    final scores = <PersonalityDimension, double>{};

    // 计算外向性得分 (E vs I)
    double extroversionScore = 0.5; // 基准值
    for (final entry in behaviorFeatures.entries) {
      final behavior = entry.key;
      final weight = entry.value;
      final influence = BehaviorPersonalityWeights.extroversionWeights[behavior] ?? 0.0;
      extroversionScore += influence * weight * 0.1;
    }
    scores[PersonalityDimension.energyOrientation] = extroversionScore.clamp(0.0, 1.0);

    // 计算直觉性得分 (N vs S)
    double intuitionScore = 0.5;
    for (final entry in behaviorFeatures.entries) {
      final behavior = entry.key;
      final weight = entry.value;
      final influence = BehaviorPersonalityWeights.intuitionWeights[behavior] ?? 0.0;
      intuitionScore += influence * weight * 0.1;
    }
    scores[PersonalityDimension.informationProcessing] = intuitionScore.clamp(0.0, 1.0);

    // 计算情感性得分 (F vs T)
    double feelingScore = 0.5;
    for (final entry in behaviorFeatures.entries) {
      final behavior = entry.key;
      final weight = entry.value;
      final influence = BehaviorPersonalityWeights.feelingWeights[behavior] ?? 0.0;
      feelingScore += influence * weight * 0.1;
    }
    scores[PersonalityDimension.decisionMaking] = feelingScore.clamp(0.0, 1.0);

    // 计算感知性得分 (P vs J)
    double perceivingScore = 0.5;
    for (final entry in behaviorFeatures.entries) {
      final behavior = entry.key;
      final weight = entry.value;
      final influence = BehaviorPersonalityWeights.perceivingWeights[behavior] ?? 0.0;
      perceivingScore += influence * weight * 0.1;
    }
    scores[PersonalityDimension.lifestylePreference] = perceivingScore.clamp(0.0, 1.0);

    return scores;
  }

  /// 确定最匹配的性格类型
  PetMBTIPersonality _determinePersonalityType(
    Map<PersonalityDimension, double> dimensionScores,
  ) {
    final personalities = PetMBTIDatabase.getAllPersonalities();
    double bestMatch = 0.0;
    PetMBTIPersonality? bestPersonality;

    for (final personality in personalities) {
      double similarity = 0.0;
      
      for (final dimension in PersonalityDimension.values) {
        final actualScore = dimensionScores[dimension] ?? 0.5;
        final expectedScore = personality.dimensionScores[dimension] ?? 0.5;
        
        // 计算相似度（使用余弦相似度的简化版本）
        final diff = (actualScore - expectedScore).abs();
        similarity += (1.0 - diff);
      }
      
      similarity /= PersonalityDimension.values.length;
      
      if (similarity > bestMatch) {
        bestMatch = similarity;
        bestPersonality = personality;
      }
    }

    return bestPersonality ?? PetMBTIDatabase.getPersonalityByType(PetMBTIType.ESCN)!;
  }

  /// 计算分析置信度
  double _calculateConfidence(
    Map<PersonalityDimension, double> dimensionScores,
    Map<String, double> behaviorFeatures,
  ) {
    // 基于维度得分的确定性
    double dimensionConfidence = 0.0;
    for (final score in dimensionScores.values) {
      // 越接近0.5置信度越低，越接近0或1置信度越高
      final certainty = (score - 0.5).abs() * 2;
      dimensionConfidence += certainty;
    }
    dimensionConfidence /= dimensionScores.length;

    // 基于行为数据的丰富度
    final behaviorCount = behaviorFeatures.length;
    final dataRichness = (behaviorCount / 10.0).clamp(0.0, 1.0); // 假设10种行为为满分

    // 基于行为权重的一致性
    final totalWeight = behaviorFeatures.values.fold(0.0, (sum, weight) => sum + weight);
    final consistency = totalWeight > 0 ? (totalWeight / behaviorFeatures.length).clamp(0.0, 1.0) : 0.0;

    // 综合置信度
    return (dimensionConfidence * 0.5 + dataRichness * 0.3 + consistency * 0.2).clamp(0.0, 1.0);
  }

  /// 提取证据行为
  List<String> _extractEvidenceBehaviors(
    List<AnalysisHistory> histories,
    PetMBTIPersonality personality,
  ) {
    final evidenceBehaviors = <String>[];
    final behaviorCounts = <String, int>{};

    for (final history in histories) {
      final analyzer = BehaviorAnalyzer.instance;
      final tags = analyzer.inferBehaviorTags(history.result, 'pet');
      
      for (final tag in tags) {
        if (personality.behaviorPatterns.any((pattern) => pattern.contains(tag)) ||
            personality.keywords.contains(tag)) {
          behaviorCounts[tag] = (behaviorCounts[tag] ?? 0) + 1;
        }
      }
    }

    // 按频率排序，取前5个作为主要证据
    final sortedBehaviors = behaviorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    evidenceBehaviors.addAll(
      sortedBehaviors.take(5).map((entry) => entry.key),
    );

    return evidenceBehaviors;
  }

  /// 计算行为影响权重
  Map<String, double> _calculateBehaviorInfluence(Map<String, double> behaviorFeatures) {
    final totalWeight = behaviorFeatures.values.fold(0.0, (sum, weight) => sum + weight);
    
    if (totalWeight == 0) return {};

    return behaviorFeatures.map((behavior, weight) => 
      MapEntry(behavior, weight / totalWeight));
  }

  /// 生成性格分析报告
  String generatePersonalityReport(PersonalityAnalysisResult result) {
    final personality = result.personality;
    final confidence = (result.overallConfidence * 100).round();
    
    final report = StringBuffer();
    
    report.writeln('=== 宠物性格分析报告 ===');
    report.writeln('');
    report.writeln('性格类型: ${personality.chineseName} (${personality.code})');
    report.writeln('英文名称: ${personality.englishName}');
    report.writeln('分析置信度: $confidence%');
    report.writeln('');
    report.writeln('核心特征: ${personality.coreCharacteristics}');
    report.writeln('');
    report.writeln('关键词标签: ${personality.keywords.join('、')}');
    report.writeln('');
    report.writeln('=== 维度分析 ===');
    
    for (final entry in result.dimensionScores.entries) {
      final dimension = entry.key;
      final score = entry.value;
      final percentage = (score * 100).round();
      
      String dimensionName;
      String interpretation;
      
      switch (dimension) {
        case PersonalityDimension.energyOrientation:
          dimensionName = '能量导向';
          interpretation = score > 0.5 ? '外向型 ($percentage%)' : '内向型 (${100-percentage}%)';
          break;
        case PersonalityDimension.informationProcessing:
          dimensionName = '信息处理';
          interpretation = score > 0.5 ? '直觉型 ($percentage%)' : '感觉型 (${100-percentage}%)';
          break;
        case PersonalityDimension.decisionMaking:
          dimensionName = '决策方式';
          interpretation = score > 0.5 ? '情感型 ($percentage%)' : '思考型 (${100-percentage}%)';
          break;
        case PersonalityDimension.lifestylePreference:
          dimensionName = '生活方式';
          interpretation = score > 0.5 ? '感知型 ($percentage%)' : '判断型 (${100-percentage}%)';
          break;
      }
      
      report.writeln('$dimensionName: $interpretation');
    }
    
    report.writeln('');
    report.writeln('=== 行为证据 ===');
    report.writeln('主要行为表现: ${result.evidenceBehaviors.join('、')}');
    
    report.writeln('');
    report.writeln('=== 典型行为模式 ===');
    for (final pattern in personality.behaviorPatterns) {
      report.writeln('• $pattern');
    }
    
    report.writeln('');
    report.writeln('=== 社交特征 ===');
    for (final trait in personality.socialTraits) {
      report.writeln('• $trait');
    }
    
    report.writeln('');
    report.writeln('=== 活动偏好 ===');
    for (final preference in personality.activityPreferences) {
      report.writeln('• $preference');
    }
    
    report.writeln('');
    report.writeln('分析时间: ${result.analysisDate.toString().substring(0, 19)}');
    report.writeln('数据样本: ${result.totalBehaviorRecords} 条行为记录');
    
    return report.toString();
  }

  /// 获取性格改善建议
  List<String> getPersonalityRecommendations(PersonalityAnalysisResult result) {
    final personality = result.personality;
    final recommendations = <String>[];

    // 基于性格类型提供建议
    switch (personality.type) {
      case PetMBTIType.EACN:
        recommendations.addAll([
          '提供丰富的探索环境和新玩具',
          '增加社交互动时间',
          '定期更换活动场所',
        ]);
        break;
      case PetMBTIType.EAWN:
        recommendations.addAll([
          '给予充分的关爱和陪伴',
          '建立稳定的日常互动',
          '提供安全舒适的环境',
        ]);
        break;
      case PetMBTIType.SACN:
        recommendations.addAll([
          '创造安静舒适的居家环境',
          '避免过度刺激',
          '提供温和的互动方式',
        ]);
        break;
      default:
        recommendations.addAll([
          '根据宠物的个性特点调整互动方式',
          '保持规律的作息和活动',
          '观察并满足其特定需求',
        ]);
    }

    // 基于维度得分提供针对性建议
    final extroversion = result.dimensionScores[PersonalityDimension.energyOrientation] ?? 0.5;
    if (extroversion < 0.3) {
      recommendations.add('尊重其内向特质，避免强迫社交');
    } else if (extroversion > 0.7) {
      recommendations.add('提供充足的社交和活动机会');
    }

    return recommendations;
  }
}