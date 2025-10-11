import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class HabitsDetailScreen extends StatefulWidget {
  const HabitsDetailScreen({super.key});

  @override
  State<HabitsDetailScreen> createState() => _HabitsDetailScreenState();
}

class _HabitsDetailScreenState extends State<HabitsDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _dailyHabits = [
    {
      'habit': '晨起散步',
      'frequency': '每天',
      'time': '07:00-07:30',
      'completion': 0.85,
      'trend': 'up',
      'icon': Icons.directions_walk,
      'color': NothingTheme.success,
      'category': '运动',
      'streak': 12,
      'weeklyGoal': 7,
      'weeklyCompleted': 6,
    },
    {
      'habit': '午餐后休息',
      'frequency': '每天',
      'time': '13:00-14:00',
      'completion': 0.92,
      'trend': 'stable',
      'icon': Icons.bed,
      'color': NothingTheme.info,
      'category': '休息',
      'streak': 18,
      'weeklyGoal': 7,
      'weeklyCompleted': 6,
    },
    {
      'habit': '晚间游戏',
      'frequency': '每天',
      'time': '19:00-19:30',
      'completion': 0.78,
      'trend': 'down',
      'icon': Icons.sports_esports,
      'color': NothingTheme.warning,
      'category': '娱乐',
      'streak': 5,
      'weeklyGoal': 7,
      'weeklyCompleted': 5,
    },
    {
      'habit': '定时喂食',
      'frequency': '每天',
      'time': '08:00, 18:00',
      'completion': 0.95,
      'trend': 'up',
      'icon': Icons.restaurant,
      'color': const Color(0xFFE91E63),
      'category': '饮食',
      'streak': 25,
      'weeklyGoal': 14,
      'weeklyCompleted': 13,
    },
  ];

  final List<Map<String, dynamic>> _behaviorAnalysis = [
    {
      'behavior': '活跃度',
      'score': 85,
      'description': '小白的活跃度较高，喜欢户外活动',
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

  final List<Map<String, dynamic>> _weeklyInsights = [
    {
      'title': '本周表现优秀',
      'description': '习惯完成度达到85%，比上周提升了8%',
      'icon': Icons.trending_up,
      'color': NothingTheme.success,
    },
    {
      'title': '连续坚持记录',
      'description': '已连续记录25天，创造了新的个人记录',
      'icon': Icons.emoji_events,
      'color': const Color(0xFFFFD84D),
    },
    {
      'title': '需要关注',
      'description': '晚间游戏时间有所减少，建议增加互动',
      'icon': Icons.warning,
      'color': NothingTheme.warning,
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD84D), // Nothing黄色 - 符合设计规范
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Felo',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '习惯分析',
              style: TextStyle(
                color: NothingTheme.textSecondary, // 中灰色 - 符合设计规范
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: NothingTheme.textSecondary, // 中灰色 - 符合设计规范
          indicatorColor: const Color(0xFFFFD84D), // Nothing黄色 - 符合设计规范
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
          // 统计概览卡片
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
          
          // 每周洞察
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
          
          // 习惯列表
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
          
          // 快捷操作
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
                  '小白的整体表现优秀，各项行为指标均在良好范围内',
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

  Widget _buildHabitStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: NothingTheme.textSecondary, // 中灰色 - 符合设计规范
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> habit) {
    IconData trendIcon = Icons.trending_flat;
    Color trendColor = NothingTheme.textSecondary; // 中灰色 - 符合设计规范
    
    switch (habit['trend']) {
      case 'up':
        trendIcon = Icons.trending_up;
        trendColor = NothingTheme.success;
        break;
      case 'down':
        trendIcon = Icons.trending_down;
        trendColor = NothingTheme.error;
        break;
      case 'stable':
        trendIcon = Icons.trending_flat;
        trendColor = NothingTheme.info;
        break;
    }

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
                  color: habit['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  habit['icon'],
                  color: habit['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit['habit'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      habit['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: NothingTheme.textSecondary, // 中灰色 - 符合设计规范
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    trendIcon,
                    color: trendColor,
                    size: 20,
                  ),
                  Text(
                    '${habit['streak']}天',
                    style: TextStyle(
                      fontSize: 12,
                      color: trendColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: NothingTheme.textSecondary, // 中灰色 - 符合设计规范
              ),
              const SizedBox(width: 4),
              Text(
                '${habit['frequency']} · ${habit['time']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: NothingTheme.textSecondary, // 中灰色 - 符合设计规范
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '本周进度',
                style: TextStyle(
                  fontSize: 14,
                  color: NothingTheme.textSecondary, // 中灰色 - 符合设计规范
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: habit['completion'],
                  backgroundColor: NothingTheme.textSecondary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    habit['completion'] >= 0.8 ? NothingTheme.success : 
                    habit['completion'] >= 0.6 ? NothingTheme.warning : NothingTheme.error,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${habit['weeklyCompleted']}/${habit['weeklyGoal']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
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