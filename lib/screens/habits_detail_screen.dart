import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../widgets/unified_app_bar.dart';

class HabitsDetailScreen extends StatefulWidget {
  const HabitsDetailScreen({super.key});

  @override
  State<HabitsDetailScreen> createState() => _HabitsDetailScreenState();
}

class _HabitsDetailScreenState extends State<HabitsDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _dailyHabits = [
    {
      'name': '晨起散步',
      'time': '每天 · 07:00-07:30',
      'icon': Icons.directions_walk,
      'color': NothingTheme.success,
      'completed': true,
    },
    {
      'name': '阅读习惯',
      'time': '每天 · 21:00-21:30',
      'icon': Icons.book,
      'color': NothingTheme.info,
      'completed': false,
    },
    {
      'name': '冥想练习',
      'time': '每天 · 06:30-07:00',
      'icon': Icons.self_improvement,
      'color': NothingTheme.warning,
      'completed': true,
    },
    {
      'name': '健身锻炼',
      'time': '每周3次 · 18:00-19:00',
      'icon': Icons.fitness_center,
      'color': NothingTheme.error,
      'completed': false,
    },
  ];

  final List<Map<String, dynamic>> _weeklyInsights = [
    {
      'title': '本周表现优秀',
      'description': '习惯完成率达到87%，比上周提升了7%',
      'icon': Icons.trending_up,
      'color': NothingTheme.success,
    },
    {
      'title': '注意保持记录',
      'description': '已连续记录25天，继续保持良好的记录习惯',
      'icon': Icons.schedule,
      'color': NothingTheme.warning,
    },
    {
      'title': '建议调整时间',
      'description': '晚间习惯完成率较低，建议调整到更合适的时间',
      'icon': Icons.access_time,
      'color': NothingTheme.info,
    },
  ];

  final List<Map<String, dynamic>> _behaviorAnalysis = [
    {
      'behavior': '活跃度',
      'score': 85,
      'description': '泡泡的性格温和安静，喜欢室内休息',
      'suggestions': ['增加户外运动时间', '提供更多玩具'],
      'icon': Icons.directions_run,
      'color': NothingTheme.success,
      'trend': '+5%',
      'lastWeekScore': 80,
    },
    {
      'behavior': '社交性',
      'score': 72,
      'description': '对陌生人较为谨慎，但与熟人互动良好',
      'suggestions': ['多接触不同的人和环境', '参加宠物社交活动'],
      'icon': Icons.people,
      'color': NothingTheme.warning,
      'trend': '+2%',
      'lastWeekScore': 70,
    },
    {
      'behavior': '学习能力',
      'score': 90,
      'description': '学习新指令很快，记忆力强',
      'suggestions': ['定期训练新技能', '使用正向激励'],
      'icon': Icons.psychology,
      'color': NothingTheme.info,
      'trend': '+8%',
      'lastWeekScore': 82,
    },
    {
      'behavior': '情绪稳定性',
      'score': 88,
      'description': '情绪稳定，适应能力强',
      'suggestions': ['保持规律作息', '提供安全感'],
      'icon': Icons.favorite,
      'color': const Color(0xFFE91E63),
      'trend': '+3%',
      'lastWeekScore': 85,
    },
    {
      'behavior': '食欲状况',
      'score': 92,
      'description': '食欲良好，进食规律',
      'suggestions': ['保持定时喂食', '注意食物新鲜度'],
      'icon': Icons.restaurant_menu,
      'color': const Color(0xFF9C27B0),
      'trend': '+1%',
      'lastWeekScore': 91,
    },
  ];



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background, // 浅灰背景 - 符合设计规范
      appBar: UnifiedAppBar(
        title: 'Felo 习惯分析',
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: NothingTheme.textSecondary,
          indicatorColor: const Color(0xFFFFD84D),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '日常习惯'),
            Tab(text: '行为分析'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyHabits(),
          _buildBehaviorAnalysis(),
        ],
      ),
    );
  }

  Widget _buildDailyHabits() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计概览卡片 - 简化为与图片一致的样式
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '本周习惯完成度',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildHabitStat('平均完成度', '87%', NothingTheme.success),
                    ),
                    Expanded(
                      child: _buildHabitStat('连续天数', '25天', NothingTheme.info),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildHabitStat('习惯数量', '${_dailyHabits.length}个', NothingTheme.warning),
                    ),
                    Expanded(
                      child: _buildHabitStat('改善趋势', '↗ 上升', NothingTheme.success),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 每周洞察 - 简化标题样式
          const Text(
            '本周洞察',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _weeklyInsights.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final insight = _weeklyInsights[index];
                return Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: insight['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              insight['icon'],
                              color: insight['color'],
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              insight['title'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: NothingTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 习惯列表 - 简化标题样式
          const Text(
            '日常习惯',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dailyHabits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final habit = _dailyHabits[index];
              return _buildHabitCard(habit);
            },
          ),
          
          const SizedBox(height: 24),
          
          // 快捷操作 - 使用与档案界面一致的按钮样式
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFD84D)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // TODO: 添加新习惯
                    },
                    child: const Text(
                      '添加新习惯',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                    color: const Color(0xFFFFD84D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // TODO: 习惯设置
                    },
                    child: const Text(
                      '习惯设置',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
 
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorAnalysis() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 综合评分卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '综合行为评分',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD84D), // Nothing黄色 - 符合设计规范
                      width: 8,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '84',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '优秀',
                          style: TextStyle(
                            fontSize: 14,
                            color: NothingTheme.textSecondary, // 中灰色 - 符合设计规范
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '泡泡的整体表现优秀，各项行为指标均在良好范围内',
                  style: TextStyle(
                    fontSize: 14,
                    color: NothingTheme.textSecondary, // 中灰色 - 符合设计规范
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 行为分析列表
          const Text(
            '行为分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _behaviorAnalysis.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final analysis = _behaviorAnalysis[index];
              return _buildBehaviorCard(analysis);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> habit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 习惯图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: habit['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              habit['icon'],
              color: habit['color'],
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 习惯信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  habit['time'],
                  style: TextStyle(
                    fontSize: 11,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // 完成状态指示器
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: habit['completed'] ? NothingTheme.success : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: habit['completed']
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: NothingTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorCard(Map<String, dynamic> analysis) {
    Color scoreColor = Colors.green;
    if (analysis['score'] < 60) scoreColor = Colors.red;
    else if (analysis['score'] < 80) scoreColor = Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: analysis['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  analysis['icon'],
                  color: analysis['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis['behavior'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '趋势: ${analysis['trend']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: NothingTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${analysis['score']}分',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            analysis['description'],
            style: const TextStyle(
              fontSize: 14,
              color: NothingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '本周评分',
                style: TextStyle(
                  fontSize: 14,
                  color: NothingTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '上周: ${analysis['lastWeekScore']}分',
                style: const TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: analysis['score'] / 100,
            backgroundColor: NothingTheme.textSecondary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              analysis['score'] >= 80 ? NothingTheme.success : 
              analysis['score'] >= 60 ? NothingTheme.warning : NothingTheme.error,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '改善建议',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...analysis['suggestions'].map<Widget>((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD84D),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: NothingTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}