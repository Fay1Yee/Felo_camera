import '../models/ai_result.dart';

/// 宠物对话助手 - 将分析结果转换为可爱的宠物对话语气
class PetConversationHelper {
  
  /// 将AI分析结果转换为宠物对话语气
  static AIResult convertToPetTone(AIResult originalResult) {
    final petTitle = _convertTitleToPetTone(originalResult.title);
    final petSubInfo = _convertSubInfoToPetTone(originalResult.subInfo);
    
    return AIResult(
      title: petTitle,
      confidence: originalResult.confidence,
      subInfo: petSubInfo,
      bbox: originalResult.bbox,
    );
  }
  
  /// 转换标题为宠物语气
  static String _convertTitleToPetTone(String originalTitle) {
    // 移除技术性词汇和原始格式
    String cleanTitle = originalTitle
        .replaceAll(RegExp(r'[{}[\]"]'), '') // 移除大括号和引号
        .replaceAll('分析结果', '')
        .replaceAll('检测到', '')
        .replaceAll('识别', '')
        .trim();
    
    // 根据不同类型的分析结果生成对应的宠物语气，默认所有宠物都是"我的宠物"
    if (cleanTitle.contains('猫') || cleanTitle.contains('喵')) {
      return '主人~ 我看到了我们家的小猫咪呢！';
    } else if (cleanTitle.contains('狗') || cleanTitle.contains('犬')) {
      return '主人~ 我看到了我们家的小狗狗！';
    } else if (cleanTitle.contains('睡觉') || cleanTitle.contains('休息')) {
      return '主人~ 我们的小宝贝正在安静地休息呢~';
    } else if (cleanTitle.contains('吃') || cleanTitle.contains('进食')) {
      return '主人~ 看起来我们的小可爱在享用美食！';
    } else if (cleanTitle.contains('玩') || cleanTitle.contains('游戏')) {
      return '主人~ 发现我们的小宝贝正在开心玩耍！';
    } else if (cleanTitle.contains('跑') || cleanTitle.contains('运动')) {
      return '主人~ 我们的小家伙正在活力满满地运动呢！';
    } else if (cleanTitle.contains('健康')) {
      return '主人~ 让我来关心一下我们小宝贝的健康状况~';
    } else if (cleanTitle.contains('旅行') || cleanTitle.contains('出行')) {
      return '主人~ 准备和我们的小伙伴一起出门冒险吗？';
    } else if (cleanTitle.contains('毛发') || cleanTitle.contains('毛色')) {
      return '主人~ 我们小可爱的毛毛好漂亮呀！';
    } else if (cleanTitle.contains('眼睛') || cleanTitle.contains('眼部')) {
      return '主人~ 我们小宝贝的这双小眼睛真是太有神了！';
    } else if (cleanTitle.contains('失败') || cleanTitle.contains('错误')) {
      return '主人~ 不好意思，我刚才走神了，能再让我看看我们的小宝贝吗？';
    } else if (cleanTitle.isEmpty || cleanTitle == '图像分析结果') {
      return '主人~ 根据我的观察，我们的小宝贝有很多有趣的地方呢！';
    } else {
      // 通用的宠物语气转换，默认认为是"我的宠物"
      return '主人~ 根据我的分析，我们的小宝贝$cleanTitle';
    }
  }
  
  /// 转换详细信息为宠物语气
  static String? _convertSubInfoToPetTone(String? originalSubInfo) {
    if (originalSubInfo == null || originalSubInfo.isEmpty) {
      return '让我仔细观察一下... 嗯嗯，发现了很多有趣的细节呢！';
    }
    
    // 移除技术性词汇和原始格式
    String cleanSubInfo = originalSubInfo
        .replaceAll(RegExp(r'[{}[\]"]'), '') // 移除大括号和引号
        .replaceAll('基于图像特征的综合分析', '')
        .replaceAll('检测到', '我发现了')
        .replaceAll('分析', '观察')
        .replaceAll('识别', '认出')
        .replaceAll('置信度', '我的确信程度')
        .trim();
    
    // 添加宠物语气的前缀和后缀
    List<String> petPrefixes = [
      '我仔细看了看，',
      '根据我的小眼睛观察，',
      '让我告诉主人，',
      '我发现呢，',
      '从我的角度来看，',
    ];
    
    List<String> petSuffixes = [
      '~ 是不是很有趣呀？',
      '~ 主人觉得怎么样？',
      '~ 我观察得对吗？',
      '~ 希望对主人有帮助！',
      '~ 我会继续努力观察的！',
    ];
    
    String prefix = petPrefixes[DateTime.now().millisecond % petPrefixes.length];
    String suffix = petSuffixes[DateTime.now().millisecond % petSuffixes.length];
    
    return '$prefix$cleanSubInfo$suffix';
  }
  
  /// 根据置信度生成鼓励性的表达
  static String getConfidenceExpression(int confidence) {
    if (confidence >= 90) {
      return '我非常确定哦！';
    } else if (confidence >= 80) {
      return '我很有信心呢~';
    } else if (confidence >= 70) {
      return '我觉得应该是这样的~';
    } else if (confidence >= 60) {
      return '我觉得可能是这样~';
    } else {
      return '让我再仔细看看...';
    }
  }
  
  /// 生成随机的宠物表情符号
  static String getRandomPetEmoji() {
    List<String> emojis = ['🐱', '🐶', '🐾', '💕', '✨', '🌟', '😊', '😸', '🥰'];
    return emojis[DateTime.now().millisecond % emojis.length];
  }
}