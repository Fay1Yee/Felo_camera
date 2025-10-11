import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/behavior_analytics.dart';
import '../models/analysis_history.dart';
import '../services/history_notifier.dart';
import '../config/nothing_theme.dart';

class BehaviorAnalyticsWidget extends StatefulWidget {
  final List<AnalysisHistory> histories;

  const BehaviorAnalyticsWidget({
    super.key,
    required this.histories,
  });

  @override
  State<BehaviorAnalyticsWidget> createState() => _BehaviorAnalyticsWidgetState();
}

class _BehaviorAnalyticsWidgetState extends State<BehaviorAnalyticsWidget> {
  BehaviorAnalytics? _analytics;
  String _selectedTimeRange = '7天';
  bool _isLoading = false;
  String? _errorMessage;
  List<AnalysisHistory> _currentHistories = [];
  StreamSubscription<HistoryEvent>? _historySubscription;

  @override
  void initState() {
    super.initState();
    _currentHistories = List.from(widget.histories);
    _setupHistoryListener();
    _updateAnalytics();
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(BehaviorAnalyticsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.histories != widget.histories) {
      _currentHistories = List.from(widget.histories);
      _updateAnalytics();
    }
  }

  /// 设置历史记录变化监听器
  void _setupHistoryListener() {
    _historySubscription = HistoryNotifier.instance.historyStream.listen((event) {
      if (mounted) {
        setState(() {
          switch (event.type) {
            case HistoryEventType.added:
              if (event.history != null) {
                _currentHistories.removeWhere((h) => h.id == event.history!.id);
                _currentHistories.insert(0, event.history!);
              }
              break;
            case HistoryEventType.deleted:
              if (event.historyId != null) {
                _currentHistories.removeWhere((h) => h.id == event.historyId);
              }
              break;
            case HistoryEventType.cleared:
              _currentHistories.clear();
              break;
            case HistoryEventType.updated:
              if (event.history != null) {
                final index = _currentHistories.indexWhere((h) => h.id == event.history!.id);
                if (index != -1) {
                  _currentHistories[index] = event.history!;
                }
              }
              break;
          }
        });
        // 历史记录变化后重新计算分析结果
        _updateAnalytics();
      }
    });
  }

  Future<void> _updateAnalytics() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final filteredHistories = _getFilteredHistories();
      
      // 使用compute在隔离线程中计算分析结果，避免阻塞UI
      final analytics = await compute(_computeAnalytics, filteredHistories);
      
