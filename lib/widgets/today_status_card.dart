import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class TodayStatusCard extends StatelessWidget {
  final PetTodayStatus status;
  final VoidCallback? onTap;

  const TodayStatusCard({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NothingTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: NothingTheme.gray300,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pets,
                  color: NothingTheme.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日状态',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeLg,
                    fontWeight: NothingTheme.fontWeightSemiBold,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                _buildStatusIndicator(status.overallStatus),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 主要状态信息
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.favorite,
                    label: '心情',
                    value: status.mood,
                    color: _getMoodColor(status.mood),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.directions_run,
                    label: '活跃度',
                    value: '${status.activityLevel}%',
                    color: _getActivityColor(status.activityLevel),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 今日活动
            _buildTodayActivities(),
            
            const SizedBox(height: 16),
            
            // 健康指标
            _buildHealthIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(PetOverallStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case PetOverallStatus.excellent:
        color = const Color(0xFF4CAF50);
        text = '优秀';
        icon = Icons.sentiment_very_satisfied;
        break;
      case PetOverallStatus.good:
        color = const Color(0xFF2196F3);
        text = '良好';
        icon = Icons.sentiment_satisfied;
        break;
      case PetOverallStatus.normal:
        color = const Color(0xFFFF9800);
        text = '一般';
        icon = Icons.sentiment_neutral;
        break;
      case PetOverallStatus.attention:
        color = const Color(0xFFF44336);
        text = '需关注';
        icon = Icons.sentiment_dissatisfied;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: NothingTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日活动',
          style: TextStyle(
            fontSize: NothingTheme.fontSizeBase,
            fontWeight: NothingTheme.fontWeightMedium,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: status.todayActivities.map((activity) {
            return _buildActivityChip(activity);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivityChip(TodayActivity activity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: NothingTheme.surfaceTertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activity.icon,
            size: 14,
            color: NothingTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            activity.name,
            style: TextStyle(
              fontSize: 12,
              color: NothingTheme.textSecondary,
            ),
          ),
          if (activity.time != null) ...[
            const SizedBox(width: 4),
            Text(
              activity.time!,
              style: TextStyle(
                fontSize: 10,
                color: NothingTheme.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '健康指标',
          style: TextStyle(
            fontSize: NothingTheme.fontSizeBase,
            fontWeight: NothingTheme.fontWeightMedium,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildHealthIndicator(
                label: '体温',
                value: '${status.temperature}°C',
                isNormal: status.temperature >= 38.0 && status.temperature <= 39.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthIndicator(
                label: '心率',
                value: '${status.heartRate}bpm',
                isNormal: status.heartRate >= 60 && status.heartRate <= 120,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthIndicator(
                label: '体重',
                value: '${status.weight}kg',
                isNormal: true, // 假设体重正常
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthIndicator({
    required String label,
    required String value,
    required bool isNormal,
  }) {
    final color = isNormal ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: NothingTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case '开心':
      case '愉快':
        return const Color(0xFF4CAF50);
      case '平静':
      case '安静':
        return const Color(0xFF2196F3);
      case '兴奋':
      case '活跃':
        return const Color(0xFFFF9800);
      case '焦虑':
      case '不安':
        return const Color(0xFFF44336);
      default:
        return NothingTheme.textSecondary;
    }
  }

  Color _getActivityColor(int level) {
    if (level >= 80) return const Color(0xFF4CAF50);
    if (level >= 60) return const Color(0xFF2196F3);
    if (level >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}

// 数据模型
class PetTodayStatus {
  final PetOverallStatus overallStatus;
  final String mood;
  final int activityLevel; // 0-100
  final List<TodayActivity> todayActivities;
  final double temperature; // 体温
  final int heartRate; // 心率
  final double weight; // 体重

  const PetTodayStatus({
    required this.overallStatus,
    required this.mood,
    required this.activityLevel,
    required this.todayActivities,
    required this.temperature,
    required this.heartRate,
    required this.weight,
  });

  // 模拟数据
  static PetTodayStatus getMockData() {
    return PetTodayStatus(
      overallStatus: PetOverallStatus.good,
      mood: '开心',
      activityLevel: 75,
      todayActivities: [
        TodayActivity(
          name: '晨间散步',
          icon: Icons.directions_walk,
          time: '07:30',
        ),
        TodayActivity(
          name: '进食',
          icon: Icons.restaurant,
          time: '08:00',
        ),
        TodayActivity(
          name: '午休',
          icon: Icons.bedtime,
          time: '13:00',
        ),
        TodayActivity(
          name: '玩耍',
          icon: Icons.sports_esports,
          time: '16:30',
        ),
      ],
      temperature: 38.5,
      heartRate: 85,
      weight: 12.5,
    );
  }
}

class TodayActivity {
  final String name;
  final IconData icon;
  final String? time;

  const TodayActivity({
    required this.name,
    required this.icon,
    this.time,
  });
}

enum PetOverallStatus {
  excellent, // 优秀
  good,      // 良好
  normal,    // 一般
  attention, // 需关注
}