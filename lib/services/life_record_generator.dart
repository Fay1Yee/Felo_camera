import 'dart:math';
import '../models/analysis_history.dart';
import '../models/ai_result.dart';
import '../screens/data_management/life_records_screen.dart';
import 'history_manager.dart';

/// 基于AI分析历史的生活记录生成器
class LifeRecordGenerator {
  static LifeRecordGenerator? _instance;
  static LifeRecordGenerator get instance {
    return _instance ??= LifeRecordGenerator._();
  }
  
  LifeRecordGenerator._();

  /// 根据分析历史生成生活记录
  Future<List<LifeRecord>> generateLifeRecordsFromHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? petId,
  }) async {
    final histories = await HistoryManager.instance.getAllHistories();
    
    // 按日期范围筛选
    final filteredHistories = histories.where((history) {
      if (startDate != null && history.timestamp.isBefore(startDate)) return false;
      if (endDate != null && history.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();

    final List<LifeRecord> lifeRecords = [];
    
    for (final history in filteredHistories) {
      final record = _convertAnalysisToLifeRecord(history, petId ?? 'default_pet');
      if (record != null) {
        lifeRecords.add(record);
      }
    }

    return lifeRecords;
  }

  /// 将分析历史转换为生活记录
  LifeRecord? _convertAnalysisToLifeRecord(AnalysisHistory history, String petId) {
    final result = history.result;
    final mode = history.mode;
    
    // 根据分析模式和结果内容推断记录类型
    final recordType = _inferRecordType(mode, result);
    if (recordType == null) return null;

    // 生成记录标题和描述
    final title = _generateTitle(recordType, result);
    final description = _generateDescription(recordType, result, history);
    
    // 推断活动强度
    final intensity = _inferActivityIntensity(recordType, result);
    
    // 推断情绪状态
    final mood = _inferMoodState(result);
    
    // 生成标签
    final tags = _generateTags(mode, result);

    return LifeRecord(
      id: 'generated_${history.id}',
      type: recordType,
      timestamp: history.timestamp,
      title: title,
      description: description,
      intensity: intensity,
      mood: mood,
      tags: tags,
      imageUrl: history.imagePath,
      metadata: {
        'sourceAnalysisId': history.id,
        'analysisMode': mode,
        'confidence': result.confidence,
        'isGenerated': true,
        'generatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 根据分析模式和结果推断记录类型
  RecordType? _inferRecordType(String mode, AIResult result) {
    final title = result.title.toLowerCase();
    final subInfo = result.subInfo?.toLowerCase() ?? '';
    
    // 基于分析模式的映射
    switch (mode) {
      case 'health':
        if (title.contains('睡') || title.contains('休息')) return RecordType.sleep;
        if (title.contains('吃') || title.contains('食') || title.contains('喂')) return RecordType.feeding;
        if (title.contains('喝') || title.contains('水')) return RecordType.drinking;
        return RecordType.health;
        
      case 'behavior':
        if (title.contains('玩') || title.contains('游戏')) return RecordType.play;
        if (title.contains('跑') || title.contains('运动') || title.contains('散步')) return RecordType.exercise;
        if (title.contains('训练') || title.contains('学习')) return RecordType.training;
        if (title.contains('社交') || title.contains('互动')) return RecordType.social;
        return RecordType.play;
        
      case 'emotion':
        if (title.contains('睡') || subInfo.contains('休息')) return RecordType.sleep;
        if (title.contains('玩') || subInfo.contains('开心')) return RecordType.play;
        return RecordType.other;
        
      case 'activity':
        if (title.contains('吃') || title.contains('食')) return RecordType.feeding;
        if (title.contains('喝') || title.contains('水')) return RecordType.drinking;
        if (title.contains('跑') || title.contains('运动')) return RecordType.exercise;
        if (title.contains('玩')) return RecordType.play;
        if (title.contains('睡')) return RecordType.sleep;
        return RecordType.exercise;
        
      case 'travel':
        return RecordType.social; // 出行通常涉及社交
        
      default:
        // 通用推断逻辑
        if (title.contains('吃') || title.contains('食') || title.contains('喂')) return RecordType.feeding;
        if (title.contains('喝') || title.contains('水')) return RecordType.drinking;
        if (title.contains('跑') || title.contains('运动') || title.contains('散步')) return RecordType.exercise;
        if (title.contains('睡') || title.contains('休息')) return RecordType.sleep;
        if (title.contains('玩') || title.contains('游戏')) return RecordType.play;
        if (title.contains('训练') || title.contains('学习')) return RecordType.training;
        if (title.contains('美容') || title.contains('洗澡')) return RecordType.grooming;
        if (title.contains('健康') || title.contains('体检')) return RecordType.health;
        return RecordType.other;
    }
  }

  /// 生成记录标题
  String _generateTitle(RecordType type, AIResult result) {
    final originalTitle = result.title;
    
    // 如果原标题已经很合适，直接使用
    if (_isTitleAppropriate(originalTitle, type)) {
      return originalTitle;
    }
    
    // 根据类型生成合适的标题
    switch (type) {
      case RecordType.feeding:
        return '进食活动';
      case RecordType.drinking:
        return '饮水记录';
      case RecordType.exercise:
        return '运动时光';
      case RecordType.sleep:
        return '休息时间';
      case RecordType.play:
        return '玩耍时光';
      case RecordType.training:
        return '训练时间';
      case RecordType.grooming:
        return '美容护理';
      case RecordType.health:
        return '健康检查';
      case RecordType.social:
        return '社交活动';
      case RecordType.other:
        return originalTitle;
    }
  }

  /// 生成记录描述
  String _generateDescription(RecordType type, AIResult result, AnalysisHistory history) {
    final baseDescription = result.title;
    final subInfo = result.subInfo ?? '';
    final confidence = result.confidence;
    final mode = history.mode;
    
    String description = baseDescription;
    
    // 添加详细信息
    if (subInfo.isNotEmpty) {
      description += '，$subInfo';
    }
    
    // 添加分析相关信息
    description += '（基于${_getModeDisplayName(mode)}分析，置信度$confidence%）';
    
    return description;
  }

  /// 推断活动强度
  ActivityIntensity? _inferActivityIntensity(RecordType type, AIResult result) {
    final title = result.title.toLowerCase();
    final subInfo = result.subInfo?.toLowerCase() ?? '';
    final confidence = result.confidence;
    
    // 只有运动、玩耍、训练类型才有强度
    if (![RecordType.exercise, RecordType.play, RecordType.training].contains(type)) {
      return null;
    }
    
    // 基于关键词推断强度
    if (title.contains('激烈') || title.contains('剧烈') || title.contains('高强度') ||
        subInfo.contains('快速') || subInfo.contains('兴奋')) {
      return ActivityIntensity.high;
    }
    
    if (title.contains('缓慢') || title.contains('轻松') || title.contains('低强度') ||
        subInfo.contains('平静') || subInfo.contains('温和')) {
      return ActivityIntensity.low;
    }
    
    // 基于置信度推断（高置信度可能意味着明显的活动）
    if (confidence > 80) {
      return ActivityIntensity.medium;
    }
    
    return ActivityIntensity.low;
  }

  /// 推断情绪状态
  MoodState _inferMoodState(AIResult result) {
    final title = result.title.toLowerCase();
    final subInfo = result.subInfo?.toLowerCase() ?? '';
    final confidence = result.confidence;
    
    // 基于关键词推断情绪
    if (title.contains('开心') || title.contains('快乐') || title.contains('兴奋') ||
        subInfo.contains('活跃') || subInfo.contains('愉快')) {
      return MoodState.happy;
    }
    
    if (title.contains('疲惫') || title.contains('累') || title.contains('困') ||
        subInfo.contains('休息') || subInfo.contains('睡觉')) {
      return MoodState.tired;
    }
    
    if (title.contains('焦虑') || title.contains('紧张') || title.contains('不安') ||
        subInfo.contains('警惕') || subInfo.contains('担心')) {
      return MoodState.anxious;
    }
    
    if (title.contains('沮丧') || title.contains('难过') || title.contains('低落') ||
        confidence < 50) {
      return MoodState.sad;
    }
    
    return MoodState.normal;
  }

  /// 生成标签
  List<String> _generateTags(String mode, AIResult result) {
    final tags = <String>[];
    
    // 添加分析模式标签
    tags.add(_getModeDisplayName(mode));
    
    // 基于结果内容生成标签
    final title = result.title.toLowerCase();
    final subInfo = result.subInfo?.toLowerCase() ?? '';
    
    if (title.contains('室内') || subInfo.contains('室内')) tags.add('室内');
    if (title.contains('室外') || subInfo.contains('室外')) tags.add('室外');
    if (title.contains('公园') || subInfo.contains('公园')) tags.add('公园');
    if (title.contains('家') || subInfo.contains('家')) tags.add('家中');
    if (title.contains('社交') || subInfo.contains('其他')) tags.add('社交');
    if (title.contains('独自') || subInfo.contains('独自')) tags.add('独处');
    
    // 添加置信度标签
    if (result.confidence > 90) {
      tags.add('高置信度');
    } else if (result.confidence < 60) {
      tags.add('低置信度');
    }
    
    // 添加生成标签
    tags.add('AI生成');
    
    return tags;
  }

  /// 获取分析模式显示名称
  String _getModeDisplayName(String mode) {
    switch (mode) {
      case 'health': return '健康分析';
      case 'behavior': return '行为分析';
      case 'emotion': return '情绪分析';
      case 'activity': return '活动分析';
      case 'travel': return '出行分析';
      default: return '智能分析';
    }
  }

  /// 判断标题是否适合该记录类型
  bool _isTitleAppropriate(String title, RecordType type) {
    final lowerTitle = title.toLowerCase();
    
    switch (type) {
      case RecordType.feeding:
        return lowerTitle.contains('吃') || lowerTitle.contains('食') || lowerTitle.contains('喂');
      case RecordType.drinking:
        return lowerTitle.contains('喝') || lowerTitle.contains('水');
      case RecordType.exercise:
        return lowerTitle.contains('跑') || lowerTitle.contains('运动') || lowerTitle.contains('散步');
      case RecordType.sleep:
        return lowerTitle.contains('睡') || lowerTitle.contains('休息');
      case RecordType.play:
        return lowerTitle.contains('玩') || lowerTitle.contains('游戏');
      case RecordType.training:
        return lowerTitle.contains('训练') || lowerTitle.contains('学习');
      case RecordType.grooming:
        return lowerTitle.contains('美容') || lowerTitle.contains('洗澡');
      case RecordType.health:
        return lowerTitle.contains('健康') || lowerTitle.contains('体检');
      case RecordType.social:
        return lowerTitle.contains('社交') || lowerTitle.contains('互动');
      case RecordType.other:
        return true;
    }
  }

  /// 生成行为模式分析
  Future<List<BehaviorPattern>> generateBehaviorPatterns({
    DateTime? startDate,
    DateTime? endDate,
    String? petId,
  }) async {
    final lifeRecords = await generateLifeRecordsFromHistory(
      startDate: startDate,
      endDate: endDate,
      petId: petId,
    );

    final patterns = <BehaviorPattern>[];
    final recordsByType = <RecordType, List<LifeRecord>>{};
    
    // 按类型分组
    for (final record in lifeRecords) {
      recordsByType.putIfAbsent(record.type, () => []).add(record);
    }

    // 为每种类型生成行为模式
    for (final entry in recordsByType.entries) {
      final type = entry.key;
      final records = entry.value;
      
      if (records.length < 3) continue; // 数据太少，不生成模式
      
      final pattern = _analyzeBehaviorPattern(type, records);
      if (pattern != null) {
        patterns.add(pattern);
      }
    }

    return patterns;
  }

  /// 分析行为模式
  BehaviorPattern? _analyzeBehaviorPattern(RecordType type, List<LifeRecord> records) {
    if (records.isEmpty) return null;

    // 计算频次（假设分析一周的数据）
    final frequency = records.length;
    
    // 计算平均持续时间
    final durationsWithValue = records
        .where((r) => r.duration != null)
        .map((r) => r.duration ?? Duration.zero)
        .toList();
    
    final averageDuration = durationsWithValue.isNotEmpty
        ? Duration(
            milliseconds: durationsWithValue
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a + b) ~/
                durationsWithValue.length,
          )
        : _getDefaultDuration(type);

    // 分析偏好时间段
    final hourCounts = <int, int>{};
    for (final record in records) {
      final hour = record.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    final preferredHours = hourCounts.entries
        .where((e) => e.value >= 2) // 至少出现2次
        .map((e) => e.key)
        .toList()
      ..sort();

    // 计算一致性（基于时间分布的标准差）
    final consistency = _calculateConsistency(records);
    
    // 分析趋势（简化版本，基于最近记录的频率变化）
    final trend = _analyzeTrend(records);

    return BehaviorPattern(
      id: 'pattern_${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      name: '${type.displayName}习惯',
      type: type,
      frequency: frequency,
      averageDuration: averageDuration,
      preferredHours: preferredHours,
      consistency: consistency,
      trend: trend,
    );
  }

  /// 获取默认持续时间
  Duration _getDefaultDuration(RecordType type) {
    switch (type) {
      case RecordType.feeding:
        return const Duration(minutes: 15);
      case RecordType.drinking:
        return const Duration(minutes: 2);
      case RecordType.exercise:
        return const Duration(minutes: 30);
      case RecordType.sleep:
        return const Duration(hours: 8);
      case RecordType.play:
        return const Duration(minutes: 20);
      case RecordType.training:
        return const Duration(minutes: 15);
      case RecordType.grooming:
        return const Duration(minutes: 30);
      case RecordType.health:
        return const Duration(minutes: 45);
      case RecordType.social:
        return const Duration(minutes: 25);
      case RecordType.other:
        return const Duration(minutes: 10);
    }
  }

  /// 计算一致性
  double _calculateConsistency(List<LifeRecord> records) {
    if (records.length < 2) return 1.0;

    // 基于时间间隔的一致性计算
    final intervals = <int>[];
    for (int i = 1; i < records.length; i++) {
      final interval = records[i-1].timestamp.difference(records[i].timestamp).inHours.abs();
      intervals.add(interval);
    }

    if (intervals.isEmpty) return 1.0;

    final mean = intervals.reduce((a, b) => a + b) / intervals.length;
    final variance = intervals.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / intervals.length;
    final standardDeviation = sqrt(variance);

    // 将标准差转换为0-1的一致性分数（标准差越小，一致性越高）
    final consistency = 1.0 - (standardDeviation / (mean + 1)).clamp(0.0, 1.0);
    return consistency;
  }

  /// 分析趋势
  String _analyzeTrend(List<LifeRecord> records) {
    if (records.length < 4) return 'stable';

    // 将记录按时间排序
    final sortedRecords = List<LifeRecord>.from(records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 比较前半部分和后半部分的频率
    final midPoint = sortedRecords.length ~/ 2;
    final firstHalf = sortedRecords.take(midPoint).length;
    final secondHalf = sortedRecords.skip(midPoint).length;

    if (secondHalf > firstHalf * 1.2) {
      return 'increasing';
    } else if (secondHalf < firstHalf * 0.8) {
      return 'decreasing';
    } else {
      return 'stable';
    }
  }
}