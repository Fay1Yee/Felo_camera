import 'dart:math';
import '../models/ai_result.dart';
import '../screens/data_management/life_records_screen.dart';
import 'history_manager.dart';

/// 行为分析器 - 基于AI相机历史数据分析宠物行为
class BehaviorAnalyzer {
  static BehaviorAnalyzer? _instance;
  static BehaviorAnalyzer get instance {
    return _instance ??= BehaviorAnalyzer._();
  }
  
  BehaviorAnalyzer._();

  /// 行为标签映射 - 与ActivityType枚举的中文显示名称保持一致
  static const Map<String, List<String>> _behaviorKeywords = {
    // 文档标准分类 (与ActivityType枚举对应)
    '观望行为': ['观望', '观察', '注视', '警觉', '注意', '守护', '警戒', '凝视', '盯着', 'observe'],
    '探索行为': ['探索', '嗅探', '巡视', '移动', '好奇', '新环境', '嗅', '巡查', '搜寻', 'explore'],
    '领地行为': ['领地', '占据', '占有', '长时间', '固定位置', '守护', '标记', '霸占', 'occupy'],
    '玩耍行为': ['玩耍', '游戏', '嬉戏', '玩', '球', '玩具', '跑', '跳', '追', '打闹', 'play'],
    '攻击行为': ['攻击', '攻击性', '对峙', '紧张', '威胁', '挥爪', '咬', '冲突', '争斗', 'attack'],
    '无特定行为': ['中性', '无特定行为', '静止', '无明显行为', '平静', '普通状态', 'neutral'],
    '无宠物': ['无宠物', '未检测到', '没有宠物', '空白', '无动物', 'no_pet'],
    
    // 程序现有分类 (与ActivityType枚举对应)
    '玩耍': ['玩耍', '游戏', '嬉戏', '玩', '球', '玩具', 'playing'],
    '进食': ['进食', '吃', '食物', '饮食', '用餐', '咀嚼', '吞咽', '食用', 'eating'],
    '睡觉': ['睡眠', '睡觉', '休眠', '打盹', '小憩', '熟睡', '入睡', 'sleeping'],
    '休息': ['休息', '放松', '静卧', '躺着', '趴着', '安静', 'resting'],
    '运动': ['奔跑', '快跑', '冲刺', '疾跑', '飞奔', '急跑', '运动', 'exercising'],
    '静止': ['静止', '不动', '站立', '坐着', '固定', 'stationary'],
    '发声': ['发声', '叫', '吠', '喵', '鸣叫', '嚎叫', 'vocalizing'],
    '梳理': ['梳理', '美容', '护理', '清洁', '洗澡', '修剪', '美容护理', 'grooming'],
    '探索': ['探索活动', '搜寻', '调查', '发现', '寻找', '查看', 'exploring'],
    '社交': ['社交', '互动', '交流', '玩伴', '群体', '社会化', 'socializing'],
    '警戒': ['警戒', '警惕', '戒备', '守卫', '监视', 'alerting'],
    '其他': ['其他', '未分类', '杂项', '混合行为', '复合动作', 'other'],
  };

  /// 根据AI分析结果推断行为标签
  List<String> inferBehaviorTags(AIResult result, String mode) {
    final tags = <String>[];
    final content = '${result.title} ${result.subInfo ?? ''}'.toLowerCase();
    
    // 基于关键词匹配
    for (final entry in _behaviorKeywords.entries) {
      final behavior = entry.key;
      final keywords = entry.value;
      
      for (final keyword in keywords) {
        if (content.contains(keyword)) {
          tags.add(behavior);
          break;
        }
      }
    }
    
    // 基于分析模式添加默认标签
    switch (mode) {
      case 'pet':
        if (tags.isEmpty) tags.add('日常活动');
        break;
      case 'health':
        tags.add('健康检查');
        break;
      case 'normal':
        if (tags.isEmpty) tags.add('一般观察');
        break;
      case 'travel':
        tags.add('出行记录');
        break;
    }
    
    return tags.toSet().toList(); // 去重
  }

