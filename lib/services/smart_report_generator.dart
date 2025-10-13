import 'package:flutter/material.dart';
import '../models/analysis_history.dart';
import '../screens/data_management/life_records_screen.dart';
import '../screens/data_management/habit_analysis_screen.dart';
import '../config/nothing_theme.dart';
import 'history_manager.dart';
import 'life_record_generator.dart';
import 'data_association_service.dart';

/// 报告类型
enum ReportType {
  daily,    // 日报
  weekly,   // 周报
  monthly,  // 月报
  custom,   // 自定义时间范围
}

/// 智能分析报告
class SmartAnalysisReport {
  final String id;
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final String petId;
  final String petName;
  
  // 基础统计
  final int totalAnalyses;
  final int totalLifeRecords;
  final int associationCount;
  final double averageConfidence;
  
  // 行为分析
  final List<BehaviorPattern> behaviorPatterns;
  final List<BehaviorInsight> behaviorInsights;
  
  // 健康指标
  final HealthSummary healthSummary;
  
  // 活动统计
  final ActivitySummary activitySummary;
  
  // 智能建议
  final List<SmartSuggestion> smartSuggestions;
  
  // 趋势分析
  final List<TrendAnalysis> trendAnalyses;
  
  final DateTime generatedAt;
  final Map<String, dynamic> metadata;

  const SmartAnalysisReport({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.petId,
    required this.petName,
    required this.totalAnalyses,
    required this.totalLifeRecords,
    required this.associationCount,
    required this.averageConfidence,
    required this.behaviorPatterns,
    required this.behaviorInsights,
    required this.healthSummary,
    required this.activitySummary,
    required this.smartSuggestions,
    required this.trendAnalyses,
    required this.generatedAt,
    this.metadata = const {},
  });
}

/// 行为洞察
class BehaviorInsight {
  final String id;
  final String title;
  final String description;
  final RecordType relatedType;
  final double significance; // 重要性评分 0-1
  final List<String> supportingEvidence; // 支持证据
  final String recommendation;

  const BehaviorInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.relatedType,
    required this.significance,
    required this.supportingEvidence,
    required this.recommendation,
  });
}

/// 健康摘要
class HealthSummary {
  final double overallScore; // 总体健康评分 0-100
  final Map<String, double> categoryScores; // 各类别评分
  final List<String> healthHighlights; // 健康亮点
  final List<String> healthConcerns; // 健康关注点
  final int healthAnalysisCount; // 健康分析次数

  const HealthSummary({
    required this.overallScore,
    required this.categoryScores,
    required this.healthHighlights,
    required this.healthConcerns,
    required this.healthAnalysisCount,
  });
}

/// 活动摘要
class ActivitySummary {
  final Duration totalActiveTime;
  final int totalActivities;
  final Map<RecordType, int> activityCounts;
  final Map<RecordType, Duration> activityDurations;
  final RecordType mostFrequentActivity;
  final RecordType longestActivity;
  final double activityVariety; // 活动多样性 0-1

  const ActivitySummary({
    required this.totalActiveTime,
    required this.totalActivities,
    required this.activityCounts,
    required this.activityDurations,
    required this.mostFrequentActivity,
    required this.longestActivity,
    required this.activityVariety,
  });
}

/// 趋势分析
class TrendAnalysis {
  final String id;
  final String title;
  final String description;
  final TrendDirection direction;
  final double changePercentage;
  final List<DataPoint> dataPoints;
  final String interpretation;

  const TrendAnalysis({
    required this.id,
    required this.title,
    required this.description,
    required this.direction,
    required this.changePercentage,
    required this.dataPoints,
    required this.interpretation,
  });
}

/// 趋势方向
enum TrendDirection {
  increasing,
  decreasing,
  stable,
  fluctuating,
}

/// 数据点
class DataPoint {
  final DateTime timestamp;
  final double value;
  final String label;

  const DataPoint({
    required this.timestamp,
    required this.value,
    required this.label,
  });
}

/// 智能报告生成器
class SmartReportGenerator {
  static SmartReportGenerator? _instance;
  static SmartReportGenerator get instance {
    return _instance ??= SmartReportGenerator._();
  }
  
