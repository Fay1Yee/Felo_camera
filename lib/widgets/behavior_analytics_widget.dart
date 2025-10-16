import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/behavior_analytics.dart';
import '../models/analysis_history.dart';
import '../models/ai_result.dart';
import '../services/history_notifier.dart';
import '../services/pet_activity_data_service.dart';
import '../services/behavior_classification_service.dart';
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
  
  // 宠物活动分类数据
  final PetActivityDataService _activityDataService = PetActivityDataService.instance;
  PetActivitySummary? _categorizedSummary;
  List<PetActivityEvent>? _categorizedEvents;
  bool _isCategoryDataLoading = false;
  
  // 搜索和过滤状态
  String _searchQuery = '';
  String _selectedCategory = '全部';
  String _sortBy = '时间'; // 时间、置信度、类型

  @override
  void initState() {
    super.initState();
    _currentHistories = List.from(widget.histories);
    _setupHistoryListener();
    _updateAnalytics();
    _loadCategorizedData();
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
    // 临时测试：添加一些测试数据来验证映射逻辑
    if (histories.isEmpty) {
      final testHistories = _createTestHistories();
      return BehaviorAnalytics.fromHistories(testHistories);
    }
    return BehaviorAnalytics.fromHistories(histories);
  }
  
  // 创建测试历史数据
  static List<AnalysisHistory> _createTestHistories() {
    final now = DateTime.now();
    return [
      AnalysisHistory(
        id: 'test_1',
        timestamp: now.subtract(Duration(hours: 1)),
        result: AIResult(
          title: '宠物观望行为',
          confidence: 90,
          subInfo: '{"category": "观望", "confidence": 0.9, "reasons": "测试数据"}',
        ),
        mode: 'pet_activity',
        isRealtimeAnalysis: false,
      ),
      AnalysisHistory(
        id: 'test_2',
        timestamp: now.subtract(Duration(hours: 2)),
        result: AIResult(
          title: '宠物探索行为',
          confidence: 85,
          subInfo: '{"category": "探索", "confidence": 0.85, "reasons": "测试数据"}',
        ),
        mode: 'pet_activity',
        isRealtimeAnalysis: false,
      ),
      AnalysisHistory(
        id: 'test_3',
        timestamp: now.subtract(Duration(hours: 3)),
        result: AIResult(
          title: '宠物玩耍行为',
          confidence: 92,
          subInfo: '{"category": "玩耍", "confidence": 0.92, "reasons": "测试数据"}',
        ),
        mode: 'pet_activity',
        isRealtimeAnalysis: false,
      ),
      AnalysisHistory(
        id: 'test_4',
        timestamp: now.subtract(Duration(hours: 4)),
        result: AIResult(
          title: '宠物攻击行为',
          confidence: 88,
          subInfo: '{"category": "攻击", "confidence": 0.88, "reasons": "测试数据"}',
        ),
        mode: 'pet_activity',
        isRealtimeAnalysis: false,
      ),
      AnalysisHistory(
        id: 'test_5',
        timestamp: now.subtract(Duration(hours: 5)),
        result: AIResult(
          title: '无宠物',
          confidence: 95,
          subInfo: '{"category": "无宠物", "confidence": 0.95, "reasons": "测试数据"}',
        ),
        mode: 'pet_activity',
        isRealtimeAnalysis: false,
      ),
    ];
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
        return _currentHistories.where((h) => !_isNoPetData(h)).toList();
    }
    
    final cutoffDate = now.subtract(duration);
    return _currentHistories.where((h) => 
      h.timestamp.isAfter(cutoffDate) && !_isNoPetData(h)
    ).toList();
  }

  /// 检查是否为无宠物数据
  bool _isNoPetData(AnalysisHistory history) {
    final title = history.result.title.toLowerCase();
    return title.contains('no_pet') || 
           title.contains('无宠物') || 
           title.contains('没有宠物') ||
           title.contains('未检测到宠物');
  }

  /// 检查活动事件是否为无宠物数据
  bool _isNoPetEvent(PetActivityEvent event) {
    final title = event.title.toLowerCase();
    final category = event.originalCategory.toLowerCase();
    return title.contains('no_pet') || 
           title.contains('无宠物') || 
           title.contains('没有宠物') ||
           title.contains('未检测到宠物') ||
           category.contains('no_pet') ||
           category.contains('无宠物');
  }

  /// 获取过滤后的活动事件
  List<PetActivityEvent> _getFilteredEvents() {
    if (_categorizedEvents == null) return [];
    
    var filteredEvents = _categorizedEvents!.where((event) {
      // 过滤无宠物数据
      if (_isNoPetEvent(event)) {
        return false;
      }
      
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!event.title.toLowerCase().contains(query) &&
            !event.originalCategory.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // 分类过滤
      if (_selectedCategory != '全部' && event.originalCategory != _selectedCategory) {
        return false;
      }
      
      return true;
    }).toList();
    
    // 排序
    switch (_sortBy) {
      case '时间':
        filteredEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case '置信度':
        filteredEvents.sort((a, b) => b.confidence.compareTo(a.confidence));
        break;
      case '类型':
        filteredEvents.sort((a, b) => a.originalCategory.compareTo(b.originalCategory));
        break;
    }
    
    return filteredEvents;
  }

  /// 加载宠物活动分类数据
  Future<void> _loadCategorizedData() async {
    if (mounted) {
      setState(() {
        _isCategoryDataLoading = true;
      });
    }

    try {
      final success = await _activityDataService.loadCategorizedData();
      if (success && mounted) {
        setState(() {
          _categorizedSummary = _activityDataService.getSummary();
          _categorizedEvents = _activityDataService.getAllEvents();
          _isCategoryDataLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 加载宠物活动分类数据失败: $e');
      if (mounted) {
        setState(() {
          _isCategoryDataLoading = false;
        });
      }
    }
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
                // 添加宠物活动分类数据展示
                _buildCategorizedActivitiesSection(),
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

    // 使用行为分类服务标准化行为名称
    final classificationService = BehaviorClassificationService.instance;
    final normalizedBehaviors = <String, int>{};
    
    // 将所有行为映射为标准中文显示名称并合并计数
    for (final entry in _analytics!.behaviorFrequency.entries) {
      final standardName = classificationService.mapBehaviorToDisplayName(entry.key);
      normalizedBehaviors[standardName] = (normalizedBehaviors[standardName] ?? 0) + entry.value;
    }

    // 按文档定义的优先级排序：文档标准分类优先，然后按频率排序
    final sortedBehaviors = normalizedBehaviors.entries.toList()
      ..sort((a, b) {
        final aIsStandard = classificationService.isDocumentStandardCategory(a.key);
        final bIsStandard = classificationService.isDocumentStandardCategory(b.key);
        
        // 文档标准分类优先
        if (aIsStandard && !bIsStandard) return -1;
        if (!aIsStandard && bIsStandard) return 1;
        
        // 同类型内按频率排序
        return b.value.compareTo(a.value);
      });

    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '行为频率分布',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NothingTheme.nothingDarkGray,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NothingTheme.accentPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '严格遵循文档分类',
                  style: TextStyle(
                    fontSize: 12,
                    color: NothingTheme.accentPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          ...sortedBehaviors.map((entry) => _buildFrequencyBar(
            entry.key, 
            entry.value, 
            sortedBehaviors.first.value,
            classificationService.getBehaviorCategoryLabel(entry.key),
          )),
        ],
      ),
    );
  }

  Widget _buildFrequencyBar(String behavior, int count, int maxCount, String categoryLabel) {
    final percentage = count / maxCount;
    final classificationService = BehaviorClassificationService.instance;
    final isStandardCategory = classificationService.isDocumentStandardCategory(behavior);
    
    return Container(
      margin: const EdgeInsets.only(bottom: NothingTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      _getBehaviorIcon(behavior),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            behavior,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isStandardCategory ? FontWeight.w600 : FontWeight.w500,
                              color: NothingTheme.nothingDarkGray,
                            ),
                          ),
                          if (categoryLabel.isNotEmpty)
                            Text(
                              categoryLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: isStandardCategory 
                                    ? NothingTheme.accentPrimary 
                                    : NothingTheme.nothingDarkGray.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$count次',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
    final behaviorColors = _getBehaviorColors();
    final totalActivity = _analytics!.hourlyActivity.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
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
                Icons.bar_chart,
                color: NothingTheme.info,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '24小时活动分布图表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NothingTheme.nothingDarkGray,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NothingTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '堆叠柱状图',
                  style: TextStyle(
                    fontSize: 12,
                    color: NothingTheme.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 图表区域
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (hour) {
                final activity = _analytics!.hourlyActivity[hour] ?? 0;
                final hourBehaviors = _analytics!.hourlyBehaviorDistribution[hour] ?? {};
                final height = activity > 0 ? (activity / maxActivity) * 140 : 0.0;
                final percentage = totalActivity > 0 ? (activity / totalActivity * 100) : 0.0;
                
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 百分比标注（仅在有活动时显示）
                        if (activity > 0 && percentage >= 2.0) // 只显示占比大于2%的标注
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 9,
                                color: NothingTheme.nothingDarkGray.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        
                        // 堆叠柱状图
                        if (activity > 0)
                          _buildEnhancedStackedBar(hourBehaviors, height, behaviorColors, activity)
                        else
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: NothingTheme.nothingLightGray.withValues(alpha: 0.2),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                            ),
                          ),
                        
                        const SizedBox(height: 6),
                        
                        // 时间轴刻度（精确到整点小时）
                        Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            fontSize: 10,
                            color: NothingTheme.nothingDarkGray.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: NothingTheme.spacingLarge),
          
          // 图例说明
          _buildEnhancedBehaviorLegend(behaviorColors),
        ],
      ),
    );
  }

  Widget _buildEnhancedStackedBar(Map<String, int> behaviors, double totalHeight, Map<String, Color> behaviorColors, int totalActivity) {
    if (behaviors.isEmpty) return const SizedBox.shrink();
    
    final totalCount = behaviors.values.reduce((a, b) => a + b);
    final sortedBehaviors = behaviors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      height: totalHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Column(
          children: sortedBehaviors.map((entry) {
            final proportion = entry.value / totalCount;
            final segmentHeight = totalHeight * proportion;
            
            return Container(
              height: segmentHeight,
              decoration: BoxDecoration(
                color: behaviorColors[entry.key] ?? NothingTheme.nothingYellow,
                border: segmentHeight > 8 ? Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ) : null,
              ),
              child: segmentHeight > 12 ? Center(
                child: Text(
                  '${entry.value}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
              ) : null,
            );
          }).toList(),
        ),
      ),
    );
  }



  Widget _buildEnhancedBehaviorLegend(Map<String, Color> behaviorColors) {
    final allBehaviors = _analytics!.behaviorFrequency.keys.toList()
      ..sort();
    
    final totalEvents = _analytics!.behaviorFrequency.values.reduce((a, b) => a + b);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(color: NothingTheme.gray200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.legend_toggle,
                color: NothingTheme.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '图例说明',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NothingTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '总计: $totalEvents 个事件',
                style: TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: allBehaviors.map((behavior) {
              final count = _analytics!.behaviorFrequency[behavior] ?? 0;
              final percentage = totalEvents > 0 ? (count / totalEvents * 100) : 0.0;
              final displayName = BehaviorClassificationService.instance.mapBehaviorToDisplayName(behavior);
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: (behaviorColors[behavior] ?? NothingTheme.nothingYellow).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (behaviorColors[behavior] ?? NothingTheme.nothingYellow).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: behaviorColors[behavior] ?? NothingTheme.nothingYellow,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: NothingTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }



  Map<String, Color> _getBehaviorColors() {
    return {
      // 程序现有分类 - 莫兰迪色系（低饱和度、柔和）
      '休息': const Color(0xFFA8B5A0),      // 莫兰迪绿 - 平静休息
      '进食': const Color(0xFFD4A574),      // 莫兰迪橙 - 温暖进食
      '玩耍': const Color(0xFF8FA4C7),      // 莫兰迪蓝 - 活跃玩耍
      '运动': const Color(0xFFD19BA8),      // 莫兰迪粉 - 活力运动
      '静止': const Color(0xFFB5A4C7),      // 莫兰迪紫 - 安静静止
      '发声': const Color(0xFFD4A085),      // 莫兰迪棕橙 - 表达发声
      '其他': const Color(0xFF9EAAB0),      // 莫兰迪灰蓝 - 中性其他
      
      // 文档标准分类 - 莫兰迪色系，确保清晰辨识
      'explore': const Color(0xFF9BB5A0),   // 莫兰迪橄榄绿 - 探索
      'observe': const Color(0xFF8EABC7),   // 莫兰迪天蓝 - 观望
      'occupy': const Color(0xFFD4B574),    // 莫兰迪金黄 - 领地
      'neutral': const Color(0xFFB0B0B0),   // 莫兰迪中灰 - 中性
      'play': const Color(0xFFA89BC7),      // 莫兰迪薰衣草 - 玩耍
      'attack': const Color(0xFFD49B9B),    // 莫兰迪粉红 - 攻击
      'no_pet': const Color(0xFFC5C5C5),    // 莫兰迪浅灰 - 无宠物
      
      // 中文映射（确保兼容性）
      '观望': const Color(0xFF8EABC7),      // 莫兰迪天蓝 - 观望
      '探索': const Color(0xFF9BB5A0),      // 莫兰迪橄榄绿 - 探索
      '领地': const Color(0xFFD4B574),      // 莫兰迪金黄 - 领地
      '攻击': const Color(0xFFD49B9B),      // 莫兰迪粉红 - 攻击
      '中性': const Color(0xFFB0B0B0),      // 莫兰迪中灰 - 中性
      '无宠物': const Color(0xFFC5C5C5),    // 莫兰迪浅灰 - 无宠物
      
      // 行为类型映射
      '观望行为': const Color(0xFF8EABC7),  // 莫兰迪天蓝 - 观望行为
      '探索行为': const Color(0xFF9BB5A0),  // 莫兰迪橄榄绿 - 探索行为
      '领地行为': const Color(0xFFD4B574),  // 莫兰迪金黄 - 领地行为
      '玩耍行为': const Color(0xFFA89BC7),  // 莫兰迪薰衣草 - 玩耍行为
      '攻击行为': const Color(0xFFD49B9B),  // 莫兰迪粉红 - 攻击行为
      '中性行为': const Color(0xFFB0B0B0),  // 莫兰迪中灰 - 中性行为
      '无宠物活动': const Color(0xFFC5C5C5), // 莫兰迪浅灰 - 无宠物活动
      
      // 额外的活动类型（确保完整覆盖）
      '睡眠': const Color(0xFFB5B5D4),      // 莫兰迪淡紫 - 睡眠
      '喂食': const Color(0xFFD4C574),      // 莫兰迪淡黄 - 喂食
      '美容护理': const Color(0xFFD4B5A0),  // 莫兰迪米色 - 美容护理
      '奔跑': const Color(0xFFD4A5A5),      // 莫兰迪浅粉 - 奔跑
      '散步': const Color(0xFFA5D4B5),      // 莫兰迪薄荷绿 - 散步
      '训练': const Color(0xFFA5B5D4),      // 莫兰迪浅蓝 - 训练
      '社交': const Color(0xFFD4A5D4),      // 莫兰迪淡紫粉 - 社交
    };
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
    final seconds = duration.inSeconds % 60;
    
    String durationText;
    if (hours > 0) {
      durationText = '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      durationText = '${minutes}m';
    } else if (seconds > 0) {
      durationText = '${seconds}s';
    } else {
      durationText = '<1s';  // 对于极短的持续时间
    }

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
      // 文档标准分类
      case '观望行为': return '👀';
      case '探索行为': return '🔍';
      case '领地行为': return '🏠';
      case '无特定行为': return '😐';
      case '攻击行为': return '⚔️';
      case '玩耍行为': return '🎾';
      case '无宠物': return '❌';
      
      // 程序现有分类
      case '玩耍': return '🎾';
      case '进食': return '🍽️';
      case '睡觉': return '😴';
      case '休息': return '😴';
      case '运动': return '🏃';
      case '静止': return '🧘';
      case '发声': return '🔊';
      case '梳理': return '🪮';
      case '探索': return '🔍';
      case '社交': return '👥';
      case '警戒': return '⚠️';
      case '其他': return '❓';
      
      // 兼容英文显示（逐步淘汰）
      case 'observe': return '👀';
      case 'explore': return '🔍';
      case 'occupy': return '🏠';
      case 'neutral': return '😐';
      case 'attack': return '⚔️';
      case 'play': return '🎾';
      case 'no_pet': return '❌';
      case 'playing': return '🎾';
      case 'eating': return '🍽️';
      case 'sleeping': return '😴';
      case 'resting': return '😴';
      case 'exercising': return '🏃';
      case 'stationary': return '🧘';
      case 'vocalizing': return '🔊';
      case 'grooming': return '🪮';
      case 'exploring': return '🔍';
      case 'socializing': return '👥';
      case 'alerting': return '⚠️';
      case 'other': return '❓';
      
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

  /// 构建宠物活动分类数据展示区域
  Widget _buildCategorizedActivitiesSection() {
    if (_isCategoryDataLoading) {
      return Container(
        padding: const EdgeInsets.all(NothingTheme.spacingLarge),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.nothingYellow),
              ),
              SizedBox(height: NothingTheme.spacingMedium),
              Text(
                '正在加载活动分类数据...',
                style: TextStyle(
                  color: NothingTheme.nothingDarkGray,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_categorizedSummary == null || _categorizedEvents == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(NothingTheme.spacingLarge),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(color: NothingTheme.gray200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(NothingTheme.spacingLarge),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  NothingTheme.info,
                  NothingTheme.info.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(NothingTheme.radiusMd),
                topRight: Radius.circular(NothingTheme.radiusMd),
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
                    Icons.category,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: NothingTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '活动分类统计',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '共${_categorizedSummary!.totalEvents}个活动，${_categorizedSummary!.activityTypes}种类型',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 搜索和过滤栏
          Padding(
            padding: const EdgeInsets.all(NothingTheme.spacingLarge),
            child: Column(
              children: [
                _buildSearchAndFilterBar(),
                const SizedBox(height: NothingTheme.spacingLarge),
                _buildCategoryStatsGrid(),
                const SizedBox(height: NothingTheme.spacingLarge),
                _buildFilteredActivitiesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索和过滤栏
  Widget _buildSearchAndFilterBar() {
    final categories = ['全部'];
    if (_categorizedSummary != null) {
      categories.addAll(_categorizedSummary!.typeStats.keys);
    }
    
    return Column(
      children: [
        // 搜索栏
        Container(
          decoration: BoxDecoration(
            color: NothingTheme.gray100,
            borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            border: Border.all(color: NothingTheme.gray200, width: 1),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: const InputDecoration(
              hintText: '搜索活动...',
              prefixIcon: Icon(Icons.search, color: NothingTheme.nothingGray),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: NothingTheme.spacingMedium,
                vertical: NothingTheme.spacingMedium,
              ),
            ),
          ),
        ),
        const SizedBox(height: NothingTheme.spacingMedium),
        
        // 过滤选项
        Row(
          children: [
            // 分类过滤
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: NothingTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: NothingTheme.gray100,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  border: Border.all(color: NothingTheme.gray200, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: NothingTheme.spacingMedium),
            
            // 排序选项
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: NothingTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: NothingTheme.gray100,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  border: Border.all(color: NothingTheme.gray200, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    items: ['时间', '置信度', '类型'].map((sortOption) {
                      return DropdownMenuItem<String>(
                        value: sortOption,
                        child: Text(
                          '按$sortOption排序',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建分类统计网格
  Widget _buildCategoryStatsGrid() {
    final typeStats = _categorizedSummary!.typeStats;
    final categories = typeStats.keys.toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: NothingTheme.spacingMedium,
        mainAxisSpacing: NothingTheme.spacingMedium,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final stats = typeStats[category]!;
        final color = _activityDataService.getActivityTypeColor(category);
        final icon = _activityDataService.getActivityTypeIcon(category);
        
        return Container(
          padding: const EdgeInsets.all(NothingTheme.spacingMedium),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: NothingTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NothingTheme.spacingSmall),
              Text(
                '${stats.eventCount}次',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: NothingTheme.nothingDarkGray,
                ),
              ),
              Text(
                '置信度 ${(stats.averageConfidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  color: NothingTheme.nothingDarkGray.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建过滤后的活动列表
  Widget _buildFilteredActivitiesList() {
    final filteredEvents = _getFilteredEvents().take(10).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近活动',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: NothingTheme.nothingDarkGray,
          ),
        ),
        const SizedBox(height: NothingTheme.spacingMedium),
        ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEvents.length,
            separatorBuilder: (context, index) => const SizedBox(height: NothingTheme.spacingSmall),
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
            final color = _activityDataService.getActivityTypeColor(event.originalCategory);
            final icon = _activityDataService.getActivityTypeIcon(event.originalCategory);
            
            return Container(
              padding: const EdgeInsets.all(NothingTheme.spacingMedium),
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                border: Border.all(color: NothingTheme.gray200, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: NothingTheme.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: NothingTheme.nothingDarkGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          BehaviorClassificationService.instance.mapBehaviorToDisplayName(event.originalCategory),
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        event.formattedTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: NothingTheme.nothingDarkGray.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '${(event.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: NothingTheme.nothingDarkGray.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}