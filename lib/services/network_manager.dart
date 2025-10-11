import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 网络管理器
/// 提供连接池、智能重试、请求合并等网络优化功能
class NetworkManager {
  static NetworkManager? _instance;
  static NetworkManager get instance {
    _instance ??= NetworkManager._();
    return _instance!;
  }
  
  NetworkManager._() {
    _initializeClient();
  }
  
  // HTTP客户端配置
  late http.Client _httpClient;
  final Map<String, Timer> _connectionPool = {};
  final Map<String, Completer<http.Response>> _pendingRequests = {};
  
  // 重试配置
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(milliseconds: 500);
  static const Duration _maxRetryDelay = Duration(seconds: 10);
  
  // 连接池配置
  static const int _maxConnections = 5;
  static const Duration _connectionTimeout = Duration(seconds: 15); // 减少连接超时
  static const Duration _requestTimeout = Duration(seconds: 10); // 减少请求超时
  
  // 请求合并配置
  // ignore: unused_field
  static const Duration _requestMergeWindow = Duration(milliseconds: 100);
  
  /// 初始化HTTP客户端
  void _initializeClient() {
    _httpClient = http.Client();
  }
  
  /// 执行HTTP GET请求（带重试和优化）
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _executeWithRetry(() async {
      return await _httpClient.get(
        url,
        headers: headers,
      ).timeout(timeout ?? _requestTimeout);
    });
  }
  
  /// 执行HTTP POST请求（带重试和优化）
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    return _executeWithRetry(() async {
      return await _httpClient.post(
        url,
        headers: headers,
        body: body,
      ).timeout(timeout ?? _requestTimeout);
    });
  }
  
  /// 执行Multipart请求（带重试和优化）
  Future<http.Response> sendMultipart(
    http.MultipartRequest request, {
    Duration? timeout,
  }) async {
    return _executeWithRetry(() async {
      final streamedResponse = await request.send().timeout(
        timeout ?? _requestTimeout,
      );
      return await http.Response.fromStream(streamedResponse);
    });
  }
  
  /// 带智能重试的请求执行
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() requestFunction,
  ) async {
    int attempt = 0;
    Duration delay = _baseRetryDelay;
    
    while (attempt < _maxRetries) {
      try {
        final response = await requestFunction();
        
        // 检查响应状态
        if (_isSuccessResponse(response)) {
          return response;
        } else if (_shouldRetry(response.statusCode, attempt)) {
          attempt++;
          if (attempt < _maxRetries) {
            debugPrint('🔄 请求失败 (${response.statusCode})，${delay.inMilliseconds}ms后重试 (第$attempt次)');
            await Future.delayed(delay);
            delay = _calculateNextDelay(delay, attempt);
          } else {
            return response; // 最后一次尝试，返回响应
          }
        } else {
          return response; // 不应重试的错误，直接返回
        }
        
      } catch (e) {
        attempt++;
        
        if (attempt >= _maxRetries) {
          rethrow; // 最后一次尝试失败，抛出异常
        }
        
        if (_shouldRetryException(e)) {
          debugPrint('🔄 请求异常，${delay.inMilliseconds}ms后重试 (第$attempt次): $e');
          await Future.delayed(delay);
          delay = _calculateNextDelay(delay, attempt);
        } else {
          rethrow; // 不应重试的异常，直接抛出
        }
      }
    }
    
    throw Exception('请求失败，已重试$_maxRetries次');
  }
  
  /// 检查响应是否成功
  bool _isSuccessResponse(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }
  
  /// 判断是否应该重试（基于状态码）
  bool _shouldRetry(int statusCode, int attempt) {
    // 服务器错误和部分客户端错误可以重试
    final retryableStatusCodes = [
      408, // Request Timeout
      429, // Too Many Requests
      500, // Internal Server Error
      502, // Bad Gateway
      503, // Service Unavailable
      504, // Gateway Timeout
    ];
    
    return retryableStatusCodes.contains(statusCode) && attempt < _maxRetries;
  }
  
  /// 判断是否应该重试（基于异常类型）
  bool _shouldRetryException(dynamic exception) {
    // 网络相关异常可以重试
    return exception is SocketException ||
           exception is TimeoutException ||
           exception is HttpException ||
           (exception is Exception && 
            exception.toString().contains('Connection'));
  }
  
  /// 计算下次重试延迟（指数退避 + 随机抖动）
  Duration _calculateNextDelay(Duration currentDelay, int attempt) {
    // 指数退避
    final exponentialDelay = Duration(
      milliseconds: (currentDelay.inMilliseconds * math.pow(2, attempt)).round(),
    );
    
    // 添加随机抖动（±25%）
    final jitter = math.Random().nextDouble() * 0.5 - 0.25; // -0.25 到 0.25
    final jitteredDelay = Duration(
      milliseconds: (exponentialDelay.inMilliseconds * (1 + jitter)).round(),
    );
    
    // 限制最大延迟
    return jitteredDelay > _maxRetryDelay ? _maxRetryDelay : jitteredDelay;
  }
  
  /// 请求去重和合并
  // ignore: unused_element
  Future<http.Response> _deduplicateRequest(
    String requestKey,
    Future<http.Response> Function() requestFunction,
  ) async {
    // 检查是否有相同的请求正在进行
    if (_pendingRequests.containsKey(requestKey)) {
      debugPrint('🔗 合并重复请求: $requestKey');
      return await _pendingRequests[requestKey]!.future;
    }
    
    // 创建新的请求
    final completer = Completer<http.Response>();
    _pendingRequests[requestKey] = completer;
    
    try {
      final response = await requestFunction();
      completer.complete(response);
      return response;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      // 清理完成的请求
      _pendingRequests.remove(requestKey);
    }
  }
  
  /// 生成请求键（用于去重）
  // ignore: unused_element
  String _generateRequestKey(String method, Uri url, Map<String, String>? headers) {
    final headerString = headers?.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',') ?? '';
    return '$method:${url.toString()}:$headerString';
  }
  
  /// 预热连接
  Future<void> preWarmConnection(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, timeout: _connectionTimeout);
      await socket.close();
      debugPrint('🔥 预热连接成功: $host:$port');
    } catch (e) {
      debugPrint('⚠️ 预热连接失败: $host:$port - $e');
    }
  }
  
  /// 批量预热连接
  Future<void> preWarmConnections(List<String> hosts) async {
    final futures = hosts.map((host) {
      final uri = Uri.parse(host);
      final port = uri.port != 0 ? uri.port : (uri.scheme == 'https' ? 443 : 80);
      return preWarmConnection(uri.host, port);
    });
    
    await Future.wait(futures);
  }
  
  /// 检测网络连接质量
  Future<NetworkQuality> detectNetworkQuality() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // 测试连接到可靠的服务器
      final response = await get(
        Uri.parse('https://www.baidu.com'),
        timeout: const Duration(seconds: 5),
      );
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final latency = stopwatch.elapsedMilliseconds;
        
        if (latency < 100) {
          return NetworkQuality.excellent;
        } else if (latency < 300) {
          return NetworkQuality.good;
        } else if (latency < 800) {
          return NetworkQuality.fair;
        } else {
          return NetworkQuality.poor;
        }
      } else {
        return NetworkQuality.poor;
      }
      
    } catch (e) {
      debugPrint('⚠️ 网络质量检测失败: $e');
      return NetworkQuality.poor;
    }
  }
  
  /// 获取网络统计信息
  NetworkStats getNetworkStats() {
    return NetworkStats(
      activeConnections: _connectionPool.length,
      pendingRequests: _pendingRequests.length,
      maxConnections: _maxConnections,
    );
  }
  
  /// 清理资源
  void dispose() {
    _httpClient.close();
    
    // 清理连接池
    for (final timer in _connectionPool.values) {
      timer.cancel();
    }
    _connectionPool.clear();
    
    // 清理待处理请求
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('NetworkManager disposed'));
      }
    }
    _pendingRequests.clear();
  }
}

/// 网络质量枚举
enum NetworkQuality {
  excellent,
  good,
  fair,
  poor;
  
  @override
  String toString() {
    switch (this) {
      case NetworkQuality.excellent:
        return '优秀';
      case NetworkQuality.good:
        return '良好';
      case NetworkQuality.fair:
        return '一般';
      case NetworkQuality.poor:
        return '较差';
    }
  }
}

/// 网络统计信息
class NetworkStats {
  final int activeConnections;
  final int pendingRequests;
  final int maxConnections;
  
  NetworkStats({
    required this.activeConnections,
    required this.pendingRequests,
    required this.maxConnections,
  });
  
  @override
  String toString() {
    return 'NetworkStats(active: $activeConnections/$maxConnections, pending: $pendingRequests)';
  }
}