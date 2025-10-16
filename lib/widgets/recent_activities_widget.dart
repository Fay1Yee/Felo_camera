import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/pet_activity.dart';

class RecentActivitiesWidget extends StatefulWidget {
  final String petId;

  const RecentActivitiesWidget({
    super.key,
    required this.petId,
  });

  @override
  State<RecentActivitiesWidget> createState() => _RecentActivitiesWidgetState();
}

class _RecentActivitiesWidgetState extends State<RecentActivitiesWidget> {
  List<PetActivity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() {
    // 模拟加载活动数据
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _activities = _getMockActivities();
        _isLoading = false;
      });
    });
  }

  List<PetActivity> _getMockActivities() {
    final now = DateTime.now();
    return [
      PetActivity(
        activityId: '1',
        petId: widget.petId,
        timestamp: now.subtract(const Duration(minutes: 30)),
        petName: '泡泡',
        activityType: ActivityType.playing,
        description: '在客厅里追逐激光笔，表现得非常兴奋',
        location: '客厅',
        duration: const Duration(minutes: 15),
        energyLevel: 8,
        tags: ['室内', '互动', '兴奋'],
        imageUrl: null,
        metadata: {'mood': '兴奋', 'intensity': '高'},
      ),
      PetActivity(
        activityId: '2',
        petId: widget.petId,
        timestamp: now.subtract(const Duration(hours: 2)),
        petName: '泡泡',
        activityType: ActivityType.eating,
        description: '正常进食，食欲良好',
        location: '厨房',
        duration: const Duration(minutes: 10),
        energyLevel: 5,
        tags: ['进食', '正常'],
        imageUrl: null,
        metadata: {'food_type': '干粮', 'amount': '正常'},
      ),
      PetActivity(
        activityId: '3',
        petId: widget.petId,
        timestamp: now.subtract(const Duration(hours: 4)),
        petName: '泡泡',
        activityType: ActivityType.sleeping,
        description: '在阳台的猫窝里安静睡觉',
        location: '阳台',
        duration: const Duration(hours: 2),
        energyLevel: 2,
        tags: ['休息', '安静'],
        imageUrl: null,
        metadata: {'sleep_quality': '深度睡眠'},
      ),
      PetActivity(
        activityId: '4',
        petId: widget.petId,
        timestamp: now.subtract(const Duration(hours: 6)),
        petName: '泡泡',
        activityType: ActivityType.grooming,
        description: '自我清洁，梳理毛发',
        location: '卧室',
        duration: const Duration(minutes: 20),
        energyLevel: 3,
        tags: ['清洁', '自理'],
        imageUrl: null,
        metadata: {'grooming_area': '全身'},
      ),
      PetActivity(
        activityId: '5',
        petId: widget.petId,
        timestamp: now.subtract(const Duration(hours: 8)),
        petName: '泡泡',
        activityType: ActivityType.exploring,
        description: '在阳台观察外面的鸟类',
        location: '阳台',
        duration: const Duration(minutes: 45),
        energyLevel: 6,
        tags: ['观察', '好奇'],
        imageUrl: null,
        metadata: {'interest': '鸟类', 'attention_level': '高'},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_activities.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // 活动统计
        _buildActivityStats(),
        const SizedBox(height: 16),
        
        // 活动列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              final activity = _activities[index];
              return _buildActivityItem(activity, index == 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets_outlined,
            size: 64,
            color: NothingTheme.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无活动记录',
            style: TextStyle(
              fontSize: 16,
              color: NothingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '使用AI相机记录宠物活动',
            style: TextStyle(
              fontSize: 14,
              color: NothingTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats() {
    final todayActivities = _activities.where((activity) {
      final today = DateTime.now();
      return activity.timestamp.day == today.day &&
             activity.timestamp.month == today.month &&
             activity.timestamp.year == today.year;
    }).toList();

    final totalDuration = todayActivities.fold<Duration>(
      Duration.zero,
      (sum, activity) => sum + activity.duration,
    );

    final averageEnergy = todayActivities.isNotEmpty
        ? todayActivities.fold<int>(0, (sum, activity) => sum + activity.energyLevel) / todayActivities.length
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日活动概览',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '活动次数',
                  '${todayActivities.length}次',
                  Icons.timeline_outlined,
                  NothingTheme.accentPrimary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '活跃时长',
                  '${totalDuration.inMinutes}分钟',
                  Icons.schedule_outlined,
                  NothingTheme.success,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '平均活力',
                  '${averageEnergy.toStringAsFixed(1)}/10',
                  Icons.battery_charging_full_outlined,
                  NothingTheme.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: NothingTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivityItem(PetActivity activity, bool isLatest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isLatest 
                      ? NothingTheme.accentPrimary 
                      : NothingTheme.gray300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              if (_activities.indexOf(activity) < _activities.length - 1)
                Container(
                  width: 2,
                  height: 60,
                  color: NothingTheme.gray200,
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // 活动内容
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                border: Border.all(
                  color: isLatest 
                      ? NothingTheme.accentPrimary.withOpacity(0.3)
                      : NothingTheme.gray200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 活动头部
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getActivityColor(activity.activityType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getActivityIcon(activity.activityType),
                          size: 16,
                          color: _getActivityColor(activity.activityType),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.activityType.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: NothingTheme.textPrimary,
                              ),
                            ),
                            Text(
                              _formatTime(activity.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: NothingTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getEnergyColor(activity.energyLevel).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '活力 ${activity.energyLevel}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getEnergyColor(activity.energyLevel),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 活动描述
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: NothingTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 活动详情
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: NothingTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: NothingTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: NothingTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(activity.duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: NothingTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // 标签
                  if (activity.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: activity.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: NothingTheme.gray100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: NothingTheme.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      // 文档标准分类
      case ActivityType.observe:
        return Icons.visibility_outlined;
      case ActivityType.explore:
        return Icons.search_outlined;
      case ActivityType.occupy:
        return Icons.home_outlined;
      case ActivityType.play:
        return Icons.sports_tennis_outlined;
      case ActivityType.attack:
        return Icons.warning_outlined;
      case ActivityType.neutral:
        return Icons.remove_circle_outline;
      case ActivityType.no_pet:
        return Icons.pets_outlined;
      // 程序现有分类
      case ActivityType.playing:
        return Icons.sports_esports_outlined;
      case ActivityType.eating:
        return Icons.restaurant_outlined;
      case ActivityType.sleeping:
        return Icons.bedtime_outlined;
      case ActivityType.feeding:
        return Icons.food_bank_outlined;
      case ActivityType.walking:
        return Icons.directions_walk_outlined;
      case ActivityType.running:
        return Icons.directions_run_outlined;
      case ActivityType.grooming:
        return Icons.spa_outlined;
      case ActivityType.training:
        return Icons.school_outlined;
      case ActivityType.socializing:
        return Icons.group_outlined;
      case ActivityType.exploring:
        return Icons.explore_outlined;
      case ActivityType.resting:
        return Icons.chair_outlined;
      case ActivityType.other:
        return Icons.pets_outlined;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      // 文档标准分类
      case ActivityType.observe:
        return NothingTheme.info;
      case ActivityType.explore:
        return NothingTheme.accentPrimary;
      case ActivityType.occupy:
        return NothingTheme.brandPrimary;
      case ActivityType.play:
        return NothingTheme.warning;
      case ActivityType.attack:
        return NothingTheme.error;
      case ActivityType.neutral:
        return NothingTheme.gray400;
      case ActivityType.no_pet:
        return NothingTheme.textSecondary;
      // 程序现有分类
      case ActivityType.playing:
        return NothingTheme.warning;
      case ActivityType.eating:
        return NothingTheme.success;
      case ActivityType.sleeping:
        return NothingTheme.info;
      case ActivityType.feeding:
        return NothingTheme.success;
      case ActivityType.walking:
      case ActivityType.running:
        return NothingTheme.accentPrimary;
      case ActivityType.grooming:
        return NothingTheme.brandPrimary;
      case ActivityType.training:
        return NothingTheme.error;
      case ActivityType.socializing:
        return NothingTheme.accentSecondary;
      case ActivityType.exploring:
        return NothingTheme.warning;
      case ActivityType.resting:
        return NothingTheme.gray400;
      case ActivityType.other:
        return NothingTheme.textSecondary;
    }
  }

  Color _getEnergyColor(int energyLevel) {
    if (energyLevel >= 8) return NothingTheme.error;
    if (energyLevel >= 6) return NothingTheme.warning;
    if (energyLevel >= 4) return NothingTheme.success;
    return NothingTheme.info;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes % 60}分钟';
    } else {
      return '${duration.inMinutes}分钟';
    }
  }
}