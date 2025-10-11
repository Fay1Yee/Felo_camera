import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'network_manager.dart';

class DoubaoApiClient {
  static final DoubaoApiClient _instance = DoubaoApiClient._();
  static DoubaoApiClient get instance => _instance;

  DoubaoApiClient._() {
    // 预热豆包API连接，降低首包延迟
    try {
      NetworkManager.instance.preWarmConnections([ApiConfig.getChatCompletionsUrl()]);
    } catch (e) {
      debugPrint('预热豆包API连接失败: $e');
    }
  }

  final NetworkManager _networkManager = NetworkManager.instance;

  /// 分析图像并返回结果
  Future<String> analyzeImage(Uint8List imageBytes, String prompt) async {
    try {
      // 将图像转换为base64
      String base64Image = base64Encode(imageBytes);
      String imageUrl = 'data:image/jpeg;base64,$base64Image';

      // 构建请求体
      Map<String, dynamic> requestBody = {
        'model': ApiConfig.doubaoModel,
        'messages': [
          {
            'role': 'system',
            'content': [
              {
                'type': 'text',
                'text': ApiConfig.systemPromptStyle,
              }
            ]
          },
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

      // 使用统一的网络管理器（带重试与短超时）
      final response = await _networkManager.post(
        Uri.parse(ApiConfig.getChatCompletionsUrl()),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['choices'][0]['message']['content'];
      } else {
        throw Exception('API请求失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('图像分析失败: $e');
    }
  }

  /// 分析宠物健康状况
  Future<String> analyzePetHealth(Uint8List imageBytes, String petName, String petType) async {
    String prompt = '''
请分析这张宠物照片中的健康状况。宠物名称：$petName，类型：$petType。

请从以下方面进行分析：
1. 外观健康状况（毛发、眼睛、鼻子、姿态等）
2. 精神状态评估
3. 可能的健康风险
4. 建议的护理措施

请以JSON格式返回结果，包含以下字段：
{
  "healthStatus": "健康/一般/需要关注",
  "riskLevel": "低/中/高",
  "observations": ["观察到的具体情况"],
  "recommendations": ["具体建议"]
}
''';

    return await analyzeImage(imageBytes, prompt);
  }

  /// 分析宠物活动状况
  Future<String> analyzePetActivity(Uint8List imageBytes, String petName) async {
    String prompt = '''
请分析这张宠物照片中的活动状况。宠物名称：$petName。

请评估：
1. 当前活动类型（睡觉、玩耍、进食、休息等）
2. 活动强度水平（1-10分）
3. 精力状态评估
4. 行为特征分析

请以JSON格式返回结果，且仅返回JSON，不要包含任何额外文本或解释。字段如下：
{
  "activityType": "活动类型",
  "energyLevel": 数值(1-10),
  "behaviorNotes": "行为观察",
  "timestamp": "当前时间戳"
}
''';

    return await analyzeImage(imageBytes, prompt);
  }

  /// 分析旅行场景
  Future<String> analyzeTravelScene(Uint8List imageBytes) async {
    String prompt = '''
请分析这张照片中的场景和环境。

请识别：
1. 场景类型（室内/室外、具体环境）
2. 地理位置特征
3. 天气状况
4. 适合的活动建议
5. 安全注意事项

请以JSON格式返回结果，包含以下字段：
{
  "sceneType": "场景类型",
  "location": "可能的地点",
  "weather": "天气状况",
  "activities": ["推荐活动"],
  "safetyTips": ["安全提示"]
}
''';

    return await analyzeImage(imageBytes, prompt);
  }
}