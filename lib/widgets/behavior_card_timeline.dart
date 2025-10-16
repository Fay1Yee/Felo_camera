import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../config/nothing_theme.dart';
import '../models/analysis_history.dart';
import '../services/behavior_analyzer.dart';
import '../services/behavior_classification_service.dart';
import '../services/history_manager.dart';
import '../services/history_notifier.dart';
import 'record_detail_dialog.dart';
import '../screens/data_management/life_records_screen.dart';

/// 行为记录卡片数据模型
class BehaviorCard {
  final String id;
  final String behaviorType;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final List<String> tags;
  final List<AnalysisHistory> records;
  final RecordType recordType;
  final double averageConfidence;

  const BehaviorCard({
    required this.id,
    required this.behaviorType,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.tags,
    required this.records,
    required this.recordType,
    required this.averageConfidence,
  });

  /// 格式化持续时间显示
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else if (minutes > 0) {
      return '${minutes}分钟${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }

  /// 格式化时间范围显示
  String get formattedTimeRange {
    final startFormat = DateFormat('HH:mm');
    final endFormat = DateFormat('HH:mm');
    return '${startFormat.format(startTime)} - ${endFormat.format(endTime)}';
  }
}

/// 卡片式行为记录时间轴组件
class BehaviorCardTimeline extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? behaviorFilter;
  final Function(AnalysisHistory)? onRecordTap;

  const BehaviorCardTimeline({
    super.key,
    this.startDate,
    this.endDate,
    this.behaviorFilter,
    this.onRecordTap,
  });

  @override
  State<BehaviorCardTimeline> createState() => _BehaviorCardTimelineState();
}

class _BehaviorCardTimelineState extends State<BehaviorCardTimeline> {
  List<BehaviorCard> _behaviorCards = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription<HistoryEvent>? _historySubscription;

  @override
  void initState() {
    super.initState();
    _setupHistoryListener();
    _loadBehaviorCards();
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }

  /// 设置历史记录变化监听器
  void _setupHistoryListener() {
    _historySubscription = HistoryNotifier.instance.historyStream.listen((event) {
      if (mounted) {
        switch (event.type) {
          case HistoryEventType.added:
          case HistoryEventType.deleted:
          case HistoryEventType.updated:
          case HistoryEventType.cleared:
            debugPrint('🔄 行为卡片时间线检测到数据变化，重新加载');
            _loadBehaviorCards();
            break;
        }
      }
    });
  }