  SmartReportGenerator._();

  /// 生成智能分析报告
  Future<SmartAnalysisReport> generateReport({
    required ReportType type,
    required String petId,
    required String petName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 确定时间范围
    final dateRange = _calculateDateRange(type, startDate, endDate);
    final reportStartDate = dateRange['start'] ?? DateTime.now().subtract(Duration(days: 7));
    final reportEndDate = dateRange['end'] ?? DateTime.now();

    // 获取分析历史数据
    final histories = await HistoryManager.instance.getHistoriesByDateRange(
      reportStartDate,
      reportEndDate,
    );

    // 生成生活记录
    final lifeRecords = await LifeRecordGenerator.instance.generateLifeRecordsFromHistory(
      startDate: reportStartDate,
      endDate: reportEndDate,
      petId: petId,
    );

    // 获取关联数据
    final associations = DataAssociationService.instance.getAllAssociations()
        .where((assoc) => histories.any((h) => h.id == assoc.analysisHistoryId))
        .toList();

    // 生成各部分分析
    final behaviorPatterns = await _generateBehaviorPatterns(lifeRecords);
    final behaviorInsights = await _generateBehaviorInsights(histories, lifeRecords);
    final healthSummary = await _generateHealthSummary(histories);
    final activitySummary = await _generateActivitySummary(lifeRecords);
    final smartSuggestions = await _generateSmartSuggestions(histories, lifeRecords, behaviorPatterns);
    final trendAnalyses = await _generateTrendAnalyses(histories, type);

    // 计算基础统计
    final averageConfidence = histories.isNotEmpty
        ? histories.map((h) => h.result.confidence).reduce((a, b) => a + b) / histories.length
        : 0.0;

    return SmartAnalysisReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      startDate: reportStartDate,
      endDate: reportEndDate,
      petId: petId,
      petName: petName,
      totalAnalyses: histories.length,
      totalLifeRecords: lifeRecords.length,
      associationCount: associations.length,
      averageConfidence: averageConfidence,
      behaviorPatterns: behaviorPatterns,
      behaviorInsights: behaviorInsights,
      healthSummary: healthSummary,
      activitySummary: activitySummary,
      smartSuggestions: smartSuggestions,
      trendAnalyses: trendAnalyses,
      generatedAt: DateTime.now(),
      metadata: {
        'generationMethod': 'smart_analysis',
        'dataQuality': _assessDataQuality(histories, lifeRecords),
        'reportVersion': '1.0',
      },
    );
  }

  /// 计算日期范围
  Map<String, DateTime> _calculateDateRange(ReportType type, DateTime? startDate, DateTime? endDate) {
    final now = DateTime.now();
    
    switch (type) {
      case ReportType.daily:
        final start = DateTime(now.year, now.month, now.day);
        return {
          'start': start,
          'end': start.add(const Duration(days: 1)),
        };
        
      case ReportType.weekly:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
        return {
          'start': start,
          'end': start.add(const Duration(days: 7)),
        };
        
      case ReportType.monthly:
        final start = DateTime(now.year, now.month, 1);
        final nextMonth = start.month == 12 
            ? DateTime(start.year + 1, 1, 1)
            : DateTime(start.year, start.month + 1, 1);
        return {
          'start': start,
          'end': nextMonth,
        };
        
      case ReportType.custom:
        return {
          'start': startDate ?? now.subtract(const Duration(days: 7)),
          'end': endDate ?? now,
        };
    }
  }

  /// 生成行为模式
  Future<List<BehaviorPattern>> _generateBehaviorPatterns(List<LifeRecord> lifeRecords) async {
    return await LifeRecordGenerator.instance.generateBehaviorPatterns();
  }

  /// 生成行为洞察
  Future<List<BehaviorInsight>> _generateBehaviorInsights(
    List<AnalysisHistory> histories,
    List<LifeRecord> lifeRecords,
  ) async {
    final insights = <BehaviorInsight>[];

    // 分析活动频率变化
    final activityInsight = _analyzeActivityFrequency(lifeRecords);
    if (activityInsight != null) insights.add(activityInsight);

    // 分析时间模式
    final timePatternInsight = _analyzeTimePatterns(lifeRecords);
    if (timePatternInsight != null) insights.add(timePatternInsight);

    // 分析情绪变化
    final emotionInsight = _analyzeEmotionPatterns(histories);
    if (emotionInsight != null) insights.add(emotionInsight);

    return insights;
  }

