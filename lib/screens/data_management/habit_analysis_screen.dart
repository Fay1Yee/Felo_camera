import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 分析时间范围
enum AnalysisTimeRange {
  week('本周', 7),
  month('本月', 30),
  quarter('本季度', 90),
  year('本年', 365);

  const AnalysisTimeRange(this.displayName, this.days);
  
  final String displayName;
  final int days;
}

/// 习惯类型
enum HabitType {
  feeding('进食习惯', Icons.restaurant, NothingTheme.warning),
  exercise('运动习惯', Icons.directions_run, NothingTheme.success),
  sleep('睡眠习惯', Icons.bedtime, NothingTheme.accentPrimary),
  health('健康习惯', Icons.favorite, NothingTheme.error),
  social('社交习惯', Icons.pets, NothingTheme.info);

  const HabitType(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 趋势方向
enum TrendDirection {
  up('上升', Icons.trending_up, NothingTheme.success),
  down('下降', Icons.trending_down, NothingTheme.error),
  stable('稳定', Icons.trending_flat, NothingTheme.info);

  const TrendDirection(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 习惯数据点
class HabitDataPoint {
  final DateTime date;
  final double value;
  final String? note;

  const HabitDataPoint({
    required this.date,
    required this.value,
    this.note,
  });
}

/// 习惯分析数据
class HabitAnalysis {
  final String id;
  final HabitType type;
  final String name;
  final List<HabitDataPoint> dataPoints;
  final double currentValue;
  final double averageValue;
  final double targetValue;
  final TrendDirection trend;
  final double trendPercentage;
  final int streakDays;
  final double consistency;
  final String unit;

  const HabitAnalysis({
    required this.id,
    required this.type,
    required this.name,
    required this.dataPoints,
    required this.currentValue,
    required this.averageValue,
    required this.targetValue,
    required this.trend,
    required this.trendPercentage,
    required this.streakDays,
    required this.consistency,
    required this.unit,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  
  bool get isOnTrack => currentValue >= targetValue * 0.8;
  
  Color get statusColor {
    if (isOnTrack) return NothingTheme.success;
    if (progress > 0.5) return NothingTheme.warning;
    return NothingTheme.error;
  }
}

/// 智能建议
class SmartSuggestion {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final int priority; // 1-5, 5最高
  final DateTime createdAt;
  final bool isRead;

  const SmartSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
  });

  SmartSuggestion copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    IconData? icon,
    Color? color,
    int? priority,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return SmartSuggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// 习惯分析界面
class HabitAnalysisScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const HabitAnalysisScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<HabitAnalysisScreen> createState() => _HabitAnalysisScreenState();
}

class _HabitAnalysisScreenState extends State<HabitAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  List<HabitAnalysis> _habitAnalyses = [];
  List<SmartSuggestion> _suggestions = [];
  AnalysisTimeRange _selectedTimeRange = AnalysisTimeRange.week;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _loadHabitAnalyses();
    _loadSuggestions();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadHabitAnalyses() {
    // 模拟习惯分析数据
    final now = DateTime.now();
    setState(() {
      _habitAnalyses = [
        HabitAnalysis(
          id: '1',
          type: HabitType.feeding,
          name: '进食规律',
          dataPoints: List.generate(7, (index) {
            return HabitDataPoint(
              date: now.subtract(Duration(days: 6 - index)),
              value: 2.0 + (index % 3) * 0.5,
            );
          }),
          currentValue: 2.5,
          averageValue: 2.2,
          targetValue: 3.0,
          trend: TrendDirection.up,
          trendPercentage: 12.5,
          streakDays: 5,
          consistency: 0.85,
          unit: '次/天',
        ),
        HabitAnalysis(
          id: '2',
          type: HabitType.exercise,
          name: '运动量',
          dataPoints: List.generate(7, (index) {
            return HabitDataPoint(
              date: now.subtract(Duration(days: 6 - index)),
              value: 30.0 + (index % 4) * 10.0,
            );
          }),
          currentValue: 45.0,
          averageValue: 38.0,
          targetValue: 60.0,
          trend: TrendDirection.up,
          trendPercentage: 18.4,
          streakDays: 3,
          consistency: 0.72,
          unit: '分钟/天',
        ),
        HabitAnalysis(
          id: '3',
          type: HabitType.sleep,
          name: '睡眠质量',
          dataPoints: List.generate(7, (index) {
            return HabitDataPoint(
              date: now.subtract(Duration(days: 6 - index)),
              value: 7.5 + (index % 2) * 0.5,
            );
          }),
          currentValue: 8.0,
          averageValue: 7.8,
          targetValue: 8.0,
          trend: TrendDirection.stable,
          trendPercentage: 2.6,
          streakDays: 7,
          consistency: 0.92,
          unit: '小时/天',
        ),
        HabitAnalysis(
          id: '4',
          type: HabitType.health,
          name: '健康指标',
          dataPoints: List.generate(7, (index) {
            return HabitDataPoint(
              date: now.subtract(Duration(days: 6 - index)),
              value: 85.0 + (index % 3) * 2.0,
            );
          }),
          currentValue: 89.0,
          averageValue: 87.0,
          targetValue: 90.0,
          trend: TrendDirection.up,
          trendPercentage: 4.6,
          streakDays: 4,
          consistency: 0.88,
          unit: '分',
        ),
        HabitAnalysis(
          id: '5',
          type: HabitType.social,
          name: '社交活动',
          dataPoints: List.generate(7, (index) {
            return HabitDataPoint(
              date: now.subtract(Duration(days: 6 - index)),
              value: 1.0 + (index % 2) * 0.5,
            );
          }),
          currentValue: 1.5,
          averageValue: 1.3,
          targetValue: 2.0,
          trend: TrendDirection.down,
          trendPercentage: -8.3,
          streakDays: 0,
          consistency: 0.65,
          unit: '次/天',
        ),
      ];
    });
  }

  void _loadSuggestions() {
    // 模拟智能建议数据
    setState(() {
      _suggestions = [
        SmartSuggestion(
          id: '1',
          title: '增加运动时间',
          description: '根据分析，您的宠物运动量略低于目标。建议每天增加15分钟的户外活动。',
          category: '运动建议',
          icon: Icons.directions_run,
          color: NothingTheme.success,
          priority: 5,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        SmartSuggestion(
          id: '2',
          title: '调整进食时间',
          description: '数据显示进食时间不够规律，建议固定在每天7点、12点、18点进食。',
          category: '饮食建议',
          icon: Icons.schedule,
          color: NothingTheme.warning,
          priority: 4,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        SmartSuggestion(
          id: '3',
          title: '保持良好睡眠',
          description: '睡眠质量很好！继续保持现有的作息规律，有助于宠物健康成长。',
          category: '睡眠建议',
          icon: Icons.thumb_up,
          color: NothingTheme.success,
          priority: 2,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        SmartSuggestion(
          id: '4',
          title: '增加社交机会',
          description: '社交活动有所减少，建议多带宠物到公园与其他动物互动。',
          category: '社交建议',
          icon: Icons.pets,
          color: NothingTheme.info,
          priority: 3,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        SmartSuggestion(
          id: '5',
          title: '定期健康检查',
          description: '健康指标良好，建议每月进行一次全面体检以预防疾病。',
          category: '健康建议',
          icon: Icons.medical_services,
          color: NothingTheme.accentPrimary,
          priority: 4,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        title: const Text(
          '习惯分析',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NothingTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<AnalysisTimeRange>(
            icon: const Icon(Icons.date_range, color: NothingTheme.textPrimary),
            onSelected: (range) {
              setState(() {
                _selectedTimeRange = range;
              });
              _loadHabitAnalyses(); // 重新加载数据
            },
            itemBuilder: (context) {
              return AnalysisTimeRange.values.map((range) {
                return PopupMenuItem<AnalysisTimeRange>(
                  value: range,
                  child: Row(
                    children: [
                      if (_selectedTimeRange == range)
                        Icon(
                          Icons.check,
                          color: NothingTheme.info,
                          size: 16,
                        )
                      else
                        const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Text(range.displayName),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 时间范围显示
            _buildTimeRangeHeader(),
            
            // 标签页
            _buildTabBar(),
            
            // 内容区域
            Expanded(
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: _buildTabContent(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: NothingTheme.surface,
          borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: NothingTheme.blackAlpha05,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.analytics,
              color: NothingTheme.info,
              size: 20,
            ),
            const SizedBox(width: 12),
            
            Text(
              '分析周期: ${_selectedTimeRange.displayName}',
              style: const TextStyle(
                color: NothingTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const Spacer(),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: NothingTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
              ),
              child: Text(
                '${_selectedTimeRange.days}天',
                style: TextStyle(
                  color: NothingTheme.info,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['习惯趋势', '数据可视化', '智能建议'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _currentTabIndex == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? NothingTheme.info : Colors.transparent,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : NothingTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildTrendsView();
      case 1:
        return _buildVisualizationView();
      case 2:
        return _buildSuggestionsView();
      default:
        return _buildTrendsView();
    }
  }

  Widget _buildTrendsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总体概览
          _buildOverviewCard(),
          const SizedBox(height: 16),
          
          // 习惯列表
          const Text(
            '习惯详情',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ..._habitAnalyses.map((habit) => _buildHabitCard(habit)),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    final totalHabits = _habitAnalyses.length;
    final improvingHabits = _habitAnalyses.where((h) => h.trend == TrendDirection.up).length;
    final onTrackHabits = _habitAnalyses.where((h) => h.isOnTrack).length;
    final avgConsistency = _habitAnalyses.map((h) => h.consistency).reduce((a, b) => a + b) / totalHabits;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
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
              Icon(
                Icons.trending_up,
                color: NothingTheme.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              
              const Text(
                '总体趋势',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  '改善中',
                  '$improvingHabits/$totalHabits',
                  Icons.trending_up,
                  NothingTheme.success,
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  '达标率',
                  '${(onTrackHabits / totalHabits * 100).toStringAsFixed(0)}%',
                  Icons.check_circle,
                  NothingTheme.info,
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  '一致性',
                  '${(avgConsistency * 100).toStringAsFixed(0)}%',
                  Icons.analytics,
                  NothingTheme.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: NothingTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitCard(HabitAnalysis habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
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
                  color: habit.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Icon(
                  habit.type.icon,
                  color: habit.type.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.type.displayName,
                      style: TextStyle(
                        color: habit.type.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: habit.trend.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      habit.trend.icon,
                      color: habit.trend.color,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.trendPercentage > 0 ? '+' : ''}${habit.trendPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: habit.trend.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 当前值和目标
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前值',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${habit.currentValue.toStringAsFixed(1)} ${habit.unit}',
                      style: TextStyle(
                        color: habit.statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '目标值',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${habit.targetValue.toStringAsFixed(1)} ${habit.unit}',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '连续天数',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${habit.streakDays}天',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 进度条
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '完成度',
                    style: TextStyle(
                      color: NothingTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(habit.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: habit.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              LinearProgressIndicator(
                value: habit.progress,
                backgroundColor: NothingTheme.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(habit.statusColor),
                minHeight: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '数据可视化',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // 简化的图表展示
          ..._habitAnalyses.map((habit) => _buildChartCard(habit)),
        ],
      ),
    );
  }

  Widget _buildChartCard(HabitAnalysis habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
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
              Icon(
                habit.type.icon,
                color: habit.type.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              
              Text(
                habit.name,
                style: const TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const Spacer(),
              
              Text(
                '${_selectedTimeRange.displayName}趋势',
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 简化的折线图表示
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: habit.type.color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            ),
            child: CustomPaint(
              painter: SimpleLinePainter(
                dataPoints: habit.dataPoints,
                color: habit.type.color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 数据统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildChartStat('最高', _getMaxValue(habit.dataPoints), habit.unit),
              _buildChartStat('最低', _getMinValue(habit.dataPoints), habit.unit),
              _buildChartStat('平均', habit.averageValue, habit.unit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartStat(String label, double value, String unit) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: const TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: NothingTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsView() {
    // 按优先级排序
    final sortedSuggestions = List<SmartSuggestion>.from(_suggestions)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '智能建议',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NothingTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Text(
                  '${_suggestions.where((s) => !s.isRead).length}条新建议',
                  style: TextStyle(
                    color: NothingTheme.info,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...sortedSuggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(SmartSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: suggestion.isRead 
            ? null 
            : Border.all(color: suggestion.color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: suggestion.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Icon(
                  suggestion.icon,
                  color: suggestion.color,
                  size: 18,
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
                            suggestion.title,
                            style: const TextStyle(
                              color: NothingTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        if (!suggestion.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: suggestion.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: suggestion.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                          ),
                          child: Text(
                            suggestion.category,
                            style: TextStyle(
                              color: suggestion.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // 优先级指示器
                        Row(
                          children: List.generate(5, (index) {
                            return Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: index < suggestion.priority 
                                    ? suggestion.color 
                                    : NothingTheme.gray300,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
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
            suggestion.description,
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatSuggestionTime(suggestion.createdAt),
                style: TextStyle(
                  color: NothingTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
              
              if (!suggestion.isRead)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final index = _suggestions.indexOf(suggestion);
                      _suggestions[index] = suggestion.copyWith(isRead: true);
                    });
                  },
                  child: Text(
                    '标记已读',
                    style: TextStyle(
                      color: suggestion.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  double _getMaxValue(List<HabitDataPoint> dataPoints) {
    return dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
  }

  double _getMinValue(List<HabitDataPoint> dataPoints) {
    return dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
  }

  String _formatSuggestionTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }
}

/// 简单的折线图绘制器
class SimpleLinePainter extends CustomPainter {
  final List<HabitDataPoint> dataPoints;
  final Color color;

  SimpleLinePainter({
    required this.dataPoints,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // 计算数据范围
    final minValue = dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxValue = dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;
    
    // 绘制折线
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final normalizedValue = valueRange > 0 ? (dataPoints[i].value - minValue) / valueRange : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.8) - (size.height * 0.1);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // 绘制数据点
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final normalizedValue = valueRange > 0 ? (dataPoints[i].value - minValue) / valueRange : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.8) - (size.height * 0.1);
      
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}