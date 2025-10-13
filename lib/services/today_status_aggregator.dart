import 'package:flutter/material.dart';
import '../models/ai_result.dart';
import '../models/analysis_history.dart';
import '../models/mode.dart';
import '../widgets/today_status_card.dart';
import '../services/history_manager.dart';
import '../services/behavior_analyzer.dart';

/// AI摄像头数据聚合服务
/// 从各个AI服务中收集数据并生成今日状态
class TodayStatusAggregator {
  static TodayStatusAggregator? _instance;
  static TodayStatusAggregator get instance {
    return _instance ??= TodayStatusAggregator._();
  }
  
  TodayStatusAggregator._();

  /// 从AI摄像头数据生成今日状态
  Future<PetTodayStatus> generateTodayStatus(String petName) async {
    try {
      debugPrint('🔄 开始聚合AI摄像头数据生成今日状态...');
      
      // 获取今日的AI分析历史记录
      final todayHistories = await _getTodayHistories();
      debugPrint('📊 获取到今日AI分析记录: ${todayHistories.length}条');
      
      // 获取最新的宠物模式分析结果
      final latestPetAnalysis = await _getLatestPetAnalysis(todayHistories);
      
      // 获取今日活动数据
      final todayActivities = await _generateTodayActivities(todayHistories);
      
      // 分析整体状态
      final overallStatus = _analyzeOverallStatus(todayHistories, latestPetAnalysis);
      
      // 分析心情
      final mood = _analyzeMood(todayHistories, latestPetAnalysis);
      
      // 计算活跃度
      final activityLevel = _calculateActivityLevel(todayHistories, todayActivities);
      
      // 获取体重信息（从最新的健康分析中获取，如果没有则使用默认值）
      final weight = await _getLatestWeight(todayHistories);
      
      final status = PetTodayStatus(
        overallStatus: overallStatus,
        mood: mood,
        activityLevel: activityLevel,
        todayActivities: todayActivities,
        weight: weight,
      );
      
      debugPrint('✅ AI数据聚合完成: 状态=${overallStatus.name}, 心情=$mood, 活跃度=$activityLevel%');
      return status;
      
    } catch (e) {
      debugPrint('❌ AI数据聚合失败: $e');
      // 返回安全的默认状态
      return _createFallbackStatus();
    }
  }

  /// 获取今日的AI分析历史记录
  Future<List<AnalysisHistory>> _getTodayHistories() async {
    try {
      final historyManager = HistoryManager.instance;
      final allHistories = await historyManager.getAllHistories();
      
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      return allHistories.where((history) {
        return history.timestamp.isAfter(todayStart) && 
               history.timestamp.isBefore(todayEnd);
      }).toList();
    } catch (e) {
      debugPrint('⚠️ 获取今日历史记录失败: $e');
      return [];
    }
  }

  Future<AIResult?> _getLatestPetAnalysis(List<AnalysisHistory> histories) async {
    try {
      // 筛选宠物模式的分析记录
      final petHistories = histories.where((h) => 
        h.mode == Mode.pet || 
        h.result.title.contains('宠物') ||
        h.result.subInfo?.contains('宠物') == true
      ).toList();
      
      if (petHistories.isEmpty) return null;
      
      // 按时间排序，获取最新的
      petHistories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return petHistories.first.result;
    } catch (e) {
      debugPrint('⚠️ 获取最新宠物分析失败: $e');
      return null;
    }
  }