  /// 生成行为时间分布数据
  Future<Map<String, dynamic>> generateTimeDistribution({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final histories = await HistoryManager.instance.getAllHistories();
    
    // 筛选日期范围
    final filteredHistories = histories.where((h) {
      if (startDate != null && h.timestamp.isBefore(startDate)) return false;
      if (endDate != null && h.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();

    // 按小时统计行为分布
    final hourlyDistribution = <int, Map<String, int>>{};
    for (int hour = 0; hour < 24; hour++) {
      hourlyDistribution[hour] = {};
    }

    for (final history in filteredHistories) {
      final hour = history.timestamp.hour;
      final tags = inferBehaviorTags(history.result, history.mode);
      
      for (final tag in tags) {
        final hourData = hourlyDistribution[hour];
        if (hourData != null) {
          hourData[tag] = (hourData[tag] ?? 0) + 1;
        }
      }
    }

    return {
      'hourlyDistribution': hourlyDistribution,
      'totalRecords': filteredHistories.length,
      'dateRange': {
        'start': startDate?.toIso8601String(),
        'end': endDate?.toIso8601String(),
      },
    };
  }

  /// 生成行为频率统计
  Future<Map<String, int>> generateBehaviorFrequency({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final histories = await HistoryManager.instance.getAllHistories();
    
    final filteredHistories = histories.where((h) {
      if (startDate != null && h.timestamp.isBefore(startDate)) return false;
      if (endDate != null && h.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();

    final frequency = <String, int>{};
    
    for (final history in filteredHistories) {
      final tags = inferBehaviorTags(history.result, history.mode);
      for (final tag in tags) {
        frequency[tag] = (frequency[tag] ?? 0) + 1;
      }
    }

    // 按频率排序
    final sortedEntries = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries);
  }

  /// 生成行为模式分析
  Future<List<BehaviorPattern>> analyzeBehaviorPatterns({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final histories = await HistoryManager.instance.getAllHistories();
    
    final filteredHistories = histories.where((h) {
      if (startDate != null && h.timestamp.isBefore(startDate)) return false;
      if (endDate != null && h.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();

    final patterns = <BehaviorPattern>[];
    final behaviorByTime = <String, List<DateTime>>{};

    // 收集每种行为的时间点
    for (final history in filteredHistories) {
      final tags = inferBehaviorTags(history.result, history.mode);
      for (final tag in tags) {
        behaviorByTime.putIfAbsent(tag, () => []).add(history.timestamp);
      }
    }

    // 分析每种行为的模式
    for (final entry in behaviorByTime.entries) {
      final behavior = entry.key;
      final timestamps = entry.value;
      
      if (timestamps.length < 3) continue; // 数据太少

      // 计算平均时间
      final hours = timestamps.map((t) => t.hour).toList();
      final avgHour = hours.reduce((a, b) => a + b) / hours.length;
      
      // 计算频率
      final frequency = timestamps.length;
      final days = (endDate ?? DateTime.now())
          .difference(startDate ?? timestamps.first)
          .inDays + 1;
      final avgFrequency = frequency / days;

      patterns.add(BehaviorPattern(
        behavior: behavior,
        frequency: frequency,
        averageTime: TimeOfDay(
          hour: avgHour.round(),
          minute: 0,
        ),
        confidence: _calculatePatternConfidence(timestamps),
        description: _generatePatternDescription(behavior, avgHour, avgFrequency),
      ));
    }

    // 按置信度排序
    patterns.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return patterns;
  }

  /// 计算模式置信度
  double _calculatePatternConfidence(List<DateTime> timestamps) {
    if (timestamps.length < 3) return 0.0;
    
    // 基于时间一致性计算置信度
    final hours = timestamps.map((t) => t.hour).toList();
    final avgHour = hours.reduce((a, b) => a + b) / hours.length;
    
    // 计算标准差
    final variance = hours
        .map((h) => pow(h - avgHour, 2))
        .reduce((a, b) => a + b) / hours.length;
    final stdDev = sqrt(variance);
    
    // 标准差越小，置信度越高
    final confidence = max(0.0, min(1.0, 1.0 - (stdDev / 12.0)));
    
    return confidence;
  }

  /// 生成模式描述
  String _generatePatternDescription(String behavior, double avgHour, double avgFrequency) {
    final timeDesc = _getTimeDescription(avgHour.round());
    final freqDesc = _getFrequencyDescription(avgFrequency);
    
    return '$behavior通常在$timeDesc进行，$freqDesc';
  }

  String _getTimeDescription(int hour) {
    if (hour >= 6 && hour < 12) return '上午';
    if (hour >= 12 && hour < 18) return '下午';
    if (hour >= 18 && hour < 22) return '晚上';
    return '深夜';
  }

  String _getFrequencyDescription(double frequency) {
    if (frequency >= 2) return '频率较高';
    if (frequency >= 1) return '每天都有';
    if (frequency >= 0.5) return '隔天进行';
    return '偶尔进行';
  }

  /// 将AI历史记录转换为增强的生活记录
  Future<List<LifeRecord>> convertToEnhancedLifeRecords({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final histories = await HistoryManager.instance.getAllHistories();
    
    final filteredHistories = histories.where((h) {
      if (startDate != null && h.timestamp.isBefore(startDate)) return false;
      if (endDate != null && h.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();

    final records = <LifeRecord>[];
    
    for (final history in filteredHistories) {
      final tags = inferBehaviorTags(history.result, history.mode);
      final recordType = _inferRecordType(tags, history.mode);
      
      final record = LifeRecord(
        id: 'ai_${history.id}',
        type: recordType,
        timestamp: history.timestamp,
        title: _generateRecordTitle(history.result, tags),
        description: _generateRecordDescription(history.result, history.mode),
        tags: tags,
        imageUrl: history.imagePath,
        metadata: {
          'sourceAnalysisId': history.id,
          'analysisMode': history.mode,
          'confidence': history.result.confidence,
          'aiGenerated': true,
          'behaviorTags': tags,
        },
      );
      
      records.add(record);
    }
    
    // 按时间正序排列
    records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return records;
  }

  RecordType _inferRecordType(List<String> tags, String mode) {
    if (tags.contains('进食')) return RecordType.feeding;
    if (tags.contains('玩耍')) return RecordType.play;
    if (tags.contains('休息')) return RecordType.sleep;
    if (tags.contains('运动')) return RecordType.exercise;
    if (tags.contains('清洁')) return RecordType.grooming;
    if (tags.contains('健康检查')) return RecordType.health;
    if (tags.contains('社交')) return RecordType.social;
    
    // 基于模式的默认类型
    switch (mode) {
      case 'health': return RecordType.health;
      case 'pet': return RecordType.play;
      case 'travel': return RecordType.exercise;
      default: return RecordType.other;
    }
  }

  String _generateRecordTitle(AIResult result, List<String> tags) {
    if (tags.isNotEmpty) {
      return '${tags.first} - ${result.title}';
    }
    return result.title;
  }

  String _generateRecordDescription(AIResult result, String mode) {
    final confidence = result.confidence;
    final confidenceDesc = confidence >= 80 ? '高置信度' : 
                          confidence >= 60 ? '中等置信度' : '低置信度';
    
    return '${result.subInfo ?? ''}（AI分析，$confidenceDesc：$confidence%）';
  }
}

/// 行为模式数据模型
class BehaviorPattern {
  final String behavior;
  final int frequency;
  final TimeOfDay averageTime;
  final double confidence;
  final String description;

  const BehaviorPattern({
    required this.behavior,
    required this.frequency,
    required this.averageTime,
    required this.confidence,
    required this.description,
  });
}

/// 时间类
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}