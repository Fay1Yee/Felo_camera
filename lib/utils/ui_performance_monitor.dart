import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// UI性能监控工具
/// 用于检测和优化渲染性能问题
class UIPerformanceMonitor {
  static final UIPerformanceMonitor _instance = UIPerformanceMonitor._internal();
  factory UIPerformanceMonitor() => _instance;
  UIPerformanceMonitor._internal();

  bool _isMonitoring = false;
  final List<Duration> _frameTimes = [];
  final int _maxFrameHistory = 60; // 保存最近60帧的数据
  
  /// 开始监控UI性能
  void startMonitoring() {
    if (_isMonitoring || !kDebugMode) return;
    
    _isMonitoring = true;
    _frameTimes.clear();
    
    SchedulerBinding.instance.addTimingsCallback(_onFrameCallback);
    debugPrint('🎯 UI性能监控已启动');
  }
  
  /// 停止监控UI性能
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameCallback);
    debugPrint('🎯 UI性能监控已停止');
  }
  
  /// 帧回调处理
  void _onFrameCallback(List<FrameTiming> timings) {
    if (!_isMonitoring) return;
    
    for (final timing in timings) {
      final frameDuration = timing.totalSpan;
      _frameTimes.add(frameDuration);
      
      // 保持历史记录在限制范围内
      if (_frameTimes.length > _maxFrameHistory) {
        _frameTimes.removeAt(0);
      }
      
      // 检测跳帧问题
      _checkFrameDrops(frameDuration);
    }
  }
  
  /// 检测跳帧问题
  void _checkFrameDrops(Duration frameDuration) {
    const targetFrameTime = Duration(milliseconds: 16); // 60 FPS
    const warningThreshold = Duration(milliseconds: 32); // 30 FPS
    const criticalThreshold = Duration(milliseconds: 48); // 20 FPS
    
    if (frameDuration > criticalThreshold) {
      debugPrint('🔴 严重跳帧警告: ${frameDuration.inMilliseconds}ms (目标: 16ms)');
      HapticFeedback.lightImpact(); // 触觉反馈提醒
    } else if (frameDuration > warningThreshold) {
      debugPrint('🟡 跳帧警告: ${frameDuration.inMilliseconds}ms (目标: 16ms)');
    }
  }
  
  /// 获取性能统计信息
  PerformanceStats getPerformanceStats() {
    if (_frameTimes.isEmpty) {
      return PerformanceStats.empty();
    }
    
    final frameTimesMs = _frameTimes.map((d) => d.inMilliseconds).toList();
    frameTimesMs.sort();
    
    final avgFrameTime = frameTimesMs.reduce((a, b) => a + b) / frameTimesMs.length;
    final p95FrameTime = frameTimesMs[(frameTimesMs.length * 0.95).floor()];
    final maxFrameTime = frameTimesMs.last;
    final minFrameTime = frameTimesMs.first;
    
    final droppedFrames = frameTimesMs.where((time) => time > 16).length;
    final frameDropRate = droppedFrames / frameTimesMs.length;
    
    return PerformanceStats(
      avgFrameTime: avgFrameTime,
      p95FrameTime: p95FrameTime.toDouble(),
      maxFrameTime: maxFrameTime.toDouble(),
      minFrameTime: minFrameTime.toDouble(),
      frameDropRate: frameDropRate,
      totalFrames: frameTimesMs.length,
      droppedFrames: droppedFrames,
    );
  }
  
  /// 打印性能报告
  void printPerformanceReport() {
    final stats = getPerformanceStats();
    if (stats.totalFrames == 0) {
      debugPrint('📊 暂无性能数据');
      return;
    }
    
    debugPrint('📊 UI性能报告:');
    debugPrint('   平均帧时间: ${stats.avgFrameTime.toStringAsFixed(1)}ms');
    debugPrint('   95%帧时间: ${stats.p95FrameTime.toStringAsFixed(1)}ms');
    debugPrint('   最大帧时间: ${stats.maxFrameTime.toStringAsFixed(1)}ms');
    debugPrint('   最小帧时间: ${stats.minFrameTime.toStringAsFixed(1)}ms');
    debugPrint('   跳帧率: ${(stats.frameDropRate * 100).toStringAsFixed(1)}%');
    debugPrint('   总帧数: ${stats.totalFrames}');
    debugPrint('   跳帧数: ${stats.droppedFrames}');
    
    // 性能评级
    String grade = 'A';
    if (stats.frameDropRate > 0.1) grade = 'B';
    if (stats.frameDropRate > 0.2) grade = 'C';
    if (stats.frameDropRate > 0.3) grade = 'D';
    if (stats.frameDropRate > 0.5) grade = 'F';
    
    debugPrint('   性能评级: $grade');
  }
  
  /// 重置性能数据
  void reset() {
    _frameTimes.clear();
    debugPrint('🎯 性能数据已重置');
  }
}

/// 性能统计数据
class PerformanceStats {
  final double avgFrameTime;
  final double p95FrameTime;
  final double maxFrameTime;
  final double minFrameTime;
  final double frameDropRate;
  final int totalFrames;
  final int droppedFrames;
  
  const PerformanceStats({
    required this.avgFrameTime,
    required this.p95FrameTime,
    required this.maxFrameTime,
    required this.minFrameTime,
    required this.frameDropRate,
    required this.totalFrames,
    required this.droppedFrames,
  });
  
  factory PerformanceStats.empty() {
    return const PerformanceStats(
      avgFrameTime: 0,
      p95FrameTime: 0,
      maxFrameTime: 0,
      minFrameTime: 0,
      frameDropRate: 0,
      totalFrames: 0,
      droppedFrames: 0,
    );
  }
}

/// 性能监控混入类
/// 可以在需要监控的页面中使用
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  final _monitor = UIPerformanceMonitor();
  
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _monitor.startMonitoring();
      });
    }
  }
  
  @override
  void dispose() {
    if (kDebugMode) {
      _monitor.stopMonitoring();
      _monitor.printPerformanceReport();
    }
    super.dispose();
  }
}