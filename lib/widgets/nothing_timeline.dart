import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../config/nothing_theme.dart';
import '../models/analysis_history.dart';
import '../models/ai_result.dart';
import '../services/history_notifier.dart';
import 'dart:convert';

/// Nothing OS风格的时间轴组件
class NothingTimeline extends StatefulWidget {
  final List<AnalysisHistory> histories;
  final Function(AnalysisHistory)? onItemTap;
  final Function(AnalysisHistory)? onItemDelete;

  const NothingTimeline({
    super.key,
    required this.histories,
    this.onItemTap,
    this.onItemDelete,
  });

  @override
  State<NothingTimeline> createState() => _NothingTimelineState();
}

class _NothingTimelineState extends State<NothingTimeline> {
  List<AnalysisHistory> _currentHistories = [];
  StreamSubscription<HistoryEvent>? _historySubscription;

  @override
  void initState() {
    super.initState();
    _currentHistories = List.from(widget.histories);
    _setupHistoryListener();
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(NothingTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.histories != oldWidget.histories) {
      _currentHistories = List.from(widget.histories);
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentHistories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: NothingTheme.nothingGray,
            ),
            SizedBox(height: NothingTheme.spacingMedium),
            Text(
              '暂无历史记录',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                color: NothingTheme.nothingGray,
              ),
            ),
          ],
        ),
      );
    }

    // 按日期分组
    final groupedHistories = _groupHistoriesByDate(_currentHistories);
    
    return ListView.builder(
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      itemCount: groupedHistories.length,
      itemBuilder: (context, index) {
        final dateGroup = groupedHistories[index];
        return _buildDateGroup(dateGroup);
      },
    );
  }

  List<DateGroup> _groupHistoriesByDate(List<AnalysisHistory> histories) {
    final Map<String, List<AnalysisHistory>> grouped = {};
    
    // 首先展开所有多事件历史记录
    final List<AnalysisHistory> expandedHistories = [];
    
    for (final history in histories) {
      if (history.result.multipleEvents != null && history.result.multipleEvents!.isNotEmpty) {
        // 为每个事件创建独立的AnalysisHistory对象
        for (int eventIndex = 0; eventIndex < history.result.multipleEvents!.length; eventIndex++) {
          final event = history.result.multipleEvents![eventIndex];
          
          final eventHistory = AnalysisHistory(
            id: '${history.id}_event_$eventIndex',
            result: AIResult(
              title: '${event.category} - ${event.title}',
              confidence: event.confidence.toInt(),
              subInfo: event.content,
              bbox: history.result.bbox,
              multipleEvents: null,
            ),
            timestamp: event.timestamp,
            mode: history.mode,
            isRealtimeAnalysis: history.isRealtimeAnalysis,
            imagePath: history.imagePath,
          );
          
          expandedHistories.add(eventHistory);
        }
      } else {
        // 没有多个事件，直接添加原始历史记录
        expandedHistories.add(history);
      }
    }
    
    // 按日期分组展开后的历史记录
    for (final history in expandedHistories) {
      final dateKey = DateFormat('yyyy-MM-dd').format(history.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(history);
    }
    
    return grouped.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      return DateGroup(
        date: date,
        histories: entry.value..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
      );
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Widget _buildDateGroup(DateGroup dateGroup) {
    final isToday = _isToday(dateGroup.date);
    final isYesterday = _isYesterday(dateGroup.date);
    
    String dateLabel;
    if (isToday) {
      dateLabel = '今天';
    } else if (isYesterday) {
      dateLabel = '昨天';
    } else {
      dateLabel = DateFormat('MM月dd日').format(dateGroup.date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Container(
          margin: const EdgeInsets.only(
            bottom: NothingTheme.spacingMedium,
            top: NothingTheme.spacingLarge,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: NothingTheme.spacingMedium,
                  vertical: NothingTheme.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: isToday ? NothingTheme.nothingYellow : NothingTheme.nothingLightGray,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                ),
                child: Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: isToday ? NothingTheme.nothingBlack : NothingTheme.nothingGray,
                  ),
                ),
              ),
              const SizedBox(width: NothingTheme.spacingMedium),
              Expanded(
                child: Container(
                  height: 1,
                  color: NothingTheme.nothingLightGray,
                ),
              ),
            ],
          ),
        ),
        // 时间轴项目
        ..._buildExpandedTimelineItems(dateGroup.histories),
      ],
    );
  }

  /// 构建时间轴项目列表（多事件已在日期分组中展开）
  List<Widget> _buildExpandedTimelineItems(List<AnalysisHistory> histories) {
    final List<Widget> items = [];
    
    for (int index = 0; index < histories.length; index++) {
      final history = histories[index];
      final isLast = index == histories.length - 1;
      items.add(_buildTimelineItem(history, isLast));
    }
    
    return items;
  }

  Widget _buildTimelineItem(AnalysisHistory history, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间轴线条和节点
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // 节点
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getModeColor(history.mode),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NothingTheme.nothingWhite,
                      width: 2,
                    ),
                  ),
                ),
                // 连接线
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: NothingTheme.nothingLightGray,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          // 内容卡片
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: NothingTheme.spacingMedium),
              child: GestureDetector(
                onTap: () => widget.onItemTap?.call(history),
                child: Container(
                  decoration: BoxDecoration(
                    color: NothingTheme.surface,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                    border: Border.all(color: NothingTheme.gray200, width: 1),
                  ),
                  padding: const EdgeInsets.all(NothingTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题行
                      Row(
                        children: [
                          Icon(
                            _getModeIcon(history.mode),
                            size: 16,
                            color: _getModeColor(history.mode),
                          ),
                          const SizedBox(width: NothingTheme.spacingSmall),
                          Expanded(
                            child: Text(
                              history.result.title, // 使用专业、亲和且自然的原始风格
                              style: const TextStyle(
                                fontSize: NothingTheme.fontSizeBody,
                                fontWeight: NothingTheme.fontWeightMedium,
                                color: NothingTheme.nothingBlack,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(history.timestamp),
                            style: const TextStyle(
                              fontSize: NothingTheme.fontSizeCaption,
                              color: NothingTheme.nothingGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NothingTheme.spacingSmall),
                      // 详细信息
                      if (history.result.subInfo != null) ...[
                        if (history.mode == 'travel') ...[
                          _buildTravelSummary(history.result.subInfo!),
                          const SizedBox(height: NothingTheme.spacingSmall),
                        ] else ...[
                          Text(
                            history.result.subInfo ?? '暂无详细信息', // 使用原始风格的附加信息
                            style: TextStyle(
                              fontSize: NothingTheme.fontSizeCaption,
                              color: NothingTheme.nothingGray,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: NothingTheme.spacingSmall),
                        ],
                      ],
                      // 底部信息
                      Row(
                        children: [
                          // 分析类型标签
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: NothingTheme.spacingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: history.isRealtimeAnalysis 
                                  ? NothingTheme.successGreen.withValues(alpha: 0.1)
                                  : NothingTheme.infoBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                            ),
                            child: Text(
                              history.isRealtimeAnalysis ? '实时分析' : '手动拍照',
                              style: TextStyle(
                                fontSize: NothingTheme.fontSizeCaption,
                                fontWeight: NothingTheme.fontWeightMedium,
                                color: history.isRealtimeAnalysis 
                                    ? NothingTheme.successGreen
                                    : NothingTheme.infoBlue,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // 置信度
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: NothingTheme.spacingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: NothingTheme.nothingYellow,
                              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                            ),
                            child: Text(
                              '置信度：${history.result.confidence}%', // 清晰专业表达
                              style: const TextStyle(
                                fontSize: NothingTheme.fontSizeCaption,
                                fontWeight: NothingTheme.fontWeightBold,
                                color: NothingTheme.nothingBlack,
                              ),
                            ),
                          ),
                          // 删除按钮
                          if (widget.onItemDelete != null) ...[
                            const SizedBox(width: NothingTheme.spacingSmall),
                            Builder(
                              builder: (context) => GestureDetector(
                                onTap: widget.onItemDelete != null ? () => _showDeleteDialog(context, history, widget.onItemDelete!) : null,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: NothingTheme.nothingDarkGray.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: NothingTheme.nothingDarkGray,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  // 新增：获取模式颜色
  Color _getModeColor(String mode) {
    switch (mode) {
      case 'normal':
        return NothingTheme.infoBlue;
      case 'pet':
        return NothingTheme.successGreen;
      case 'health':
        return NothingTheme.warningOrange;
      case 'travel':
        return NothingTheme.nothingYellow;
      default:
        return NothingTheme.nothingGray;
    }
  }

  // 新增：获取模式图标
  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'normal':
        return Icons.camera_alt;
      case 'pet':
        return Icons.pets;
      case 'health':
        return Icons.health_and_safety;
      case 'travel':
        return Icons.travel_explore;
      default:
        return Icons.analytics;
    }
  }



  void _showDeleteDialog(BuildContext context, AnalysisHistory history, Function(AnalysisHistory) onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NothingTheme.nothingWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
        ),
        title: const Text(
          '删除记录',
          style: TextStyle(
            fontSize: NothingTheme.fontSizeHeadline,
            fontWeight: NothingTheme.fontWeightBold,
            color: NothingTheme.nothingBlack,
          ),
        ),
        content: Text(
          '确定要删除这条分析记录吗？\n\n"${history.result.title}"\n\n此操作无法撤销。',
          style: const TextStyle(
            fontSize: NothingTheme.fontSizeBody,
            color: NothingTheme.nothingGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                color: NothingTheme.nothingGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(history);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NothingTheme.nothingDarkGray,
              foregroundColor: NothingTheme.nothingWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              ),
            ),
            child: const Text(
              '删除',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                fontWeight: NothingTheme.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 日期分组数据模型
class DateGroup {
  final DateTime date;
  final List<AnalysisHistory> histories;

  DateGroup({
    required this.date,
    required this.histories,
  });
}


  // 旅行模式的结构化摘要
  Widget _buildTravelSummary(String subInfoText) {
    final data = _parseTravelSubInfo(subInfoText);
    if (data == null) {
      return Text(
        '暂无结构化出行信息',
        style: TextStyle(
          fontSize: NothingTheme.fontSizeCaption,
          color: NothingTheme.nothingGray,
        ),
      );
    }

    final scene = data['scene_analysis'] as Map<String, dynamic>? ?? {};
    final rec = data['recommendations'] as Map<String, dynamic>? ?? {};

    final sceneType = scene['type']?.toString() ?? '未知场景';
    final location = scene['location']?.toString() ?? '未知位置';
    final weather = scene['weather']?.toString() ?? '未知天气';
    final safety = scene['safety_level']?.toString().toUpperCase() ?? 'MEDIUM';

    final activities = (rec['activities'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final safetyTips = (rec['safety_tips'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final travelAdvice = (rec['travel_advice'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];

    Color badgeColor;
    String badgeText;
    switch (safety) {
      case 'LOW':
        badgeColor = NothingTheme.successGreen;
        badgeText = '安全风险低';
        break;
      case 'HIGH':
        badgeColor = NothingTheme.error;
        badgeText = '安全风险高';
        break;
      default:
        badgeColor = NothingTheme.warningOrange;
        badgeText = '安全风险中';
    }

    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      decoration: BoxDecoration(
        color: NothingTheme.nothingWhite,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
        border: Border.all(color: NothingTheme.nothingLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 安全徽章与场景信息
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: NothingTheme.spacingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: badgeColor,
                    ),
                    const SizedBox(width: NothingTheme.spacingXSmall),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeCaption,
                        fontWeight: NothingTheme.fontWeightMedium,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                weather,
                style: const TextStyle(
                  fontSize: NothingTheme.fontSizeCaption,
                  color: NothingTheme.nothingGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: NothingTheme.spacingSmall),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 16, color: NothingTheme.nothingGray),
              const SizedBox(width: NothingTheme.spacingXSmall),
              Expanded(
                child: Text(
                  '$sceneType · $location',
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    color: NothingTheme.nothingBlack,
                  ),
                ),
              ),
            ],
          ),

          // 推荐活动
          if (activities.isNotEmpty) ...[
            const SizedBox(height: NothingTheme.spacingSmall),
            _sectionTitle('推荐活动', Icons.directions_walk_outlined),
            const SizedBox(height: NothingTheme.spacingXSmall),
            Wrap(
              spacing: NothingTheme.spacingXSmall,
              runSpacing: NothingTheme.spacingXSmall,
              children: activities.map((a) => _chip(a)).toList(),
            ),
          ],

          // 安全提示
          if (safetyTips.isNotEmpty) ...[
            const SizedBox(height: NothingTheme.spacingSmall),
            _sectionTitle('安全提示', Icons.shield_outlined),
            const SizedBox(height: NothingTheme.spacingXSmall),
            Wrap(
              spacing: NothingTheme.spacingXSmall,
              runSpacing: NothingTheme.spacingXSmall,
              children: safetyTips.map((s) => _chip(s)).toList(),
            ),
          ],

          // 旅行建议
          if (travelAdvice.isNotEmpty) ...[
            const SizedBox(height: NothingTheme.spacingSmall),
            _sectionTitle('旅行建议', Icons.map_outlined),
            const SizedBox(height: NothingTheme.spacingXSmall),
            Wrap(
              spacing: NothingTheme.spacingXSmall,
              runSpacing: NothingTheme.spacingXSmall,
              children: travelAdvice.map((t) => _chip(t)).toList(),
            ),
          ],

          if (activities.isEmpty && safetyTips.isEmpty && travelAdvice.isEmpty) ...[
            const SizedBox(height: NothingTheme.spacingSmall),
            _emptyHint('暂无详细建议'),
          ],
        ],
      ),
    );
  }

  // 解析 subInfo 文本为结构化 Map
  Map<String, dynamic>? _parseTravelSubInfo(String text) {
    dynamic parsed;
    try {
      parsed = jsonDecode(text);
    } catch (_) {
      // 尝试提取嵌套JSON
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (match != null) {
        try {
          parsed = jsonDecode(match.group(0)!);
        } catch (_) {
          return null;
        }
      } else {
        return null;
      }
    }

    if (parsed is Map<String, dynamic>) {
      // 如果包含 scene_analysis 与 recommendations，直接返回
      if (parsed.containsKey('scene_analysis') && parsed.containsKey('recommendations')) {
        return parsed;
      }
      // 如果是 API 顶层响应，尝试从 subInfo 中提取内部结构
      final sub = parsed['subInfo'];
      if (sub is String) {
        try {
          final inner = jsonDecode(sub);
          if (inner is Map<String, dynamic>) return inner;
        } catch (_) {
          final match = RegExp(r'\{[\s\S]*\}').firstMatch(sub);
          if (match != null) {
            try {
              final inner = jsonDecode(match.group(0)!);
              if (inner is Map<String, dynamic>) return inner;
            } catch (_) {}
          }
        }
      }
    }
    return null;
  }

  // 辅助：小节标题
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: NothingTheme.nothingGray),
        const SizedBox(width: NothingTheme.spacingXSmall),
        Text(
          title,
          style: const TextStyle(
            fontSize: NothingTheme.fontSizeCaption,
            fontWeight: NothingTheme.fontWeightMedium,
            color: NothingTheme.nothingBlack,
          ),
        ),
      ],
    );
  }

  // 辅助：信息标签
  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NothingTheme.spacingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: NothingTheme.nothingLightGray.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: NothingTheme.fontSizeCaption,
          color: NothingTheme.nothingBlack,
        ),
      ),
    );
  }

  // 辅助：空内容提示
  Widget _emptyHint(String text) => Text(
        text,
        style: TextStyle(
          color: NothingTheme.nothingDarkGray,
          fontSize: NothingTheme.fontSizeCaption,
        ),
      );