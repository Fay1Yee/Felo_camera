import 'package:flutter/material.dart';

/// 性格特征
class PersonalityTrait {
  final String name;
  final double intensity;
  final Color color;
  final String? description;

  const PersonalityTrait({
    required this.name,
    required this.intensity,
    required this.color,
    this.description,
  });

  /// 从JSON创建实例
  factory PersonalityTrait.fromJson(Map<String, dynamic> json) {
    return PersonalityTrait(
      name: json['name'] ?? '',
      intensity: (json['intensity'] ?? 0.5).toDouble(),
      color: Color(json['color'] ?? 0xFF2196F3),
      description: json['description'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'intensity': intensity,
      'color': color.value,
      'description': description,
    };
  }

  /// 获取强度描述
  String get intensityDescription {
    if (intensity >= 0.8) return '非常明显';
    if (intensity >= 0.6) return '比较明显';
    if (intensity >= 0.4) return '一般';
    if (intensity >= 0.2) return '较弱';
    return '很弱';
  }

  /// 复制并修改属性
  PersonalityTrait copyWith({
    String? name,
    double? intensity,
    Color? color,
    String? description,
  }) {
    return PersonalityTrait(
      name: name ?? this.name,
      intensity: intensity ?? this.intensity,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }
}