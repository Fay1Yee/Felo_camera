import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ai_result.dart';

/// 错误类型枚举
enum ErrorType {
  network,      // 网络错误
  api,          // API错误
  parsing,      // 解析错误
  image,        // 图像处理错误
  storage,      // 存储错误
  permission,   // 权限错误
  timeout,      // 超时错误
  unknown,      // 未知错误
}

/// 错误严重程度
enum ErrorSeverity {
  low,          // 低：不影响核心功能
  medium,       // 中：影响部分功能
  high,         // 高：影响核心功能
  critical,     // 严重：系统无法正常工作
}

/// 错误恢复策略
enum RecoveryStrategy {
  retry,        // 重试
  fallback,     // 降级处理
  cache,        // 使用缓存
  mock,         // 使用模拟数据
  userAction,   // 需要用户操作
  ignore,       // 忽略错误
}

/// 分析错误详情
class AnalysisError {
  final ErrorType type;
  final ErrorSeverity severity;
  final String message;
  final String? details;
  final DateTime timestamp;
  final String? stackTrace;
  final Map<String, dynamic>? context;
  final RecoveryStrategy recommendedStrategy;
  final int confidenceImpact; // 对置信度的影响 (0-100)

  AnalysisError({
    required this.type,
    required this.severity,
    required this.message,
    this.details,
    DateTime? timestamp,
    this.stackTrace,
    this.context,
    required this.recommendedStrategy,
    required this.confidenceImpact,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'AnalysisError(type: $type, severity: $severity, message: $message)';
  }
}

/// 错误处理结果
class ErrorHandlingResult {
  final bool canContinue;
  final AIResult? fallbackResult;
  final String userMessage;
  final int adjustedConfidence;
  final List<String> suggestions;
  final bool shouldRetry;
  final Duration? retryDelay;

  ErrorHandlingResult({
    required this.canContinue,
    this.fallbackResult,
    required this.userMessage,
    required this.adjustedConfidence,
    required this.suggestions,
    required this.shouldRetry,
    this.retryDelay,
  });
}

/// 多层次错误处理器
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  static ErrorHandler get instance => _instance;

  final List<AnalysisError> _errorHistory = [];
  final Map<ErrorType, int> _errorCounts = {};

  /// 分析异常并创建错误对象
  AnalysisError analyzeException(dynamic exception, {
    String? context,
    Map<String, dynamic>? additionalContext,
  }) {
    final errorType = _classifyError(exception);
    final severity = _determineSeverity(errorType, exception);
    final strategy = _determineRecoveryStrategy(errorType, severity);
    final confidenceImpact = _calculateConfidenceImpact(errorType, severity);

    return AnalysisError(
      type: errorType,
      severity: severity,
      message: _extractErrorMessage(exception),
      details: _extractErrorDetails(exception),
      stackTrace: _extractStackTrace(exception),
      context: {
        if (context != null) 'context': context,
        ...?additionalContext,
      },
      recommendedStrategy: strategy,
      confidenceImpact: confidenceImpact,
    );
  }

  /// 处理错误并返回处理结果
  ErrorHandlingResult handleError(AnalysisError error, {
    String mode = 'normal',
    int originalConfidence = 0,
  }) {
    // 记录错误
    _recordError(error);

    // 根据错误类型和严重程度决定处理策略
    switch (error.recommendedStrategy) {
      case RecoveryStrategy.retry:
        return _handleRetryStrategy(error, originalConfidence);
      
      case RecoveryStrategy.fallback:
        return _handleFallbackStrategy(error, mode, originalConfidence);
      
      case RecoveryStrategy.cache:
        return _handleCacheStrategy(error, originalConfidence);
      
      case RecoveryStrategy.mock:
        return _handleMockStrategy(error, mode, originalConfidence);
      
      case RecoveryStrategy.userAction:
        return _handleUserActionStrategy(error, originalConfidence);
      
      case RecoveryStrategy.ignore:
        return _handleIgnoreStrategy(error, originalConfidence);
    }
  }

  /// 分类错误类型
  ErrorType _classifyError(dynamic exception) {
    final errorString = exception.toString().toLowerCase();
    
    if (exception is SocketException || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return ErrorType.network;
    }
    
    if (errorString.contains('timeout')) {
      return ErrorType.timeout;
    }
    
    if (errorString.contains('permission') ||
        errorString.contains('access denied')) {
      return ErrorType.permission;
    }
    
    if (errorString.contains('json') ||
        errorString.contains('parse') ||
        errorString.contains('format')) {
      return ErrorType.parsing;
    }
    
    if (errorString.contains('image') ||
        errorString.contains('decode') ||
        errorString.contains('file')) {
      return ErrorType.image;
    }
    
    if (errorString.contains('storage') ||
        errorString.contains('disk') ||
        errorString.contains('space')) {
      return ErrorType.storage;
    }
    
    if (errorString.contains('api') ||
        errorString.contains('http') ||
        errorString.contains('status code')) {
      return ErrorType.api;
    }
    
    return ErrorType.unknown;
  }

  /// 确定错误严重程度
  ErrorSeverity _determineSeverity(ErrorType type, dynamic exception) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
        return ErrorSeverity.medium;
      
