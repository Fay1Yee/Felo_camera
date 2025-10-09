import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 性能监控服务
/// 实时跟踪API响应时间、成功率和系统性能指标
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  static PerformanceMonitor get instance => _instance;
  
  PerformanceMonitor._internal();
  
  bool _isInitialized = false;
  Timer? _reportTimer;
  
  // 性能指标
  final List<ApiCallMetric> _apiMetrics = [];
  final List<SystemMetric> _systemMetrics = [];
  
  // 统计数据
  int _totalApiCalls = 0;
  int _successfulApiCalls = 0;
  int _failedApiCalls = 0;
  double _totalResponseTime = 0.0;
  
  // 配置
  static const int _maxMetricsHistory = 1000;
  static const Duration _reportInterval = Duration(minutes: 5);
  static const Duration _metricRetentionPeriod = Duration(hours: 24);
  
  /// 初始化性能监控
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('📊 初始化性能监控服务...');
      
      // 加载历史数据
      await _loadHistoricalData();
      
      // 启动定期报告
      _startPeriodicReporting();
      
      // 启动系统监控
      _startSystemMonitoring();
      
      _isInitialized = true;
      debugPrint('✅ 性能监控服务初始化完成');
      debugPrint('📈 当前统计: 总调用 $_totalApiCalls, 成功 $_successfulApiCalls, 失败 $_failedApiCalls');
    } catch (e) {
      debugPrint('❌ 性能监控服务初始化失败: $e');
      // 即使初始化失败，也要确保基本功能可用
      _isInitialized = true;
    }
  }
  
  /// 记录API调用指标
  void recordApiCall({
    required String endpoint,
    required Duration responseTime,
    required bool isSuccess,
    required int statusCode,
    String? errorMessage,
    int? dataSize,
  }) {
    final metric = ApiCallMetric(
      endpoint: endpoint,
      responseTime: responseTime,
      isSuccess: isSuccess,
      statusCode: statusCode,
      timestamp: DateTime.now(),
      errorMessage: errorMessage,
      dataSize: dataSize,
    );
    
    _apiMetrics.add(metric);
    
    // 更新统计
    _totalApiCalls++;
    if (isSuccess) {
      _successfulApiCalls++;
    } else {
      _failedApiCalls++;
    }
    _totalResponseTime += responseTime.inMilliseconds;
    
    // 清理旧数据
    _cleanupOldMetrics();
    
    // 实时分析
    _analyzePerformance(metric);
    
    debugPrint('📈 API调用记录: $endpoint - ${responseTime.inMilliseconds}ms - ${isSuccess ? '成功' : '失败'}');
  }
  
  /// 记录系统指标
  void recordSystemMetric({
    required double cpuUsage,
    required double memoryUsage,
    required double batteryLevel,
    required String networkType,
    required double networkSpeed,
  }) {
    final metric = SystemMetric(
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      batteryLevel: batteryLevel,
      networkType: networkType,
      networkSpeed: networkSpeed,
      timestamp: DateTime.now(),
    );
    
    _systemMetrics.add(metric);
    
    // 清理旧数据
    _cleanupOldMetrics();
    
    debugPrint('🖥️ 系统指标: CPU ${cpuUsage.toStringAsFixed(1)}% | 内存 ${memoryUsage.toStringAsFixed(1)}% | 电量 ${batteryLevel.toStringAsFixed(1)}%');
  }
  
  /// 获取性能统计信息
  Future<PerformanceStats> getPerformanceStats() async {
    if (!_isInitialized) await initialize();
    
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    final last1h = now.subtract(const Duration(hours: 1));
    
    // 过滤最近24小时和1小时的数据
    final recent24hMetrics = _apiMetrics.where((m) => m.timestamp.isAfter(last24h)).toList();
    final recent1hMetrics = _apiMetrics.where((m) => m.timestamp.isAfter(last1h)).toList();
    
    // 计算统计数据
    final recent24hSuccessful = recent24hMetrics.where((m) => m.isSuccess).length;
    final recent1hSuccessful = recent1hMetrics.where((m) => m.isSuccess).length;
    
    final recent24hAvgTime = recent24hMetrics.isEmpty ? 0.0 : 
        recent24hMetrics.map((m) => m.responseTime.inMilliseconds).reduce((a, b) => a + b) / recent24hMetrics.length;
    final recent1hAvgTime = recent1hMetrics.isEmpty ? 0.0 : 
        recent1hMetrics.map((m) => m.responseTime.inMilliseconds).reduce((a, b) => a + b) / recent1hMetrics.length;
    
    return PerformanceStats(
      totalApiCalls: _totalApiCalls,
      successfulApiCalls: _successfulApiCalls,
      failedApiCalls: _failedApiCalls,
      successRate: _totalApiCalls > 0 ? (_successfulApiCalls / _totalApiCalls) * 100 : 0.0,
      averageResponseTime: _totalApiCalls > 0 ? _totalResponseTime / _totalApiCalls : 0.0,
      recent24hCalls: recent24hMetrics.length,
      recent1hCalls: recent1hMetrics.length,
      recent24hSuccessRate: recent24hMetrics.isEmpty ? 0.0 : (recent24hSuccessful / recent24hMetrics.length) * 100,
      recent1hSuccessRate: recent1hMetrics.isEmpty ? 0.0 : (recent1hSuccessful / recent1hMetrics.length) * 100,
      recent24hAvgResponseTime: recent24hAvgTime,
      recent1hAvgResponseTime: recent1hAvgTime,
    );
  }
  
  /// 获取端点性能分析
  Map<String, EndpointStats> getEndpointStats() {
    final Map<String, List<ApiCallMetric>> endpointGroups = {};
    
    // 按端点分组
    for (final metric in _apiMetrics) {
      endpointGroups.putIfAbsent(metric.endpoint, () => []).add(metric);
    }
    
    // 计算每个端点的统计
    final Map<String, EndpointStats> stats = {};
    for (final entry in endpointGroups.entries) {
      final metrics = entry.value;
      final successCount = metrics.where((m) => m.isSuccess).length;
      final avgResponseTime = metrics.isNotEmpty 
          ? metrics.map((m) => m.responseTime.inMilliseconds).reduce((a, b) => a + b) / metrics.length 
          : 0.0;
      
      stats[entry.key] = EndpointStats(
        endpoint: entry.key,
        totalCalls: metrics.length,
        successfulCalls: successCount,
        failedCalls: metrics.length - successCount,
        successRate: metrics.isNotEmpty ? successCount / metrics.length : 0.0,
        averageResponseTime: avgResponseTime,
        minResponseTime: metrics.isNotEmpty 
            ? metrics.map((m) => m.responseTime.inMilliseconds).reduce((a, b) => a < b ? a : b).toDouble()
            : 0.0,
        maxResponseTime: metrics.isNotEmpty 
            ? metrics.map((m) => m.responseTime.inMilliseconds).reduce((a, b) => a > b ? a : b).toDouble()
            : 0.0,
      );
    }
    
    return stats;
  }
  
  /// 获取性能趋势
  List<PerformanceTrend> getPerformanceTrends({Duration? period}) {
    final targetPeriod = period ?? const Duration(hours: 24);
    final now = DateTime.now();
    final startTime = now.subtract(targetPeriod);
    
    final relevantMetrics = _apiMetrics
        .where((m) => m.timestamp.isAfter(startTime))
        .toList();
    
    // 按小时分组
    final Map<int, List<ApiCallMetric>> hourlyGroups = {};
    for (final metric in relevantMetrics) {
      final hour = metric.timestamp.hour;
      hourlyGroups.putIfAbsent(hour, () => []).add(metric);
    }
    
    // 生成趋势数据
    final trends = <PerformanceTrend>[];
    for (final entry in hourlyGroups.entries) {
      final metrics = entry.value;
      final successCount = metrics.where((m) => m.isSuccess).length;
      final avgResponseTime = metrics.isNotEmpty 
          ? metrics.map((m) => m.responseTime.inMilliseconds).reduce((a, b) => a + b) / metrics.length 
          : 0.0;
      
      trends.add(PerformanceTrend(
        timestamp: DateTime(now.year, now.month, now.day, entry.key),
        totalCalls: metrics.length,
        successRate: metrics.isNotEmpty ? successCount / metrics.length : 0.0,
        averageResponseTime: avgResponseTime,
      ));
    }
    
    trends.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return trends;
  }
  
  /// 启动定期报告
  void _startPeriodicReporting() {
    _reportTimer = Timer.periodic(_reportInterval, (timer) async {
      await _generatePerformanceReport();
    });
  }
  
  /// 启动系统监控
  void _startSystemMonitoring() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _collectSystemMetrics();
    });
  }
  
  /// 收集系统指标
  Future<void> _collectSystemMetrics() async {
    try {
      // 这里可以集成更详细的系统监控
      // 目前提供基础的模拟数据
      recordSystemMetric(
        cpuUsage: 0.0, // 需要平台特定的实现
        memoryUsage: 0.0, // 需要平台特定的实现
        batteryLevel: 100.0, // 需要电池插件
        networkType: 'WiFi',
        networkSpeed: 0.0, // 需要网络速度检测
      );
    } catch (e) {
      debugPrint('⚠️ 系统指标收集失败: $e');
    }
  }
  
  /// 生成性能报告
  Future<void> _generatePerformanceReport() async {
    final stats = await getPerformanceStats();
    
    debugPrint('📊 === 性能报告 ===');
    debugPrint('总API调用: ${stats.totalApiCalls}');
    debugPrint('成功率: ${stats.successRate.toStringAsFixed(1)}%');
    debugPrint('平均响应时间: ${stats.averageResponseTime.toStringAsFixed(1)}ms');
    debugPrint('最近24小时调用: ${stats.recent24hCalls}');
    debugPrint('最近1小时调用: ${stats.recent1hCalls}');
    debugPrint('==================');
    
    // 保存报告到本地存储
    _savePerformanceReport(stats);
  }
  
  /// 实时性能分析
  void _analyzePerformance(ApiCallMetric metric) {
    // 检查响应时间异常
    if (metric.responseTime.inMilliseconds > 5000) {
      debugPrint('⚠️ 响应时间异常: ${metric.endpoint} - ${metric.responseTime.inMilliseconds}ms');
    }
    
    // 检查错误率
    final recentMetrics = _apiMetrics
        .where((m) => m.timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 10))))
        .toList();
    
    if (recentMetrics.length >= 10) {
      final errorRate = recentMetrics.where((m) => !m.isSuccess).length / recentMetrics.length;
      if (errorRate > 0.2) {
        debugPrint('🚨 错误率过高: ${(errorRate * 100).toStringAsFixed(1)}%');
      }
    }
  }
  
  /// 清理旧指标
  void _cleanupOldMetrics() {
    final cutoff = DateTime.now().subtract(_metricRetentionPeriod);
    
    _apiMetrics.removeWhere((metric) => metric.timestamp.isBefore(cutoff));
    _systemMetrics.removeWhere((metric) => metric.timestamp.isBefore(cutoff));
    
    // 限制内存中的指标数量
    if (_apiMetrics.length > _maxMetricsHistory) {
      _apiMetrics.removeRange(0, _apiMetrics.length - _maxMetricsHistory);
    }
    
    if (_systemMetrics.length > _maxMetricsHistory) {
      _systemMetrics.removeRange(0, _systemMetrics.length - _maxMetricsHistory);
    }
  }
  
  /// 加载历史数据
  Future<void> _loadHistoricalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _totalApiCalls = prefs.getInt('perf_total_calls') ?? 0;
      _successfulApiCalls = prefs.getInt('perf_success_calls') ?? 0;
      _failedApiCalls = prefs.getInt('perf_failed_calls') ?? 0;
      _totalResponseTime = prefs.getDouble('perf_total_response_time') ?? 0.0;
      
      debugPrint('📚 加载历史性能数据: 总调用 $_totalApiCalls, 成功 $_successfulApiCalls');
    } catch (e) {
      debugPrint('⚠️ 加载历史数据失败: $e');
    }
  }
  
  /// 保存性能报告
  Future<void> _savePerformanceReport(PerformanceStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('perf_total_calls', stats.totalApiCalls);
      await prefs.setInt('perf_success_calls', stats.successfulApiCalls);
      await prefs.setInt('perf_failed_calls', stats.failedApiCalls);
      await prefs.setDouble('perf_total_response_time', _totalResponseTime);
      await prefs.setString('perf_last_report', DateTime.now().toIso8601String());
      
    } catch (e) {
      debugPrint('⚠️ 保存性能报告失败: $e');
    }
  }
  
  /// 清理资源
  void dispose() {
    _reportTimer?.cancel();
    _reportTimer = null;
    _isInitialized = false;
    
    debugPrint('🧹 性能监控服务已清理');
  }
}