  /// 分析活动频率
  BehaviorInsight? _analyzeActivityFrequency(List<LifeRecord> records) {
    if (records.length < 5) return null;

    final activityCounts = <RecordType, int>{};
    for (final record in records) {
      activityCounts[record.type] = (activityCounts[record.type] ?? 0) + 1;
    }

    final mostFrequent = activityCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    if (mostFrequent.value < 3) return null;

    return BehaviorInsight(
      id: 'insight_activity_frequency',
      title: '活动偏好分析',
      description: '${mostFrequent.key.displayName}是最频繁的活动，占总活动的${(mostFrequent.value / records.length * 100).toStringAsFixed(1)}%',
      relatedType: mostFrequent.key,
      significance: 0.8,
      supportingEvidence: [
        '在${records.length}次记录中，${mostFrequent.key.displayName}出现了${mostFrequent.value}次',
        '该活动的频率明显高于其他活动类型',
      ],
      recommendation: '建议保持当前的${mostFrequent.key.displayName}频率，同时适当增加其他类型活动的多样性',
    );
  }

  /// 分析时间模式
  BehaviorInsight? _analyzeTimePatterns(List<LifeRecord> records) {
    if (records.length < 10) return null;

    final hourCounts = <int, int>{};
    for (final record in records) {
      final hour = record.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final peakHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    if (peakHour.value < 3) return null;

    final timeDescription = _getTimeDescription(peakHour.key);

    return BehaviorInsight(
      id: 'insight_time_pattern',
      title: '活动时间偏好',
      description: '最活跃的时间段是$timeDescription（${peakHour.key}:00），占活动总数的${(peakHour.value / records.length * 100).toStringAsFixed(1)}%',
      relatedType: RecordType.other,
      significance: 0.7,
      supportingEvidence: [
        '在${peakHour.key}:00时段记录了${peakHour.value}次活动',
        '该时段的活动频率明显高于其他时段',
      ],
      recommendation: '建议在$timeDescription安排更多互动活动，这是宠物最活跃的时间',
    );
  }

  /// 分析情绪模式
  BehaviorInsight? _analyzeEmotionPatterns(List<AnalysisHistory> histories) {
    if (histories.length < 5) return null;

    final emotionKeywords = <String, int>{};
    for (final history in histories) {
      final title = history.result.title.toLowerCase();
      final subInfo = history.result.subInfo?.toLowerCase() ?? '';
      
      if (title.contains('开心') || subInfo.contains('开心')) {
        emotionKeywords['开心'] = (emotionKeywords['开心'] ?? 0) + 1;
      }
      if (title.contains('疲惫') || subInfo.contains('疲惫')) {
        emotionKeywords['疲惫'] = (emotionKeywords['疲惫'] ?? 0) + 1;
      }
      if (title.contains('焦虑') || subInfo.contains('焦虑')) {
        emotionKeywords['焦虑'] = (emotionKeywords['焦虑'] ?? 0) + 1;
      }
    }

    if (emotionKeywords.isEmpty) return null;

    final dominantEmotion = emotionKeywords.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return BehaviorInsight(
      id: 'insight_emotion_pattern',
      title: '情绪状态分析',
      description: '最常观察到的情绪状态是"${dominantEmotion.key}"，在${histories.length}次分析中出现了${dominantEmotion.value}次',
      relatedType: RecordType.other,
      significance: 0.6,
      supportingEvidence: [
        '情绪关键词"${dominantEmotion.key}"出现频率最高',
        '占总分析次数的${(dominantEmotion.value / histories.length * 100).toStringAsFixed(1)}%',
      ],
      recommendation: _getEmotionRecommendation(dominantEmotion.key),
    );
  }

  /// 生成健康摘要
  Future<HealthSummary> _generateHealthSummary(List<AnalysisHistory> histories) async {
    final healthHistories = histories.where((h) => h.mode == 'health').toList();
    
    if (healthHistories.isEmpty) {
      return const HealthSummary(
        overallScore: 75.0, // 默认分数
        categoryScores: {},
        healthHighlights: ['暂无健康分析数据'],
        healthConcerns: [],
        healthAnalysisCount: 0,
      );
    }

    // 计算总体健康评分（基于置信度和分析结果）
    final averageConfidence = healthHistories
        .map((h) => h.result.confidence)
        .reduce((a, b) => a + b) / healthHistories.length;
    
    final overallScore = (averageConfidence * 0.8 + 20).clamp(0.0, 100.0);

    // 分析健康亮点和关注点
    final highlights = <String>[];
    final concerns = <String>[];

    for (final history in healthHistories) {
      final title = history.result.title.toLowerCase();
      if (history.result.confidence > 80) {
        if (title.contains('健康') || title.contains('正常')) {
          highlights.add(history.result.title);
        } else if (title.contains('异常') || title.contains('问题')) {
          concerns.add(history.result.title);
        }
      }
    }

    return HealthSummary(
      overallScore: overallScore,
      categoryScores: {
        '活动能力': overallScore * 0.9,
        '食欲状况': overallScore * 1.1,
        '精神状态': overallScore,
      },
      healthHighlights: highlights.isEmpty ? ['整体状态良好'] : highlights,
      healthConcerns: concerns,
      healthAnalysisCount: healthHistories.length,
    );
  }

  /// 生成活动摘要
  Future<ActivitySummary> _generateActivitySummary(List<LifeRecord> lifeRecords) async {
    if (lifeRecords.isEmpty) {
      return const ActivitySummary(
        totalActiveTime: Duration.zero,
        totalActivities: 0,
        activityCounts: {},
        activityDurations: {},
        mostFrequentActivity: RecordType.other,
        longestActivity: RecordType.other,
        activityVariety: 0.0,
      );
    }

    final activityCounts = <RecordType, int>{};
    final activityDurations = <RecordType, Duration>{};
    Duration totalActiveTime = Duration.zero;

    for (final record in lifeRecords) {
      activityCounts[record.type] = (activityCounts[record.type] ?? 0) + 1;
      
      if (record.duration != null) {
        final duration = record.duration!;
        activityDurations[record.type] = 
            (activityDurations[record.type] ?? Duration.zero) + duration;
        totalActiveTime += duration;
      }
    }

    final mostFrequent = activityCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;
    
    final longest = activityDurations.entries.isNotEmpty
        ? activityDurations.entries
            .reduce((a, b) => a.value > b.value ? a : b).key
        : RecordType.other;

    // 计算活动多样性（不同活动类型的数量 / 总可能类型数量）
    final activityVariety = activityCounts.keys.length / RecordType.values.length;

    return ActivitySummary(
      totalActiveTime: totalActiveTime,
      totalActivities: lifeRecords.length,
      activityCounts: activityCounts,
      activityDurations: activityDurations,
      mostFrequentActivity: mostFrequent,
      longestActivity: longest,
      activityVariety: activityVariety,
    );
  }

  /// 生成智能建议
  Future<List<SmartSuggestion>> _generateSmartSuggestions(
    List<AnalysisHistory> histories,
    List<LifeRecord> lifeRecords,
    List<BehaviorPattern> patterns,
  ) async {
    final suggestions = <SmartSuggestion>[];

    // 基于活动频率的建议
    if (lifeRecords.isNotEmpty) {
      final activitySuggestion = _generateActivitySuggestion(lifeRecords);
      if (activitySuggestion != null) suggestions.add(activitySuggestion);
    }

    // 基于行为模式的建议
    for (final pattern in patterns) {
      final patternSuggestion = _generatePatternSuggestion(pattern);
      if (patternSuggestion != null) suggestions.add(patternSuggestion);
    }

    // 基于分析历史的建议
    if (histories.isNotEmpty) {
      final analysisSuggestion = _generateAnalysisSuggestion(histories);
      if (analysisSuggestion != null) suggestions.add(analysisSuggestion);
    }

    return suggestions;
  }

  /// 生成趋势分析
  Future<List<TrendAnalysis>> _generateTrendAnalyses(
    List<AnalysisHistory> histories,
    ReportType reportType,
  ) async {
    final trends = <TrendAnalysis>[];

    if (histories.length < 5) return trends;

    // 分析置信度趋势
    final confidenceTrend = _analyzeConfidenceTrend(histories);
    if (confidenceTrend != null) trends.add(confidenceTrend);

    // 分析活动频率趋势
    final frequencyTrend = _analyzeFrequencyTrend(histories, reportType);
    if (frequencyTrend != null) trends.add(frequencyTrend);

    return trends;
  }

  /// 分析置信度趋势
  TrendAnalysis? _analyzeConfidenceTrend(List<AnalysisHistory> histories) {
    if (histories.length < 5) return null;

    final sortedHistories = List<AnalysisHistory>.from(histories)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final dataPoints = sortedHistories.map((h) => DataPoint(
      timestamp: h.timestamp,
      value: h.result.confidence.toDouble(),
      label: '${h.result.confidence}%',
    )).toList();

    // 计算趋势方向
    final firstHalf = dataPoints.take(dataPoints.length ~/ 2).toList();
    final secondHalf = dataPoints.skip(dataPoints.length ~/ 2).toList();
    
    final firstAvg = firstHalf.map((p) => p.value).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((p) => p.value).reduce((a, b) => a + b) / secondHalf.length;
    
    final changePercentage = ((secondAvg - firstAvg) / firstAvg * 100);
    final direction = changePercentage > 5 
        ? TrendDirection.increasing
        : changePercentage < -5 
            ? TrendDirection.decreasing 
            : TrendDirection.stable;

    return TrendAnalysis(
      id: 'trend_confidence',
      title: '分析置信度趋势',
      description: '分析结果的置信度变化趋势',
      direction: direction,
      changePercentage: changePercentage,
      dataPoints: dataPoints,
      interpretation: _interpretConfidenceTrend(direction, changePercentage),
    );
  }

  /// 分析频率趋势
  TrendAnalysis? _analyzeFrequencyTrend(List<AnalysisHistory> histories, ReportType reportType) {
    if (histories.length < 10) return null;

    // 按时间分组统计频率
    final frequencyData = <DateTime, int>{};
    
    for (final history in histories) {
      final key = _getTimeKey(history.timestamp, reportType);
      frequencyData[key] = (frequencyData[key] ?? 0) + 1;
    }

    final sortedEntries = frequencyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final dataPoints = sortedEntries.map((entry) => DataPoint(
      timestamp: entry.key,
      value: entry.value.toDouble(),
      label: '${entry.value}次',
    )).toList();

    // 计算趋势
    final values = dataPoints.map((p) => p.value).toList();
    final changePercentage = values.length > 1 
        ? ((values.last - values.first) / values.first * 100)
        : 0.0;
    
    final direction = changePercentage > 10 
        ? TrendDirection.increasing
        : changePercentage < -10 
            ? TrendDirection.decreasing 
            : TrendDirection.stable;

    return TrendAnalysis(
      id: 'trend_frequency',
      title: '分析频率趋势',
      description: '分析活动的频率变化趋势',
      direction: direction,
      changePercentage: changePercentage,
      dataPoints: dataPoints,
      interpretation: _interpretFrequencyTrend(direction, changePercentage),
    );
  }

  // 辅助方法
  String _getTimeDescription(int hour) {
    if (hour >= 6 && hour < 12) return '上午';
    if (hour >= 12 && hour < 18) return '下午';
    if (hour >= 18 && hour < 22) return '傍晚';
    return '夜间';
  }

  String _getEmotionRecommendation(String emotion) {
    switch (emotion) {
      case '开心':
        return '继续保持当前的活动安排，宠物情绪状态良好';
      case '疲惫':
        return '适当减少活动强度，增加休息时间';
      case '焦虑':
        return '创造更安静舒适的环境，避免过度刺激';
      default:
        return '密切观察宠物的情绪变化，适时调整护理方式';
    }
  }

  SmartSuggestion? _generateActivitySuggestion(List<LifeRecord> records) {
    final activityCounts = <RecordType, int>{};
    for (final record in records) {
      activityCounts[record.type] = (activityCounts[record.type] ?? 0) + 1;
    }

    if (activityCounts.length < 3) {
      return SmartSuggestion(
        id: 'suggestion_activity_variety',
        title: '增加活动多样性',
        description: '建议增加不同类型的活动，让宠物的生活更加丰富多彩',
        category: '活动建议',
        icon: Icons.sports_esports,
        color: NothingTheme.info,
        priority: 2,
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  SmartSuggestion? _generatePatternSuggestion(BehaviorPattern pattern) {
    if (pattern.consistency < 0.6) {
      return SmartSuggestion(
        id: 'suggestion_pattern_${pattern.id}',
        title: '建立规律作息',
        description: '${pattern.name}的时间不够规律，建议建立固定的作息时间',
        category: '行为建议',
        icon: Icons.schedule,
        color: NothingTheme.warning,
        priority: 3,
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  SmartSuggestion? _generateAnalysisSuggestion(List<AnalysisHistory> histories) {
    final avgConfidence = histories.map((h) => h.result.confidence).reduce((a, b) => a + b) / histories.length;
    
    if (avgConfidence < 70) {
      return SmartSuggestion(
        id: 'suggestion_analysis_quality',
        title: '提高分析质量',
        description: '建议在光线充足的环境下进行分析，以提高识别准确度',
        category: '使用建议',
        icon: Icons.lightbulb,
        color: NothingTheme.brandAccent,
        priority: 1,
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  DateTime _getTimeKey(DateTime timestamp, ReportType reportType) {
    switch (reportType) {
      case ReportType.daily:
        return DateTime(timestamp.year, timestamp.month, timestamp.day, timestamp.hour);
      case ReportType.weekly:
        return DateTime(timestamp.year, timestamp.month, timestamp.day);
      case ReportType.monthly:
        final weekOfMonth = (timestamp.day - 1) ~/ 7 + 1;
        return DateTime(timestamp.year, timestamp.month, weekOfMonth);
      case ReportType.custom:
        return DateTime(timestamp.year, timestamp.month, timestamp.day);
    }
  }

  String _interpretConfidenceTrend(TrendDirection direction, double changePercentage) {
    switch (direction) {
      case TrendDirection.increasing:
        return '分析置信度呈上升趋势，提升了${changePercentage.abs().toStringAsFixed(1)}%，说明分析质量在改善';
      case TrendDirection.decreasing:
        return '分析置信度呈下降趋势，下降了${changePercentage.abs().toStringAsFixed(1)}%，建议检查拍摄环境';
      case TrendDirection.stable:
        return '分析置信度保持稳定，变化幅度在${changePercentage.abs().toStringAsFixed(1)}%以内';
      case TrendDirection.fluctuating:
        return '分析置信度波动较大，建议保持一致的拍摄条件';
    }
  }

  String _interpretFrequencyTrend(TrendDirection direction, double changePercentage) {
    switch (direction) {
      case TrendDirection.increasing:
        return '分析频率呈上升趋势，增加了${changePercentage.abs().toStringAsFixed(1)}%，使用更加频繁';
      case TrendDirection.decreasing:
        return '分析频率呈下降趋势，减少了${changePercentage.abs().toStringAsFixed(1)}%，使用频率有所降低';
      case TrendDirection.stable:
        return '分析频率保持稳定，变化幅度在${changePercentage.abs().toStringAsFixed(1)}%以内';
      case TrendDirection.fluctuating:
        return '分析频率波动较大，使用模式不够规律';
    }
  }

  double _assessDataQuality(List<AnalysisHistory> histories, List<LifeRecord> records) {
    if (histories.isEmpty) return 0.0;
    
    double quality = 0.0;
    
    // 数据量评分 (30%)
    final dataVolumeScore = (histories.length / 50.0).clamp(0.0, 1.0);
    quality += dataVolumeScore * 0.3;
    
    // 置信度评分 (40%)
    final avgConfidence = histories.map((h) => h.result.confidence).reduce((a, b) => a + b) / histories.length;
    quality += (avgConfidence / 100.0) * 0.4;
    
    // 关联度评分 (30%)
    final associationScore = records.isNotEmpty ? (records.length / histories.length).clamp(0.0, 1.0) : 0.0;
    quality += associationScore * 0.3;
    
    return quality;
  }
}