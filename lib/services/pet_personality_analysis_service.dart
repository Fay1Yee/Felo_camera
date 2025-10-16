import 'dart:math';
import '../models/pet_activity.dart';
import '../models/pet_mbti_personality.dart';
import '../models/behavior_hierarchy.dart';
import 'behavior_quantification_service.dart';
import 'behavior_personality_correlation_service.dart';

/// 完整的宠物性格分析结果
class ComprehensivePersonalityAnalysis {
  final String petId;
  final String petName;
  final PetMBTIType personalityType;
  final Map<PersonalityDimension, double> dimensionScores;
  final double overallConfidence;
  final List<String> keyBehaviorPatterns;
  final List<String> personalityTraits;
  final String detailedReport;
  final List<String> recommendations;
  final DateTime analysisDate;
  final int totalActivitiesAnalyzed;
  final Map<String, double> behaviorFrequencies;
  final Map<PetMBTIType, double> typeConfidences;

  ComprehensivePersonalityAnalysis({
    required this.petId,
    required this.petName,
    required this.personalityType,
    required this.dimensionScores,
    required this.overallConfidence,
    required this.keyBehaviorPatterns,
    required this.personalityTraits,
    required this.detailedReport,
    required this.recommendations,
    required this.analysisDate,
    required this.totalActivitiesAnalyzed,
    required this.behaviorFrequencies,
    required this.typeConfidences,
  });

  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    final personality = PetMBTIDatabase.getPersonalityByType(personalityType);
    return {
      'petId': petId,
      'petName': petName,
      'personalityType': personalityType.name,
      'personalityTypeName': personality?.chineseName ?? personalityType.name,
      'dimensionScores': dimensionScores.map((k, v) => MapEntry(k.name, v)),
      'overallConfidence': overallConfidence,
      'keyBehaviorPatterns': keyBehaviorPatterns,
      'personalityTraits': personalityTraits,
      'detailedReport': detailedReport,
      'recommendations': recommendations,
      'analysisDate': analysisDate.toIso8601String(),
      'totalActivitiesAnalyzed': totalActivitiesAnalyzed,
      'behaviorFrequencies': behaviorFrequencies,
      'typeConfidences': typeConfidences.map((k, v) => MapEntry(k.name, v)),
    };
  }
}

/// 性格分析配置
class PersonalityAnalysisConfig {
  final int minActivitiesRequired;
  final int maxActivitiesAnalyzed;
  final double minConfidenceThreshold;
  final Duration analysisTimeWindow;
  final bool includeDetailedReport;
  final bool includeRecommendations;

  const PersonalityAnalysisConfig({
    this.minActivitiesRequired = 10,
    this.maxActivitiesAnalyzed = 100,
    this.minConfidenceThreshold = 0.6,
    this.analysisTimeWindow = const Duration(days: 30),
    this.includeDetailedReport = true,
    this.includeRecommendations = true,
  });
}

/// 宠物性格分析服务
class PetPersonalityAnalysisService {
  final BehaviorQuantificationService _behaviorService;
  final BehaviorPersonalityCorrelationService _correlationService;
  final PersonalityAnalysisConfig _config;

  PetPersonalityAnalysisService({
    PersonalityAnalysisConfig? config,
  }) : _behaviorService = BehaviorQuantificationService.instance,
       _correlationService = BehaviorPersonalityCorrelationService.instance,
       _config = config ?? const PersonalityAnalysisConfig();