/// API调用指标
class ApiCallMetric {
  final String endpoint;
  final Duration responseTime;
  final bool isSuccess;
  final int statusCode;
  final DateTime timestamp;
  final String? errorMessage;
  final int? dataSize;
  
  ApiCallMetric({
    required this.endpoint,
    required this.responseTime,
    required this.isSuccess,
    required this.statusCode,
    required this.timestamp,
    this.errorMessage,
    this.dataSize,
  });
}

/// 系统指标
class SystemMetric {
  final double cpuUsage;
  final double memoryUsage;
  final double batteryLevel;
  final String networkType;
  final double networkSpeed;
  final DateTime timestamp;
  
  SystemMetric({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.batteryLevel,
    required this.networkType,
    required this.networkSpeed,
    required this.timestamp,
  });
}

/// 性能统计
class PerformanceStats {
  final int totalApiCalls;
  final int successfulApiCalls;
  final int failedApiCalls;
  final double successRate;
  final double averageResponseTime;
  final int recent24hCalls;
  final int recent1hCalls;
  final double recent24hSuccessRate;
  final double recent1hSuccessRate;
  final double recent24hAvgResponseTime;
  final double recent1hAvgResponseTime;
  
  PerformanceStats({
    required this.totalApiCalls,
    required this.successfulApiCalls,
    required this.failedApiCalls,
    required this.successRate,
    required this.averageResponseTime,
    required this.recent24hCalls,
    required this.recent1hCalls,
    required this.recent24hSuccessRate,
    required this.recent1hSuccessRate,
    required this.recent24hAvgResponseTime,
    required this.recent1hAvgResponseTime,
  });
}

/// 端点统计
class EndpointStats {
  final String endpoint;
  final int totalCalls;
  final int successfulCalls;
  final int failedCalls;
  final double successRate;
  final double averageResponseTime;
  final double minResponseTime;
  final double maxResponseTime;
  
  EndpointStats({
    required this.endpoint,
    required this.totalCalls,
    required this.successfulCalls,
    required this.failedCalls,
    required this.successRate,
    required this.averageResponseTime,
    required this.minResponseTime,
    required this.maxResponseTime,
  });
}

/// 性能趋势
class PerformanceTrend {
  final DateTime timestamp;
  final int totalCalls;
  final double successRate;
  final double averageResponseTime;
  
  PerformanceTrend({
    required this.timestamp,
    required this.totalCalls,
    required this.successRate,
    required this.averageResponseTime,
  });
}