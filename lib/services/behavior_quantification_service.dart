/// 行为量化评估服务
/// 实现科学的行为判定标准和量化分析算法

import 'dart:math';
import '../models/behavior_hierarchy.dart';
import '../models/pet_activity.dart';

/// 行为评估结果
class BehaviorAssessmentResult {
  final String behaviorId;
  final String behaviorName;
  final double confidence;
  final BehaviorQuantification quantification;
  final List<String> evidenceFactors; // 证据因子
  final Map<String, double> criteriaScores; // 各项标准得分
  final String assessmentReason; // 评估理由

  const BehaviorAssessmentResult({
    required this.behaviorId,
    required this.behaviorName,
    required this.confidence,
    required this.quantification,
    required this.evidenceFactors,
    required this.criteriaScores,
    required this.assessmentReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'behaviorId': behaviorId,
      'behaviorName': behaviorName,
      'confidence': confidence,
      'quantification': quantification.toJson(),
      'evidenceFactors': evidenceFactors,
      'criteriaScores': criteriaScores,
      'assessmentReason': assessmentReason,
    };
  }
}

/// 行为数据输入
class BehaviorDataInput {
  final String activityType;
  final double duration; // 持续时间（秒）
  final double intensity; // 强度（0-1）
  final Map<String, dynamic> metadata; // 元数据
  final DateTime timestamp;
  final List<String> keywords; // 关键词
  final double? confidence; // 原始置信度

  const BehaviorDataInput({
    required this.activityType,
    required this.duration,
    required this.intensity,
    required this.metadata,
    required this.timestamp,
    required this.keywords,
    this.confidence,
  });

  factory BehaviorDataInput.fromPetActivity(PetActivity activity) {
    return BehaviorDataInput(
      activityType: activity.activityType.name,
      duration: activity.duration.inSeconds.toDouble(),
      intensity: activity.energyLevel / 5.0, // 将1-5能量等级转换为0-1强度
      metadata: {
        'energyLevel': activity.energyLevel,
        'location': activity.location,
        'description': activity.description,
        'petName': activity.petName,
        ...activity.metadata,
      },
      timestamp: activity.timestamp,
      keywords: activity.tags,
      confidence: activity.energyLevel / 5.0, // 使用能量等级作为置信度
    );
  }
}

/// 行为量化评估服务
class BehaviorQuantificationService {
  static BehaviorQuantificationService? _instance;
  static BehaviorQuantificationService get instance {
    return _instance ??= BehaviorQuantificationService._();
  }

  BehaviorQuantificationService._();

  final BehaviorHierarchyManager _hierarchyManager = BehaviorHierarchyManager.instance;

  /// 评估行为数据
  Future<List<BehaviorAssessmentResult>> assessBehavior(BehaviorDataInput input) async {
    final results = <BehaviorAssessmentResult>[];
    
    // 1. 根据关键词和活动类型匹配可能的行为节点
    final candidateNodes = _findCandidateNodes(input);
    
    // 2. 对每个候选节点进行量化评估
    for (final node in candidateNodes) {
      final assessment = await _assessBehaviorNode(node, input);
      if (assessment.confidence >= node.confidenceThreshold) {
        results.add(assessment);
      }
    }
    
    // 3. 按置信度排序
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return results;
  }

  /// 批量评估行为数据
  Future<Map<String, List<BehaviorAssessmentResult>>> batchAssessBehavior(
    List<BehaviorDataInput> inputs,
  ) async {
    final results = <String, List<BehaviorAssessmentResult>>{};
    
    for (int i = 0; i < inputs.length; i++) {
      final input = inputs[i];
      final assessments = await assessBehavior(input);
      results['input_$i'] = assessments;
    }
    
    return results;
  }

  /// 计算行为频率统计
  Map<String, BehaviorFrequency> calculateBehaviorFrequencies(
    List<BehaviorAssessmentResult> assessments,
    Duration timeWindow,
  ) {
    final behaviorCounts = <String, int>{};
    final totalTime = timeWindow.inSeconds.toDouble();
    
    // 统计各行为出现次数
    for (final assessment in assessments) {
      behaviorCounts[assessment.behaviorId] = 
          (behaviorCounts[assessment.behaviorId] ?? 0) + 1;
    }
    
    // 计算频率
    final frequencies = <String, BehaviorFrequency>{};
    final totalAssessments = assessments.length;
    
    for (final entry in behaviorCounts.entries) {
      final ratio = totalAssessments > 0 ? entry.value / totalAssessments : 0.0;
      frequencies[entry.key] = BehaviorFrequency.fromRatio(ratio);
    }
    
    return frequencies;
  }

