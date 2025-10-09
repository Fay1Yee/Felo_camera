import 'analysis_history.dart';

/// 宠物行为分析数据模型
class BehaviorAnalytics {
  final Map<String, int> behaviorFrequency;
  final Map<String, Duration> behaviorDuration;
  final Map<int, int> hourlyActivity; // 小时 -> 活动次数
  final Map<String, double> behaviorTrends; // 行为趋势（相比上周的变化百分比）
  final List<BehaviorInsight> insights;
  final DateTime analysisDate;
  final int totalRecords;

  const BehaviorAnalytics({
    required this.behaviorFrequency,
    required this.behaviorDuration,
    required this.hourlyActivity,
    required this.behaviorTrends,
    required this.insights,
    required this.analysisDate,
    required this.totalRecords,
  });

  /// 从历史记录列表生成行为分析
  factory BehaviorAnalytics.fromHistories(List<AnalysisHistory> histories) {
    final behaviorFreq = <String, int>{};
    final behaviorDur = <String, Duration>{};
    final hourlyAct = <int, int>{};
    final behaviorTrends = <String, double>{};
    
    // 统计行为频率和时间分布
    for (final history in histories) {
      final behavior = _extractBehavior(history.result.title);
      behaviorFreq[behavior] = (behaviorFreq[behavior] ?? 0) + 1;
      
      final hour = history.timestamp.hour;
      hourlyAct[hour] = (hourlyAct[hour] ?? 0) + 1;
    }

    // 计算行为持续时间（基于连续相同行为的时间间隔）
    _calculateBehaviorDurations(histories, behaviorDur);

    // 计算行为趋势
    _calculateBehaviorTrends(histories, behaviorTrends);

    // 生成洞察
    final insights = _generateInsights(behaviorFreq, hourlyAct, behaviorDur);

    return BehaviorAnalytics(
      behaviorFrequency: behaviorFreq,
      behaviorDuration: behaviorDur,
      hourlyActivity: hourlyAct,
      behaviorTrends: behaviorTrends,
      insights: insights,
      analysisDate: DateTime.now(),
      totalRecords: histories.length,
    );
  }

