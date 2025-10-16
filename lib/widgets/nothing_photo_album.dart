import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/nothing_theme.dart';
import '../models/analysis_history.dart';
import '../services/history_notifier.dart';

/// Nothing OS风格的相册组件
class NothingPhotoAlbum extends StatefulWidget {
  final List<AnalysisHistory> histories;
  final Function(AnalysisHistory)? onPhotoTap;

  const NothingPhotoAlbum({
    super.key,
    required this.histories,
    this.onPhotoTap,
  });

  @override
  State<NothingPhotoAlbum> createState() => _NothingPhotoAlbumState();
}

class _NothingPhotoAlbumState extends State<NothingPhotoAlbum> {
  String _selectedFilter = 'all';
  List<AnalysisHistory> _currentHistories = [];
  StreamSubscription<HistoryEvent>? _historySubscription;

  final List<AlbumFilter> _filters = [
    AlbumFilter('all', '全部', Icons.photo_library),
    AlbumFilter('pet', '宠物', Icons.pets),
    AlbumFilter('health', '健康', Icons.health_and_safety),
    AlbumFilter('travel', '旅行', Icons.luggage),
    AlbumFilter('normal', '日常', Icons.camera_alt),
  ];

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
  void didUpdateWidget(NothingPhotoAlbum oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.histories != oldWidget.histories) {
      _currentHistories = List.from(widget.histories);
    }
  }

  /// 设置历史记录变化监听器
  void _setupHistoryListener() {
    _historySubscription = HistoryNotifier.instance.historyStream.listen((
      event,
    ) {
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
                final index = _currentHistories.indexWhere(
                  (h) => h.id == event.history!.id,
                );
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
    final filteredHistories = _getFilteredHistories();

    return Column(
      children: [
        // 过滤器
        _buildFilterBar(),
        // 相册网格
        Expanded(
          child: filteredHistories.isEmpty
              ? _buildEmptyState()
              : _buildPhotoGrid(filteredHistories),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: NothingTheme.spacingSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: NothingTheme.spacingMedium,
        ),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter.key;

          return Container(
            margin: const EdgeInsets.only(right: NothingTheme.spacingSmall),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.icon,
                    size: 16,
                    color: isSelected
                        ? NothingTheme.nothingBlack
                        : NothingTheme.nothingGray,
                  ),
                  const SizedBox(width: NothingTheme.spacingSmall),
                  Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: NothingTheme.fontSizeCaption,
                      fontWeight: isSelected
                          ? NothingTheme.fontWeightMedium
                          : NothingTheme.fontWeightRegular,
                      color: isSelected
                          ? NothingTheme.nothingBlack
                          : NothingTheme.nothingGray,
                    ),
                  ),
                ],
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter.key;
                });
              },
              backgroundColor: NothingTheme.nothingWhite,
              selectedColor: NothingTheme.nothingYellow,
              side: BorderSide(
                color: isSelected
                    ? NothingTheme.nothingYellow
                    : NothingTheme.nothingLightGray,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: NothingTheme.nothingGray,
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          Text(
            '暂无照片',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBody,
              color: NothingTheme.nothingGray,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingSmall),
          Text(
            '开始拍摄来记录美好时刻',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeCaption,
              color: NothingTheme.nothingGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<AnalysisHistory> histories) {
    // 按月份分组
    final groupedHistories = _groupHistoriesByMonth(histories);

    return ListView.builder(
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      itemCount: groupedHistories.length,
      itemBuilder: (context, index) {
        final monthGroup = groupedHistories[index];
        return _buildMonthGroup(monthGroup);
      },
    );
  }

  List<MonthGroup> _groupHistoriesByMonth(List<AnalysisHistory> histories) {
    final Map<String, List<AnalysisHistory>> grouped = {};

    for (final history in histories) {
      final monthKey = DateFormat('yyyy-MM').format(history.timestamp);
      grouped.putIfAbsent(monthKey, () => []).add(history);
    }

    return grouped.entries.map((entry) {
      final date = DateTime.parse('${entry.key}-01');
      return MonthGroup(
        date: date,
        histories: entry.value
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
      );
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Widget _buildMonthGroup(MonthGroup monthGroup) {
    final monthLabel = DateFormat('yyyy年MM月').format(monthGroup.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 月份标题
        Container(
          margin: const EdgeInsets.only(
            bottom: NothingTheme.spacingMedium,
            top: NothingTheme.spacingLarge,
          ),
          child: Row(
            children: [
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: NothingTheme.fontSizeHeadline,
                  fontWeight: NothingTheme.fontWeightBold,
                  color: NothingTheme.nothingBlack,
                ),
              ),
              const SizedBox(width: NothingTheme.spacingMedium),
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
                  '${monthGroup.histories.length}张',
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeCaption,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.nothingBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 照片网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: NothingTheme.spacingSmall,
            mainAxisSpacing: NothingTheme.spacingSmall,
            childAspectRatio: 1.0,
          ),
          itemCount: monthGroup.histories.length,
          itemBuilder: (context, index) {
            final history = monthGroup.histories[index];
            return _buildPhotoItem(history);
          },
        ),
        const SizedBox(height: NothingTheme.spacingLarge),
      ],
    );
  }

  Widget _buildPhotoItem(AnalysisHistory history) {
    return GestureDetector(
      onTap: () => widget.onPhotoTap?.call(history),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
          boxShadow: NothingTheme.nothingShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 照片
              history.imagePath != null
                  ? Image.file(
                      File(history.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
              // 渐变遮罩
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      NothingTheme.nothingBlack.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              // 信息覆盖层
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(NothingTheme.spacingSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 模式图标
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: _getModeColor(history.mode),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getModeIcon(history.mode),
                              size: 12,
                              color: NothingTheme.nothingWhite,
                            ),
                          ),
                          const Spacer(),
                          // 分析类型标识
                          if (history.isRealtimeAnalysis)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: NothingTheme.successGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // 时间
                      Text(
                        DateFormat('HH:mm').format(history.timestamp),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: NothingTheme.fontWeightMedium,
                          color: NothingTheme.nothingWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: NothingTheme.nothingLightGray,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: NothingTheme.nothingGray,
        ),
      ),
    );
  }

  List<AnalysisHistory> _getFilteredHistories() {
    if (_selectedFilter == 'all') {
      return _currentHistories;
    }
    return _currentHistories
        .where((history) => history.mode == _selectedFilter)
        .toList();
  }

  Color _getModeColor(String mode) {
    switch (mode) {
      case 'normal':
        return NothingTheme.infoBlue;
      case 'pet':
        return NothingTheme.successGreen;
      case 'health':
        return NothingTheme.successGreen; // 改为绿色，表示健康关怀
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
}

/// 相册过滤器数据模型
class AlbumFilter {
  final String key;
  final String label;
  final IconData icon;

  AlbumFilter(this.key, this.label, this.icon);
}

/// 月份分组数据模型
class MonthGroup {
  final DateTime date;
  final List<AnalysisHistory> histories;

  MonthGroup({required this.date, required this.histories});
}
