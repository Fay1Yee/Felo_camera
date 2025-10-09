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
        orElse: () => ActivityType.other,
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

/// 活动类型枚举
enum ActivityType {
  playing,    // 玩耍
  eating,     // 进食
  sleeping,   // 睡觉
  walking,    // 散步
  running,    // 奔跑
  grooming,   // 梳理
  training,   // 训练
  socializing, // 社交
  exploring,  // 探索
  resting,    // 休息
  other,      // 其他
}

/// 活动类型扩展
extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.playing:
        return '玩耍';
      case ActivityType.eating:
        return '进食';
      case ActivityType.sleeping:
        return '睡觉';
      case ActivityType.walking:
        return '散步';
      case ActivityType.running:
        return '奔跑';
      case ActivityType.grooming:
        return '梳理';
      case ActivityType.training:
        return '训练';
      case ActivityType.socializing:
        return '社交';
      case ActivityType.exploring:
        return '探索';
      case ActivityType.resting:
        return '休息';
      case ActivityType.other:
        return '其他';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityType.playing:
        return '🎾';
      case ActivityType.eating:
        return '🍽️';
      case ActivityType.sleeping:
        return '😴';
      case ActivityType.walking:
        return '🚶';
      case ActivityType.running:
        return '🏃';
      case ActivityType.grooming:
        return '🧼';
      case ActivityType.training:
        return '🎯';
      case ActivityType.socializing:
        return '👥';
      case ActivityType.exploring:
        return '🔍';
      case ActivityType.resting:
        return '😌';
      case ActivityType.other:
        return '📝';
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