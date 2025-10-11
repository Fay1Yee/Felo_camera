import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/pet_profile.dart';

class ScenarioModeSelector extends StatefulWidget {
  final ScenarioMode selectedMode;
  final Function(ScenarioMode) onModeChanged;

  const ScenarioModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  State<ScenarioModeSelector> createState() => _ScenarioModeSelectorState();
}

class _ScenarioModeSelectorState extends State<ScenarioModeSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NothingTheme.gray300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: NothingTheme.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '场景模式',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeLg,
                  fontWeight: NothingTheme.fontWeightSemiBold,
                  color: NothingTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 场景模式网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: ScenarioMode.values.map((mode) {
              final isSelected = mode == widget.selectedMode;
              return _buildModeCard(mode, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(ScenarioMode mode, bool isSelected) {
    return InkWell(
      onTap: () => widget.onModeChanged(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? NothingTheme.brandPrimary.withOpacity(0.1)
              : NothingTheme.surfaceTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? NothingTheme.brandPrimary
                : NothingTheme.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? NothingTheme.brandPrimary
                    : NothingTheme.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  mode.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 模式名称
            Text(
              mode.displayName,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBase,
                fontWeight: isSelected ? NothingTheme.fontWeightSemiBold : NothingTheme.fontWeightMedium,
                color: isSelected 
                    ? NothingTheme.brandPrimary
                    : NothingTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // 描述
            Text(
              mode.description,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeSm,
                color: NothingTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}