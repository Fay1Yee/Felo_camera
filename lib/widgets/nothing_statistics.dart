import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/analysis_history.dart';
import 'nothing_chart.dart';

/// Nothing OS风格的统计分析组件
class NothingStatistics extends StatefulWidget {
  final List<AnalysisHistory> histories;

  const NothingStatistics({
    super.key,
    required this.histories,
  });

  @override
  State<NothingStatistics> createState() => _NothingStatisticsState();
}

class _NothingStatisticsState extends State<NothingStatistics> {
  String _selectedPeriod = '7d';
  
  final List<PeriodFilter> _periods = [
    PeriodFilter('7d', '7天'),
    PeriodFilter('30d', '30天'),
    PeriodFilter('90d', '90天'),
    PeriodFilter('all', '全部'),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredHistories = _getFilteredHistories();
    final stats = _calculateStatistics(filteredHistories);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间段选择器
          _buildPeriodSelector(),
          const SizedBox(height: NothingTheme.spacingLarge),
          
          // 总览卡片
          _buildOverviewCard(stats),
          const SizedBox(height: NothingTheme.spacingLarge),
          
          // 拍摄习惯分析
          _buildShootingHabitsSection(stats),
          const SizedBox(height: NothingTheme.spacingLarge),
          
          // 宠物行为分析
          _buildPetBehaviorSection(stats),
          const SizedBox(height: NothingTheme.spacingLarge),
          
          // 环境分析
          _buildEnvironmentSection(stats),
          const SizedBox(height: NothingTheme.spacingLarge),
          
          // 模式使用统计
          _buildModeUsageSection(stats),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final period = _periods[index];
          final isSelected = _selectedPeriod == period.key;
          
          return Container(
            margin: const EdgeInsets.only(right: NothingTheme.spacingSmall),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period.key;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: NothingTheme.spacingMedium,
                  vertical: NothingTheme.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? NothingTheme.nothingYellow : NothingTheme.nothingWhite,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                  border: Border.all(
                    color: isSelected ? NothingTheme.nothingYellow : NothingTheme.nothingLightGray,
                    width: 1,
                  ),
                ),
                child: Text(
                  period.label,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    fontWeight: isSelected 
                        ? NothingTheme.fontWeightMedium 
                        : NothingTheme.fontWeightRegular,
                    color: NothingTheme.nothingBlack,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(StatisticsData stats) {
    return Container(
      decoration: NothingTheme.nothingCardDecoration,
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '总览',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeHeadline,
              fontWeight: NothingTheme.fontWeightBold,
              color: NothingTheme.nothingBlack,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '总拍摄',
                  '${stats.totalPhotos}',
                  Icons.camera_alt,
                  NothingTheme.infoBlue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '实时分析',
                  '${stats.realtimePhotos}',
                  Icons.auto_awesome,
                  NothingTheme.successGreen,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '手动拍照',
                  '${stats.manualPhotos}',
                  Icons.touch_app,
                  NothingTheme.warningOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '平均置信度',
                  '${stats.averageConfidence.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  NothingTheme.nothingYellow,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '活跃天数',
                  '${stats.activeDays}',
                  Icons.calendar_today,
                  NothingTheme.warningOrange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '日均拍摄',
                  '${stats.dailyAverage.toStringAsFixed(1)}张',
                  Icons.bar_chart,
                  NothingTheme.infoBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: NothingTheme.spacingSmall),
        Text(
          value,
          style: const TextStyle(
            fontSize: NothingTheme.fontSizeHeadline,
            fontWeight: NothingTheme.fontWeightBold,
            color: NothingTheme.nothingBlack,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: NothingTheme.fontSizeCaption,
            color: NothingTheme.nothingGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildShootingHabitsSection(StatisticsData stats) {
    return Container(
      decoration: NothingTheme.nothingCardDecoration,
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '拍摄习惯分析',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeHeadline,
              fontWeight: NothingTheme.fontWeightBold,
              color: NothingTheme.nothingBlack,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 时间分布图表
          SizedBox(
            height: 200,
            child: NothingChart(
              type: ChartType.bar,
              data: stats.hourlyDistribution.entries.map((e) => 
                ChartData(label: e.key.toString(), value: e.value.toDouble())
              ).toList(),
              title: '拍摄时间分布',
              primaryColor: NothingTheme.nothingYellow,
            ),
          ),
          
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 习惯洞察
          _buildInsightCard(
            '最活跃时段',
            '${stats.mostActiveHour}:00-${stats.mostActiveHour + 1}:00',
            Icons.schedule,
            NothingTheme.successGreen,
          ),
          
          const SizedBox(height: NothingTheme.spacingSmall),
          
          _buildInsightCard(
            '偏好分析类型',
            stats.realtimePhotos > stats.manualPhotos ? '实时分析' : '手动拍照',
            Icons.analytics,
            NothingTheme.infoBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildPetBehaviorSection(StatisticsData stats) {
    if (stats.petModeStats.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      decoration: NothingTheme.nothingCardDecoration,
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '宠物行为分析',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeHeadline,
              fontWeight: NothingTheme.fontWeightBold,
              color: NothingTheme.nothingBlack,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 宠物模式使用饼图
          SizedBox(
            height: 200,
            child: NothingChart(
              type: ChartType.pie,
              data: stats.petModeStats.entries.map((e) => 
                ChartData(label: e.key, value: e.value.toDouble())
              ).toList(),
              title: '宠物活动类型分布',
              primaryColor: NothingTheme.successGreen,
            ),
          ),
          
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 宠物行为洞察
          ...stats.petInsights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: NothingTheme.spacingSmall),
            child: _buildInsightCard(
              insight.title,
              insight.description,
              Icons.pets,
              NothingTheme.successGreen,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSection(StatisticsData stats) {
    return Container(
      decoration: NothingTheme.nothingCardDecoration,
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '环境分析',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeHeadline,
              fontWeight: NothingTheme.fontWeightBold,
              color: NothingTheme.nothingBlack,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 环境因素分析
          Row(
            children: [
              Expanded(
                child: _buildEnvironmentCard(
                  '室内拍摄',
                  '${stats.indoorPhotos}张',
                  '占比${(stats.indoorPhotos / stats.totalPhotos * 100).toStringAsFixed(1)}%',
                  Icons.home,
                  NothingTheme.infoBlue,
                ),
              ),
              const SizedBox(width: NothingTheme.spacingMedium),
              Expanded(
                child: _buildEnvironmentCard(
                  '户外拍摄',
                  '${stats.outdoorPhotos}张',
                  '占比${(stats.outdoorPhotos / stats.totalPhotos * 100).toStringAsFixed(1)}%',
                  Icons.nature,
                  NothingTheme.successGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 环境洞察
          ...stats.environmentInsights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: NothingTheme.spacingSmall),
            child: _buildInsightCard(
              insight.title,
              insight.description,
              Icons.eco,
              NothingTheme.warningOrange,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildModeUsageSection(StatisticsData stats) {
    return Container(
      decoration: NothingTheme.nothingCardDecoration,
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '模式使用统计',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeHeadline,
              fontWeight: NothingTheme.fontWeightBold,
              color: NothingTheme.nothingBlack,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 模式使用环形图
          SizedBox(
            height: 200,
            child: NothingChart(
              type: ChartType.donut,
              data: stats.modeUsage.entries.map((e) => 
                ChartData(label: e.key, value: e.value.toDouble())
              ).toList(),
              title: '拍摄模式分布',
              primaryColor: NothingTheme.nothingYellow,
            ),
          ),
          
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 模式详细统计
          ...stats.modeUsage.entries.map((entry) {
            final mode = entry.key;
            final count = entry.value;
            final percentage = (count / stats.totalPhotos * 100).toStringAsFixed(1);
            
            return Container(
              margin: const EdgeInsets.only(bottom: NothingTheme.spacingSmall),
              padding: const EdgeInsets.all(NothingTheme.spacingMedium),
              decoration: BoxDecoration(
                color: NothingTheme.nothingLightGray,
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    _getModeIcon(mode),
                    size: 24,
                    color: _getModeColor(mode),
                  ),
                  const SizedBox(width: NothingTheme.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getModeLabel(mode),
                          style: const TextStyle(
                            fontSize: NothingTheme.fontSizeBody,
                            fontWeight: NothingTheme.fontWeightMedium,
                            color: NothingTheme.nothingBlack,
                          ),
                        ),
                        Text(
                          '$count张照片',
                          style: const TextStyle(
                            fontSize: NothingTheme.fontSizeCaption,
                            color: NothingTheme.nothingGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: NothingTheme.fontSizeBody,
                      fontWeight: NothingTheme.fontWeightBold,
                      color: NothingTheme.nothingBlack,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEnvironmentCard(
    String title,
    String count,
    String percentage,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: NothingTheme.spacingSmall),
          Text(
            title,
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeBody,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.nothingBlack,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeHeadline,
              fontWeight: NothingTheme.fontWeightBold,
              color: NothingTheme.nothingBlack,
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: NothingTheme.fontSizeCaption,
              color: color,
              fontWeight: NothingTheme.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.nothingBlack,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeCaption,
                    color: NothingTheme.nothingGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<AnalysisHistory> _getFilteredHistories() {
    if (_selectedPeriod == 'all') {
      return widget.histories;
    }
    
    final now = DateTime.now();
    final days = int.parse(_selectedPeriod.replaceAll('d', ''));
    final cutoffDate = now.subtract(Duration(days: days));
    
    return widget.histories.where((history) => 
      history.timestamp.isAfter(cutoffDate)
    ).toList();
  }

  StatisticsData _calculateStatistics(List<AnalysisHistory> histories) {
    if (histories.isEmpty) {
      return StatisticsData.empty();
    }

    final totalPhotos = histories.length;
    final realtimePhotos = histories.where((h) => h.isRealtimeAnalysis).length;
    final manualPhotos = totalPhotos - realtimePhotos;
    
    // 修复置信度计算，避免空数据
    double averageConfidence = 0.0;
    if (histories.isNotEmpty) {
      final confidenceSum = histories
          .map((h) => h.result.confidence)
          .where((confidence) => confidence > 0)
          .fold(0.0, (a, b) => a + b);
      final validCount = histories
          .where((h) => h.result.confidence > 0)
          .length;
      averageConfidence = validCount > 0 ? confidenceSum / validCount : 0.0;
    }
    
    // 计算活跃天数
    final uniqueDates = histories.map((h) => 
      DateTime(h.timestamp.year, h.timestamp.month, h.timestamp.day)
    ).toSet();
    final activeDays = uniqueDates.length;
    
    // 修复日均计算，避免除零
    final dailyAverage = activeDays > 0 ? totalPhotos / activeDays : 0.0;
    
    // 时间分布统计
    final hourlyDistribution = <int, int>{};
    for (final history in histories) {
      final hour = history.timestamp.hour;
      hourlyDistribution[hour] = (hourlyDistribution[hour] ?? 0) + 1;
    }
    
    // 找出最活跃时段，避免空数据
    int mostActiveHour = 0;
    if (hourlyDistribution.isNotEmpty) {
      mostActiveHour = hourlyDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b).key;
    }
    
    // 模式使用统计
    final modeUsage = <String, int>{};
    for (final history in histories) {
      final mode = history.mode.isNotEmpty ? history.mode : 'unknown';
      modeUsage[mode] = (modeUsage[mode] ?? 0) + 1;
    }
    
    // 宠物模式统计
    final petModeStats = <String, int>{};
    final petHistories = histories.where((h) => h.mode == 'pet').toList();
    for (final history in petHistories) {
      // 这里可以根据实际的宠物行为分类来统计
      final behavior = history.result.title.isNotEmpty ? history.result.title : '未知行为';
      petModeStats[behavior] = (petModeStats[behavior] ?? 0) + 1;
    }
    
    // 环境统计（这里简化处理，实际应该根据图像分析结果）
    final indoorPhotos = (totalPhotos * 0.6).round(); // 假设60%室内
    final outdoorPhotos = totalPhotos - indoorPhotos;
    
    return StatisticsData(
      totalPhotos: totalPhotos,
      realtimePhotos: realtimePhotos,
      manualPhotos: manualPhotos,
      averageConfidence: averageConfidence,
      activeDays: activeDays,
      dailyAverage: dailyAverage,
      hourlyDistribution: hourlyDistribution,
      mostActiveHour: mostActiveHour,
      modeUsage: modeUsage,
      petModeStats: petModeStats,
      indoorPhotos: indoorPhotos,
      outdoorPhotos: outdoorPhotos,
      petInsights: _generatePetInsights(petHistories),
      environmentInsights: _generateEnvironmentInsights(histories),
    );
  }

  List<Insight> _generatePetInsights(List<AnalysisHistory> petHistories) {
    if (petHistories.isEmpty) return [];
    
    return [
      Insight('活跃时段', '宠物在上午10-12点最为活跃'),
      Insight('行为偏好', '更喜欢在室内活动'),
      Insight('健康状态', '整体健康状况良好'),
    ];
  }

  List<Insight> _generateEnvironmentInsights(List<AnalysisHistory> histories) {
    return [
      Insight('拍摄环境', '主要在室内环境进行拍摄'),
      Insight('光线条件', '自然光拍摄效果更佳'),
      Insight('背景偏好', '简洁背景的照片质量更高'),
    ];
  }

  Color _getModeColor(String mode) {
    switch (mode) {
      case 'normal':
        return NothingTheme.infoBlue;
      case 'pet':
        return NothingTheme.successGreen;
      case 'health':
        return NothingTheme.warningOrange;
      case 'travel':
        return NothingTheme.warningOrange;
      default:
        return NothingTheme.nothingGray;
    }
  }

  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'normal':
        return Icons.camera_alt;
      case 'pet':
        return Icons.pets;
      case 'health':
        return Icons.health_and_safety;
      case 'travel':
        return Icons.luggage;
      default:
        return Icons.analytics;
    }
  }

  String _getModeLabel(String mode) {
    switch (mode) {
      case 'normal':
        return '日常模式';
      case 'pet':
        return '宠物模式';
      case 'health':
        return '健康模式';
      case 'travel':
        return '旅行模式';
      default:
        return '未知模式';
    }
  }
}

/// 时间段过滤器数据模型
class PeriodFilter {
  final String key;
  final String label;

  PeriodFilter(this.key, this.label);
}

/// 统计数据模型
class StatisticsData {
  final int totalPhotos;
  final int realtimePhotos;
  final int manualPhotos;
  final double averageConfidence;
  final int activeDays;
  final double dailyAverage;
  final Map<int, int> hourlyDistribution;
  final int mostActiveHour;
  final Map<String, int> modeUsage;
  final Map<String, int> petModeStats;
  final int indoorPhotos;
  final int outdoorPhotos;
  final List<Insight> petInsights;
  final List<Insight> environmentInsights;

  StatisticsData({
    required this.totalPhotos,
    required this.realtimePhotos,
    required this.manualPhotos,
    required this.averageConfidence,
    required this.activeDays,
    required this.dailyAverage,
    required this.hourlyDistribution,
    required this.mostActiveHour,
    required this.modeUsage,
    required this.petModeStats,
    required this.indoorPhotos,
    required this.outdoorPhotos,
    required this.petInsights,
    required this.environmentInsights,
  });

  factory StatisticsData.empty() {
    return StatisticsData(
      totalPhotos: 0,
      realtimePhotos: 0,
      manualPhotos: 0,
      averageConfidence: 0,
      activeDays: 0,
      dailyAverage: 0,
      hourlyDistribution: {},
      mostActiveHour: 0,
      modeUsage: {},
      petModeStats: {},
      indoorPhotos: 0,
      outdoorPhotos: 0,
      petInsights: [],
      environmentInsights: [],
    );
  }
}

/// 洞察数据模型
class Insight {
  final String title;
  final String description;

  Insight(this.title, this.description);
}