import 'package:flutter/material.dart';
import 'daily_habits_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  void _handleQuickAction(String action) {
    switch (action) {
      case '日常习惯':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DailyHabitsScreen(),
          ),
        );
        break;
      case '健康档案':
        Navigator.pushNamed(context, '/health');
        break;
      case '添加提醒':
        Navigator.pushNamed(context, '/reminder');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7), // 米白主背景
      body: SafeArea(child: _buildHomeContent()),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPetStatusCard(),
          const SizedBox(height: 20),
          _buildTodayHighlightCard(),
          const SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildPetStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // 纯白卡片
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFECEFF1), // 浅灰分隔
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), // 浅灰背景
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.pets,
                  color: const Color(0xFF2F5233), // 墨绿色图标
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '泡泡',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2F5233), // 墨绿色主文本
                      ),
                    ),
                    Text(
                      '布偶猫 · 3岁7个月 · 健康',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF90A4AE), // 浅灰辅助
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF2F5233,
                  ).withValues(alpha: 0.1), // 墨绿色背景
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '活跃',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2F5233), // 墨绿色文本
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '性格特征',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2F5233), // 墨绿色主文本
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['友善', '活泼', '聪明', '忠诚'].map((trait) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), // 浅灰背景
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFECEFF1), // 浅灰分隔
                    width: 1,
                  ),
                ),
                child: Text(
                  trait,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF90A4AE), // 浅灰辅助
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHighlightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // 纯白卡片
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFECEFF1), // 浅灰分隔
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: const Color(0xFFFFD84D), // 金黄色图标
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '今日亮点',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F5233), // 墨绿色主文本
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '泡泡今天表现很棒！温和安静地度过了一天，食欲良好，眼神温顺。建议继续保持规律的生活节奏。',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF90A4AE), // 浅灰辅助
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('运动', '45分钟', const Color(0xFF4CAF50)),
              const SizedBox(width: 20),
              _buildStatItem('心情', '愉悦', const Color(0xFFFFD84D)),
              const SizedBox(width: 20),
              _buildStatItem('健康', '良好', const Color(0xFF2196F3)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/history'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F5233).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        color: const Color(0xFF2F5233),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '查看历史',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2F5233),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF90A4AE), // 浅灰辅助
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2F5233), // 墨绿色主文本
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.schedule,
        'label': '日常习惯',
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.folder_special,
        'label': '健康档案',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': Icons.notification_add,
        'label': '添加提醒',
        'color': const Color(0xFFFF9800),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F5233), // 墨绿色主文本
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _handleQuickAction(action['label'] as String),
                  child: _buildActionCard(
                    action['icon'] as IconData,
                    action['label'] as String,
                    action['color'] as Color,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // 纯白卡片
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFECEFF1), // 浅灰分隔
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2F5233), // 墨绿色主文本
            ),
          ),
        ],
      ),
    );
  }
}
