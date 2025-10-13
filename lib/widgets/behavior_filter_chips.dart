import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class BehaviorFilterChips extends StatefulWidget {
  final String? selectedBehavior;
  final Function(String?) onBehaviorChanged;
  final List<String> availableBehaviors;

  const BehaviorFilterChips({
    super.key,
    this.selectedBehavior,
    required this.onBehaviorChanged,
    this.availableBehaviors = const [
      '进食',
      '玩耍',
      '休息',
      '运动',
      '清洁',
      '健康检查',
      '社交',
      '其他',
    ],
  });

  @override
  State<BehaviorFilterChips> createState() => _BehaviorFilterChipsState();
}

class _BehaviorFilterChipsState extends State<BehaviorFilterChips> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 20,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '行为类型筛选',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: NothingTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              if (widget.selectedBehavior != null)
                TextButton(
                  onPressed: () => widget.onBehaviorChanged(null),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(
                    '清除',
                    style: TextStyle(
                      fontSize: 14,
                      color: NothingTheme.accentPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 全部选项
              _buildFilterChip(
                label: '全部',
                isSelected: widget.selectedBehavior == null,
                onTap: () => widget.onBehaviorChanged(null),
                icon: Icons.all_inclusive,
              ),
              // 行为类型选项
              ...widget.availableBehaviors.map((behavior) => _buildFilterChip(
                label: behavior,
                isSelected: widget.selectedBehavior == behavior,
                onTap: () => widget.onBehaviorChanged(behavior),
                icon: _getBehaviorIcon(behavior),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? NothingTheme.accentPrimary.withOpacity(0.1)
              : NothingTheme.surface,
          borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
          border: Border.all(
            color: isSelected 
                ? NothingTheme.accentPrimary
                : NothingTheme.gray300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: NothingTheme.accentPrimary.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected 
                    ? NothingTheme.accentPrimary
                    : NothingTheme.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? NothingTheme.accentPrimary
                      : NothingTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
           ],
         ),
      ),
    );
  }

  IconData _getBehaviorIcon(String behavior) {
    switch (behavior) {
      case '进食':
        return Icons.restaurant;
      case '玩耍':
        return Icons.sports_esports;
      case '休息':
        return Icons.bedtime;
      case '运动':
        return Icons.directions_run;
      case '清洁':
        return Icons.cleaning_services;
      case '健康检查':
        return Icons.health_and_safety;
      case '社交':
        return Icons.people;
      case '其他':
        return Icons.more_horiz;
      default:
        return Icons.pets;
    }
  }
}