  /// 分析宠物性格
  Future<ComprehensivePersonalityAnalysis> analyzePersonality({
    required String petId,
    required String petName,
    required List<PetActivity> activities,
  }) async {
    // 1. 验证数据充分性
    _validateAnalysisData(activities);

    // 2. 过滤和预处理活动数据
    final filteredActivities = _filterActivities(activities);

    // 3. 行为量化分析
    final behaviorResults = <BehaviorAssessmentResult>[];
    for (final activity in filteredActivities) {
      final input = BehaviorDataInput.fromPetActivity(activity);
      final results = await _behaviorService.assessBehavior(input);
      behaviorResults.addAll(results);
    }

    // 4. 计算行为频率
    final behaviorFrequencies = _calculateBehaviorFrequencies(behaviorResults);

    // 5. 性格关联分析
    final correlationResult = await _correlationService.analyzePersonalityFromBehaviors(behaviorResults);

    // 6. 确定最终性格类型
    final finalPersonalityType = _determineFinalPersonalityType(correlationResult);

    // 7. 提取关键行为模式
    final keyPatterns = _extractKeyBehaviorPatterns(behaviorResults);

    // 8. 生成性格特征描述
    final personalityTraits = _generatePersonalityTraits(finalPersonalityType);

    // 9. 生成详细报告
    final detailedReport = _config.includeDetailedReport
        ? _generateDetailedReport(
            petName,
            finalPersonalityType,
            correlationResult,
            behaviorFrequencies,
            keyPatterns,
          )
        : '';

    // 10. 生成建议
    final recommendations = _config.includeRecommendations
        ? _generateRecommendations(finalPersonalityType, keyPatterns)
        : <String>[];

    return ComprehensivePersonalityAnalysis(
      petId: petId,
      petName: petName,
      personalityType: finalPersonalityType,
      dimensionScores: _extractDimensionScores(correlationResult),
      overallConfidence: correlationResult.overallConfidence,
      keyBehaviorPatterns: keyPatterns,
      personalityTraits: personalityTraits,
      detailedReport: detailedReport,
      recommendations: recommendations,
      analysisDate: DateTime.now(),
      totalActivitiesAnalyzed: filteredActivities.length,
      behaviorFrequencies: behaviorFrequencies,
      typeConfidences: _extractTypeConfidences(correlationResult),
    );
  }

  /// 批量分析多个宠物的性格
  Future<List<ComprehensivePersonalityAnalysis>> batchAnalyzePersonalities({
    required Map<String, List<PetActivity>> petActivities,
  }) async {
    final results = <ComprehensivePersonalityAnalysis>[];

    for (final entry in petActivities.entries) {
      final petId = entry.key;
      final activities = entry.value;
      
      if (activities.isNotEmpty) {
        final petName = activities.first.petName;
        try {
          final analysis = await analyzePersonality(
            petId: petId,
            petName: petName,
            activities: activities,
          );
          results.add(analysis);
        } catch (e) {
          // 记录错误但继续处理其他宠物
          print('分析宠物 $petName ($petId) 性格时出错: $e');
        }
      }
    }

    return results;
  }

  /// 比较两个宠物的性格兼容性
  double calculateCompatibility(
    ComprehensivePersonalityAnalysis pet1,
    ComprehensivePersonalityAnalysis pet2,
  ) {
    final type1 = pet1.personalityType;
    final type2 = pet2.personalityType;

    // 基于MBTI理论的兼容性计算
    double compatibility = 0.0;
    int dimensionCount = 0;

    // 比较各个维度
    for (final dimension in PersonalityDimension.values) {
      final score1 = pet1.dimensionScores[dimension] ?? 0.0;
      final score2 = pet2.dimensionScores[dimension] ?? 0.0;
      
      // 计算维度差异（0-1之间，越小越兼容）
      final difference = (score1 - score2).abs();
      final dimensionCompatibility = 1.0 - difference;
      
      compatibility += dimensionCompatibility;
      dimensionCount++;
    }

    // 特殊兼容性规则
    compatibility += _calculateSpecialCompatibility(type1, type2);

    return (compatibility / (dimensionCount + 1)).clamp(0.0, 1.0);
  }

  /// 验证分析数据的充分性
  void _validateAnalysisData(List<PetActivity> activities) {
    if (activities.length < _config.minActivitiesRequired) {
      throw ArgumentError(
        '活动数据不足：需要至少 ${_config.minActivitiesRequired} 条记录，当前只有 ${activities.length} 条',
      );
    }
  }

  /// 过滤活动数据
  List<PetActivity> _filterActivities(List<PetActivity> activities) {
    final cutoffDate = DateTime.now().subtract(_config.analysisTimeWindow);
    
    return activities
        .where((activity) => activity.timestamp.isAfter(cutoffDate))
        .take(_config.maxActivitiesAnalyzed)
        .toList();
  }

  /// 计算行为频率
  Map<String, double> _calculateBehaviorFrequencies(
    List<BehaviorAssessmentResult> results,
  ) {
    final frequencies = <String, int>{};
    final total = results.length;

    for (final result in results) {
      final behaviorId = result.behaviorId;
      frequencies[behaviorId] = (frequencies[behaviorId] ?? 0) + 1;
    }

    return frequencies.map((k, v) => MapEntry(k, v / total));
  }

