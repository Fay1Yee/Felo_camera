import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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
  Future<AIResult> analyzeImage(File imageFile, {String mode = 'normal'}) async {
    debugPrint('🔍 API客户端开始图像分析: ${imageFile.path}, 模式: $mode');
    
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
      
      // 3. 强制使用真正的豆包API调用，不使用本地AI或后端回退
      final result = await _analyzeImageViaAPI(optimizedFile, mode);
      
      // 4. 缓存结果
      await _resultCache.cacheResult(imageFile, mode, result);
      
      debugPrint('✅ 远程API图像分析完成: ${result.title} (置信度: ${result.confidence}%)');
      return result;
      
    } catch (e) {
      debugPrint('❌ 远程API分析失败: $e');
      
      // 使用新的错误处理系统
      final error = ErrorHandler.instance.analyzeException(
        e,
        context: '图像分析',
        additionalContext: {
          'mode': mode,
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
  
  /// 通过真正的API调用分析图像（仅豆包）
  Future<AIResult> _analyzeImageViaAPI(File imageFile, String mode) async {
    // 移动端优先且仅使用豆包API，避免任何本地或后端回退
    return await _analyzeImageViaDoubao(imageFile, mode);
  }

  /// 直接通过豆包API分析图像
  Future<AIResult> _analyzeImageViaDoubao(File imageFile, String mode) async {
    final stopwatch = Stopwatch()..start();
    const endpoint = 'doubao_analyze';

    try {
      // 读取图像并编码为 base64 data URL
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final imageUrl = 'data:image/jpeg;base64,$base64Image';

      // 根据模式设定提示词，严格要求纯JSON输出
      String prompt;
      switch (mode) {
        case 'pet':
          prompt = '你是宠物行为与识别专家。严格基于图片分析宠物信息（品种、行为、环境、健康线索），并以严格的JSON输出，包含 title（字符串）、confidence（0-100的整数）、subInfo（字符串，内部可嵌入结构化JSON文本，但最终响应只返回最外层JSON）。仅返回纯JSON，不要额外文本。';
          break;
        case 'health':
          prompt = '你是宠物健康评估专家。严格基于图片分析健康状况、风险与建议，并以严格的JSON输出，包含 title（字符串）、confidence（0-100的整数）、subInfo（字符串，内部可嵌入结构化JSON文本，但最终响应只返回最外层JSON）。仅返回纯JSON，不要额外文本。';
          break;
        case 'travel':
          prompt = '你是出行场景分析专家。严格基于图片分析出行相关场景与安全提示，并以严格的JSON输出，包含 title（字符串）、confidence（0-100的整数）、subInfo（字符串，内部可嵌入结构化JSON文本，但最终响应只返回最外层JSON）。仅返回纯JSON，不要额外文本。';
          break;
        default:
          prompt = '严格基于图片进行通用分析，并以严格的JSON输出，包含 title、confidence、subInfo 三个字段。仅返回纯JSON，不要额外文本。';
      }

      final requestBody = {
        'model': ApiConfig.doubaoModel,
        'messages': [
          {
            'role': 'system',
            'content': [
              { 'type': 'text', 'text': ApiConfig.systemPromptStyle }
            ]
          },
          {
            'role': 'user',
            'content': [
              { 'type': 'image_url', 'image_url': { 'url': imageUrl } },
              { 'type': 'text', 'text': prompt }
            ]
          }
        ],
        'max_tokens': ApiConfig.defaultMaxTokens,
        'temperature': ApiConfig.defaultTemperature,
      };

      // 发送豆包API请求
      final response = await _networkManager.post(
        Uri.parse(ApiConfig.getChatCompletionsUrl()),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode(requestBody),
        timeout: const Duration(seconds: 12),
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
        throw Exception('豆包API请求失败: ${response.statusCode} - ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      final content = responseData['choices'][0]['message']['content'];

      // 尝试解析为纯JSON
      try {
        final parsed = jsonDecode(content);
        final confidence = parsed['confidence'];
        
        // 使用强化的置信度解析
        int confidenceValue = _parseConfidenceRobustly(confidence, 'normal');
        
        debugPrint('🔍 API响应解析: title=${parsed['title']}, confidence=$confidenceValue');
        
        return AIResult(
          title: parsed['title'] ?? '图像分析结果',
          confidence: confidenceValue,
          subInfo: parsed['subInfo'] == null
              ? content
              : (parsed['subInfo'] is String
                  ? parsed['subInfo']
                  : jsonEncode(parsed['subInfo'])),
        );
      } catch (parseError) {
        debugPrint('⚠️ JSON解析失败: $parseError, 原始内容: $content');
        // 如果不是纯JSON，尝试提取JSON片段
        final extracted = _extractJson(content);
        if (extracted != null) {
          final parsed = jsonDecode(extracted);
          final confidence = parsed['confidence'];
          
          // 使用强化的置信度解析
          int confidenceValue = _parseConfidenceRobustly(confidence, 'normal');
          
          debugPrint('🔍 提取JSON解析: title=${parsed['title']}, confidence=$confidenceValue');
          
          return AIResult(
            title: parsed['title'] ?? '图像分析结果',
            confidence: confidenceValue,
            subInfo: parsed['subInfo'] == null
                ? extracted
                : (parsed['subInfo'] is String
                    ? parsed['subInfo']
                    : jsonEncode(parsed['subInfo'])),
          );
        }
        throw Exception('豆包响应未按要求返回纯JSON: $content');
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
        context: 'API调用',
        additionalContext: {
          'endpoint': endpoint,
          'mode': mode,
        },
      );
      
      debugPrint('🚨 API调用错误分析: ${error.type} - ${error.severity}');
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