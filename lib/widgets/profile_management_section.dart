import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class ProfileManagementSection extends StatelessWidget {
  final VoidCallback? onEditProfile;
  final VoidCallback? onHealthRecords;
  final VoidCallback? onHabitsAnalysis;
  final VoidCallback? onLifeRecords;
  final VoidCallback? onPersonalityAnalysis;

  const ProfileManagementSection({
    super.key,
    this.onEditProfile,
    this.onHealthRecords,
    this.onHabitsAnalysis,
    this.onLifeRecords,
    this.onPersonalityAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我的档案管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 管理功能网格
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildManagementCard(
              icon: Icons.edit,
              title: '编辑我的档案',
              subtitle: '修改我的基本信息',
              color: NothingTheme.brandPrimary,
              onTap: onEditProfile,
            ),
            _buildManagementCard(
              icon: Icons.psychology,
              title: '性格分析',
              subtitle: 'AI智能性格分析',
              color: NothingTheme.accentPrimary,
              onTap: onPersonalityAnalysis,
            ),
            _buildManagementCard(
              icon: Icons.health_and_safety,
              title: '我的健康记录',
              subtitle: '查看我的健康档案',
              color: NothingTheme.accentSecondary,
              onTap: onHealthRecords,
            ),
            _buildManagementCard(
              icon: Icons.analytics,
              title: '我的习惯分析',
              subtitle: '我的行为数据分析',
              color: NothingTheme.brandSecondary,
              onTap: onHabitsAnalysis,
            ),
            _buildManagementCard(
              icon: Icons.photo_library,
              title: '我的生活记录',
              subtitle: '我的成长轨迹记录',
              color: NothingTheme.warning,
              onTap: onLifeRecords,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NothingTheme.gray200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.gray900.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NothingTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: NothingTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}