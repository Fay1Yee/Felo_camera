/// 宠物活动记录数据模型
class PetActivity {
  final String activityId;
  final String petId;
  final DateTime timestamp;
  final String petName;
  final ActivityType activityType;
  final String description;
  final String location;
  final Duration duration;
  final int energyLevel; // 1-5 能量等级
  final List<String> tags;
  final String? imageUrl;
  final Map<String, dynamic> metadata;

  PetActivity({
    required this.activityId,
    required this.petId,
    required this.timestamp,
    required this.petName,
    required this.activityType,
    required this.description,
    required this.location,
    required this.duration,
    required this.energyLevel,
    required this.tags,
    this.imageUrl,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'petId': petId,
      'timestamp': timestamp.toIso8601String(),
      'petName': petName,
      'activityType': activityType.toString(),
      'description': description,
      'location': location,
      'duration': duration.inSeconds,
      'energyLevel': energyLevel,
      'tags': tags,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  factory PetActivity.fromJson(Map<String, dynamic> json) {
    return PetActivity(
      activityId: json['activityId'],
      petId: json['petId'],
      timestamp: DateTime.parse(json['timestamp']),
      petName: json['petName'],
      activityType: ActivityType.values.firstWhere(
        (e) => e.toString() == json['activityType'],
        orElse: () => ActivityType.neutral,
      ),
      description: json['description'],
      location: json['location'],
      duration: Duration(seconds: json['duration']),
      energyLevel: json['energyLevel'],
      tags: List<String>.from(json['tags']),
      imageUrl: json['imageUrl'],
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }
}

/// 活动类型枚举 - 包含文档标准分类和程序现有分类
enum ActivityType {
  // 文档标准分类 (timestampcategoryconfidencereasons2025.docx)
  observe,    // 观望 - 宠物保持警觉，注视某个方向
  explore,    // 探索 - 宠物主动移动、嗅探、巡视环境
  occupy,     // 领地 - 宠物长时间占据某个位置，表现领地行为
  play,       // 玩耍 - 宠物进行游戏、嬉戏活动
  attack,     // 攻击 - 宠物表现出攻击性行为
  neutral,    // 中性/无特定行为 - 宠物处于静止或无明显行为状态
  no_pet,     // 无宠物 - 监控区域内未检测到宠物
  
  // 程序现有分类 (保持向后兼容)
  playing,    // 玩耍 (旧版本)
  eating,     // 进食
  sleeping,   // 睡眠
  feeding,    // 喂食
  grooming,   // 美容护理
  resting,    // 休息
  running,    // 奔跑
  walking,    // 散步
  training,   // 训练
  socializing, // 社交
  exploring,  // 探索 (旧版本，与文档标准的explore不同)
  other,      // 其他
}

/// 活动类型扩展
extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      // 文档标准分类
      case ActivityType.observe:
        return '观望';
      case ActivityType.explore:
        return '探索';
      case ActivityType.occupy:
        return '领地';
      case ActivityType.play:
        return '玩耍';
      case ActivityType.attack:
        return '攻击';
      case ActivityType.neutral:
        return '中性';
      case ActivityType.no_pet:
        return '无宠物';
      // 程序现有分类
      case ActivityType.playing:
        return '玩耍';
      case ActivityType.eating:
        return '进食';
      case ActivityType.sleeping:
        return '睡眠';
      case ActivityType.feeding:
        return '喂食';
      case ActivityType.grooming:
        return '美容护理';
      case ActivityType.resting:
        return '休息';
      case ActivityType.running:
        return '奔跑';
      case ActivityType.walking:
        return '散步';
      case ActivityType.training:
        return '训练';
      case ActivityType.socializing:
        return '社交';
      case ActivityType.exploring:
        return '探索';
      case ActivityType.other:
        return '其他';
    }
  }

  String get emoji {
    switch (this) {
      // 文档标准分类
      case ActivityType.observe:
        return '👀';
      case ActivityType.explore:
        return '🔍';
      case ActivityType.occupy:
        return '🏠';
      case ActivityType.play:
        return '🎾';
      case ActivityType.attack:
        return '⚔️';
      case ActivityType.neutral:
        return '😐';
      case ActivityType.no_pet:
        return '❌';
      // 程序现有分类
      case ActivityType.playing:
        return '🎮';
      case ActivityType.eating:
        return '🍽️';
      case ActivityType.sleeping:
        return '💤';
      case ActivityType.feeding:
        return '🥣';
      case ActivityType.grooming:
        return '🧼';
      case ActivityType.resting:
        return '😴';
      case ActivityType.running:
        return '🏃';
      case ActivityType.walking:
        return '🚶';
      case ActivityType.training:
        return '🎯';
      case ActivityType.socializing:
        return '🤝';
      case ActivityType.exploring:
        return '🔍';
      case ActivityType.other:
        return '❓';
    }
  }
}

/// 每日活动统计
class DailyActivityStats {
  final DateTime date;
  final String petId;
  final String petName;
  final int totalActivities;
  final Duration totalActiveTime;
  final Map<ActivityType, int> activityCounts;
  final Map<ActivityType, Duration> activityDurations;
  final double averageEnergyLevel;
  final List<String> mostCommonTags;

  DailyActivityStats({
    required this.date,
    required this.petId,
    required this.petName,
    required this.totalActivities,
    required this.totalActiveTime,
    required this.activityCounts,
    required this.activityDurations,
    required this.averageEnergyLevel,
    required this.mostCommonTags,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'petId': petId,
      'petName': petName,
      'totalActivities': totalActivities,
      'totalActiveTime': totalActiveTime.inSeconds,
      'activityCounts': activityCounts.map((k, v) => MapEntry(k.toString(), v)),
      'activityDurations': activityDurations.map((k, v) => MapEntry(k.toString(), v.inSeconds)),
      'averageEnergyLevel': averageEnergyLevel,
      'mostCommonTags': mostCommonTags,
    };
  }

  factory DailyActivityStats.fromJson(Map<String, dynamic> json) {
    return DailyActivityStats(
      date: DateTime.parse(json['date']),
      petId: json['petId'],
      petName: json['petName'],
      totalActivities: json['totalActivities'],
      totalActiveTime: Duration(seconds: json['totalActiveTime']),
      activityCounts: Map<ActivityType, int>.fromEntries(
        (json['activityCounts'] as Map<String, dynamic>).entries.map(
          (e) => MapEntry(
            ActivityType.values.firstWhere((type) => type.toString() == e.key),
            e.value as int,
          ),
        ),
      ),
      activityDurations: Map<ActivityType, Duration>.fromEntries(
        (json['activityDurations'] as Map<String, dynamic>).entries.map(
          (e) => MapEntry(
            ActivityType.values.firstWhere((type) => type.toString() == e.key),
            Duration(seconds: e.value as int),
          ),
        ),
      ),
      averageEnergyLevel: json['averageEnergyLevel'].toDouble(),
      mostCommonTags: List<String>.from(json['mostCommonTags']),
    );
  }
}