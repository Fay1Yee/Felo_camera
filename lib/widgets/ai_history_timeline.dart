import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../config/nothing_theme.dart';
import '../models/analysis_history.dart';
import '../screens/data_management/life_records_screen.dart';
import '../services/behavior_analyzer.dart';
import '../services/history_manager.dart';
import '../services/data_association_service.dart';
import '../services/history_notifier.dart';
import 'record_detail_dialog.dart';

/// AI历史时间轴组件
class AIHistoryTimeline extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? behaviorFilter;
  final Function(AnalysisHistory)? onRecordTap;

  const AIHistoryTimeline({
    super.key,
    this.startDate,
    this.endDate,
    this.behaviorFilter,
    this.onRecordTap,
  });

  @override
  State<AIHistoryTimeline> createState() => _AIHistoryTimelineState();
}

class _AIHistoryTimelineState extends State<AIHistoryTimeline> {
  List<AnalysisHistory> _histories = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription<HistoryEvent>? _historySubscription;

  @override
  void initState() {
    super.initState();
    _setupHistoryListener();
    _loadHistories();
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }

  /// 设置AI历史记录变化监听器，确保实时数据同步
  void _setupHistoryListener() {
    _historySubscription = HistoryNotifier.instance.historyStream.listen((event) {
      if (mounted) {
        // 当AI历史记录发生变化时，重新加载数据以保持同步
        switch (event.type) {
          case HistoryEventType.added:
          case HistoryEventType.deleted:
          case HistoryEventType.updated:
          case HistoryEventType.cleared:
            debugPrint('🔄 AI历史时间线检测到数据变化，重新加载');
            _loadHistories();
            break;
        }
      }
    });
  }

  @override
  void didUpdateWidget(AIHistoryTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.behaviorFilter != widget.behaviorFilter) {
      _loadHistories();
    }
  }

  Future<void> _loadHistories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 获取AI分析历史
      final allHistories = await HistoryManager.instance.getAllHistories();
      
      // 筛选日期范围
      var filteredHistories = allHistories.where((h) {
        final startDate = widget.startDate;
        if (startDate != null && h.timestamp.isBefore(startDate)) {
          return false;
        }
        final endDate = widget.endDate;
        if (endDate != null && h.timestamp.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();

      // 转换为增强的生活记录并确保数据同步
      final enhancedRecords = await BehaviorAnalyzer.instance.convertToEnhancedLifeRecords(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
      
      // 触发数据关联服务，确保AI历史与生活记录同步
      await DataAssociationService.instance.autoGenerateAndAssociate(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
      
      debugPrint('🔄 AI历史时间线数据同步完成: ${enhancedRecords.length}条增强记录');

      // 行为类型筛选
      final behaviorFilter = widget.behaviorFilter;
      if (behaviorFilter != null && behaviorFilter.isNotEmpty) {
        filteredHistories = filteredHistories.where((h) {
          final tags = BehaviorAnalyzer.instance.inferBehaviorTags(h.result, h.mode);
          return tags.contains(widget.behaviorFilter);
        }).toList();
      }

      setState(() {
        _histories = filteredHistories;
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: NothingTheme.brandPrimary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: NothingTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: NothingTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: NothingTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistories,
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

    if (_histories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 48,
              color: NothingTheme.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无记录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: NothingTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '使用AI相机拍摄后，记录将在这里显示',
              style: TextStyle(
                fontSize: 14,
                color: NothingTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistories,
      color: NothingTheme.brandPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _histories.length,
        itemBuilder: (context, index) {
          final history = _histories[index];
          final isFirst = index == 0;
          final isLast = index == _histories.length - 1;
          
          return _buildTimelineItem(history, isFirst, isLast);
        },
      ),
    );
  }

  Widget _buildTimelineItem(AnalysisHistory history, bool isFirst, bool isLast) {
    final tags = BehaviorAnalyzer.instance.inferBehaviorTags(history.result, history.mode);
    final primaryTag = tags.isNotEmpty ? tags.first : '未知行为';
    final recordType = _getRecordTypeFromTags(tags, history.mode);
    
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间轴线条和节点
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    color: NothingTheme.gray300,
                  ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: recordType.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NothingTheme.surface,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: NothingTheme.gray300,
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 记录内容
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.onRecordTap != null) {
                  widget.onRecordTap!(history);
                } else {
                  // 默认显示详情对话框
                  _showRecordDetail(history, primaryTag);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NothingTheme.surface,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                  border: Border.all(
                    color: NothingTheme.gray200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NothingTheme.blackAlpha05,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题和时间
                    Row(
                      children: [
                        Icon(
                          recordType.icon,
                          size: 20,
                          color: recordType.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            history.result.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: NothingTheme.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(history.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: NothingTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 行为标签
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: recordType.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: recordType.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // 描述信息
                    if (history.result.subInfo != null && history.result.subInfo!.isNotEmpty)
                      Text(
                        history.result.subInfo!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: NothingTheme.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // 底部信息
                    Row(
                      children: [
                        // 置信度
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(history.result.confidence).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(NothingTheme.radiusXs),
                          ),
                          child: Text(
                            '${history.result.confidence}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: _getConfidenceColor(history.result.confidence),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // 分析模式
                        Text(
                          _getModeDisplayName(history.mode),
                          style: const TextStyle(
                            fontSize: 11,
                            color: NothingTheme.textTertiary,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // 图片指示器
                        if (history.imagePath != null)
                          Icon(
                            Icons.image,
                            size: 16,
                            color: NothingTheme.textTertiary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  RecordType _getRecordTypeFromTags(List<String> tags, String mode) {
    if (tags.contains('进食')) return RecordType.feeding;
    if (tags.contains('玩耍')) return RecordType.play;
    if (tags.contains('休息')) return RecordType.sleep;
    if (tags.contains('运动')) return RecordType.exercise;
    if (tags.contains('清洁')) return RecordType.grooming;
    if (tags.contains('健康检查')) return RecordType.health;
    if (tags.contains('社交')) return RecordType.social;
    
    // 基于模式的默认类型
    switch (mode) {
      case 'health': return RecordType.health;
      case 'pet': return RecordType.play;
      case 'travel': return RecordType.exercise;
      default: return RecordType.other;
    }
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return NothingTheme.success;
    if (confidence >= 60) return NothingTheme.warning;
    return NothingTheme.error;
  }

  String _getModeDisplayName(String mode) {
    switch (mode) {
      case 'health': return '健康检查';
      case 'pet': return '宠物行为';
      case 'travel': return '旅行记录';
      default: return mode;
    }
  }

  /// 显示记录详情对话框
  void _showRecordDetail(AnalysisHistory record, String behaviorLabel) {
    showDialog(
      context: context,
      builder: (context) => RecordDetailDialog(
        record: record,
        behaviorLabel: behaviorLabel,
      ),
    );
  }
}