import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../widgets/unified_app_bar.dart';

class DailyHabitsScreen extends StatefulWidget {
  const DailyHabitsScreen({super.key});

  @override
  State<DailyHabitsScreen> createState() => _DailyHabitsScreenState();
}

class _DailyHabitsScreenState extends State<DailyHabitsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // 模拟数据 - 日常习惯
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

  // 模拟数据 - 本周洞察
  final List<Map<String, dynamic>> _weeklyInsights = [
    {
      'title': '完成率提升',
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

  // 模拟数据 - 行为分析（与档案界面保持一致）
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

  // 模拟数据 - 改善建议
  final List<Map<String, dynamic>> _improvements = [
    {
      'title': '增加户外运动时间',
      'description': '建议每天增加15-20分钟的户外活动',
      'priority': 'high',
    },
    {
      'title': '规律作息时间',
      'description': '保持固定的睡眠和进食时间',
      'priority': 'medium',
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
      backgroundColor: NothingTheme.background,
      appBar: UnifiedAppBar(
        title: '今日习惯',
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
          _buildDailyHabitsTab(),
          _buildBehaviorAnalysisTab(),
        ],
      ),
    );
  }

  // 第一个标签页：日常习惯
  Widget _buildDailyHabitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 本周习惯完成度
          _buildWeeklyCompletionCard(),
          const SizedBox(height: 24),
          
          // 本周洞察
          _buildWeeklyInsightsSection(),
          const SizedBox(height: 24),
          
          // 日常习惯列表
          _buildDailyHabitsSection(),
        ],
      ),
    );
  }

  // 第二个标签页：行为分析（与档案界面保持一致）
  Widget _buildBehaviorAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 综合行为评分
          _buildOverallScoreCard(),
          const SizedBox(height: 24),
          
          // 行为分析列表
          _buildBehaviorAnalysisSection(),
          const SizedBox(height: 24),
          
          // 改善建议
          _buildImprovementSuggestions(),
        ],
      ),
    );
  }

  // 本周习惯完成度卡片
  Widget _buildWeeklyCompletionCard() {
    return Container(
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
                child: _buildStatItem('平均完成度', '87%', NothingTheme.success),
              ),
              Expanded(
                child: _buildStatItem('连续天数', '25天', NothingTheme.info),
              ),
              Expanded(
                child: _buildStatItem('本周目标', '90%', NothingTheme.warning),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 统计项目
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
    );
  }

  // 本周洞察部分
  Widget _buildWeeklyInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '本周洞察',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F5233),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _weeklyInsights.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final insight = _weeklyInsights[index];
            return _buildInsightCard(insight);
          },
        ),
      ],
    );
  }

  // 洞察卡片
  Widget _buildInsightCard(Map<String, dynamic> insight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: insight['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              insight['icon'],
              color: insight['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F5233),
                  ),
                ),
                const SizedBox(height: 4),
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
          ),
        ],
      ),
    );
  }

  // 日常习惯部分
  Widget _buildDailyHabitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '日常习惯',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F5233),
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
      ],
    );
  }

  // 习惯卡片
  Widget _buildHabitCard(Map<String, dynamic> habit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: habit['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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
                  habit['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F5233),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  habit['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            habit['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
            color: habit['completed'] ? NothingTheme.success : NothingTheme.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  // 综合行为评分卡片（与档案界面保持一致）
  Widget _buildOverallScoreCard() {
    return Container(
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
            '综合行为评分',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // 圆形进度指示器
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: 0.84,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(NothingTheme.success),
                    ),
                    const Center(
                      child: Text(
                        '84',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: NothingTheme.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '优秀',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: NothingTheme.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '比上周提升了 +6%',
                      style: TextStyle(
                        fontSize: 14,
                        color: NothingTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 行为分析部分（与档案界面保持一致）
  Widget _buildBehaviorAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '行为分析',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F5233),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _behaviorAnalysis.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final behavior = _behaviorAnalysis[index];
            return _buildBehaviorCard(behavior);
          },
        ),
      ],
    );
  }

  // 行为分析卡片（与档案界面保持一致）
  Widget _buildBehaviorCard(Map<String, dynamic> behavior) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
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
                  color: behavior['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  behavior['icon'],
                  color: behavior['color'],
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
                        Text(
                          behavior['behavior'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2F5233),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: behavior['color'].withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            behavior['trend'],
                            style: TextStyle(
                              fontSize: 12,
                              color: behavior['color'],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '上周: ${behavior['lastWeekScore']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: NothingTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: behavior['lastWeekScore'] / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              behavior['color'].withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${behavior['score']}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: behavior['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            behavior['description'],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF90A4AE),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: behavior['suggestions'].map<Widget>((suggestion) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: behavior['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 12,
                    color: behavior['color'],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 改善建议部分
  Widget _buildImprovementSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '改善建议',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F5233),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _improvements.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final improvement = _improvements[index];
            return _buildImprovementCard(improvement);
          },
        ),
      ],
    );
  }

  // 改善建议卡片
  Widget _buildImprovementCard(Map<String, dynamic> improvement) {
    Color priorityColor = improvement['priority'] == 'high' 
        ? NothingTheme.error 
        : NothingTheme.warning;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  improvement['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F5233),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  improvement['description'],
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
    );
  }
}