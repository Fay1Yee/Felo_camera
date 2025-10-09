import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'performance_monitor.dart';
import 'network_manager.dart';

/// 性能优化器 - 根据监控数据自动调整性能参数
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  static PerformanceOptimizer get instance => _instance;

  final PerformanceMonitor _monitor = PerformanceMonitor.instance;
  final NetworkManager _networkManager = NetworkManager.instance;

  Timer? _optimizationTimer;
  bool _isOptimizing = false;

  /// 优化配置
  final OptimizationConfig _config = OptimizationConfig();

  /// 开始自动优化
  void startAutoOptimization() {
    if (_optimizationTimer != null) return;

    _optimizationTimer = Timer.periodic(
      Duration(seconds: _config.optimizationInterval),
      (_) => _performOptimization(),
    );
  }

  /// 停止自动优化
  void stopAutoOptimization() {
    _optimizationTimer?.cancel();
    _optimizationTimer = null;
  }

  /// 执行优化
  Future<void> _performOptimization() async {
    if (_isOptimizing) return;
    _isOptimizing = true;

    try {
      final stats = await _monitor.getPerformanceStats();
      
      // 优化网络配置
      await _optimizeNetworkConfig(stats);
      
      // 优化图像处理参数
      await _optimizeImageProcessing(stats);
      
    } catch (e) {
      debugPrint('Performance optimization error: $e');
    } finally {
      _isOptimizing = false;
    }
  }

  /// 优化网络配置
  Future<void> _optimizeNetworkConfig(PerformanceStats stats) async {
    final endpointStats = _monitor.getEndpointStats();
    
    for (final endpoint in endpointStats.keys) {
      final stat = endpointStats[endpoint]!;
      
      // 根据响应时间调整重试策略
      if (stat.averageResponseTime > _config.highResponseTimeThreshold) {
        debugPrint('High response time detected for $endpoint: ${stat.averageResponseTime}ms');
        // 可以在这里实现具体的网络优化逻辑
      }
      
      // 根据成功率调整重试策略
      if (stat.successRate < _config.lowSuccessRateThreshold) {
        debugPrint('Low success rate detected for $endpoint: ${stat.successRate}');
        // 可以在这里实现具体的重试优化逻辑
      }
    }
  }

  /// 优化图像处理参数
  Future<void> _optimizeImageProcessing(PerformanceStats stats) async {
    // 根据API调用频率调整图像质量
    if (stats.recent1hCalls > _config.highApiCallThreshold) {
      // API调用频率高，降低图像质量以减少处理负担
      _config.imageQuality = max(0.5, _config.imageQuality - 0.1);
      debugPrint('Reduced image quality to ${_config.imageQuality} due to high API call frequency');
    } else if (stats.recent1hCalls < _config.lowApiCallThreshold) {
      // API调用频率低，可以提高图像质量
      _config.imageQuality = min(1.0, _config.imageQuality + 0.1);
      debugPrint('Increased image quality to ${_config.imageQuality} due to low API call frequency');
    }
  }

  /// 获取当前优化配置
  OptimizationConfig get config => _config;

  /// 手动触发优化
  Future<void> optimize() async {
    await _performOptimization();
  }

  /// 重置优化配置
  void resetConfig() {
    _config.reset();
  }

  /// 释放资源
  void dispose() {
    stopAutoOptimization();
  }
}

/// 优化配置
class OptimizationConfig {
  // 网络性能阈值
  int highResponseTimeThreshold = 5000; // ms
  double lowSuccessRateThreshold = 0.8;
  
  // API调用频率阈值
  int highApiCallThreshold = 100; // 每小时调用次数
  int lowApiCallThreshold = 10;   // 每小时调用次数
  
  // 图像质量
  double imageQuality = 0.8;
  
  // 优化间隔 (秒)
  int optimizationInterval = 30;

  /// 重置为默认值
  void reset() {
    highResponseTimeThreshold = 5000;
    lowSuccessRateThreshold = 0.8;
    highApiCallThreshold = 100;
    lowApiCallThreshold = 10;
    imageQuality = 0.8;
    optimizationInterval = 30;
  }
}

/// 优化建议
class OptimizationSuggestion {
  final String category;
  final String description;
  final String action;
  final double impact; // 预期影响 (0-1)
  final DateTime timestamp;

  OptimizationSuggestion({
    required this.category,
    required this.description,
    required this.action,
    required this.impact,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'category': category,
    'description': description,
    'action': action,
    'impact': impact,
    'timestamp': timestamp.toIso8601String(),
  };
}