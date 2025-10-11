import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/pet_profile.dart';
import '../services/scenario_manager.dart';

/// 增强版场景选择器
/// 提供更丰富的场景切换UI和功能展示
class EnhancedScenarioSelector extends StatefulWidget {
  final ScenarioMode currentScenario;
  final ValueChanged<ScenarioMode> onScenarioChanged;
  final bool showFeatures;
  final bool showQuickActions;

  const EnhancedScenarioSelector({
    super.key,
    required this.currentScenario,
    required this.onScenarioChanged,
    this.showFeatures = true,
    this.showQuickActions = true,
  });

  @override
  State<EnhancedScenarioSelector> createState() => _EnhancedScenarioSelectorState();
}

class _EnhancedScenarioSelectorState extends State<EnhancedScenarioSelector>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  final ScenarioManager _scenarioManager = ScenarioManager();
  ScenarioMode? _suggestedScenario;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
    _loadSuggestedScenario();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadSuggestedScenario() {
    setState(() {
      _suggestedScenario = _scenarioManager.getSuggestedScenario();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: NothingTheme.blackAlpha10,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildScenarioGrid(),
                  if (widget.showFeatures) _buildRecommendedFeatures(),
                  if (widget.showQuickActions) _buildQuickActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NothingTheme.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune,
                  color: NothingTheme.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: NothingTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '场景模式',
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeLg,
                        fontWeight: NothingTheme.fontWeightSemiBold,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '当前: ${widget.currentScenario.displayName}',
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeSm,
                        color: NothingTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_suggestedScenario != null && _suggestedScenario != widget.currentScenario)
                _buildSuggestionChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip() {
    return GestureDetector(
      onTap: () {
        if (_suggestedScenario != null) {
          widget.onScenarioChanged(_suggestedScenario!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: NothingTheme.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: NothingTheme.warning.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 14,
              color: NothingTheme.warning,
            ),
            const SizedBox(width: 4),
            Text(
              '建议: ${_suggestedScenario!.displayName}',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeXs,
                fontWeight: NothingTheme.fontWeightMedium,
                color: NothingTheme.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NothingTheme.spacingLarge),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: NothingTheme.spacingMedium,
        crossAxisSpacing: NothingTheme.spacingMedium,
        childAspectRatio: 1.3,
        children: ScenarioMode.values.map((mode) {
          final isSelected = mode == widget.currentScenario;
          final isSuggested = mode == _suggestedScenario;
          return _buildScenarioCard(mode, isSelected, isSuggested);
        }).toList(),
      ),
    );
  }

  Widget _buildScenarioCard(ScenarioMode mode, bool isSelected, bool isSuggested) {
    final config = _scenarioManager.getScenarioConfig(mode);
    
    return GestureDetector(
      onTap: () => widget.onScenarioChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(NothingTheme.spacingMedium),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    config.primaryColor.withOpacity(0.1),
                    config.accentColor.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : NothingTheme.surfaceTertiary,
          borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
          border: Border.all(
            color: isSelected
                ? config.primaryColor
                : isSuggested
                    ? NothingTheme.warning.withOpacity(0.5)
                    : NothingTheme.gray300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: config.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标容器
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? config.primaryColor
                    : NothingTheme.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  mode.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            
            const SizedBox(height: NothingTheme.spacingSmall),
            
            // 模式名称
            Text(
              mode.displayName,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBase,
                fontWeight: isSelected
                    ? NothingTheme.fontWeightSemiBold
                    : NothingTheme.fontWeightMedium,
                color: isSelected
                    ? config.primaryColor
                    : NothingTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 2),
            
            // 描述
            Text(
              mode.description,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeXs,
                color: NothingTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // 建议标识
            if (isSuggested && !isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: NothingTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '推荐',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeXs,
                    color: NothingTheme.warning,
                    fontWeight: NothingTheme.fontWeightMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedFeatures() {
    final features = _scenarioManager.getRecommendedFeatures(widget.currentScenario);
    
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐功能',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightSemiBold,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          ...features.take(3).map((feature) => _buildFeatureItem(feature)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(ScenarioFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NothingTheme.spacingSmall),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: NothingTheme.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              feature.icon,
              size: 16,
              color: NothingTheme.brandPrimary,
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeSm,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeXs,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = _scenarioManager.getQuickActions(widget.currentScenario);
    
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快捷操作',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightSemiBold,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          Row(
            children: actions.map((action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: NothingTheme.spacingSmall),
                child: _buildQuickActionButton(action),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(QuickAction action) {
    return GestureDetector(
      onTap: () {
        // 处理快捷操作点击
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('执行操作: ${action.title}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: NothingTheme.spacingMedium,
          horizontal: NothingTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
          border: Border.all(
            color: action.color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              action.icon,
              color: action.color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              action.title,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeXs,
                fontWeight: NothingTheme.fontWeightMedium,
                color: action.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}