import 'dart:math';
import '../models/pet_corpus.dart';

/// 宠物语料库服务
/// 负责管理和提供宠物的个性化对话内容
class PetCorpusService {
  static final PetCorpusService _instance = PetCorpusService._internal();
  factory PetCorpusService() => _instance;
  PetCorpusService._internal();

  PetCorpus? _currentCorpus;
  final Random _random = Random();

  /// 初始化语料库
  void initialize({String? petId}) {
    // 目前使用泡泡的语料库，后续可以根据petId加载不同的语料库
    _currentCorpus = PetCorpus.createBubbleCorpus();
  }

  /// 获取当前语料库
  PetCorpus? get currentCorpus => _currentCorpus;

  /// 根据类别获取随机对话
  String getRandomDialogue(CorpusCategory category) {
    if (_currentCorpus == null) {
      initialize();
    }
    return _currentCorpus!.getRandomDialogue(category.key);
  }

  /// 根据时间获取合适的对话
  String getTimeBasedDialogue() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 9) {
      // 早晨时间
      return getRandomDialogue(CorpusCategory.dailyGreeting);
    } else if (hour >= 11 && hour < 14) {
      // 午餐时间
      return getRandomDialogue(CorpusCategory.feedingTime);
    } else if (hour >= 14 && hour < 17) {
      // 下午休息时间
      return getRandomDialogue(CorpusCategory.restTime);
    } else if (hour >= 17 && hour < 20) {
      // 傍晚活动时间
      return getRandomDialogue(CorpusCategory.playTime);
    } else if (hour >= 20 && hour < 22) {
      // 晚餐时间
      return getRandomDialogue(CorpusCategory.feedingTime);
    } else {
      // 夜晚时间
      return getRandomDialogue(CorpusCategory.nightTime);
    }
  }

  /// 根据行为类型获取对话
  String getBehaviorBasedDialogue(String behaviorType) {
    switch (behaviorType) {
      case '玩耍':
      case 'playing':
        return getRandomDialogue(CorpusCategory.playTime);
      case '观望':
      case 'watching':
        return getRandomDialogue(CorpusCategory.moodExpression);
      case '探索':
      case 'exploring':
        return getRandomDialogue(CorpusCategory.playTime);
      case '攻击':
      case 'attacking':
        return getRandomDialogue(CorpusCategory.playTime);
      case '无宠物':
      case 'no_pet':
        return '主人，我想念你的陪伴，快回来看看我吧~';
      default:
        return getRandomDialogue(CorpusCategory.dailyGreeting);
    }
  }

  /// 获取情感表达对话
  String getAffectionDialogue() {
    return getRandomDialogue(CorpusCategory.affection);
  }

  /// 获取健康状态对话
  String getHealthDialogue() {
    return getRandomDialogue(CorpusCategory.healthStatus);
  }

  /// 根据天气获取对话
  String getWeatherBasedDialogue(String weatherCondition) {
    // 这里可以根据实际天气API返回的数据来判断
    return getRandomDialogue(CorpusCategory.weatherResponse);
  }

  /// 获取随机心情表达
  String getRandomMoodExpression() {
    return getRandomDialogue(CorpusCategory.moodExpression);
  }

  /// 获取所有可用的对话类别
  List<CorpusCategory> get availableCategories => CorpusCategory.values;

  /// 获取宠物名字
  String get petName => _currentCorpus?.petName ?? '泡泡';

  /// 获取性格标签
  List<String> get personalityTags => _currentCorpus?.personalityTags ?? [];

  /// 创建个性化问候语
  String createPersonalizedGreeting() {
    final greetings = [
      '主人，${petName}想你了！今天过得怎么样？',
      '${petName}一直在等你回来呢，快来抱抱我吧~',
      '主人，${petName}今天表现得很乖，有没有小奖励呢？',
      '${petName}感觉今天的你特别温柔，我好喜欢~',
    ];
    return greetings[_random.nextInt(greetings.length)];
  }

  /// 创建基于活动的对话
  String createActivityBasedDialogue(String activity, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    String timeDescription = '';
    if (hours > 0) {
      timeDescription = '${hours}小时';
      if (minutes > 0) {
        timeDescription += '${minutes}分钟';
      }
    } else {
      timeDescription = '${minutes}分钟';
    }

    switch (activity) {
      case '晒太阳':
        return '主人，我在窗台晒了${timeDescription}的太阳，感觉毛发都变得更加柔顺了呢~';
      case '睡觉':
        return '我刚刚睡了一个${timeDescription}的美容觉，现在精神饱满，想要和主人玩耍~';
      case '吃饭':
        return '刚才的美食真是太棒了，我用了${timeDescription}慢慢品尝，现在心满意足~';
      case '玩耍':
        return '和主人玩了${timeDescription}，虽然有点累，但是很开心！';
      default:
        return '我刚刚${activity}了${timeDescription}，感觉很充实呢~';
    }
  }
}