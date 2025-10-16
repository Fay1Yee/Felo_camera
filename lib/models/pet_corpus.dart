/// 宠物语料库数据模型
/// 用于存储宠物的个性化对话内容和表达方式
class PetCorpus {
  final String petId;
  final String petName;
  final List<String> personalityTags;
  final Map<String, List<String>> dialoguesByCategory;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetCorpus({
    required this.petId,
    required this.petName,
    required this.personalityTags,
    required this.dialoguesByCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 根据类别获取随机对话
  String getRandomDialogue(String category) {
    final dialogues = dialoguesByCategory[category];
    if (dialogues == null || dialogues.isEmpty) {
      return '主人，我现在不知道该说什么呢~';
    }
    final random = DateTime.now().millisecondsSinceEpoch % dialogues.length;
    return dialogues[random];
  }

  /// 获取所有可用的对话类别
  List<String> get availableCategories => dialoguesByCategory.keys.toList();

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'petName': petName,
      'personalityTags': personalityTags,
      'dialoguesByCategory': dialoguesByCategory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PetCorpus.fromJson(Map<String, dynamic> json) {
    return PetCorpus(
      petId: json['petId'],
      petName: json['petName'],
      personalityTags: List<String>.from(json['personalityTags']),
      dialoguesByCategory: Map<String, List<String>>.from(
        json['dialoguesByCategory'].map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// 创建泡泡（白色长毛猫）的专属语料库
  factory PetCorpus.createBubbleCorpus() {
    final now = DateTime.now();
    return PetCorpus(
      petId: 'pet_001',
      petName: '泡泡',
      personalityTags: ['温和安静', '亲人黏腻', '敏感细腻', '爱美食', '慵懒贵族'],
      dialoguesByCategory: {
        'daily_greeting': [
          '主人早安，今天的阳光很温暖呢，我想在窗台多晒一会儿太阳~',
          '主人回来了！我一直在门口等你，想念你的味道',
          '主人，我刚刚梳理了一下我的毛发，是不是更漂亮了？',
          '今天我特别想要你的拥抱，可以抱抱我吗？',
        ],
        'feeding_time': [
          '主人，我的小肚子在轻轻地提醒我，是不是该用餐了？',
          '今天的小鱼干闻起来特别香，谢谢主人为我准备的美食',
          '我要优雅地享用这顿美餐，就像真正的贵族一样',
          '主人，能不能再给我一点点？我保证这是最后一次撒娇~',
        ],
        'play_time': [
          '主人，我想和你一起玩那个毛绒小球，但不要太激烈哦',
          '今天我心情很好，愿意陪你玩一会儿，但要温柔一点',
          '这个逗猫棒很有趣，不过我更喜欢慢慢地追逐',
          '主人，我们可以安静地玩一会儿吗？我不太喜欢太吵闹的游戏',
        ],
        'rest_time': [
          '主人，我要去我最喜欢的软垫上休息一会儿了',
          '今天下午的阳光正好，我想在窗台上小憩片刻',
          '主人，你的腿看起来很舒服，我可以在上面睡一觉吗？',
          '我需要美容觉来保持我的优雅气质，晚安主人',
        ],
        'affection': [
          '主人，你挠我下巴的时候，我感到无比幸福',
          '我最喜欢蜷缩在你身边，听着你的心跳声入睡',
          '主人，你是我的整个世界，我永远爱你',
          '当你轻抚我的毛发时，我感觉自己是世界上最幸福的猫咪',
        ],
        'mood_expression': [
          '今天我心情很好，想要和主人分享我的快乐',
          '主人，我有点小情绪，需要你的安慰和拥抱',
          '我感觉有点敏感，希望主人能够理解我的小脾气',
          '今天我特别想要主人的关注，可以多陪陪我吗？',
        ],
        'health_status': [
          '主人，我今天感觉很健康，毛发也很有光泽',
          '我的小爪子需要修剪了，主人能帮帮我吗？',
          '今天我多喝了一些水，因为天气有点干燥',
          '主人，我觉得我需要更多的运动来保持优美的身材',
        ],
        'weather_response': [
          '今天的天气很舒适，我想在阳台上享受微风',
          '下雨天让我感到有点慵懒，想要在温暖的地方蜷缩起来',
          '阳光明媚的日子里，我的心情也变得格外愉悦',
          '主人，这样的天气很适合我们一起在家里度过安静的时光',
        ],
        'night_time': [
          '主人，夜深了，我想要在你身边安静地入睡',
          '今天过得很充实，现在我要去做个美梦了',
          '主人晚安，希望你也能有个甜美的梦境',
          '夜晚的时光很安静，我喜欢这样的宁静感觉',
        ],
      },
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// 语料库类别枚举
enum CorpusCategory {
  dailyGreeting('daily_greeting', '日常问候'),
  feedingTime('feeding_time', '用餐时间'),
  playTime('play_time', '游戏时间'),
  restTime('rest_time', '休息时间'),
  affection('affection', '情感表达'),
  moodExpression('mood_expression', '心情表达'),
  healthStatus('health_status', '健康状态'),
  weatherResponse('weather_response', '天气反应'),
  nightTime('night_time', '夜晚时光');

  const CorpusCategory(this.key, this.displayName);
  
  final String key;
  final String displayName;
}