  @override
  void didUpdateWidget(BehaviorCardTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.behaviorFilter != widget.behaviorFilter) {
      _loadBehaviorCards();
    }
  }

  /// 加载并处理行为记录卡片
  Future<void> _loadBehaviorCards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 获取历史记录
      final allHistories = await HistoryManager.instance.getAllHistories();
      debugPrint('🔍 BehaviorCardTimeline: 获取到 ${allHistories.length} 条历史记录');
      
      // 打印前几条记录的详细信息
      for (int i = 0; i < allHistories.length && i < 3; i++) {
        final history = allHistories[i];
        debugPrint('📋 记录 ${i + 1}: ${history.result.title} - ${history.mode} - ${history.timestamp}');
      }
      
      // 筛选日期范围
      var filteredHistories = allHistories.where((h) {
        final startDate = widget.startDate;
        if (startDate != null && h.timestamp.isBefore(startDate)) {
          debugPrint('❌ 记录 ${h.result.title} 被日期过滤 (早于 $startDate)');
          return false;
        }
        final endDate = widget.endDate;
        if (endDate != null && h.timestamp.isAfter(endDate)) {
          debugPrint('❌ 记录 ${h.result.title} 被日期过滤 (晚于 $endDate)');
          return false;
        }
        return true;
      }).toList();
      
      debugPrint('📅 日期筛选后剩余 ${filteredHistories.length} 条记录');

      // 筛选行为类型
      if (widget.behaviorFilter != null && widget.behaviorFilter != 'all') {
        filteredHistories = filteredHistories.where((h) {
          final tags = BehaviorAnalyzer.instance.inferBehaviorTags(h.result, h.mode);
          return tags.any((tag) => tag.toLowerCase().contains(widget.behaviorFilter!.toLowerCase()));
        }).toList();
      }

      // 按时间排序
      filteredHistories.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // 合并相同行为类型的记录
      final behaviorCards = _mergeBehaviorRecords(filteredHistories);
      debugPrint('🔍 BehaviorCardTimeline: 筛选后 ${filteredHistories.length} 条记录，生成 ${behaviorCards.length} 张卡片');

      setState(() {
        _behaviorCards = behaviorCards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载行为记录失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 合并相同行为类型的连续记录
  List<BehaviorCard> _mergeBehaviorRecords(List<AnalysisHistory> histories) {
    if (histories.isEmpty) return [];

    // 按时间排序
    final sortedHistories = List<AnalysisHistory>.from(histories)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final cards = <BehaviorCard>[];
    List<AnalysisHistory> currentGroup = [sortedHistories.first];
    String currentBehaviorType = _extractBehaviorType(sortedHistories.first);

    for (int i = 1; i < sortedHistories.length; i++) {
      final history = sortedHistories[i];
      final behaviorType = _extractBehaviorType(history);
      
      // 检查是否可以与当前组合并（相同行为类型且时间间隔不超过30分钟）
      final canMerge = behaviorType == currentBehaviorType &&
          history.timestamp.difference(currentGroup.last.timestamp).inMinutes <= 30;

      if (canMerge) {
        currentGroup.add(history);
      } else {
        // 创建当前组的卡片
        cards.add(_createBehaviorCard(currentGroup, currentBehaviorType));
        
        // 开始新组
        currentGroup = [history];
        currentBehaviorType = behaviorType;
      }
    }

    // 添加最后一组
    if (currentGroup.isNotEmpty) {
      cards.add(_createBehaviorCard(currentGroup, currentBehaviorType));
    }

    return cards;
  }

  /// 提取行为类型
  String _extractBehaviorType(AnalysisHistory history) {
    final tags = BehaviorAnalyzer.instance.inferBehaviorTags(history.result, history.mode);
    return tags.isNotEmpty ? tags.first : history.result.title;
  }

  /// 创建行为卡片
  BehaviorCard _createBehaviorCard(List<AnalysisHistory> records, String behaviorType) {
    final startTime = records.first.timestamp;
    final endTime = records.last.timestamp;
    final duration = endTime.difference(startTime);
    
    // 收集所有标签
    final allTags = <String>{};
    for (final record in records) {
      final tags = BehaviorAnalyzer.instance.inferBehaviorTags(record.result, record.mode);
      allTags.addAll(tags);
    }

    // 计算平均置信度
    final totalConfidence = records.fold<double>(0, (sum, r) => sum + r.result.confidence);
    final averageConfidence = totalConfidence / records.length;

    // 获取记录类型
    final recordType = BehaviorClassificationService.instance.getRecordTypeFromTags(
      allTags.toList(), 
      records.first.mode
    );

    return BehaviorCard(
      id: '${records.first.id}_merged',
      behaviorType: behaviorType,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      tags: allTags.toList(),
      records: records,
      recordType: recordType,
      averageConfidence: averageConfidence,
    );
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
              _error!,
              style: const TextStyle(
                color: NothingTheme.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBehaviorCards,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_behaviorCards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 48,
              color: NothingTheme.textTertiary,
            ),
            SizedBox(height: 16),
            Text(
              '暂无行为记录',
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBehaviorCards,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _behaviorCards.length,
        addAutomaticKeepAlives: false, // 不保持离屏组件状态，减少内存使用
        addRepaintBoundaries: true, // 添加重绘边界，提高渲染性能
        cacheExtent: 300, // 设置缓存范围，平衡性能和内存
        itemBuilder: (context, index) {
          final card = _behaviorCards[index];
          final isLast = index == _behaviorCards.length - 1;
          return _buildBehaviorCardItem(card, isLast);
        },
      ),
    );
  }

  /// 构建行为卡片项
  Widget _buildBehaviorCardItem(BehaviorCard card, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间轴线条和节点
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // 时间节点
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: card.recordType.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NothingTheme.surface,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: card.recordType.color.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // 连接线
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          card.recordType.color.withOpacity(0.3),
                          NothingTheme.gray300,
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 卡片内容
          Expanded(
            child: GestureDetector(
              onTap: () => _showCardDetail(card),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NothingTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: card.recordType.color.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NothingTheme.blackAlpha05,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: card.recordType.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            card.recordType.icon,
                            size: 20,
                            color: card.recordType.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.behaviorType,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: NothingTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${card.records.length}次记录',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: NothingTheme.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 置信度标识
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(card.averageConfidence).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${card.averageConfidence.round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getConfidenceColor(card.averageConfidence),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 时间和持续时间信息
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NothingTheme.gray50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: NothingTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '时间范围',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: NothingTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.formattedTimeRange,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: NothingTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: NothingTheme.gray200,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 16,
                                      color: NothingTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '持续时间',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: NothingTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.formattedDuration,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: NothingTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 行为标签
                    if (card.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: card.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: card.recordType.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: card.recordType.color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: card.recordType.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
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

  /// 获取置信度颜色
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return NothingTheme.success;
    if (confidence >= 60) return NothingTheme.warning;
    return NothingTheme.error;
  }

  /// 显示卡片详情
  void _showCardDetail(BehaviorCard card) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                children: [
                  Icon(
                    card.recordType.icon,
                    size: 24,
                    color: card.recordType.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      card.behaviorType,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 统计信息
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NothingTheme.gray50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem('记录次数', '${card.records.length}次'),
                        ),
                        Expanded(
                          child: _buildStatItem('持续时间', card.formattedDuration),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem('开始时间', DateFormat('HH:mm').format(card.startTime)),
                        ),
                        Expanded(
                          child: _buildStatItem('结束时间', DateFormat('HH:mm').format(card.endTime)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 标签
              if (card.tags.isNotEmpty) ...[
                const Text(
                  '行为标签',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: card.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: card.recordType.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: card.recordType.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (widget.onRecordTap != null && card.records.isNotEmpty) {
                          widget.onRecordTap!(card.records.first);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: card.recordType.color,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('查看详情'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: NothingTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}