  /// 生成行为分析报告
  Map<String, dynamic> generateBehaviorReport(
    List<BehaviorAssessmentResult> assessments,
    Duration analysisWindow,
  ) {
    if (assessments.isEmpty) {
      return {
        'summary': '无行为数据',
        'totalBehaviors': 0,
        'analysisWindow': analysisWindow.inHours,
        'categories': <String, dynamic>{},
        'recommendations': <String>[],
      };
    }

    // 按类别分组
    final categoryGroups = <String, List<BehaviorAssessmentResult>>{};
    for (final assessment in assessments) {
      final node = _hierarchyManager.getNodeById(assessment.behaviorId);
      if (node?.parent != null) {
        final categoryId = node!.parent!.id;
        categoryGroups[categoryId] = (categoryGroups[categoryId] ?? [])..add(assessment);
      }
    }

    // 计算各类别统计
    final categoryStats = <String, dynamic>{};
    for (final entry in categoryGroups.entries) {
      final categoryNode = _hierarchyManager.getNodeById(entry.key);
      if (categoryNode != null) {
        categoryStats[categoryNode.name] = {
          'count': entry.value.length,
          'averageConfidence': entry.value.map((a) => a.confidence).reduce((a, b) => a + b) / entry.value.length,
          'behaviors': entry.value.map((a) => a.behaviorName).toSet().toList(),
          'totalDuration': entry.value.map((a) => a.quantification.duration.maxSeconds).reduce((a, b) => a + b),
        };
      }
    }

    // 生成建议
    final recommendations = _generateRecommendations(assessments, categoryStats);

    return {
      'summary': '分析了${assessments.length}个行为实例',
      'totalBehaviors': assessments.length,
      'analysisWindow': analysisWindow.inHours,
      'categories': categoryStats,
      'topBehaviors': assessments.take(5).map((a) => {
        'name': a.behaviorName,
        'confidence': a.confidence,
        'frequency': a.quantification.frequency.description,
      }).toList(),
      'recommendations': recommendations,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 查找候选行为节点
  List<BehaviorNode> _findCandidateNodes(BehaviorDataInput input) {
    final candidates = <BehaviorNode>[];
    
    // 1. 基于关键词搜索
    final keywordMatches = _hierarchyManager.searchByKeywords(input.keywords);
    candidates.addAll(keywordMatches);
    
    // 2. 基于活动类型映射
    final activityTypeMatches = _mapActivityTypeToBehavior(input.activityType);
    candidates.addAll(activityTypeMatches);
    
    // 3. 去重并返回叶子节点
    final uniqueCandidates = candidates.toSet().toList();
    return uniqueCandidates.where((node) => node.children.isEmpty).toList();
  }

  /// 活动类型到行为的映射
  List<BehaviorNode> _mapActivityTypeToBehavior(String activityType) {
    final mappings = {
      'playing': ['social_friendly', 'physical_locomotion', 'emotional_positive'],
      'eating': ['maintenance_feeding'],
      'sleeping': ['maintenance_resting'],
      'grooming': ['maintenance_grooming'],
      'exploring': ['cognitive_exploration'],
      'running': ['physical_locomotion'],
      'sitting': ['physical_posture'],
      'lying': ['physical_posture'],
      'standing': ['physical_posture'],
      'walking': ['physical_locomotion'],
      'jumping': ['physical_locomotion'],
      'aggressive': ['social_aggressive'],
      'hiding': ['social_avoidance', 'emotional_negative'],
      'learning': ['cognitive_learning'],
      'problem_solving': ['cognitive_problem_solving'],
    };

    final behaviorIds = mappings[activityType.toLowerCase()] ?? [];
    return behaviorIds
        .map((id) => _hierarchyManager.getNodeById(id))
        .where((node) => node != null)
        .cast<BehaviorNode>()
        .toList();
  }

  /// 评估特定行为节点
  Future<BehaviorAssessmentResult> _assessBehaviorNode(
    BehaviorNode node,
    BehaviorDataInput input,
  ) async {
    // 1. 计算各项标准得分
    final criteriaScores = <String, double>{};
    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (final entry in node.quantificationCriteria.entries) {
      final criterion = entry.key;
      final weight = entry.value;
      final score = _calculateCriterionScore(criterion, input, node);
      
      criteriaScores[criterion] = score;
      totalScore += score * weight;
      totalWeight += weight;
    }

    // 2. 计算综合置信度
    final baseConfidence = totalWeight > 0 ? totalScore / totalWeight : 0.0;
    final keywordBonus = _calculateKeywordBonus(node, input);
    final confidence = min(1.0, baseConfidence + keywordBonus);

    // 3. 生成量化结果
    final quantification = BehaviorQuantification(
      behaviorId: node.id,
      intensity: BehaviorIntensity.fromValue(input.intensity),
      duration: BehaviorDuration.fromSeconds(input.duration),
      frequency: BehaviorFrequency.regular, // 需要历史数据计算
      confidence: confidence,
      metrics: criteriaScores,
      timestamp: input.timestamp,
    );

    // 4. 生成证据因子
    final evidenceFactors = _generateEvidenceFactors(node, input, criteriaScores);

    // 5. 生成评估理由
    final assessmentReason = _generateAssessmentReason(node, input, criteriaScores, confidence);

    return BehaviorAssessmentResult(
      behaviorId: node.id,
      behaviorName: node.name,
      confidence: confidence,
      quantification: quantification,
      evidenceFactors: evidenceFactors,
      criteriaScores: criteriaScores,
      assessmentReason: assessmentReason,
    );
  }

  /// 计算单项标准得分
  double _calculateCriterionScore(String criterion, BehaviorDataInput input, BehaviorNode node) {
    switch (criterion) {
      case '接触频率':
      case '主动接近频率':
      case '威胁姿态频率':
      case '回避频率':
      case '移动频率':
      case '梳理频率':
      case '休息频率':
        return _calculateFrequencyScore(input);
      
      case '互动时长':
      case '身体接触时长':
      case '躲藏时长':
      case '姿态持续时间':
      case '探索时长':
      case '梳理时长':
      case '睡眠时长':
        return _calculateDurationScore(input);
      
      case '反应积极性':
      case '温和反应比例':
      case '积极表现频率':
        return _calculatePositivityScore(input);
      
      case '攻击动作强度':
      case '活动强度':
      case '情感强度':
      case '紧张程度':
        return _calculateIntensityScore(input);
      
      case '移动速度':
      case '逃离速度':
        return _calculateSpeedScore(input);
      
      case '学习进度':
      case '技能掌握':
      case '解决成功率':
        return _calculateLearningScore(input);
      
      default:
        return input.intensity; // 默认使用输入强度
    }
  }

  /// 计算频率得分
  double _calculateFrequencyScore(BehaviorDataInput input) {
    // 基于关键词和元数据推断频率
    final keywords = input.keywords.join(' ').toLowerCase();
    if (keywords.contains('频繁') || keywords.contains('经常')) return 0.8;
    if (keywords.contains('偶尔') || keywords.contains('有时')) return 0.5;
    if (keywords.contains('罕见') || keywords.contains('很少')) return 0.2;
    return input.intensity;
  }

  /// 计算持续时间得分
  double _calculateDurationScore(BehaviorDataInput input) {
    // 将持续时间标准化到0-1范围
    final duration = input.duration;
    if (duration <= 5) return 0.1;      // 瞬时
    if (duration <= 30) return 0.3;     // 短暂
    if (duration <= 300) return 0.5;    // 短期
    if (duration <= 1800) return 0.7;   // 中期
    if (duration <= 7200) return 0.9;   // 长期
    return 1.0;                         // 持续
  }

  /// 计算积极性得分
  double _calculatePositivityScore(BehaviorDataInput input) {
    final keywords = input.keywords.join(' ').toLowerCase();
    final reason = input.metadata['reason']?.toString().toLowerCase() ?? '';
    
    double score = input.intensity;
    
    // 积极关键词加分
    if (keywords.contains('友好') || keywords.contains('温和') || keywords.contains('快乐')) {
      score += 0.2;
    }
    if (reason.contains('主动') || reason.contains('积极')) {
      score += 0.1;
    }
    
    // 消极关键词减分
    if (keywords.contains('攻击') || keywords.contains('恐惧') || keywords.contains('紧张')) {
      score -= 0.2;
    }
    
    return max(0.0, min(1.0, score));
  }

  /// 计算强度得分
  double _calculateIntensityScore(BehaviorDataInput input) {
    return input.intensity;
  }

  /// 计算速度得分
  double _calculateSpeedScore(BehaviorDataInput input) {
    final keywords = input.keywords.join(' ').toLowerCase();
    if (keywords.contains('快速') || keywords.contains('迅速')) return 0.8;
    if (keywords.contains('缓慢') || keywords.contains('慢')) return 0.3;
    return input.intensity;
  }

  /// 计算学习得分
  double _calculateLearningScore(BehaviorDataInput input) {
    final reason = input.metadata['reason']?.toString().toLowerCase() ?? '';
    if (reason.contains('成功') || reason.contains('掌握')) return 0.8;
    if (reason.contains('尝试') || reason.contains('学习')) return 0.6;
    if (reason.contains('失败') || reason.contains('困难')) return 0.3;
    return input.intensity;
  }

  /// 计算关键词匹配奖励
  double _calculateKeywordBonus(BehaviorNode node, BehaviorDataInput input) {
    int matches = 0;
    final inputKeywords = input.keywords.map((k) => k.toLowerCase()).toList();
    
    for (final nodeKeyword in node.keywords) {
      if (inputKeywords.any((k) => k.contains(nodeKeyword.toLowerCase()))) {
        matches++;
      }
    }
    
    return min(0.2, matches * 0.05); // 最多20%奖励
  }

  /// 生成证据因子
  List<String> _generateEvidenceFactors(
    BehaviorNode node,
    BehaviorDataInput input,
    Map<String, double> criteriaScores,
  ) {
    final factors = <String>[];
    
    // 关键词匹配
    for (final keyword in node.keywords) {
      if (input.keywords.any((k) => k.toLowerCase().contains(keyword.toLowerCase()))) {
        factors.add('关键词匹配: $keyword');
      }
    }
    
    // 高分标准
    for (final entry in criteriaScores.entries) {
      if (entry.value >= 0.7) {
        factors.add('${entry.key}得分较高: ${(entry.value * 100).toStringAsFixed(1)}%');
      }
    }
    
    // 持续时间
    if (input.duration > 300) {
      factors.add('持续时间较长: ${(input.duration / 60).toStringAsFixed(1)}分钟');
    }
    
    // 强度
    if (input.intensity >= 0.8) {
      factors.add('行为强度很高: ${(input.intensity * 100).toStringAsFixed(1)}%');
    }
    
    return factors;
  }

  /// 生成评估理由
  String _generateAssessmentReason(
    BehaviorNode node,
    BehaviorDataInput input,
    Map<String, double> criteriaScores,
    double confidence,
  ) {
    final reasons = <String>[];
    
    if (confidence >= 0.8) {
      reasons.add('行为特征与${node.name}高度匹配');
    } else if (confidence >= 0.6) {
      reasons.add('行为特征与${node.name}较为匹配');
    } else {
      reasons.add('行为特征与${node.name}部分匹配');
    }
    
    // 添加主要得分因子
    final topCriteria = criteriaScores.entries
        .where((e) => e.value >= 0.6)
        .map((e) => e.key)
        .take(3)
        .toList();
    
    if (topCriteria.isNotEmpty) {
      reasons.add('主要依据: ${topCriteria.join('、')}');
    }
    
    return reasons.join('，');
  }

  /// 生成建议
  List<String> _generateRecommendations(
    List<BehaviorAssessmentResult> assessments,
    Map<String, dynamic> categoryStats,
  ) {
    final recommendations = <String>[];
    
    // 基于行为分布的建议
    if (categoryStats.containsKey('社交行为')) {
      final socialStats = categoryStats['社交行为'] as Map<String, dynamic>;
      final socialCount = socialStats['count'] as int;
      if (socialCount < assessments.length * 0.2) {
        recommendations.add('建议增加社交互动活动，促进宠物社交能力发展');
      }
    }
    
    if (categoryStats.containsKey('身体行为')) {
      final physicalStats = categoryStats['身体行为'] as Map<String, dynamic>;
      final physicalCount = physicalStats['count'] as int;
      if (physicalCount > assessments.length * 0.6) {
        recommendations.add('宠物运动量充足，注意适当休息');
      } else if (physicalCount < assessments.length * 0.3) {
        recommendations.add('建议增加运动活动，保持宠物身体健康');
      }
    }
    
    if (categoryStats.containsKey('情感行为')) {
      final emotionalStats = categoryStats['情感行为'] as Map<String, dynamic>;
      final behaviors = emotionalStats['behaviors'] as List<String>;
      if (behaviors.contains('消极情感')) {
        recommendations.add('注意宠物情感状态，提供更多关爱和安全感');
      }
    }
    
    // 基于行为频率的建议
    final lowConfidenceBehaviors = assessments.where((a) => a.confidence < 0.6).length;
    if (lowConfidenceBehaviors > assessments.length * 0.3) {
      recommendations.add('部分行为识别置信度较低，建议增加观察时间和数据收集');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('宠物行为表现良好，继续保持当前的照护方式');
    }
    
    return recommendations;
  }
}