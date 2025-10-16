/// 豆包模型配置类
class DoubaoModelConfig {
  final String name;
  final String apiKey;
  final String description;
  final int maxTokens;
  final double temperature;
  
  const DoubaoModelConfig({
    required this.name,
    required this.apiKey,
    required this.description,
    required this.maxTokens,
    required this.temperature,
  });
}

/// API配置管理
class ApiConfig {
  // 后端API配置 - 使用本地后端服务
  static const String backendBaseUrl = 'http://localhost:8000';
  
  // 豆包API配置（支持多模型）
  static const String doubaoBaseUrl = 'https://ark.cn-beijing.volces.com/api/v3';
  
  // 多个豆包模型配置
  static const Map<String, DoubaoModelConfig> doubaoModels = {
    'primary': DoubaoModelConfig(
      name: 'doubao-seed-1-6-flash-250828',
      apiKey: 'e779c50a-bc8c-4673-ada3-30c4e7987018',
      description: '主要模型 - 快速响应',
      maxTokens: 300,
      temperature: 0.3,
    ),
    'history': DoubaoModelConfig(
      name: 'doubao-seed-1-6-thinking-250715',
      apiKey: 'e779c50a-bc8c-4673-ada3-30c4e7987018',
      description: '历史记录处理模型，使用Doubao-Seed-1.6-thinking进行深度思考分析',
      maxTokens: 8192,
      temperature: 0.3,
    ),
    'secondary': DoubaoModelConfig(
      name: 'doubao-pro-4k',  // 示例第二个模型
      apiKey: 'your-second-api-key-here',  // 需要替换为实际的API密钥
      description: '备用模型 - 高质量分析',
      maxTokens: 500,
      temperature: 0.2,
    ),
  };
  
  // 默认使用的模型
  static const String defaultModelKey = 'primary';
  
  // 历史记录处理专用模型
  static const String historyModelKey = 'history';
  
  // 兼容性：保持原有的单模型配置
  static String get doubaoModel => doubaoModels[defaultModelKey]!.name;
  static String get doubaoApiKey => doubaoModels[defaultModelKey]!.apiKey;
  
  // API请求配置
  static const int requestTimeoutSeconds = 12; // 缩短超时以避免长时间阻塞
  static const int maxRetries = 3;
  static const double defaultTemperature = 0.3; // 降低温度以提升JSON一致性
  static const int defaultMaxTokens = 300; // 降低生成token以加速返回
  
  // 统一的系统提示词：简洁、专业、亲和力强；避免“宠物对主人”式语气；表达自然流畅、清晰准确
  static const String systemPromptStyle = '请以简洁、专业且亲和力强的表达方式进行输出，避免使用宠物对主人式的语气或过度拟人化。确保内容清晰准确、结构合理，并保持自然流畅的沟通效果。';
  
  // 图像处理配置
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  
  /// 获取指定模型的配置
  static DoubaoModelConfig getModelConfig(String modelKey) {
    return doubaoModels[modelKey] ?? doubaoModels[defaultModelKey]!;
  }
  
  /// 获取所有可用的模型
  static List<String> getAvailableModels() {
    return doubaoModels.keys.toList();
  }
  
  /// 获取API密钥（支持环境变量覆盖）
  static String getApiKey([String? modelKey]) {
    final config = getModelConfig(modelKey ?? defaultModelKey);
    // 在实际应用中，这里应该从环境变量或安全存储中读取
    // const apiKey = String.fromEnvironment('DOUBAO_API_KEY', defaultValue: config.apiKey);
    return config.apiKey;
  }
  
  /// 获取模型名称
  static String getModelName([String? modelKey]) {
    final config = getModelConfig(modelKey ?? defaultModelKey);
    return config.name;
  }
  
  /// 获取后端分析接口URL
  static String getAnalyzeUrl() {
    return '$backendBaseUrl/analyze';
  }
  
  /// 获取完整的API端点URL（豆包直接调用）
  static String getChatCompletionsUrl() {
    return '$doubaoBaseUrl/chat/completions';
  }
  
  /// 验证API配置
  static bool isConfigValid() {
    return doubaoApiKey.isNotEmpty && 
           doubaoBaseUrl.isNotEmpty && 
           doubaoModel.isNotEmpty;
  }
  
  /// 获取请求头
  static Map<String, String> getHeaders([String? modelKey]) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${getApiKey(modelKey)}',
    };
  }
}