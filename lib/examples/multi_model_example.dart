import 'dart:io';
import '../services/api_client.dart';
import '../config/api_config.dart';

/// 多模型使用示例
class MultiModelExample {
  static final ApiClient _apiClient = ApiClient.instance;

  /// 使用默认模型分析图像
  static Future<void> analyzeWithDefaultModel(File imageFile) async {
    print('📸 使用默认模型分析图像...');
    try {
      final result = await _apiClient.analyzeImage(imageFile, mode: 'normal');
      print('✅ 默认模型结果: ${result.title} (置信度: ${result.confidence}%)');
    } catch (e) {
      print('❌ 默认模型分析失败: $e');
    }
  }

  /// 使用指定模型分析图像
  static Future<void> analyzeWithSpecificModel(File imageFile, String modelKey) async {
    print('📸 使用模型 $modelKey 分析图像...');
    try {
      final result = await _apiClient.analyzeImage(
        imageFile, 
        mode: 'normal', 
        modelKey: modelKey
      );
      print('✅ 模型 $modelKey 结果: ${result.title} (置信度: ${result.confidence}%)');
    } catch (e) {
      print('❌ 模型 $modelKey 分析失败: $e');
    }
  }

  /// 使用多个模型对比分析
  static Future<void> compareModels(File imageFile) async {
    print('🔍 开始多模型对比分析...');
    
    final availableModels = ApiConfig.getAvailableModels();
    print('📋 可用模型: ${availableModels.join(', ')}');
    
    final results = <String, String>{};
    
    for (final modelKey in availableModels) {
      try {
        print('\n🤖 测试模型: $modelKey');
        final result = await _apiClient.analyzeImage(
          imageFile, 
          mode: 'pet', 
          modelKey: modelKey
        );
        results[modelKey] = '${result.title} (置信度: ${result.confidence}%)';
        print('✅ $modelKey: ${results[modelKey]}');
      } catch (e) {
        results[modelKey] = '分析失败: $e';
        print('❌ $modelKey: ${results[modelKey]}');
      }
    }
    
    print('\n📊 对比结果总结:');
    results.forEach((model, result) {
      print('  $model: $result');
    });
  }

  /// 智能模型选择（主模型失败时自动切换备用模型）
  static Future<void> smartModelSelection(File imageFile) async {
    print('🧠 智能模型选择分析...');
    
    try {
      // 首先尝试主模型
      final result = await _apiClient.analyzeImage(imageFile, mode: 'health');
      print('✅ 主模型分析成功: ${result.title} (置信度: ${result.confidence}%)');
    } catch (e) {
      print('⚠️ 主模型失败，已自动切换到备用模型');
      // ApiClient 内部会自动尝试备用模型
    }
  }

  /// 获取模型配置信息
  static void printModelConfigurations() {
    print('⚙️ 当前模型配置:');
    
    final availableModels = ApiConfig.getAvailableModels();
    for (final modelKey in availableModels) {
      final config = ApiConfig.getModelConfig(modelKey);
      print('  $modelKey:');
      print('    名称: ${config.name}');
      print('    描述: ${config.description}');
      print('    最大令牌: ${config.maxTokens}');
      print('    温度: ${config.temperature}');
      print('    API密钥: ${config.apiKey.substring(0, 8)}...');
      print('');
    }
    
    print('默认模型: ${ApiConfig.defaultModelKey}');
  }
}

/// 使用示例
void main() async {
  // 打印模型配置
  MultiModelExample.printModelConfigurations();
  
  // 假设有一个图像文件
  // final imageFile = File('path/to/your/image.jpg');
  
  // 使用默认模型
  // await MultiModelExample.analyzeWithDefaultModel(imageFile);
  
  // 使用指定模型
  // await MultiModelExample.analyzeWithSpecificModel(imageFile, 'secondary');
  
  // 多模型对比
  // await MultiModelExample.compareModels(imageFile);
  
  // 智能模型选择
  // await MultiModelExample.smartModelSelection(imageFile);
}