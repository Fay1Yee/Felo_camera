import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/nothing_theme.dart';
import '../models/analysis_history.dart';
import '../utils/pet_conversation_helper.dart';

/// Nothing OS风格的时间轴组件
class NothingTimeline extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (histories.isEmpty) {
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
    final groupedHistories = _groupHistoriesByDate(histories);
    
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
    
    for (final history in histories) {
      final dateKey = DateFormat('yyyy-MM-dd').format(history.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(history);
    }
    
    return grouped.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      return DateGroup(
        date: date,
        histories: entry.value..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
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
        ...dateGroup.histories.asMap().entries.map((entry) {
          final index = entry.key;
          final history = entry.value;
          final isLast = index == dateGroup.histories.length - 1;
          
          return _buildTimelineItem(history, isLast);
        }),
      ],
    );
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
                onTap: () => onItemTap?.call(history),
                child: Container(
                  decoration: NothingTheme.nothingCardDecoration,
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
                              PetConversationHelper.convertToPetTone(history.result).title, // 使用宠物语气标题
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
                        Text(
                          PetConversationHelper.convertToPetTone(history.result).subInfo ?? '暂无详细信息', // 使用宠物语气子信息
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeCaption,
                            color: NothingTheme.nothingGray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: NothingTheme.spacingSmall),
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
                              borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
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
                              borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
                            ),
                            child: Text(
                              PetConversationHelper.getConfidenceExpression(history.result.confidence), // 使用友好的置信度表达
                              style: const TextStyle(
                                fontSize: NothingTheme.fontSizeCaption,
                                fontWeight: NothingTheme.fontWeightBold,
                                color: NothingTheme.nothingBlack,
                              ),
                            ),
                          ),
                          // 删除按钮
                          if (onItemDelete != null) ...[
                            const SizedBox(width: NothingTheme.spacingSmall),
                            Builder(
                              builder: (context) => GestureDetector(
                                onTap: onItemDelete != null ? () => _showDeleteDialog(context, history, onItemDelete!) : null,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: NothingTheme.nothingDarkGray.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
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