      if (mounted) {
        setState(() {
          _analytics = analytics;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 行为分析计算失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '分析数据时出现错误，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  // 静态方法，用于在隔离线程中计算分析结果
  static BehaviorAnalytics _computeAnalytics(List<AnalysisHistory> histories) {
    return BehaviorAnalytics.fromHistories(histories);
  }

  List<AnalysisHistory> _getFilteredHistories() {
    final now = DateTime.now();
    Duration duration;
    
    switch (_selectedTimeRange) {
      case '1天':
        duration = const Duration(days: 1);
        break;
      case '7天':
        duration = const Duration(days: 7);
        break;
      case '30天':
        duration = const Duration(days: 30);
        break;
      default:
        return _currentHistories;
    }
    
    final cutoffDate = now.subtract(duration);
    return _currentHistories.where((h) => h.timestamp.isAfter(cutoffDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
          color: NothingTheme.surface,
          borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
          border: Border.all(color: NothingTheme.gray200, width: 1),
        ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (_isLoading)
                _buildLoadingState()
              else if (_errorMessage != null)
                _buildErrorState()
              else if (_analytics != null && _analytics!.totalRecords > 0) ...[
                _buildInsights(),
                _buildBehaviorFrequencyChart(),
                _buildHourlyActivityChart(),
                _buildBehaviorDurationChart(),
              ] else
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge * 2),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.nothingYellow),
            ),
            SizedBox(height: NothingTheme.spacingMedium),
            Text(
              '正在分析行为数据...',
              style: TextStyle(
                color: NothingTheme.nothingDarkGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: NothingTheme.spacingMedium),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: NothingTheme.nothingDarkGray,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NothingTheme.spacingMedium),
            ElevatedButton(
              onPressed: _updateAnalytics,
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.nothingYellow,
                foregroundColor: Colors.white,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NothingTheme.nothingYellow,
            NothingTheme.nothingYellow.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(NothingTheme.radiusLarge),
          topRight: Radius.circular(NothingTheme.radiusLarge),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(NothingTheme.spacingSmall),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            ),
            child: const Icon(
              Icons.analytics,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '行为分析',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '共${_analytics?.totalRecords ?? 0}条记录',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildTimeRangeSelector(),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimeRange,
          dropdownColor: NothingTheme.nothingDarkGray,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
          items: ['1天', '7天', '30天', '全部'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTimeRange = newValue;
              });
              _updateAnalytics(); // 异步调用
            }
          },
        ),
      ),
    );
  }

  Widget _buildInsights() {
    if (_analytics?.insights.isEmpty ?? true) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '智能洞察',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NothingTheme.nothingDarkGray,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          ...(_analytics!.insights.map((insight) => _buildInsightCard(insight))),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BehaviorInsight insight) {
    Color priorityColor;
    switch (insight.priority) {
      case InsightPriority.high:
        priorityColor = NothingTheme.nothingYellow;
        break;
      case InsightPriority.medium:
        priorityColor = NothingTheme.nothingLightGray;
        break;
      case InsightPriority.low:
        priorityColor = NothingTheme.nothingLightGray.withValues(alpha: 0.5);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: NothingTheme.spacingMedium),
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
        border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                insight.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NothingTheme.nothingDarkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: NothingTheme.nothingDarkGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorFrequencyChart() {
    if (_analytics?.behaviorFrequency.isEmpty ?? true) return const SizedBox.shrink();

    final sortedBehaviors = _analytics!.behaviorFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '行为频率分布',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NothingTheme.nothingDarkGray,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          ...sortedBehaviors.map((entry) => _buildFrequencyBar(entry.key, entry.value, sortedBehaviors.first.value)),
        ],
      ),
    );
  }

  Widget _buildFrequencyBar(String behavior, int count, int maxCount) {
    final percentage = count / maxCount;
    
    return Container(
      margin: const EdgeInsets.only(bottom: NothingTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _getBehaviorIcon(behavior),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    behavior,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: NothingTheme.nothingDarkGray,
                    ),
                  ),
                ],
              ),
              Text(
                '$count次',
                style: TextStyle(
                  fontSize: 14,
                  color: NothingTheme.nothingDarkGray.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: NothingTheme.nothingLightGray.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: NothingTheme.nothingYellow,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyActivityChart() {
    if (_analytics?.hourlyActivity.isEmpty ?? true) return const SizedBox.shrink();

    final maxActivity = _analytics!.hourlyActivity.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '24小时活动分布',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NothingTheme.nothingDarkGray,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (hour) {
                final activity = _analytics!.hourlyActivity[hour] ?? 0;
                final height = activity > 0 ? (activity / maxActivity) * 100 : 0.0;
                
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: activity > 0 ? NothingTheme.nothingYellow : NothingTheme.nothingLightGray.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hour.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 10,
                            color: NothingTheme.nothingDarkGray.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorDurationChart() {
    if (_analytics?.behaviorDuration.isEmpty ?? true) return const SizedBox.shrink();

    final sortedDurations = _analytics!.behaviorDuration.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '行为持续时间',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NothingTheme.nothingDarkGray,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          ...sortedDurations.map((entry) => _buildDurationItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildDurationItem(String behavior, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final durationText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Container(
      margin: const EdgeInsets.only(bottom: NothingTheme.spacingMedium),
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      decoration: BoxDecoration(
        color: NothingTheme.nothingLightGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: NothingTheme.nothingYellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _getBehaviorIcon(behavior),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Text(
              behavior,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: NothingTheme.nothingDarkGray,
              ),
            ),
          ),
          Text(
            durationText,
            style: TextStyle(
              fontSize: 14,
              color: NothingTheme.nothingDarkGray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取行为对应的图标
  String _getBehaviorIcon(String behavior) {
    switch (behavior) {
      case '休息': return '😴';
      case '进食': return '🍽️';
      case '玩耍': return '🎾';
      case '运动': return '🏃';
      case '静止': return '🧘';
      case '发声': return '🔊';
      default: return '🐾';
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingXLarge),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: NothingTheme.nothingLightGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 40,
                color: NothingTheme.nothingLightGray,
              ),
            ),
            const SizedBox(height: NothingTheme.spacingLarge),
            const Text(
              '暂无行为数据',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: NothingTheme.nothingLightGray,
              ),
            ),
            const SizedBox(height: NothingTheme.spacingSmall),
            Text(
              '开始记录您的宠物活动\n来查看详细的行为分析',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: NothingTheme.nothingLightGray.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}