  /// 提取行为类型
  static String _extractBehavior(String title) {
    // 根据AI结果标题提取行为类型
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('睡觉') || lowerTitle.contains('休息') || lowerTitle.contains('躺')) {
      return '休息';
    } else if (lowerTitle.contains('吃') || lowerTitle.contains('进食')) {
      return '进食';
    } else if (lowerTitle.contains('玩') || lowerTitle.contains('游戏')) {
      return '玩耍';
    } else if (lowerTitle.contains('跑') || lowerTitle.contains('运动') || lowerTitle.contains('活动')) {
      return '运动';
    } else if (lowerTitle.contains('坐') || lowerTitle.contains('站')) {
      return '静止';
    } else if (lowerTitle.contains('叫') || lowerTitle.contains('吠')) {
      return '发声';
    } else {
      return '其他';
    }
  }

  /// 计算行为持续时间
  static void _calculateBehaviorDurations(
    List<AnalysisHistory> histories, 
    Map<String, Duration> behaviorDur
  ) {
    if (histories.length < 2) return;

    for (int i = 0; i < histories.length - 1; i++) {
      final current = histories[i];
      final next = histories[i + 1];
      
      final currentBehavior = _extractBehavior(current.result.title);
      final nextBehavior = _extractBehavior(next.result.title);
      
      // 如果连续两个记录是相同行为，计算时间差
      if (currentBehavior == nextBehavior) {
        final duration = current.timestamp.difference(next.timestamp).abs();
        behaviorDur[currentBehavior] = (behaviorDur[currentBehavior] ?? Duration.zero) + duration;
      }
    }
  }

  /// 计算行为趋势
  static void _calculateBehaviorTrends(
    List<AnalysisHistory> histories,
    Map<String, double> behaviorTrends
  ) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    // 本周数据
    final thisWeek = histories.where((h) => h.timestamp.isAfter(oneWeekAgo)).toList();
    final thisWeekBehaviors = <String, int>{};
    for (final history in thisWeek) {
      final behavior = _extractBehavior(history.result.title);
      thisWeekBehaviors[behavior] = (thisWeekBehaviors[behavior] ?? 0) + 1;
    }

    // 上周数据
    final lastWeek = histories.where((h) => 
      h.timestamp.isAfter(twoWeeksAgo) && h.timestamp.isBefore(oneWeekAgo)
    ).toList();
    final lastWeekBehaviors = <String, int>{};
    for (final history in lastWeek) {
      final behavior = _extractBehavior(history.result.title);
      lastWeekBehaviors[behavior] = (lastWeekBehaviors[behavior] ?? 0) + 1;
    }

    // 计算趋势百分比
    for (final behavior in thisWeekBehaviors.keys) {
      final thisWeekCount = thisWeekBehaviors[behavior] ?? 0;
      final lastWeekCount = lastWeekBehaviors[behavior] ?? 0;
      
      if (lastWeekCount > 0) {
        final trend = ((thisWeekCount - lastWeekCount) / lastWeekCount) * 100;
        behaviorTrends[behavior] = trend;
      } else if (thisWeekCount > 0) {
        behaviorTrends[behavior] = 100.0; // 新行为
      }
    }
  }

  /// 生成行为洞察
  static List<BehaviorInsight> _generateInsights(
    Map<String, int> behaviorFreq,
    Map<int, int> hourlyAct,
    Map<String, Duration> behaviorDur,
  ) {
    final insights = <BehaviorInsight>[];

    // 最活跃的行为
    if (behaviorFreq.isNotEmpty) {
      final mostFrequent = behaviorFreq.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(BehaviorInsight(
        type: InsightType.mostFrequent,
        title: '最常见行为',
        description: '您的宠物最常表现出"${mostFrequent.key}"行为，共记录了${mostFrequent.value}次',
        icon: _getBehaviorIcon(mostFrequent.key),
        priority: InsightPriority.high,
      ));
    }

    // 最活跃的时间段
    if (hourlyAct.isNotEmpty) {
      final mostActiveHour = hourlyAct.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(BehaviorInsight(
        type: InsightType.activeTime,
        title: '活跃时间',
        description: '宠物在${mostActiveHour.key}:00-${(mostActiveHour.key + 1) % 24}:00最活跃，共有${mostActiveHour.value}次活动记录',
        icon: '🕐',
        priority: InsightPriority.medium,
      ));
    }

    // 行为持续时间分析
    if (behaviorDur.isNotEmpty) {
      final longestBehavior = behaviorDur.entries.reduce((a, b) => a.value > b.value ? a : b);
      final hours = longestBehavior.value.inHours;
      final minutes = longestBehavior.value.inMinutes % 60;
      insights.add(BehaviorInsight(
        type: InsightType.duration,
        title: '持续时间',
        description: '"${longestBehavior.key}"是持续时间最长的行为，累计${hours > 0 ? '${hours}小时' : ''}${minutes}分钟',
        icon: '⏱️',
        priority: InsightPriority.medium,
      ));
    }

    return insights;
  }

  /// 获取行为对应的图标
  static String _getBehaviorIcon(String behavior) {
    switch (behavior) {
      case '休息': return '😴';
      case '进食': return '🍽️';
      case '玩耍': return '🎾';
      case '运动': return '🏃';
      case '静止': return '🧘';
      case '发声': return '🔊';
      default: return '🐾';
    }
  }
}

/// 行为洞察
class BehaviorInsight {
  final InsightType type;
  final String title;
  final String description;
  final String icon;
  final InsightPriority priority;

  const BehaviorInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.priority,
  });
}

/// 洞察类型
enum InsightType {
  mostFrequent,
  activeTime,
  duration,
  trend,
  health,
}

/// 洞察优先级
enum InsightPriority {
  high,
  medium,
  low,
}