import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/pet_profile.dart';

class ScenarioSelector extends StatelessWidget {
  final ScenarioMode currentScenario;
  final ValueChanged<ScenarioMode> onScenarioChanged;

  const ScenarioSelector({
    super.key,
    required this.currentScenario,
    required this.onScenarioChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: ScenarioMode.values.map((scenario) {
          final isSelected = scenario == currentScenario;
          return Expanded(
            child: GestureDetector(
              onTap: () => onScenarioChanged(scenario),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? NothingTheme.brandPrimary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getScenarioIcon(scenario),
                      size: 24,
                      color: isSelected 
                          ? NothingTheme.textPrimary 
                          : NothingTheme.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScenarioName(scenario),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.w500,
                        color: isSelected 
                            ? NothingTheme.textPrimary 
                            : NothingTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getScenarioIcon(ScenarioMode scenario) {
    switch (scenario) {
      case ScenarioMode.home:
        return Icons.home_outlined;
      case ScenarioMode.urban:
        return Icons.location_city_outlined;
      case ScenarioMode.travel:
        return Icons.luggage_outlined;
      case ScenarioMode.medical:
        return Icons.medical_services_outlined;
    }
  }

  String _getScenarioName(ScenarioMode scenario) {
    switch (scenario) {
      case ScenarioMode.home:
        return '居家';
      case ScenarioMode.urban:
        return '城市';
      case ScenarioMode.travel:
        return '出行';
      case ScenarioMode.medical:
        return '医疗';
    }
  }
}