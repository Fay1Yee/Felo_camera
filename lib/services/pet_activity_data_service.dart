import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 宠物活动数据模型
class PetActivityEvent {
  final String timestamp;
  final String title;
  final String content;
  final double confidence;
  final List<String> tags;
  final String location;
  final String originalCategory;

  PetActivityEvent({
    required this.timestamp,
    required this.title,
    required this.content,
    required this.confidence,
    required this.tags,
    required this.location,
    required this.originalCategory,
  });

  factory PetActivityEvent.fromJson(Map<String, dynamic> json) {
    return PetActivityEvent(
      timestamp: json['时间'] ?? '',
      title: json['标题'] ?? '',
      content: json['内容'] ?? '',
      confidence: (json['置信度'] ?? 0).toDouble(),
      tags: List<String>.from(json['标签'] ?? []),
      location: json['位置'] ?? '',
      originalCategory: json['原始类别'] ?? '',
    );
  }

  DateTime get dateTime {
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedTime {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.month}月${dt.day}日';
    } catch (e) {
      return '';
    }
  }
}

/// 活动类型统计信息
class ActivityTypeStats {
  final int eventCount;
  final double averageConfidence;
  final String startTime;
  final String endTime;

  ActivityTypeStats({
    required this.eventCount,
    required this.averageConfidence,
    required this.startTime,
    required this.endTime,
  });

  factory ActivityTypeStats.fromJson(Map<String, dynamic> json) {
    return ActivityTypeStats(
      eventCount: json['事件数量'] ?? 0,
      averageConfidence: (json['平均置信度'] ?? 0).toDouble(),
      startTime: json['时间范围']?['开始'] ?? '',
      endTime: json['时间范围']?['结束'] ?? '',
    );
  }
}

/// 宠物活动数据汇总
class PetActivitySummary {
  final int totalEvents;
  final int activityTypes;
  final Map<String, ActivityTypeStats> typeStats;

  PetActivitySummary({
    required this.totalEvents,
    required this.activityTypes,
    required this.typeStats,
  });

  factory PetActivitySummary.fromJson(Map<String, dynamic> json) {
    final typeStatsMap = <String, ActivityTypeStats>{};
    final statsData = json['各类型统计'] as Map<String, dynamic>? ?? {};
    
    for (final entry in statsData.entries) {
      typeStatsMap[entry.key] = ActivityTypeStats.fromJson(entry.value);
    }

    return PetActivitySummary(
      totalEvents: json['总事件数'] ?? 0,
      activityTypes: json['活动类型数'] ?? 0,
      typeStats: typeStatsMap,
    );
  }
}

/// 宠物活动数据服务
class PetActivityDataService {
  static PetActivityDataService? _instance;
  static PetActivityDataService get instance {
    _instance ??= PetActivityDataService._();
    return _instance!;
  }

  PetActivityDataService._();

  Map<String, List<PetActivityEvent>>? _categorizedData;
  PetActivitySummary? _summary;
  bool _isLoaded = false;

  /// 加载分类的宠物活动数据
  Future<bool> loadCategorizedData() async {
    try {
      // 从assets读取分类数据文件
      final content = await rootBundle.loadString('assets/categorized_activities.json');
      final jsonData = json.decode(content);

      // 解析汇总信息
      _summary = PetActivitySummary.fromJson(jsonData['汇总信息']);

      // 解析分类数据
      _categorizedData = <String, List<PetActivityEvent>>{};
      final categoriesData = jsonData['分类数据'] as Map<String, dynamic>;

      for (final entry in categoriesData.entries) {
        final categoryName = entry.key;
        
        // 严格筛选并删除所有无宠物的事件内容，确保数据纯净性
        if (categoryName == '无宠物') {
          debugPrint('🚫 过滤掉无宠物事件分类: $categoryName');
          continue;
        }
        
        final eventsData = entry.value as List<dynamic>;
        
        final events = eventsData
            .map((eventJson) => PetActivityEvent.fromJson(eventJson))
            .where((event) => event.originalCategory != 'no_pet') // 额外过滤原始类别为no_pet的事件
            .toList();
        
        if (events.isNotEmpty) {
          _categorizedData![categoryName] = events;
        }
      }

      _isLoaded = true;
      debugPrint('✅ 宠物活动数据加载成功，共 ${_summary?.totalEvents} 个事件，${_summary?.activityTypes} 个类型');
      return true;
    } catch (e) {
      debugPrint('❌ 加载宠物活动数据失败: $e');
      return false;
    }
  }

  /// 获取所有活动类型
  List<String> getActivityTypes() {
    if (!_isLoaded || _categorizedData == null) return [];
    return _categorizedData!.keys.toList();
  }

  /// 获取指定类型的活动事件
  List<PetActivityEvent> getEventsByType(String type) {
    if (!_isLoaded || _categorizedData == null) return [];
    return _categorizedData![type] ?? [];
  }

  /// 获取所有事件（按时间排序）
  List<PetActivityEvent> getAllEvents() {
    if (!_isLoaded || _categorizedData == null) return [];
    
    final allEvents = <PetActivityEvent>[];
    for (final events in _categorizedData!.values) {
      allEvents.addAll(events);
    }
    
    // 按时间倒序排序（最新的在前面）
    allEvents.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return allEvents;
  }

  /// 获取数据汇总信息
  PetActivitySummary? getSummary() {
    return _summary;
  }

  /// 获取分类数据
  Map<String, List<PetActivityEvent>>? getCategorizedData() {
    return _categorizedData;
  }

  /// 检查数据是否已加载
  bool get isLoaded => _isLoaded;

  /// 重新加载数据
  Future<bool> reload() async {
    _isLoaded = false;
    _categorizedData = null;
    _summary = null;
    return await loadCategorizedData();
  }

  /// 根据日期筛选事件
  List<PetActivityEvent> getEventsByDate(DateTime date) {
    final allEvents = getAllEvents();
    return allEvents.where((event) {
      final eventDate = event.dateTime;
      return eventDate.year == date.year &&
             eventDate.month == date.month &&
             eventDate.day == date.day;
    }).toList();
  }

  /// 获取活动类型的颜色
  Color getActivityTypeColor(String type) {
    final colorMap = {
      '观望行为': const Color(0xFF3B82F6), // 蓝色
      '探索行为': const Color(0xFF10B981), // 绿色
      '休息行为': const Color(0xFF8B5CF6), // 紫色
      '领地行为': const Color(0xFFF59E0B), // 橙色
      '无宠物': const Color(0xFF6B7280), // 灰色
      '无特定行为': const Color(0xFF64748B), // 深灰色
      'attack': const Color(0xFFEF4444), // 红色
      'play': const Color(0xFFEC4899), // 粉色
    };
    
    return colorMap[type] ?? const Color(0xFF64748B);
  }

  /// 获取活动类型的图标
  String getActivityTypeIcon(String type) {
    final iconMap = {
      '观望行为': '👀',
      '探索行为': '🔍',
      '休息行为': '😴',
      '领地行为': '🏠',
      '无宠物': '❌',
      '无特定行为': '⚪',
      'attack': '⚔️',
      'play': '🎮',
    };
    
    return iconMap[type] ?? '📝';
  }
}