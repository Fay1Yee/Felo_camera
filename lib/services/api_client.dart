import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/ai_result.dart';
import '../config/api_config.dart';
// import 'local_ai_client.dart';
import 'image_optimizer.dart';
import 'result_cache.dart';
import 'network_manager.dart' as net;
import 'performance_monitor.dart';
import 'error_handler.dart';

/// API客户端 - 强制使用真正的API调用进行图像分析
class ApiClient {
  static ApiClient? _instance;
  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }
  
  ApiClient._() {
    // 预热后端与豆包API连接，降低首包延迟
    try {
      final hosts = [
        // 移动端仅预热豆包API，避免尝试 localhost:8443
        ApiConfig.getChatCompletionsUrl(),
      ];
      _networkManager.preWarmConnections(hosts);
    } catch (e) {
      debugPrint('预热API连接失败: $e');
    }
  }
  
  // final LocalAIClient _localClient = LocalAIClient.instance;
  final ImageOptimizer _imageOptimizer = ImageOptimizer.instance;
  final ResultCache _resultCache = ResultCache.instance;
  final net.NetworkManager _networkManager = net.NetworkManager.instance;
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor.instance;
  // bool _useLocalAI = false; // 强制使用真正的API调用

  // 保持兼容性：提供一个 no-op 的开关方法，外部调用不会影响逻辑
  void setUseLocalAI(bool value) {
    debugPrint('ApiClient.setUseLocalAI($value) 被调用；已强制使用远程API，忽略本地AI设置');
    // no-op：应用已强制使用远程豆包API，不启用本地AI
  }

  /// 分析图像 - 强制通过API调用实现
  Future<AIResult> analyzeImage(File imageFile, {String mode = 'normal', String? modelKey}) async {
    debugPrint('🔍 API客户端开始图像分析: ${imageFile.path}, 模式: $mode, 模型: ${modelKey ?? 'default'}');
    
    try {
      // 1. 检查缓存
      final cachedResult = await _resultCache.getCachedResult(imageFile, mode);
      if (cachedResult != null) {
        debugPrint('⚡ 使用缓存结果: ${cachedResult.title}');
        return cachedResult;
      }
      
      // 2. 移动端优化：检查文件大小，如果过大则压缩
      final optimizedFile = await _imageOptimizer.optimizeImage(
        imageFile, 
        mode: mode,
      );
      
      // 3. 强制使用真正的豆包API调用，支持多模型
      final result = await _analyzeImageViaAPI(optimizedFile, mode, modelKey);
      
      // 4. 缓存结果
      await _resultCache.cacheResult(imageFile, mode, result);
      
      debugPrint('✅ 远程API图像分析完成: ${result.title} (置信度: ${result.confidence}%)');
      return result;
      
    } catch (e) {
      debugPrint('❌ 远程API分析失败: $e');
      
      // 如果主模型失败，尝试备用模型
      if (modelKey == null || modelKey == ApiConfig.defaultModelKey) {
        final availableModels = ApiConfig.getAvailableModels();
        for (final backupModel in availableModels) {
          if (backupModel != ApiConfig.defaultModelKey) {
            try {
              debugPrint('🔄 尝试备用模型: $backupModel');
              final optimizedFile = await _imageOptimizer.optimizeImage(imageFile, mode: mode);
              final result = await _analyzeImageViaAPI(optimizedFile, mode, backupModel);
              await _resultCache.cacheResult(imageFile, mode, result);
              debugPrint('✅ 备用模型分析成功: ${result.title}');
              return result;
            } catch (backupError) {
              debugPrint('❌ 备用模型 $backupModel 也失败: $backupError');
              continue;
            }
          }
        }
      }
      
      // 使用新的错误处理系统
      final error = ErrorHandler.instance.analyzeException(
        e,
        context: '图像分析',
        additionalContext: {
          'mode': mode,
          'modelKey': modelKey,
          'imagePath': imageFile.path,
        },
      );
      
      final handlingResult = ErrorHandler.instance.handleError(
        error,
        mode: mode,
        originalConfidence: 0,
      );
      
      if (handlingResult.canContinue && handlingResult.fallbackResult != null) {
        debugPrint('🔄 使用错误处理降级结果: ${handlingResult.fallbackResult!.title}');
        return handlingResult.fallbackResult!;
      }
      
      // 如果无法恢复，抛出原始异常
      rethrow;
    }
  }

  /// 分析历史记录
  Future<AIResult> analyzeHistoryRecord(File imageFile, String title, String description) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // 使用后端的历史分析API，发送multipart/form-data请求
      final uri = Uri.parse('${ApiConfig.backendBaseUrl}/analyze-history');
      final request = http.MultipartRequest('POST', uri);
      
      // 添加文件
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
      
      // 添加表单字段
      request.fields['title'] = title;
      request.fields['description'] = description;
      
      // 发送请求
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      
      stopwatch.stop();
      _performanceMonitor.recordApiCall(
        endpoint: 'analyze-history',
        responseTime: stopwatch.elapsed,
        isSuccess: response.statusCode == 200,
        statusCode: response.statusCode,
        dataSize: response.body.length,
      );
      
      if (response.statusCode != 200) {
        throw Exception('历史记录分析API请求失败: ${response.statusCode} - ${response.body}');
      }
      
      final responseData = jsonDecode(response.body);
      
      return AIResult(
        title: responseData['title'] ?? '历史记录分析',
        confidence: responseData['confidence'] ?? 75,
        subInfo: responseData['analysis'] ?? '分析完成',
      );
    } catch (e) {
      stopwatch.stop();
      _performanceMonitor.recordApiCall(
        endpoint: 'analyze-history',
        responseTime: stopwatch.elapsed,
        isSuccess: false,
        statusCode: 0,
        errorMessage: e.toString(),
      );
      
      debugPrint('🚨 历史记录分析错误: $e');
      rethrow;
    }
  }

  /// 分析文本内容（用于文档解析和时间轴生成）
  Future<String> analyzeText(String text, String systemPrompt) async {
    final stopwatch = Stopwatch()..start();
    const endpoint = 'analyze-document';
    
    debugPrint('🤖 调用后端文档解析API: $endpoint');

    try {
      final requestBody = {
        'prompt': text,
        'analysis_type': 'document_timeline'
      };

      // 调用我们的后端API
      final response = await _networkManager.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
        timeout: const Duration(seconds: 60), // 增加超时时间到60秒
      );

      stopwatch.stop();
      _performanceMonitor.recordApiCall(
        endpoint: endpoint,
        responseTime: stopwatch.elapsed,
        isSuccess: response.statusCode == 200,
        statusCode: response.statusCode,
        dataSize: response.body.length,
      );

      if (response.statusCode != 200) {
        throw Exception('后端文本分析API请求失败: ${response.statusCode} - ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      final content = responseData['result'];
      
      debugPrint('🔍 后端文本分析API响应: ${content.substring(0, content.length > 200 ? 200 : content.length)}...');
      
      return content;
    } catch (e) {
      stopwatch.stop();
      _performanceMonitor.recordApiCall(
        endpoint: endpoint,
        responseTime: stopwatch.elapsed,
        isSuccess: false,
        statusCode: 0,
        errorMessage: e.toString(),
      );
      
      // 使用错误处理系统分析API调用错误
      final error = ErrorHandler.instance.analyzeException(
        e,
        context: '文本分析API调用',
        additionalContext: {
          'endpoint': endpoint,
          'textLength': text.length,
        },
      );
      
      debugPrint('🚨 文本分析API调用错误: ${error.type} - ${error.severity}');
      rethrow;
    }
  }

  /// 通过真正的API调用分析图像（仅豆包）
  Future<AIResult> _analyzeImageViaAPI(File imageFile, String mode, [String? modelKey]) async {
    // 移动端优先且仅使用豆包API，避免任何本地或后端回退
    return await _analyzeImageViaDoubao(imageFile, mode, modelKey);
  }

  /// 通过后端代理分析图像（修复Web环境下的认证问题）
  Future<AIResult> _analyzeImageViaDoubao(File imageFile, String mode, [String? modelKey]) async {
    final stopwatch = Stopwatch()..start();
    const endpoint = 'analyze';
    
    debugPrint('🤖 通过后端代理分析图像，模式: $mode');

    try {
      // 使用后端的分析API，发送multipart/form-data请求
      final uri = Uri.parse('${ApiConfig.backendBaseUrl}/$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // 添加文件
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
      
      // 添加模式参数
      request.fields['mode'] = mode;
      
      // 发送请求
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      stopwatch.stop();
      _performanceMonitor.recordApiCall(
        endpoint: endpoint,
        responseTime: stopwatch.elapsed,
        isSuccess: response.statusCode == 200,
        statusCode: response.statusCode,
        dataSize: response.body.length,
      );

      if (response.statusCode != 200) {
        throw Exception('后端API请求失败: ${response.statusCode} - ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      
      // 解析后端返回的数据结构
      if (responseData['success'] == true && responseData['analysis'] != null) {
        final analysis = responseData['analysis'];
        
        // 使用强化的置信度解析
        int confidenceValue = _parseConfidenceRobustly(analysis['confidence'], mode);
        
        debugPrint('🔍 后端API响应解析: title=${analysis['title']}, confidence=$confidenceValue');
        
        return AIResult(
          title: analysis['title'] ?? '图像分析结果',
          confidence: confidenceValue,
          subInfo: analysis['sub_info'] ?? analysis['description'] ?? '分析完成',
        );
      } else {
        throw Exception('后端返回格式错误: $responseData');
      }
    } catch (e) {
      stopwatch.stop();
      _performanceMonitor.recordApiCall(
        endpoint: endpoint,
        responseTime: stopwatch.elapsed,
        isSuccess: false,
        statusCode: 0,
        errorMessage: e.toString(),
      );
      
      // 使用错误处理系统分析API调用错误
      final error = ErrorHandler.instance.analyzeException(
        e,
        context: '后端代理API调用',
        additionalContext: {
          'endpoint': endpoint,
          'mode': mode,
        },
      );
      
      debugPrint('🚨 后端代理API调用错误分析: ${error.type} - ${error.severity}');
      rethrow;
    }
  }

  // 强化的置信度解析函数
  int _parseConfidenceRobustly(dynamic confidence, String analysisMode) {
    // 根据分析模式设置不同的默认值
    int defaultValue;
    switch (analysisMode.toLowerCase()) {
      case 'health':
        defaultValue = 80; // 健康分析默认较高置信度
        break;
      case 'travel':
        defaultValue = 85; // 旅行模式默认较高置信度
        break;
      case 'pet':
        defaultValue = 75; // 宠物分析默认中等置信度
        break;
      default:
        defaultValue = 70; // 普通分析默认较高置信度
    }

    print('🔍 置信度解析 - 模式: $analysisMode, 原始值: $confidence, 默认值: $defaultValue');

    if (confidence == null) {
      print('⚠️ 置信度为空，使用默认值: $defaultValue');
      return defaultValue;
    }

    // 处理不同类型的置信度值
    if (confidence is int) {
      final result = _clampConfidence(confidence);
      print('✅ 整数置信度: $confidence -> $result');
      return result;
    } else if (confidence is double) {
      final result = _clampConfidence(confidence.round());
      print('✅ 浮点置信度: $confidence -> $result');
      return result;
    } else if (confidence is String) {
      // 尝试解析字符串中的数字
      final cleanStr = confidence.replaceAll(RegExp(r'[^\d.]'), '');
      final parsed = double.tryParse(cleanStr);
      if (parsed != null) {
        final result = _clampConfidence(parsed.round());
        print('✅ 字符串置信度解析: "$confidence" -> $result');
        return result;
      }
      
      // 尝试从文本中推断置信度
      final lowerStr = confidence.toLowerCase();
      if (lowerStr.contains('very high') || lowerStr.contains('非常高')) {
        print('✅ 文本置信度推断: "$confidence" -> 95 (非常高)');
        return 95;
      } else if (lowerStr.contains('high') || lowerStr.contains('高')) {
        print('✅ 文本置信度推断: "$confidence" -> 85 (高)');
        return 85;
      } else if (lowerStr.contains('medium') || lowerStr.contains('中等')) {
        print('✅ 文本置信度推断: "$confidence" -> 70 (中等)');
        return 70;
      } else if (lowerStr.contains('low') || lowerStr.contains('低')) {
        print('✅ 文本置信度推断: "$confidence" -> 55 (低)');
        return 55;
      } else if (lowerStr.contains('very low') || lowerStr.contains('非常低')) {
        print('✅ 文本置信度推断: "$confidence" -> 40 (非常低)');
        return 40;
      }
    }

    print('⚠️ 无法解析置信度，使用默认值: $defaultValue');
    return defaultValue;
  }

  // 将置信度限制在合理范围内
  int _clampConfidence(int confidence) {
    final result = confidence.clamp(50, 99); // 置信度范围50-99，确保基础质量
    if (result != confidence) {
      print('🔧 置信度限制: $confidence -> $result (范围: 50-99)');
    }
    return result;
  }

  String? _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return null;
  }
}