  /// 确定最终性格类型
  PetMBTIType _determineFinalPersonalityType(
    PersonalityCorrelationResult correlationResult,
  ) {
    // 如果置信度足够高，直接返回最高置信度的类型
    if (correlationResult.overallConfidence >= _config.minConfidenceThreshold) {
      return correlationResult.predictedType;
    }

    // 否则基于维度得分重新计算
    return _calculatePersonalityTypeFromDimensions(correlationResult.dimensionScores);
  }

  /// 基于维度得分计算性格类型
  PetMBTIType _calculatePersonalityTypeFromDimensions(
    Map<PersonalityDimension, PersonalityDimensionScore> dimensionScores,
  ) {
    // 提取各维度的得分
    final energyScore = dimensionScores[PersonalityDimension.energyOrientation]?.score ?? 0.0;
    final infoScore = dimensionScores[PersonalityDimension.informationProcessing]?.score ?? 0.0;
    final decisionScore = dimensionScores[PersonalityDimension.decisionMaking]?.score ?? 0.0;
    final lifestyleScore = dimensionScores[PersonalityDimension.lifestylePreference]?.score ?? 0.0;

    // 根据得分确定各维度倾向
    final isExtraverted = energyScore > 0.0;
    final isIntuitive = infoScore > 0.0;
    final isFeeling = decisionScore > 0.0;
    final isPerceiving = lifestyleScore > 0.0;

    // 查找最匹配的MBTI类型
    PetMBTIType bestMatch = PetMBTIType.EACN; // 默认类型
    double bestScore = 0.0;

    for (final type in PetMBTIType.values) {
      final personality = PetMBTIDatabase.getPersonalityByType(type);
      if (personality != null) {
        final score = _calculateTypeMatchScore(
          personality,
          energyScore,
          infoScore,
          decisionScore,
          lifestyleScore,
        );
        if (score > bestScore) {
          bestScore = score;
          bestMatch = type;
        }
      }
    }

    return bestMatch;
  }

  /// 计算类型匹配得分
  double _calculateTypeMatchScore(
    PetMBTIPersonality personality,
    double energyScore,
    double infoScore,
    double decisionScore,
    double lifestyleScore,
  ) {
    double score = 0.0;
    
    // 比较能量导向
    final expectedEnergy = personality.dimensionScores[PersonalityDimension.energyOrientation] ?? 0.5;
    score += 1.0 - (energyScore - (expectedEnergy - 0.5)).abs();
    
    // 比较信息处理
    final expectedInfo = personality.dimensionScores[PersonalityDimension.informationProcessing] ?? 0.5;
    score += 1.0 - (infoScore - (expectedInfo - 0.5)).abs();
    
    // 比较决策方式
    final expectedDecision = personality.dimensionScores[PersonalityDimension.decisionMaking] ?? 0.5;
    score += 1.0 - (decisionScore - (expectedDecision - 0.5)).abs();
    
    // 比较生活方式
    final expectedLifestyle = personality.dimensionScores[PersonalityDimension.lifestylePreference] ?? 0.5;
    score += 1.0 - (lifestyleScore - (expectedLifestyle - 0.5)).abs();
    
    return score / 4.0; // 归一化到0-1
  }

  /// 提取关键行为模式
  List<String> _extractKeyBehaviorPatterns(
    List<BehaviorAssessmentResult> behaviorResults,
  ) {
    final patterns = <String>[];
    final behaviorCounts = <String, int>{};

    // 统计行为出现频率
    for (final result in behaviorResults) {
      final behaviorName = result.behaviorName;
      behaviorCounts[behaviorName] = (behaviorCounts[behaviorName] ?? 0) + 1;
    }

    // 提取高频行为模式
    final sortedBehaviors = behaviorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < min(5, sortedBehaviors.length); i++) {
      final behavior = sortedBehaviors[i];
      final frequency = behavior.value / behaviorResults.length;
      if (frequency > 0.2) { // 出现频率超过20%
        patterns.add('${behavior.key}（出现频率：${(frequency * 100).toStringAsFixed(1)}%）');
      }
    }

