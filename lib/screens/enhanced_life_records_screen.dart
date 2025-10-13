import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/nothing_theme.dart';
import '../models/analysis_history.dart';

import '../services/history_manager.dart';
import '../services/behavior_analyzer.dart';
import '../widgets/ai_history_timeline.dart';
import '../widgets/behavior_analytics_widget.dart';
import '../widgets/behavior_filter_chips.dart';

/// 增强版生活记录界面
class EnhancedLifeRecordsScreen extends StatefulWidget {
  const EnhancedLifeRecordsScreen({super.key});

  @override
  State<EnhancedLifeRecordsScreen> createState() => _EnhancedLifeRecordsScreenState();
}

class _EnhancedLifeRecordsScreenState extends State<EnhancedLifeRecordsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<AnalysisHistory> _histories = [];
  bool _isLoading = true;
  String? _error;
  
  // 筛选参数
  DateTime? _startDate;
  DateTime? _endDate;
  String? _behaviorFilter;
  
  // 可用的行为类型
  final List<String> _behaviorTypes = [
    '全部',
    '进食',
    '玩耍',
    '休息',
    '运动',
    '清洁',
    '健康检查',
    '社交',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final histories = await HistoryManager.instance.getAllHistories();
      setState(() {
        _histories = histories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        title: const Text(
          '生活记录',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(
              Icons.filter_list,
              color: _hasActiveFilters() ? NothingTheme.brandPrimary : NothingTheme.textSecondary,
            ),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(
              Icons.refresh,
              color: NothingTheme.textSecondary,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: NothingTheme.brandPrimary,
          unselectedLabelColor: NothingTheme.textSecondary,
          indicatorColor: NothingTheme.brandPrimary,
          indicatorWeight: 2,
          tabs: const [
            Tab(
              icon: Icon(Icons.timeline),
              text: '时间轴',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: '行为分析',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: NothingTheme.brandPrimary,
              ),
            )
          : _error != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // 行为筛选芯片
                    BehaviorFilterChips(
                      selectedBehavior: _behaviorFilter == '全部' ? null : _behaviorFilter,
                      onBehaviorChanged: (behavior) {
                        setState(() {
                          _behaviorFilter = behavior;
                        });
                      },
                    ),
                    
                    // 筛选状态显示
                    if (_hasActiveFilters()) _buildFilterStatus(),
                    
                    // Tab内容
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 时间轴视图
                          AIHistoryTimeline(
                            startDate: _startDate,
                            endDate: _endDate,
                            behaviorFilter: _behaviorFilter == '全部' ? null : _behaviorFilter,
                            onRecordTap: _showRecordDetail,
                          ),
                          
                          // 行为分析视图
                          BehaviorAnalyticsWidget(
                            histories: _getFilteredHistories(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: NothingTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(
              fontSize: 14,
              color: NothingTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: NothingTheme.brandPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: NothingTheme.gray50,
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: NothingTheme.brandPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (_startDate != null || _endDate != null)
                  _buildFilterChip(
                    '时间: ${_getDateRangeText()}',
                    () => setState(() {
                      _startDate = null;
                      _endDate = null;
                    }),
                  ),
                if (_behaviorFilter != null && _behaviorFilter != '全部')
                  _buildFilterChip(
                    '行为: $_behaviorFilter',
                    () => setState(() => _behaviorFilter = null),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              '清除全部',
              style: TextStyle(
                fontSize: 12,
                color: NothingTheme.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NothingTheme.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: NothingTheme.brandPrimary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: NothingTheme.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选条件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期范围选择
            const Text(
              '时间范围',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                    child: Text(
                      _startDate != null
                          ? DateFormat('MM/dd').format(_startDate!)
                          : '开始日期',
                    ),
                  ),
                ),
                const Text(' - '),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                    child: Text(
                      _endDate != null
                          ? DateFormat('MM/dd').format(_endDate!)
                          : '结束日期',
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 行为类型选择
            const Text(
              '行为类型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _behaviorFilter ?? '全部',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _behaviorTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (value) {
                setState(() => _behaviorFilter = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {}); // 触发重新构建以应用筛选
            },
            child: const Text('应用'),
          ),
        ],
      ),
    );
  }

  void _showRecordDetail(AnalysisHistory history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: NothingTheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(NothingTheme.radiusLg),
              topRight: Radius.circular(NothingTheme.radiusLg),
            ),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NothingTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 详情内容
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: _buildRecordDetailContent(history),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordDetailContent(AnalysisHistory history) {
    final tags = BehaviorAnalyzer.instance.inferBehaviorTags(history.result, history.mode);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          history.result.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: NothingTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 时间和模式
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: NothingTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              DateFormat('yyyy年MM月dd日 HH:mm').format(history.timestamp),
              style: const TextStyle(
                fontSize: 14,
                color: NothingTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: NothingTheme.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusXs),
              ),
              child: Text(
                _getModeDisplayName(history.mode),
                style: TextStyle(
                  fontSize: 12,
                  color: NothingTheme.brandPrimary,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 行为标签
        if (tags.isNotEmpty) ...[
          const Text(
            '识别行为',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: NothingTheme.brandSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                border: Border.all(
                  color: NothingTheme.brandSecondary.withOpacity(0.3),
                ),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 14,
                  color: NothingTheme.brandSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // 描述信息
        if (history.result.subInfo != null && history.result.subInfo!.isNotEmpty) ...[
          const Text(
            '详细信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            history.result.subInfo!,
            style: const TextStyle(
              fontSize: 14,
              color: NothingTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // 置信度
        const Text(
          '识别置信度',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: history.result.confidence / 100,
                backgroundColor: NothingTheme.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getConfidenceColor(history.result.confidence),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${history.result.confidence}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getConfidenceColor(history.result.confidence),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // 图片预览（如果有）
        if (history.imagePath != null) ...[
          const Text(
            '相关图片',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: NothingTheme.gray100,
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
            ),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 48,
                color: NothingTheme.gray400,
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _hasActiveFilters() {
    return _startDate != null || _endDate != null || (_behaviorFilter != null && _behaviorFilter != '全部');
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}';
    } else if (_startDate != null) {
      return '从 ${DateFormat('MM/dd').format(_startDate!)}';
    } else if (_endDate != null) {
      return '到 ${DateFormat('MM/dd').format(_endDate!)}';
    }
    return '';
  }

  void _clearAllFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _behaviorFilter = null;
    });
  }

  List<AnalysisHistory> _getFilteredHistories() {
    var filtered = _histories.where((h) {
      if (_startDate != null && h.timestamp.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && h.timestamp.isAfter(_endDate!)) {
        return false;
      }
      if (_behaviorFilter != null && _behaviorFilter != '全部') {
        final tags = BehaviorAnalyzer.instance.inferBehaviorTags(h.result, h.mode);
        if (!tags.contains(_behaviorFilter)) {
          return false;
        }
      }
      return true;
    }).toList();
    
    return filtered;
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return NothingTheme.success;
    if (confidence >= 60) return NothingTheme.warning;
    return NothingTheme.error;
  }

  String _getModeDisplayName(String mode) {
    switch (mode) {
      case 'normal': return '普通模式';
      case 'pet': return '宠物模式';
      case 'health': return '健康模式';
      case 'travel': return '出行模式';
      default: return mode;
    }
  }
}