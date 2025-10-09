import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/ai_result.dart';
import '../config/api_config.dart';
import 'local_ai_client.dart';
import 'image_optimizer.dart';
import 'result_cache.dart';
import 'network_manager.dart' as net;
import 'performance_monitor.dart';

/// API客户端 - 强制使用真正的API调用进行图像分析
class ApiClient {
  static ApiClient? _instance;
  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }
  
  ApiClient._();
  
  final LocalAIClient _localClient = LocalAIClient.instance;
  final ImageOptimizer _imageOptimizer = ImageOptimizer.instance;
  final ResultCache _resultCache = ResultCache.instance;
  final net.NetworkManager _networkManager = net.NetworkManager.instance;
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor.instance;
  bool _useLocalAI = false; // 强制使用真正的API调用

  /// 设置是否使用本地AI（现在强制使用API调用）
  void setUseLocalAI(bool useLocal) {
    _useLocalAI = false; // 强制为false，确保使用API调用
    debugPrint('🔧 API客户端配置：强制使用远程API调用，禁用本地AI服务');
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
      
      // 2. 移动端优化：添加网络连接检查
      if (!await _checkNetworkConnection()) {
        throw Exception('网络连接不可用，请检查网络设置');
      }
      
      // 3. 移动端优化：检查文件大小，如果过大则压缩
      final optimizedFile = await _imageOptimizer.optimizeImage(
        imageFile, 
        mode: mode,
      );
      
      // 4. 强制使用真正的API调用，不使用本地AI
      final result = await _analyzeImageViaAPI(optimizedFile, mode);
      
      // 5. 缓存结果
      await _resultCache.cacheResult(imageFile, mode, result);
      
      debugPrint('✅ 远程API图像分析完成: ${result.title} (置信度: ${result.confidence}%)');
      return result;
      
    } catch (e) {
      debugPrint('❌ 远程API分析失败: $e');
      // 不再使用本地AI作为备用，直接返回错误信息
      return AIResult(
        title: '分析失败',
        confidence: 0,
        subInfo: '远程API调用失败，请检查网络连接和API配置: ${e.toString()}',
      );
    }
  }
  
  /// 检查网络连接状态
  Future<bool> _checkNetworkConnection() async {
    try {
      final quality = await _networkManager.detectNetworkQuality();
      return quality != net.NetworkQuality.poor;
    } catch (e) {
      debugPrint('⚠️ 网络连接检查失败: $e');
      return false;
    }
  }
  
  /// 为移动端优化图片大小
  Future<File> _optimizeImageForMobile(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      const maxSizeBytes = 5 * 1024 * 1024; // 5MB限制
      
      if (fileSize <= maxSizeBytes) {
        return imageFile; // 文件大小合适，直接返回
      }
      
      debugPrint('📱 图片文件过大 (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)，需要压缩');
      
      // 这里可以添加图片压缩逻辑
      // 暂时直接返回原文件，实际项目中应该使用image包进行压缩
      return imageFile;
      
    } catch (e) {
      debugPrint('⚠️ 图片优化失败: $e');
      return imageFile;
    }
  }

  /// 通过真正的API调用分析图像
  Future<AIResult> _analyzeImageViaAPI(File imageFile, String mode) async {
    try {
      // 首先尝试使用后端API服务
      return await _analyzeImageViaBackend(imageFile, mode);
    } catch (backendError) {
      debugPrint('⚠️ 后端API调用失败，尝试直接调用豆包API: $backendError');
      // 如果后端失败，直接调用豆包API
      return await _analyzeImageViaDoubao(imageFile, mode);
    }
  }

  /// 通过后端API服务分析图像
  Future<AIResult> _analyzeImageViaBackend(File imageFile, String mode) async {
    final stopwatch = Stopwatch()..start();
    final endpoint = 'backend_analyze';
    
    try {
      final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.getAnalyzeUrl()));
      
      // 添加图片文件
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      // 添加分析模式
      request.fields['mode'] = mode;
      
      // 移动端优化：设置更短的超时时间和重试机制
      const maxRetries = 1; // 减少重试次数
      const timeoutSeconds = 10; // 进一步减少超时时间
      
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          debugPrint('📡 尝试后端API调用 (第${attempt}次)...');
          
          // 发送请求
          final streamedResponse = await _networkManager.sendMultipart(request);
          
          final response = streamedResponse;
          
          stopwatch.stop();
          
          // 记录性能指标
          _performanceMonitor.recordApiCall(
            endpoint: endpoint,
            responseTime: stopwatch.elapsed,
            isSuccess: response.statusCode == 200,
            statusCode: response.statusCode,
            dataSize: response.body.length,
          );
          
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            
            if (responseData['success'] == true) {
              final analysis = responseData['analysis'];
              return AIResult(
                title: analysis['title'] ?? '图像分析结果',
                confidence: (analysis['confidence'] ?? 85).toDouble(),
                subInfo: analysis['description'] ?? analysis['sub_info'] ?? '分析完成',
              );
            } else {
              throw Exception('后端分析失败: ${responseData['message'] ?? '未知错误'}');
            }
          } else {
            throw Exception('后端API请求失败: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          debugPrint('⚠️ 后端API调用失败 (第${attempt}次): $e');
          if (attempt == maxRetries) {
            stopwatch.stop();
            // 记录失败的性能指标
            _performanceMonitor.recordApiCall(
              endpoint: endpoint,
              responseTime: stopwatch.elapsed,
              isSuccess: false,
              statusCode: 0,
              errorMessage: e.toString(),
            );
            rethrow; // 最后一次尝试失败，抛出异常
          }
          // 等待一段时间后重试
          await Future.delayed(Duration(seconds: attempt));
        }
      }
      
      throw Exception('所有重试都失败了');
    } catch (e) {
      stopwatch.stop();
      // 记录失败的性能指标
      _performanceMonitor.recordApiCall(
        endpoint: endpoint,
        responseTime: stopwatch.elapsed,
        isSuccess: false,
        statusCode: 0,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// 直接通过豆包API分析图像
  Future<AIResult> _analyzeImageViaDoubao(File imageFile, String mode) async {
    final stopwatch = Stopwatch()..start();
    final endpoint = 'doubao_analyze';
    
    try {
      // 读取图像文件
      final imageBytes = await imageFile.readAsBytes();
      
      // 将图像转换为base64
      String base64Image = base64Encode(imageBytes);
      String imageUrl = 'data:image/jpeg;base64,$base64Image';

      // 根据模式选择不同的分析提示词
      String prompt;
      switch (mode) {
        case 'pet':
          prompt = '请详细分析这张图片中的宠物信息，包括品种识别、行为分析、健康状态评估等。请以JSON格式返回结果，包含title（简短标题）、confidence（置信度0-100）、subInfo（详细描述）字段。';
          break;
        case 'health':
          prompt = '请从健康角度分析这张图片，评估宠物的健康状况、潜在风险和护理建议。请以JSON格式返回结果，包含title（简短标题）、confidence（置信度0-100）、subInfo（详细描述）字段。';
          break;
        case 'travel':
          prompt = '请从出行角度分析这张图片，提供宠物旅行相关的建议和注意事项。请以JSON格式返回结果，包含title（简短标题）、confidence（置信度0-100）、subInfo（详细描述）字段。';
          break;
        default:
          prompt = '请分析这张图片的内容，识别其中的物体、场景、动物等，并提供详细的描述。请以JSON格式返回结果，包含title（简短标题）、confidence（置信度0-100）、subInfo（详细描述）字段。';
      }

      // 构建请求体
      Map<String, dynamic> requestBody = {
        'model': ApiConfig.doubaoModel,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': imageUrl,
                }
              },
              {
                'type': 'text',
                'text': prompt,
              }
            ]
          }
        ],
        'max_tokens': ApiConfig.defaultMaxTokens,
        'temperature': ApiConfig.defaultTemperature,
      };

      // 移动端优化：添加重试机制和更短的超时时间
      const maxRetries = 2;
      const timeoutSeconds = 20; // 豆包API可能需要更长时间
      
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          debugPrint('🤖 尝试豆包API调用 (第${attempt}次)...');
          
          // 发送API请求
          final response = await _networkManager.post(
            Uri.parse(ApiConfig.getChatCompletionsUrl()),
            headers: ApiConfig.getHeaders(),
            body: jsonEncode(requestBody),
          );

          stopwatch.stop();
          
          // 记录性能指标
          _performanceMonitor.recordApiCall(
            endpoint: endpoint,
            responseTime: stopwatch.elapsed,
            isSuccess: response.statusCode == 200,
            statusCode: response.statusCode,
            dataSize: response.body.length,
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            final content = responseData['choices'][0]['message']['content'];
            
            // 尝试解析JSON响应
            try {
              final jsonResult = jsonDecode(content);
              return AIResult(
                title: jsonResult['title'] ?? '图像分析结果',
                confidence: (jsonResult['confidence'] ?? 85).toDouble(),
                subInfo: jsonResult['subInfo'] ?? content,
              );
            } catch (e) {
              // 如果不是JSON格式，直接使用文本内容
              return AIResult(
                title: '图像分析结果',
                confidence: 85,
                subInfo: content,
              );
            }
          } else {
            throw Exception('豆包API请求失败: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          debugPrint('⚠️ 豆包API调用失败 (第${attempt}次): $e');
          if (attempt == maxRetries) {
            stopwatch.stop();
            // 记录失败的性能指标
            _performanceMonitor.recordApiCall(
              endpoint: endpoint,
              responseTime: stopwatch.elapsed,
              isSuccess: false,
              statusCode: 0,
              errorMessage: e.toString(),
            );
            rethrow; // 最后一次尝试失败，抛出异常
          }
          // 等待一段时间后重试
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
      
      throw Exception('豆包API调用失败，已重试${maxRetries}次');
    } catch (e) {
      stopwatch.stop();
      // 记录失败的性能指标
      _performanceMonitor.recordApiCall(
        endpoint: endpoint,
        responseTime: stopwatch.elapsed,
        isSuccess: false,
        statusCode: 0,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// 检查是否使用本地AI（现在总是返回false）
  bool get isUsingLocalAI => false;
}