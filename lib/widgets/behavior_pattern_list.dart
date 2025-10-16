import 'package:flutter/material.dart';

class BehaviorPatternList extends StatelessWidget {
  final List<BehaviorPattern> patterns;

  const BehaviorPatternList({
    Key? key,
    required this.patterns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (patterns.isEmpty) {
      return const Center(
        child: Text(
          '暂无行为模式数据',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        return BehaviorPatternCard(pattern: pattern);
      },
    );
  }
}

class BehaviorPatternCard extends StatelessWidget {
  final BehaviorPattern pattern;

  const BehaviorPatternCard({
    Key? key,
    required this.pattern,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getPatternIcon(pattern.category),
                  color: _getPatternColor(pattern.category),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pattern.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        pattern.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getFrequencyColor(pattern.frequency),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getFrequencyText(pattern.frequency),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pattern.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (pattern.examples.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '典型表现：',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: pattern.examples.map((example) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      example,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (pattern.impact.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pattern.impact,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getPatternIcon(String category) {
    switch (category.toLowerCase()) {
      case '社交行为':
        return Icons.people;
      case '活动偏好':
        return Icons.directions_run;
      case '情绪表达':
        return Icons.mood;
      case '学习能力':
        return Icons.school;
      case '适应性':
        return Icons.adjust;
      case '警觉性':
        return Icons.visibility;
      default:
        return Icons.pets;
    }
  }

  Color _getPatternColor(String category) {
    switch (category.toLowerCase()) {
      case '社交行为':
        return Colors.purple;
      case '活动偏好':
        return Colors.green;
      case '情绪表达':
        return Colors.orange;
      case '学习能力':
        return Colors.blue;
      case '适应性':
        return Colors.teal;
      case '警觉性':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getFrequencyColor(double frequency) {
    if (frequency >= 0.8) return Colors.red;
    if (frequency >= 0.6) return Colors.orange;
    if (frequency >= 0.4) return Colors.blue;
    return Colors.grey;
  }

  String _getFrequencyText(double frequency) {
    if (frequency >= 0.8) return '高频';
    if (frequency >= 0.6) return '中频';
    if (frequency >= 0.4) return '低频';
    return '偶发';
  }
}

class BehaviorPattern {
  final String name;
  final String category;
  final String description;
  final double frequency;
  final List<String> examples;
  final String impact;

  const BehaviorPattern({
    required this.name,
    required this.category,
    required this.description,
    required this.frequency,
    this.examples = const [],
    this.impact = '',
  });

  factory BehaviorPattern.fromJson(Map<String, dynamic> json) {
    return BehaviorPattern(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      frequency: (json['frequency'] ?? 0.0).toDouble(),
      examples: List<String>.from(json['examples'] ?? []),
      impact: json['impact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'frequency': frequency,
      'examples': examples,
      'impact': impact,
    };
  }
}

class BehaviorPatternSummary extends StatelessWidget {
  final List<BehaviorPattern> patterns;

  const BehaviorPatternSummary({
    Key? key,
    required this.patterns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryStats = _calculateCategoryStats();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '行为模式统计',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...categoryStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${entry.value}个',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateCategoryStats() {
    final stats = <String, int>{};
    for (final pattern in patterns) {
      stats[pattern.category] = (stats[pattern.category] ?? 0) + 1;
    }
    return stats;
  }
}