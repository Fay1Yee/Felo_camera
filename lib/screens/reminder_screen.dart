import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../widgets/unified_app_bar.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final List<Map<String, dynamic>> _reminders = [
    {
      'id': '1',
      'title': '疫苗接种提醒',
      'description': '泡泡的狂犬病疫苗即将到期，请及时预约接种',
      'time': '2024-01-20 09:00',
      'type': 'health',
      'priority': 'high',
      'isRead': false,
      'icon': Icons.vaccines_outlined,
      'color': NothingTheme.error,
    },
    {
      'id': '2',
      'title': '喂食提醒',
      'description': '该给泡泡喂晚餐了',
      'time': '2024-01-15 18:00',
      'type': 'daily',
      'priority': 'medium',
      'isRead': true,
      'icon': Icons.restaurant_outlined,
      'color': NothingTheme.warning,
    },
    {
      'id': '3',
      'title': '体检报告',
      'description': '泡泡的体检报告已出，各项指标正常',
      'time': '2024-01-14 14:30',
      'type': 'health',
      'priority': 'low',
      'isRead': true,
      'icon': Icons.assignment_outlined,
      'color': NothingTheme.success,
    },
    {
      'id': '4',
      'title': '驱虫提醒',
      'description': '距离上次驱虫已过3个月，建议进行驱虫',
      'time': '2024-01-12 10:00',
      'type': 'health',
      'priority': 'medium',
      'isRead': false,
      'icon': Icons.bug_report_outlined,
      'color': NothingTheme.warning,
    },
    {
      'id': '5',
      'title': '洗澡提醒',
      'description': '泡泡已经一周没洗澡了，该给它洗澡了',
      'time': '2024-01-10 16:00',
      'type': 'daily',
      'priority': 'low',
      'isRead': true,
      'icon': Icons.bathtub_outlined,
      'color': NothingTheme.info,
    },
    {
      'id': '6',
      'title': '运动提醒',
      'description': '今天还没有带泡泡出去散步，记得要运动哦',
      'time': '2024-01-09 19:00',
      'type': 'daily',
      'priority': 'medium',
      'isRead': false,
      'icon': Icons.directions_walk_outlined,
      'color': NothingTheme.info,
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': '健康提醒',
      'description': '疫苗、体检、驱虫',
      'icon': Icons.local_hospital_outlined,
      'color': const Color(0xFFFF4757),
      'count': 3,
    },
    {
      'title': '日常提醒',
      'description': '喂食、洗澡、运动',
      'icon': Icons.schedule_outlined,
      'color': NothingTheme.info,
      'count': 5,
    },
    {
      'title': '自定义提醒',
      'description': '个性化设置',
      'icon': Icons.tune_outlined,
      'color': NothingTheme.success,
      'count': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _reminders.where((r) => !r['isRead']).length;
    final todayReminders = _reminders.where((r) => 
      DateTime.parse(r['time']).day == DateTime.now().day).length;
    
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: UnifiedAppBar(
        title: '提醒中心',
        actions: [
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4757),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统计概览卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: NothingTheme.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFFFF9F43),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '提醒概览',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: NothingTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '今日 $todayReminders 条提醒，$unreadCount 条未读',
                              style: const TextStyle(
                                fontSize: 14,
                                color: NothingTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: NothingTheme.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: NothingTheme.gray300),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                for (var reminder in _reminders) {
                                  reminder['isRead'] = true;
                                }
                              });
                            },
                            child: const Text(
                              '全部已读',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5352ED),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem('未读消息', '$unreadCount', const Color(0xFFFF4757)),
                      ),
                      Container(width: 1, height: 40, color: NothingTheme.gray300),
                      Expanded(
                        child: _buildStatItem('今日提醒', '$todayReminders', NothingTheme.info),
                      ),
                      Container(width: 1, height: 40, color: NothingTheme.gray300),
                      Expanded(
                        child: _buildStatItem('总提醒', '${_reminders.length}', NothingTheme.success),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 快捷操作
            const Text(
              '快捷操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: NothingTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickActions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final action = _quickActions[index];
                  return _buildQuickActionCard(action);
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: NothingTheme.info,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '添加提醒',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NothingTheme.gray300),
                    ),
                    child: const Center(
                      child: Text(
                        '提醒设置',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5352ED),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 消息列表
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '消息列表',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NothingTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_list_outlined,
                        size: 16,
                        color: NothingTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '筛选',
                        style: TextStyle(
                          fontSize: 12,
                          color: NothingTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reminders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return _buildReminderCard(reminder);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: NothingTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: action['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  action['icon'],
                  color: action['color'],
                  size: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: action['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${action['count']}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: action['color'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            action['title'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            action['description'],
            style: const TextStyle(
              fontSize: 12,
              color: NothingTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            reminder['isRead'] = true;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: reminder['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    reminder['icon'],
                    color: reminder['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminder['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: NothingTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (!reminder['isRead'])
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: reminder['color'],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 12,
                            color: NothingTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reminder['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: NothingTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: reminder['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              reminder['priority'] == 'high' ? '紧急' : 
                              reminder['priority'] == 'medium' ? '普通' : '低优先级',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: reminder['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              reminder['description'],
              style: const TextStyle(
                fontSize: 14,
                color: NothingTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}