      case ErrorType.api:
        final statusCode = _extractStatusCode(exception);
        if (statusCode != null) {
          if (statusCode >= 500) return ErrorSeverity.high;
          if (statusCode >= 400) return ErrorSeverity.medium;
        }
        return ErrorSeverity.medium;
      
      case ErrorType.parsing:
        return ErrorSeverity.medium;
      
      case ErrorType.image:
        return ErrorSeverity.high;
      
      case ErrorType.storage:
      case ErrorType.permission:
        return ErrorSeverity.high;
      
      case ErrorType.unknown:
        return ErrorSeverity.medium;
    }
  }

  /// 确定恢复策略
  RecoveryStrategy _determineRecoveryStrategy(ErrorType type, ErrorSeverity severity) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
        return RecoveryStrategy.retry;
      
      case ErrorType.api:
        return severity == ErrorSeverity.high ? RecoveryStrategy.fallback : RecoveryStrategy.retry;
      
      case ErrorType.parsing:
        return RecoveryStrategy.fallback;
      
      case ErrorType.image:
        return RecoveryStrategy.userAction;
      
      case ErrorType.storage:
      case ErrorType.permission:
        return RecoveryStrategy.userAction;
      
      case ErrorType.unknown:
        return RecoveryStrategy.fallback;
    }
  }

  /// 计算置信度影响
  int _calculateConfidenceImpact(ErrorType type, ErrorSeverity severity) {
    final baseImpact = switch (severity) {
      ErrorSeverity.low => 5,
      ErrorSeverity.medium => 15,
      ErrorSeverity.high => 30,
      ErrorSeverity.critical => 50,
    };

    final typeMultiplier = switch (type) {
      ErrorType.network => 1.0,
      ErrorType.api => 1.2,
      ErrorType.parsing => 1.5,
      ErrorType.image => 2.0,
      ErrorType.storage => 1.0,
      ErrorType.permission => 1.0,
      ErrorType.timeout => 1.1,
      ErrorType.unknown => 1.3,
    };

    return (baseImpact * typeMultiplier).round().clamp(0, 100);
  }

  /// 处理重试策略
  ErrorHandlingResult _handleRetryStrategy(AnalysisError error, int originalConfidence) {
    final retryCount = _errorCounts[error.type] ?? 0;
    final maxRetries = switch (error.type) {
      ErrorType.network => 3,
      ErrorType.timeout => 2,
      ErrorType.api => 2,
      _ => 1,
    };

    if (retryCount < maxRetries) {
      return ErrorHandlingResult(
        canContinue: true,
        userMessage: '网络不稳定，正在重试...',
        adjustedConfidence: (originalConfidence * 0.9).round(),
        suggestions: ['检查网络连接', '稍后再试'],
        shouldRetry: true,
        retryDelay: Duration(seconds: (retryCount + 1) * 2),
      );
    } else {
      return _handleFallbackStrategy(error, 'normal', originalConfidence);
    }
  }

  /// 处理降级策略
  ErrorHandlingResult _handleFallbackStrategy(AnalysisError error, String mode, int originalConfidence) {
    final fallbackResult = _generateFallbackResult(error, mode);
    final adjustedConfidence = (originalConfidence - error.confidenceImpact).clamp(0, 100);

    return ErrorHandlingResult(
      canContinue: true,
      fallbackResult: fallbackResult,
      userMessage: _getFallbackMessage(error),
      adjustedConfidence: adjustedConfidence,
      suggestions: _getFallbackSuggestions(error),
      shouldRetry: false,
    );
  }

  /// 处理缓存策略
  ErrorHandlingResult _handleCacheStrategy(AnalysisError error, int originalConfidence) {
    return ErrorHandlingResult(
      canContinue: true,
      userMessage: '使用缓存数据，可能不是最新结果',
      adjustedConfidence: (originalConfidence * 0.8).round(),
      suggestions: ['稍后重新分析获取最新结果'],
      shouldRetry: false,
    );
  }

  /// 处理模拟数据策略
  ErrorHandlingResult _handleMockStrategy(AnalysisError error, String mode, int originalConfidence) {
    final mockResult = _generateMockResult(mode);
    
    return ErrorHandlingResult(
      canContinue: true,
      fallbackResult: mockResult,
      userMessage: '服务暂时不可用，显示示例结果',
      adjustedConfidence: 30, // 模拟数据置信度较低
      suggestions: ['这是示例数据，请稍后重试获取真实分析'],
      shouldRetry: false,
    );
  }

  /// 处理用户操作策略
  ErrorHandlingResult _handleUserActionStrategy(AnalysisError error, int originalConfidence) {
    return ErrorHandlingResult(
      canContinue: false,
      userMessage: _getUserActionMessage(error),
      adjustedConfidence: 0,
      suggestions: _getUserActionSuggestions(error),
      shouldRetry: false,
    );
  }

  /// 处理忽略策略
  ErrorHandlingResult _handleIgnoreStrategy(AnalysisError error, int originalConfidence) {
    return ErrorHandlingResult(
      canContinue: true,
      userMessage: '分析完成，部分功能可能受限',
      adjustedConfidence: (originalConfidence * 0.95).round(),
      suggestions: [],
      shouldRetry: false,
    );
  }

  /// 生成降级结果
  AIResult _generateFallbackResult(AnalysisError error, String mode) {
    final confidence = switch (error.severity) {
      ErrorSeverity.low => 60,
      ErrorSeverity.medium => 40,
      ErrorSeverity.high => 20,
      ErrorSeverity.critical => 10,
    };

    return AIResult(
      title: '${_getModeTitle(mode)} (降级模式)',
      confidence: confidence,
      subInfo: '由于${_getErrorTypeDescription(error.type)}，使用基础分析结果。\n\n建议：${_getFallbackSuggestions(error).join('、')}',
    );
  }

  /// 生成模拟结果
  AIResult _generateMockResult(String mode) {
    final titles = {
      'pet': '可爱的宠物',
      'health': '健康状况良好',
      'travel': '美丽的风景',
      'normal': '图像分析结果',
    };

    return AIResult(
      title: titles[mode] ?? '分析结果',
      confidence: 30,
      subInfo: '这是示例数据，仅供参考。请检查网络连接后重新分析。',
    );
  }

  /// 记录错误
  void _recordError(AnalysisError error) {
    _errorHistory.add(error);
    _errorCounts[error.type] = (_errorCounts[error.type] ?? 0) + 1;

    // 保持错误历史记录在合理范围内
    if (_errorHistory.length > 100) {
      _errorHistory.removeAt(0);
    }

    debugPrint('🚨 错误记录: ${error.type} - ${error.message}');
  }

  /// 辅助方法
  String _extractErrorMessage(dynamic exception) {
    if (exception is Exception) {
      return exception.toString().replaceFirst('Exception: ', '');
    }
    return exception.toString();
  }

  String? _extractErrorDetails(dynamic exception) {
    // 可以根据需要提取更详细的错误信息
    return null;
  }

  String? _extractStackTrace(dynamic exception) {
    if (exception is Error) {
      return exception.stackTrace?.toString();
    }
    return null;
  }

  int? _extractStatusCode(dynamic exception) {
    final errorString = exception.toString();
    final match = RegExp(r'status code[:\s]*(\d+)', caseSensitive: false).firstMatch(errorString);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  String _getFallbackMessage(AnalysisError error) {
    return switch (error.type) {
      ErrorType.network => '网络连接不稳定，使用基础分析',
      ErrorType.api => 'API服务异常，使用本地分析',
      ErrorType.parsing => '数据解析异常，使用简化结果',
      ErrorType.timeout => '分析超时，使用快速模式',
      _ => '分析遇到问题，使用备用方案',
    };
  }

  List<String> _getFallbackSuggestions(AnalysisError error) {
    return switch (error.type) {
      ErrorType.network => ['检查网络连接', '稍后重试'],
      ErrorType.api => ['服务可能维护中', '请稍后再试'],
      ErrorType.parsing => ['重新拍摄照片', '确保图像清晰'],
      ErrorType.timeout => ['网络较慢', '尝试压缩图片'],
      _ => ['重新尝试', '联系技术支持'],
    };
  }

  String _getUserActionMessage(AnalysisError error) {
    return switch (error.type) {
      ErrorType.image => '图像文件有问题，请重新拍摄',
      ErrorType.permission => '需要相机或存储权限',
      ErrorType.storage => '存储空间不足',
      _ => '需要您的操作才能继续',
    };
  }

  List<String> _getUserActionSuggestions(AnalysisError error) {
    return switch (error.type) {
      ErrorType.image => ['重新拍摄照片', '选择其他图片', '检查图片格式'],
      ErrorType.permission => ['前往设置开启权限', '重启应用'],
      ErrorType.storage => ['清理存储空间', '删除不需要的文件'],
      _ => ['检查设置', '重启应用'],
    };
  }

  String _getModeTitle(String mode) {
    return switch (mode) {
      'pet' => '宠物识别',
      'health' => '健康分析',
      'travel' => '场景分析',
      _ => '图像分析',
    };
  }

  String _getErrorTypeDescription(ErrorType type) {
    return switch (type) {
      ErrorType.network => '网络问题',
      ErrorType.api => 'API异常',
      ErrorType.parsing => '数据解析错误',
      ErrorType.image => '图像处理错误',
      ErrorType.storage => '存储问题',
      ErrorType.permission => '权限不足',
      ErrorType.timeout => '请求超时',
      ErrorType.unknown => '未知错误',
    };
  }

  /// 获取错误统计
  Map<String, dynamic> getErrorStatistics() {
    return {
      'totalErrors': _errorHistory.length,
      'errorCounts': Map.from(_errorCounts),
      'recentErrors': _errorHistory.take(10).map((e) => {
        'type': e.type.toString(),
        'severity': e.severity.toString(),
        'message': e.message,
        'timestamp': e.timestamp.toIso8601String(),
      }).toList(),
    };
  }

  /// 清理错误历史
  void clearErrorHistory() {
    _errorHistory.clear();
    _errorCounts.clear();
  }
}