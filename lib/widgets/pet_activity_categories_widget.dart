import 'package:flutter/material.dart';
import '../services/pet_activity_data_service.dart';
import '../config/nothing_theme.dart';

/// 宠物活动分类展示组件
class PetActivityCategoriesWidget extends StatefulWidget {
  const PetActivityCategoriesWidget({super.key});

  @override
  State<PetActivityCategoriesWidget> createState() =>
      _PetActivityCategoriesWidgetState();
}

class _PetActivityCategoriesWidgetState
    extends State<PetActivityCategoriesWidget> {
  bool _isLoading = true;
  String? _selectedCategory;
  List<PetActivityEvent> _selectedEvents = [];
  PetActivitySummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final success = await PetActivityDataService.instance.loadCategorizedData();

    if (success) {
      _summary = PetActivityDataService.instance.getSummary();
      final types = PetActivityDataService.instance.getActivityTypes();
      if (types.isNotEmpty) {
        _selectedCategory = types.first;
        _selectedEvents = PetActivityDataService.instance.getEventsByType(
          _selectedCategory!,
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedEvents = PetActivityDataService.instance.getEventsByType(
        category,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.brandPrimary),
        ),
      );
    }

    if (_summary == null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 16),
        _buildCategoryTabs(),
        const SizedBox(height: 16),
        Expanded(child: _buildEventsList()),
      ],
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
            color: NothingTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无宠物活动数据',
            style: TextStyle(
              fontSize: 18,
              color: NothingTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先解析宠物活动文档',
            style: TextStyle(fontSize: 14, color: NothingTheme.textTertiary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: NothingTheme.brandPrimary,
              foregroundColor: NothingTheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              ),
            ),
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(color: NothingTheme.gray200),
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
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 24,
                color: NothingTheme.brandPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                '宠物活动数据汇总',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: NothingTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  '总事件数',
                  '${_summary!.totalEvents}',
                  Icons.event_note,
                  NothingTheme.brandPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  '活动类型',
                  '${_summary!.activityTypes}',
                  Icons.category,
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: NothingTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = PetActivityDataService.instance.getActivityTypes();

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          final stats = _summary!.typeStats[category];
          final color = PetActivityDataService.instance.getActivityTypeColor(
            category,
          );
          final icon = PetActivityDataService.instance.getActivityTypeIcon(
            category,
          );

          return GestureDetector(
            onTap: () => _onCategorySelected(category),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : NothingTheme.surface,
                borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                border: Border.all(
                  color: isSelected ? color : NothingTheme.gray200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? NothingTheme.surface
                              : NothingTheme.textPrimary,
                        ),
                      ),
                      if (stats != null)
                        Text(
                          '${stats.eventCount}个',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? NothingTheme.surface.withOpacity(0.8)
                                : NothingTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList() {
    if (_selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: 48,
              color: NothingTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '该类型暂无活动记录',
              style: TextStyle(fontSize: 16, color: NothingTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(PetActivityEvent event) {
    final color = PetActivityDataService.instance.getActivityTypeColor(
      _selectedCategory!,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(color: NothingTheme.gray200),
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
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: NothingTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                event.formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 内容
          Text(
            event.content,
            style: TextStyle(
              fontSize: 14,
              color: NothingTheme.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // 标签和置信度
          Row(
            children: [
              // 标签
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: event.tags
                      .take(3)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              NothingTheme.radiusXs,
                            ),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              // 置信度
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(event.confidence).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusXs),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 12,
                      color: _getConfidenceColor(event.confidence),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(event.confidence * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: _getConfidenceColor(event.confidence),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return const Color(0xFF10B981); // 绿色
    if (confidence >= 0.8) return const Color(0xFFF59E0B); // 橙色
    return const Color(0xFFEF4444); // 红色
  }
}