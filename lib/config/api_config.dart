/// API配置管理
class ApiConfig {
  // 后端API配置 - 使用本地后端服务
  static const String backendBaseUrl = 'https://localhost:8443';
  
  // 豆包API配置（备用）
  static const String doubaoBaseUrl = 'https://ark.cn-beijing.volces.com/api/v3';
  static const String doubaoModel = 'doubao-seed-1-6-flash-250828';
  
  // API密钥 - 在生产环境中应该从环境变量或安全存储中获取
  static const String doubaoApiKey = 'e779c50a-bc8c-4673-ada3-30c4e7987018';
  
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
  
  /// 获取API密钥（支持环境变量覆盖）
  static String getApiKey() {
    // 在实际应用中，这里应该从环境变量或安全存储中读取
    // const apiKey = String.fromEnvironment('DOUBAO_API_KEY', defaultValue: doubaoApiKey);
    return doubaoApiKey;
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
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${getApiKey()}',
    };
  }
}