    return patterns;
  }

  /// 生成性格特征描述
  List<String> _generatePersonalityTraits(PetMBTIType personalityType) {
    final personality = PetMBTIDatabase.getPersonalityByType(personalityType);
    if (personality == null) {
      return ['性格特征分析中...'];
    }

    return [
      personality.coreCharacteristics,
      ...personality.behaviorPatterns,
      ...personality.socialTraits,
    ];
  }

  /// 生成详细报告
  String _generateDetailedReport(
    String petName,
    PetMBTIType personalityType,
    PersonalityCorrelationResult correlationResult,
    Map<String, double> behaviorFrequencies,
    List<String> keyPatterns,
  ) {
    final personality = PetMBTIDatabase.getPersonalityByType(personalityType);
    final buffer = StringBuffer();

    buffer.writeln('=== $petName 性格分析报告 ===\n');
    
    buffer.writeln('【性格类型】');
    if (personality != null) {
      buffer.writeln('${personality.code} - ${personality.chineseName}');
      buffer.writeln('${personality.coreCharacteristics}\n');
    }

    buffer.writeln('【维度得分】');
    for (final entry in correlationResult.dimensionScores.entries) {
      final dimension = entry.key;
      final score = entry.value.score;
      final percentage = ((score + 1) * 50).toStringAsFixed(1);
      buffer.writeln('${_getDimensionName(dimension)}: $percentage%');
    }
    buffer.writeln();

    buffer.writeln('【关键行为模式】');
    for (final pattern in keyPatterns) {
      buffer.writeln('• $pattern');
    }
    buffer.writeln();

    buffer.writeln('【分析置信度】');
    buffer.writeln('整体置信度: ${(correlationResult.overallConfidence * 100).toStringAsFixed(1)}%');

    return buffer.toString();
  }

  /// 生成建议
  List<String> _generateRecommendations(
    PetMBTIType personalityType,
    List<String> keyPatterns,
  ) {
    final personality = PetMBTIDatabase.getPersonalityByType(personalityType);
    final recommendations = <String>[];

    if (personality != null) {
      recommendations.addAll([
        '根据${personality.chineseName}特征，建议：',
        '• 提供适合的活动环境',
        '• 根据性格特点进行训练',
        '• 关注宠物的情感需求',
      ]);
    }

    // 基于行为模式的个性化建议
    if (keyPatterns.isNotEmpty) {
      recommendations.add('\n基于观察到的行为模式：');
      for (final pattern in keyPatterns.take(3)) {
        recommendations.add('• 针对$pattern，建议加强相应的引导和训练');
      }
    }

    return recommendations;
  }

  /// 获取维度名称
  String _getDimensionName(PersonalityDimension dimension) {
    switch (dimension) {
      case PersonalityDimension.energyOrientation:
        return '能量导向';
      case PersonalityDimension.informationProcessing:
        return '信息处理';
      case PersonalityDimension.decisionMaking:
        return '决策方式';
      case PersonalityDimension.lifestylePreference:
        return '生活方式';
    }
  }

  /// 计算特殊兼容性
  double _calculateSpecialCompatibility(PetMBTIType type1, PetMBTIType type2) {
    // 基于MBTI理论的特殊兼容性规则
    if (type1 == type2) {
      return 0.2; // 相同类型有一定兼容性加成
    }

    // 互补类型的兼容性加成
    final complementaryPairs = {
      PetMBTIType.EACN: PetMBTIType.EAWN,
      PetMBTIType.ESWN: PetMBTIType.ESCN,
      PetMBTIType.EAWC: PetMBTIType.SACN,
    };

    if (complementaryPairs[type1] == type2 || complementaryPairs[type2] == type1) {
      return 0.3; // 互补类型有更高的兼容性加成
    }

    return 0.0;
  }

  /// 提取维度得分
  Map<PersonalityDimension, double> _extractDimensionScores(
    PersonalityCorrelationResult correlationResult,
  ) {
    return correlationResult.dimensionScores.map(
      (dimension, score) => MapEntry(dimension, score.score),
    );
  }

  /// 提取类型置信度
  Map<PetMBTIType, double> _extractTypeConfidences(
    PersonalityCorrelationResult correlationResult,
  ) {
    // 这里需要根据实际的correlationResult结构来实现
    // 暂时返回一个基于预测类型的简单映射
    final result = <PetMBTIType, double>{};
    result[correlationResult.predictedType] = correlationResult.overallConfidence;
    
    // 为其他类型分配较低的置信度
    for (final type in PetMBTIType.values) {
      if (type != correlationResult.predictedType) {
        result[type] = (1.0 - correlationResult.overallConfidence) / (PetMBTIType.values.length - 1);
      }
    }
    
    return result;
  }
}