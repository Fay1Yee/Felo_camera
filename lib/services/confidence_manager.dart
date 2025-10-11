import 'package:flutter/foundation.dart';

/// 置信度管理器 - 处理动态阈值和多层次置信度系统
class ConfidenceManager {
  static const Map<String, int> _defaultThresholds = {
    'normal': 70,
    'pet': 75,
    'health': 80,
    'travel': 85,
  };

  static const Map<String, int> _minThresholds = {
    'normal': 60,
    'pet': 65,
    'health': 70,
    'travel': 75,
  };

  /// 获取动态置信度阈值
  static int getDynamicThreshold(String mode, {int? userPreference}) {
    final defaultThreshold = _defaultThresholds[mode.toLowerCase()] ?? _defaultThresholds['normal']!;
    final result = userPreference?.clamp(30, 95) ?? defaultThreshold;
    print('🎯 动态阈值获取 - 模式: $mode, 默认: $defaultThreshold, 用户偏好: $userPreference, 最终: $result');
    return result;
  }

  /// 获取最小置信度阈值
  static int getMinThreshold(String mode) {
    final result = _minThresholds[mode.toLowerCase()] ?? _minThresholds['normal']!;
    print('📊 最小阈值获取 - 模式: $mode, 阈值: $result');
    return result;
  }

  /// 评估置信度质量
  static ConfidenceQuality evaluateConfidence(int confidence, String mode) {
    final threshold = getDynamicThreshold(mode);
    final minThreshold = getMinThreshold(mode);
    
    ConfidenceQuality evaluation;
    if (confidence >= threshold + 15) {
      evaluation = ConfidenceQuality.excellent;
    } else if (confidence >= threshold) {
      evaluation = ConfidenceQuality.good;
    } else if (confidence >= minThreshold) {
      evaluation = ConfidenceQuality.acceptable;
    } else {
      evaluation = ConfidenceQuality.poor;
    }
    
    print('📈 置信度评估 - 置信度: $confidence, 模式: $mode, 阈值: $threshold, 最小阈值: $minThreshold, 评估: $evaluation');
    return evaluation;
  }

  /// 获取置信度建议
  static String getConfidenceAdvice(int confidence, String mode) {
    final quality = evaluateConfidence(confidence, mode);
    
    String advice;
    switch (quality) {
      case ConfidenceQuality.excellent:
        advice = '分析结果非常可靠';
        break;
      case ConfidenceQuality.good:
        advice = '分析结果较为可靠';
        break;
      case ConfidenceQuality.acceptable:
        advice = '分析结果仅供参考';
        break;
      case ConfidenceQuality.poor:
        advice = '分析结果不够可靠，建议重新拍摄';
        break;
    }
    
    print('💡 置信度建议 - 置信度: $confidence, 模式: $mode, 质量: $quality, 建议: $advice');
    return advice;
  }

  /// 应该保存到历史记录吗？
  static bool shouldSaveToHistory(int confidence, String mode) {
    final minThreshold = getMinThreshold(mode);
    final shouldSave = confidence >= minThreshold;
    print('💾 历史记录判断 - 置信度: $confidence, 最小阈值: $minThreshold, 是否保存: $shouldSave');
    return shouldSave;
  }

  /// 计算综合置信度分数
  static ConfidenceMetrics calculateMetrics(
    int confidence,
    String mode, {
    double? imageQuality,
    double? analysisTime,
    bool? hasApiResponse,
  }) {
    final quality = evaluateConfidence(confidence, mode);
    final threshold = getDynamicThreshold(mode);
    
    print('📊 置信度指标计算开始 - 原始置信度: $confidence, 模式: $mode, 阈值: $threshold');
    
    // 计算相对分数 (0-100)
    double relativeScore = (confidence / threshold * 100).clamp(0, 100);
    print('📈 基础相对分数: ${relativeScore.toStringAsFixed(1)}');
    
    // 图像质量影响
    if (imageQuality != null) {
      final oldScore = relativeScore;
      relativeScore *= (0.7 + imageQuality * 0.3);
      print('🖼️ 图像质量调整: $imageQuality -> ${oldScore.toStringAsFixed(1)} -> ${relativeScore.toStringAsFixed(1)}');
    }
    
    // 分析时间影响 (快速分析可能不够准确)
    if (analysisTime != null) {
      final oldScore = relativeScore;
      if (analysisTime < 0.5) {
        relativeScore *= 0.9; // 太快可能不准确
        print('⚡ 分析时间过快调整: ${analysisTime}s -> ${oldScore.toStringAsFixed(1)} -> ${relativeScore.toStringAsFixed(1)} (×0.9)');
      } else if (analysisTime > 10.0) {
        relativeScore *= 0.95; // 太慢可能有问题
        print('🐌 分析时间过慢调整: ${analysisTime}s -> ${oldScore.toStringAsFixed(1)} -> ${relativeScore.toStringAsFixed(1)} (×0.95)');
      } else {
        print('⏱️ 分析时间正常: ${analysisTime}s，无调整');
      }
    }
    
    // API响应影响
    if (hasApiResponse == false) {
      final oldScore = relativeScore;
      relativeScore *= 0.8; // 本地分析置信度降低
      print('🔌 无API响应调整: ${oldScore.toStringAsFixed(1)} -> ${relativeScore.toStringAsFixed(1)} (×0.8)');
    } else if (hasApiResponse == true) {
      print('🌐 有API响应，无调整');
    }
    
    final finalScore = relativeScore.round();
    print('🎯 最终置信度指标 - 原始: $confidence, 调整后: $finalScore, 质量: $quality');
    
    return ConfidenceMetrics(
      rawConfidence: confidence,
      adjustedScore: finalScore,
      quality: quality,
      threshold: threshold,
      advice: getConfidenceAdvice(confidence, mode),
    );
  }
}

/// 置信度质量等级
enum ConfidenceQuality {
  excellent, // 优秀 (>= threshold + 15)
  good,      // 良好 (>= threshold)
  acceptable, // 可接受 (>= minThreshold)
  poor,      // 较差 (< minThreshold)
}

/// 置信度指标
class ConfidenceMetrics {
  final int rawConfidence;      // 原始置信度
  final int adjustedScore;      // 调整后分数
  final ConfidenceQuality quality; // 质量等级
  final int threshold;          // 使用的阈值
  final String advice;          // 建议文本

  const ConfidenceMetrics({
    required this.rawConfidence,
    required this.adjustedScore,
    required this.quality,
    required this.threshold,
    required this.advice,
  });

  /// 是否应该显示警告
  bool get shouldShowWarning => quality == ConfidenceQuality.poor;

  /// 是否建议重新分析
  bool get shouldRetry => quality == ConfidenceQuality.poor && rawConfidence < 40;

  /// 获取质量描述
  String get qualityDescription {
    switch (quality) {
      case ConfidenceQuality.excellent:
        return '优秀';
      case ConfidenceQuality.good:
        return '良好';
      case ConfidenceQuality.acceptable:
        return '可接受';
      case ConfidenceQuality.poor:
        return '较差';
    }
  }

  @override
  String toString() {
    return 'ConfidenceMetrics(raw: $rawConfidence, adjusted: $adjustedScore, quality: $qualityDescription)';
  }
}