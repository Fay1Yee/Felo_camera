import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class QuickActionsGrid extends StatelessWidget {
  final Function(QuickActionType) onActionTap;

  const QuickActionsGrid({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Icons.dashboard,
                color: NothingTheme.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '快捷功能',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeLg,
                  fontWeight: NothingTheme.fontWeightSemiBold,
                  color: NothingTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 快捷功能网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: _getQuickActions().map((action) {
              return _buildActionCard(action);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(QuickAction action) {
    return GestureDetector(
      onTap: () => onActionTap(action.type),
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: action.color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action.icon,
                size: 24,
                color: action.color,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              action.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: NothingTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            if (action.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  action.badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<QuickAction> _getQuickActions() {
    return [
      QuickAction(
        type: QuickActionType.healthRecord,
        title: '健康记录',
        icon: Icons.favorite,
        color: const Color(0xFFF44336),
      ),
      QuickAction(
        type: QuickActionType.reminderCenter,
        title: '提醒中心',
        icon: Icons.notifications,
        color: const Color(0xFFFF9800),
        badge: '3', // 有3个待处理提醒
      ),
      QuickAction(
        type: QuickActionType.lifeRecord,
        title: '生活记录',
        icon: Icons.photo_library,
        color: const Color(0xFF4CAF50),
      ),
      QuickAction(
        type: QuickActionType.aiCamera,
        title: 'AI相机',
        icon: Icons.camera_alt,
        color: const Color(0xFF2196F3),
      ),
      QuickAction(
        type: QuickActionType.travelBox,
        title: '出行箱',
        icon: Icons.luggage,
        color: const Color(0xFF9C27B0),
      ),
      QuickAction(
        type: QuickActionType.dataAnalysis,
        title: '数据分析',
        icon: Icons.analytics,
        color: const Color(0xFF607D8B),
      ),
      QuickAction(
        type: QuickActionType.vaccination,
        title: '疫苗管理',
        icon: Icons.medical_services,
        color: const Color(0xFF795548),
        badge: '1', // 有1个疫苗即将到期
      ),
      QuickAction(
        type: QuickActionType.emergency,
        title: '紧急联系',
        icon: Icons.emergency,
        color: const Color(0xFFE91E63),
      ),
      QuickAction(
        type: QuickActionType.settings,
        title: '设置',
        icon: Icons.settings,
        color: const Color(0xFF9E9E9E),
      ),
    ];
  }
}

// 快捷功能数据模型
class QuickAction {
  final QuickActionType type;
  final String title;
  final IconData icon;
  final Color color;
  final String? badge; // 徽章数字，如未读消息数

  const QuickAction({
    required this.type,
    required this.title,
    required this.icon,
    required this.color,
    this.badge,
  });
}

// 快捷功能类型枚举
enum QuickActionType {
  healthRecord,    // 健康记录
  reminderCenter,  // 提醒中心
  lifeRecord,      // 生活记录
  aiCamera,        // AI相机
  travelBox,       // 出行箱
  dataAnalysis,    // 数据分析
  vaccination,     // 疫苗管理
  emergency,       // 紧急联系
  settings,        // 设置
}