  /// 生成今日活动列表
  Future<List<TodayActivity>> _generateTodayActivities(List<AnalysisHistory> histories) async {
    final activities = <TodayActivity>[];
    
    try {
      // 使用行为分析器分析活动
      final behaviorAnalyzer = BehaviorAnalyzer.instance;
      final patterns = await behaviorAnalyzer.analyzeBehaviorPatterns(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
      
      // 将行为模式转换为今日活动
      for (final pattern in patterns.take(4)) { // 最多显示4个活动
        final activity = TodayActivity(
          name: pattern.behavior,
          icon: _getActivityIcon(pattern.behavior),
        );
        activities.add(activity);
      }
      
      // 如果没有足够的活动，添加一些默认活动
      if (activities.length < 2) {
        activities.addAll(_getDefaultActivities());
      }
      
    } catch (e) {
      debugPrint('⚠️ 生成今日活动失败: $e');
      activities.addAll(_getDefaultActivities());
    }
    
    return activities.take(4).toList();
  }

  /// 分析整体状态
  PetOverallStatus _analyzeOverallStatus(List<AnalysisHistory> histories, AIResult? latestAnalysis) {
    try {
      if (histories.isEmpty) return PetOverallStatus.normal;
      
      // 计算平均置信度
      final avgConfidence = histories.isEmpty ? 0.5 : 
        histories.map((h) => h.result.confidence).reduce((a, b) => a + b) / histories.length;
      
      // 检查是否有健康相关的分析
      final hasHealthAnalysis = histories.any((h) => 
        h.mode == Mode.health || 
        h.result.title.contains('健康') ||
        h.result.subInfo?.contains('健康') == true
      );
      
      // 根据置信度和分析内容判断状态
      if (avgConfidence >= 0.8 && hasHealthAnalysis) {
        return PetOverallStatus.excellent;
      } else if (avgConfidence >= 0.6) {
        return PetOverallStatus.good;
      } else if (avgConfidence >= 0.4) {
        return PetOverallStatus.normal;
      } else {
        return PetOverallStatus.attention;
      }
    } catch (e) {
      debugPrint('⚠️ 分析整体状态失败: $e');
      return PetOverallStatus.normal;
    }
  }

  /// 分析心情
  String _analyzeMood(List<AnalysisHistory> histories, AIResult? latestAnalysis) {
    try {
      // 从最新分析中提取心情信息
      if (latestAnalysis?.subInfo != null) {
        final subInfo = latestAnalysis!.subInfo!.toLowerCase();
        if (subInfo.contains('开心') || subInfo.contains('快乐') || subInfo.contains('活跃')) {
          return '开心';
        } else if (subInfo.contains('安静') || subInfo.contains('平静')) {
          return '平静';
        } else if (subInfo.contains('疲惫') || subInfo.contains('累')) {
          return '疲惫';
        } else if (subInfo.contains('警觉') || subInfo.contains('紧张')) {
          return '警觉';
        }
      }
      
      // 根据活动频率判断心情
      if (histories.length >= 5) {
        return '活跃';
      } else if (histories.length >= 2) {
        return '正常';
      } else {
        return '安静';
      }
    } catch (e) {
      debugPrint('⚠️ 分析心情失败: $e');
      return '正常';
    }
  }

  /// 计算活跃度
  int _calculateActivityLevel(List<AnalysisHistory> histories, List<TodayActivity> activities) {
    try {
      // 基础活跃度：根据AI分析次数
      int baseLevel = (histories.length * 10).clamp(0, 60);
      
      int activityBonus = 0;
      for (final activity in activities) {
        if (activity.name.contains('散步') || activity.name.contains('运动')) {
          activityBonus += 15;
        } else if (activity.name.contains('玩耍') || activity.name.contains('游戏')) {
          activityBonus += 10;
        } else if (activity.name.contains('进食') || activity.name.contains('喝水')) {
          activityBonus += 5;
        }
      }
      
      // 时间分布加成：如果活动分布在不同时间段
      final timeSet = activities.map((a) => a.time?.split(':')[0] ?? '0').toSet();
      int timeBonus = timeSet.length * 5;
      
      return (baseLevel + activityBonus + timeBonus).clamp(0, 100);
    } catch (e) {
      debugPrint('⚠️ 计算活跃度失败: $e');
      return 50; // 默认活跃度
    }
  }

  /// 获取最新体重信息
  Future<double> _getLatestWeight(List<AnalysisHistory> histories) async {
    try {
      // 查找健康分析记录
      final healthHistories = histories.where((h) => 
        h.mode == Mode.health || 
        h.result.title.contains('健康')
      ).toList();
      
      if (healthHistories.isNotEmpty) {
        // 尝试从分析结果中提取体重信息
        for (final history in healthHistories) {
          final subInfo = history.result.subInfo ?? '';
          final weightMatch = RegExp(r'体重[：:]\s*(\d+\.?\d*)\s*[kK][gG]').firstMatch(subInfo);
          if (weightMatch != null) {
            return double.tryParse(weightMatch.group(1) ?? '') ?? 12.5;
          }
        }
      }
      
      // 默认体重
      return 12.5;
    } catch (e) {
      debugPrint('⚠️ 获取体重信息失败: $e');
      return 12.5;
    }
  }

  /// 获取活动图标
  IconData _getActivityIcon(String activityName) {
    if (activityName.contains('散步') || activityName.contains('运动')) {
      return Icons.directions_walk;
    } else if (activityName.contains('进食') || activityName.contains('吃')) {
      return Icons.restaurant;
    } else if (activityName.contains('睡觉') || activityName.contains('休息')) {
      return Icons.bedtime;
    } else if (activityName.contains('玩耍') || activityName.contains('游戏')) {
      return Icons.sports_esports;
    } else if (activityName.contains('喝水')) {
      return Icons.local_drink;
    } else if (activityName.contains('清洁') || activityName.contains('洗澡')) {
      return Icons.cleaning_services;
    } else {
      return Icons.pets;
    }
  }

  /// 获取默认活动
  List<TodayActivity> _getDefaultActivities() {
    return [
      const TodayActivity(
        name: '晨间观察',
        icon: Icons.visibility,
        time: '08:00',
      ),
      const TodayActivity(
        name: '日常监控',
        icon: Icons.camera_alt,
        time: '12:00',
      ),
    ];
  }

  /// 创建回退状态
  PetTodayStatus _createFallbackStatus() {
    return PetTodayStatus(
      overallStatus: PetOverallStatus.normal,
      mood: '正常',
      activityLevel: 50,
      todayActivities: _getDefaultActivities(),
      weight: 12.5,
    );
  }
}