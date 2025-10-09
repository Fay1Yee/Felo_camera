import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/ai_result.dart';
import 'pet_classifier.dart';

/// 本地AI客户端 - 基于图像内容的真实分析
class LocalAIClient {
  static LocalAIClient? _instance;
  static LocalAIClient get instance {
    _instance ??= LocalAIClient._();
    return _instance!;
  }
  
  LocalAIClient._();
  
  final PetClassifier _classifier = PetClassifier.instance;
  bool _initialized = false;

  /// 初始化本地AI客户端
  Future<void> initialize() async {
    if (_initialized) return;
    
    debugPrint('🚀 初始化本地AI客户端...');
    await _classifier.initialize();
    _initialized = true;
    debugPrint('✅ 本地AI客户端初始化完成');
  }

  /// 分析图像内容
  Future<AIResult> analyzeImage(File imageFile) async {
    if (!_initialized) {
      await initialize();
    }

    debugPrint('🔍 开始本地AI图像分析: ${imageFile.path}');
    
    try {
      // 使用宠物分类器进行真实的图像内容分析
      final result = await _classifier.classifyImage(imageFile);
      
      debugPrint('✅ 本地AI分析完成: ${result.title} (置信度: ${result.confidence}%)');
      return result;
      
    } catch (e) {
      debugPrint('❌ 本地AI分析失败: $e');
      return AIResult(
        title: '分析失败',
        confidence: 0,
        subInfo: '本地AI分析出现错误: $e',
      );
    }
  }

  /// 检查是否已初始化
  bool get isInitialized => _initialized;


}