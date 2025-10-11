import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/pet_profile.dart';

/// 数据类型
enum DataType {
  activity('活动数据', Icons.directions_run, '运动和活动统计'),
  health('健康数据', Icons.favorite, '健康指标监测'),
  behavior('行为数据', Icons.psychology, '行为模式分析'),
  environment('环境数据', Icons.thermostat, '环境参数监控'),
  feeding('喂食数据', Icons.restaurant, '饮食记录统计'),
  sleep('睡眠数据', Icons.bedtime, '睡眠质量分析');

  const DataType(this.displayName, this.icon, this.description);
  
  final String displayName;
  final IconData icon;
  final String description;
}

/// 图表类型
enum ChartType {
  line('折线图', Icons.show_chart),
  bar('柱状图', Icons.bar_chart),
  pie('饼图', Icons.pie_chart),
  area('面积图', Icons.area_chart),
  scatter('散点图', Icons.scatter_plot),
  radar('雷达图', Icons.radar);

  const ChartType(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 时间范围
enum TimeRange {
  today('今天', 1),
  week('本周', 7),
  month('本月', 30),
  quarter('本季度', 90),
  year('本年', 365);

  const TimeRange(this.displayName, this.days);
  
  final String displayName;
  final int days;
}

/// 数据点
class DataPoint {
  final DateTime timestamp;
  final double value;
  final String label;
  final Map<String, dynamic> metadata;

  const DataPoint({
    required this.timestamp,
    required this.value,
    required this.label,
    this.metadata = const {},
  });
}

/// 数据集
class DataSet {
  final String id;
  final String name;
  final DataType type;
  final List<DataPoint> points;
  final Color color;
  final String unit;

  const DataSet({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    required this.color,
    required this.unit,
  });

  static List<DataSet> getMockDataSets() {
    final now = DateTime.now();
    
    return [
      DataSet(
        id: 'activity_steps',
        name: '每日步数',
        type: DataType.activity,
        color: Colors.blue,
        unit: '步',
        points: List.generate(30, (index) {
          return DataPoint(
            timestamp: now.subtract(Duration(days: 29 - index)),
            value: 2000 + (index * 100) + (index % 7 * 500),
            label: '步数',
          );
        }),
      ),
      DataSet(
        id: 'health_heart_rate',
        name: '心率',
        type: DataType.health,
        color: Colors.red,
        unit: 'bpm',
        points: List.generate(30, (index) {
          return DataPoint(
            timestamp: now.subtract(Duration(days: 29 - index)),
            value: 80 + (index % 10) * 2,
            label: '心率',
          );
        }),
      ),
      DataSet(
        id: 'behavior_play_time',
        name: '玩耍时间',
        type: DataType.behavior,
        color: Colors.green,
        unit: '分钟',
        points: List.generate(30, (index) {
          return DataPoint(
            timestamp: now.subtract(Duration(days: 29 - index)),
            value: 30 + (index % 5) * 10,
            label: '玩耍',
          );
        }),
      ),
      DataSet(
        id: 'environment_temperature',
        name: '环境温度',
        type: DataType.environment,
        color: Colors.orange,
        unit: '°C',
        points: List.generate(30, (index) {
          return DataPoint(
            timestamp: now.subtract(Duration(days: 29 - index)),
            value: 22 + (index % 8),
            label: '温度',
          );
        }),
      ),
      DataSet(
        id: 'feeding_amount',
        name: '进食量',
        type: DataType.feeding,
        color: Colors.purple,
        unit: 'g',
        points: List.generate(30, (index) {
          return DataPoint(
            timestamp: now.subtract(Duration(days: 29 - index)),
            value: 150 + (index % 6) * 10,
            label: '进食',
          );
        }),
      ),
      DataSet(
        id: 'sleep_duration',
        name: '睡眠时长',
        type: DataType.sleep,
        color: Colors.indigo,
        unit: '小时',
        points: List.generate(30, (index) {
          return DataPoint(
            timestamp: now.subtract(Duration(days: 29 - index)),
            value: 8 + (index % 4),
            label: '睡眠',
          );
        }),
      ),
    ];
  }
}

/// 统计摘要
class StatsSummary {
  final String title;
  final String value;
  final String unit;
  final String trend;
  final double trendValue;
  final Color color;
  final IconData icon;

  const StatsSummary({
    required this.title,
    required this.value,
    required this.unit,
    required this.trend,
    required this.trendValue,
    required this.color,
    required this.icon,
  });
}

/// 增强版数据可视化组件
class EnhancedDataVisualization extends StatefulWidget {
  final ScenarioMode currentScenario;
  final Function(DataType, ChartType, TimeRange)? onViewChange;

  const EnhancedDataVisualization({
    super.key,
    required this.currentScenario,
    this.onViewChange,
  });

  @override
  State<EnhancedDataVisualization> createState() => _EnhancedDataVisualizationState();
}

class _EnhancedDataVisualizationState extends State<EnhancedDataVisualization>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<DataSet> _dataSets = [];
  DataType _selectedDataType = DataType.activity;
  ChartType _selectedChartType = ChartType.line;
  TimeRange _selectedTimeRange = TimeRange.week;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _dataSets = DataSet.getMockDataSets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: NothingTheme.blackAlpha10,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildControls(),
                  _buildStatsOverview(),
                  _buildChart(),
                  _buildInsights(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: NothingTheme.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.analytics,
              color: NothingTheme.brandPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '数据分析',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeLg,
                    fontWeight: NothingTheme.fontWeightSemiBold,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                Text(
                  '${_selectedDataType.displayName} • ${_selectedTimeRange.displayName}',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeSm,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return GestureDetector(
      onTap: _exportData,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: NothingTheme.brandSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: NothingTheme.brandSecondary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download,
              size: 14,
              color: NothingTheme.brandSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '导出',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeXs,
                fontWeight: NothingTheme.fontWeightMedium,
                color: NothingTheme.brandSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 数据类型选择
          Text(
            '数据类型',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightSemiBold,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingSmall),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DataType.values.map((type) {
                final isSelected = type == _selectedDataType;
                return Padding(
                  padding: const EdgeInsets.only(right: NothingTheme.spacingSmall),
                  child: GestureDetector(
                    onTap: () => _selectDataType(type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? NothingTheme.brandPrimary
                            : NothingTheme.surfaceTertiary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            size: 16,
                            color: isSelected
                                ? NothingTheme.surface
                                : NothingTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.displayName,
                            style: TextStyle(
                              fontSize: NothingTheme.fontSizeSm,
                              fontWeight: NothingTheme.fontWeightMedium,
                              color: isSelected
                                  ? NothingTheme.surface
                                  : NothingTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 图表类型和时间范围
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '图表类型',
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeSm,
                        fontWeight: NothingTheme.fontWeightMedium,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildChartTypeSelector(),
                  ],
                ),
              ),
              const SizedBox(width: NothingTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '时间范围',
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeSm,
                        fontWeight: NothingTheme.fontWeightMedium,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTimeRangeSelector(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NothingTheme.surfaceTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChartType>(
          value: _selectedChartType,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: NothingTheme.textSecondary,
            size: 16,
          ),
          style: TextStyle(
            fontSize: NothingTheme.fontSizeSm,
            color: NothingTheme.textPrimary,
          ),
          onChanged: (ChartType? newValue) {
            if (newValue != null) {
              _selectChartType(newValue);
            }
          },
          items: ChartType.values.map<DropdownMenuItem<ChartType>>((ChartType type) {
            return DropdownMenuItem<ChartType>(
              value: type,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    size: 16,
                    color: NothingTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(type.displayName),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NothingTheme.surfaceTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimeRange>(
          value: _selectedTimeRange,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: NothingTheme.textSecondary,
            size: 16,
          ),
          style: TextStyle(
            fontSize: NothingTheme.fontSizeSm,
            color: NothingTheme.textPrimary,
          ),
          onChanged: (TimeRange? newValue) {
            if (newValue != null) {
              _selectTimeRange(newValue);
            }
          },
          items: TimeRange.values.map<DropdownMenuItem<TimeRange>>((TimeRange range) {
            return DropdownMenuItem<TimeRange>(
              value: range,
              child: Text(range.displayName),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final stats = _getStatsForCurrentSelection();
    
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数据概览',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightSemiBold,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: NothingTheme.spacingMedium,
            crossAxisSpacing: NothingTheme.spacingMedium,
            childAspectRatio: 2.2,
            children: stats.map((stat) => _buildStatCard(stat)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(StatsSummary stat) {
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      decoration: BoxDecoration(
        color: stat.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(
          color: stat.color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stat.icon,
                color: stat.color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  stat.title,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeXs,
                    color: NothingTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeLg,
                  fontWeight: NothingTheme.fontWeightBold,
                  color: stat.color,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                stat.unit,
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeSm,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                stat.trendValue >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 12,
                color: stat.trendValue >= 0 ? NothingTheme.success : NothingTheme.error,
              ),
              const SizedBox(width: 2),
              Text(
                stat.trend,
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeXs,
                  color: stat.trendValue >= 0 ? NothingTheme.success : NothingTheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedChartType.displayName} - ${_selectedDataType.displayName}',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightSemiBold,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: NothingTheme.surfaceTertiary,
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
            ),
            child: _buildChartContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent() {
    // 这里应该集成真实的图表库，如 fl_chart
    // 现在使用模拟的图表展示
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedChartType.icon,
            size: 48,
            color: NothingTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: NothingTheme.spacingSmall),
          Text(
            '${_selectedChartType.displayName}图表',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '显示${_selectedDataType.displayName}的${_selectedTimeRange.displayName}数据',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeSm,
              color: NothingTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    final insights = _getInsightsForCurrentSelection();
    
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '智能洞察',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightSemiBold,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          ...insights.map((insight) => _buildInsightCard(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: NothingTheme.spacingMedium),
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      decoration: BoxDecoration(
        color: insight['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(
          color: insight['color'].withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: insight['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              insight['icon'],
              size: 16,
              color: insight['color'],
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'],
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeSm,
                    fontWeight: NothingTheme.fontWeightSemiBold,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                Text(
                  insight['description'],
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeXs,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (insight['actionable'] == true)
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: NothingTheme.textSecondary,
            ),
        ],
      ),
    );
  }

  void _selectDataType(DataType type) {
    setState(() {
      _selectedDataType = type;
    });
    widget.onViewChange?.call(type, _selectedChartType, _selectedTimeRange);
  }

  void _selectChartType(ChartType type) {
    setState(() {
      _selectedChartType = type;
    });
    widget.onViewChange?.call(_selectedDataType, type, _selectedTimeRange);
  }

  void _selectTimeRange(TimeRange range) {
    setState(() {
      _selectedTimeRange = range;
    });
    widget.onViewChange?.call(_selectedDataType, _selectedChartType, range);
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('数据导出功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<StatsSummary> _getStatsForCurrentSelection() {
    switch (_selectedDataType) {
      case DataType.activity:
        return [
          StatsSummary(
            title: '平均步数',
            value: '3,245',
            unit: '步',
            trend: '+12%',
            trendValue: 12,
            color: Colors.blue,
            icon: Icons.directions_walk,
          ),
          StatsSummary(
            title: '活跃时间',
            value: '4.2',
            unit: '小时',
            trend: '+8%',
            trendValue: 8,
            color: Colors.green,
            icon: Icons.timer,
          ),
          StatsSummary(
            title: '消耗卡路里',
            value: '156',
            unit: 'kcal',
            trend: '+15%',
            trendValue: 15,
            color: Colors.orange,
            icon: Icons.local_fire_department,
          ),
          StatsSummary(
            title: '运动强度',
            value: '中等',
            unit: '',
            trend: '稳定',
            trendValue: 0,
            color: Colors.purple,
            icon: Icons.fitness_center,
          ),
        ];
      case DataType.health:
        return [
          StatsSummary(
            title: '平均心率',
            value: '85',
            unit: 'bpm',
            trend: '+2%',
            trendValue: 2,
            color: Colors.red,
            icon: Icons.favorite,
          ),
          StatsSummary(
            title: '体温',
            value: '38.2',
            unit: '°C',
            trend: '正常',
            trendValue: 0,
            color: Colors.blue,
            icon: Icons.thermostat,
          ),
          StatsSummary(
            title: '健康评分',
            value: '92',
            unit: '分',
            trend: '+5%',
            trendValue: 5,
            color: Colors.green,
            icon: Icons.health_and_safety,
          ),
          StatsSummary(
            title: '异常次数',
            value: '0',
            unit: '次',
            trend: '-100%',
            trendValue: -100,
            color: Colors.orange,
            icon: Icons.warning,
          ),
        ];
      default:
        return [
          StatsSummary(
            title: '数据总量',
            value: '1,234',
            unit: '条',
            trend: '+10%',
            trendValue: 10,
            color: Colors.blue,
            icon: Icons.data_usage,
          ),
          StatsSummary(
            title: '平均值',
            value: '45.6',
            unit: '',
            trend: '+5%',
            trendValue: 5,
            color: Colors.green,
            icon: Icons.analytics,
          ),
        ];
    }
  }

  List<Map<String, dynamic>> _getInsightsForCurrentSelection() {
    switch (_selectedDataType) {
      case DataType.activity:
        return [
          {
            'title': '活动量增加',
            'description': '本周活动量比上周增加了12%，保持良好的运动习惯',
            'icon': Icons.trending_up,
            'color': Colors.green,
            'actionable': false,
          },
          {
            'title': '建议增加户外活动',
            'description': '室内活动较多，建议增加户外散步时间',
            'icon': Icons.wb_sunny,
            'color': Colors.orange,
            'actionable': true,
          },
        ];
      case DataType.health:
        return [
          {
            'title': '健康状况良好',
            'description': '各项健康指标均在正常范围内，继续保持',
            'icon': Icons.check_circle,
            'color': Colors.green,
            'actionable': false,
          },
          {
            'title': '定期体检提醒',
            'description': '距离上次体检已过3个月，建议安排健康检查',
            'icon': Icons.schedule,
            'color': Colors.blue,
            'actionable': true,
          },
        ];
      default:
        return [
          {
            'title': '数据趋势稳定',
            'description': '整体数据表现稳定，无异常波动',
            'icon': Icons.timeline,
            'color': Colors.blue,
            'actionable': false,
          },
        ];
    }
  }
}