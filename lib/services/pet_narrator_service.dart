import 'dart:math';
import '../models/pet_profile.dart';
import '../models/pet_activity.dart';

/// 宠物第一人称叙述服务
/// 提供各种场景下的宠物视角表达，让界面信息以宠物的口吻呈现
class PetNarratorService {
  static final PetNarratorService _instance = PetNarratorService._internal();
  factory PetNarratorService() => _instance;
  PetNarratorService._internal();

  final Random _random = Random();
  PetProfile? _currentPet;

  /// 初始化当前宠物信息
  void initialize(PetProfile pet) {
    _currentPet = pet;
  }

  /// 获取当前宠物
  PetProfile? get currentPet => _currentPet;

  /// 宠物自我介绍
  String getSelfIntroduction() {
    if (_currentPet == null) return '我还没有完整的档案信息呢~';
    
    final pet = _currentPet!;
    final age = _calculateAge(pet.birthDate);
    
    final introductions = [
      '大家好，我是${pet.name}！我是一只${age}的${pet.breed}，性格${pet.personalityTags.take(2).join('、')}。',
      '嗨～我叫${pet.name}，是个${age}的小${pet.type}咪。我的性格比较${pet.personalityTags.first}，希望大家喜欢我！',
      '我是${pet.name}，一只可爱的${pet.breed}。今年${age}了，平时喜欢${_getPersonalityDescription()}。',
      '你好呀！我是${pet.name}，${pet.color}的毛发是我的特色。我${age}了，是个${pet.personalityTags.take(2).join('又')}的小家伙。',
    ];
    
    return introductions[_random.nextInt(introductions.length)];
  }

  /// 档案信息的第一人称描述
  String getProfileDescription() {
    if (_currentPet == null) return '我的档案还在完善中...';
    
    final pet = _currentPet!;
    final age = _calculateAge(pet.birthDate);
    
    return '我叫${pet.name}，是一只${pet.breed}。我${age}了，体重${pet.weight}kg，有着${pet.color}的毛发。'
           '我的性格${pet.personalityTags.take(3).join('、')}，'
           '${pet.healthInfo.isNeutered ? '已经做过绝育手术了' : '还没有做绝育手术'}。';
  }

  /// 健康状态的第一人称描述
  String getHealthDescription() {
    if (_currentPet == null) return '我的健康状态还在记录中...';
    
    final pet = _currentPet!;
    final healthInfo = pet.healthInfo;
    
    final descriptions = [
      '我的身体状况很好！体重保持在${pet.weight}kg，${healthInfo.isNeutered ? '已经绝育了，' : ''}定期去${healthInfo.veterinaryClinic}找${healthInfo.veterinarian}检查。',
      '我很健康哦～现在${pet.weight}kg，${healthInfo.allergies.isEmpty ? '没有过敏源' : '对${healthInfo.allergies.join('、')}过敏'}，${healthInfo.medications.isEmpty ? '不需要吃药' : '在服用${healthInfo.medications.join('、')}'}。',
      '我的健康档案显示一切正常！${healthInfo.veterinarian}说我保养得很好，体重${pet.weight}kg刚刚好。',
    ];
    
    return descriptions[_random.nextInt(descriptions.length)];
  }

  /// 活动记录的第一人称描述
  String getActivityDescription(PetActivity activity) {
    final timeStr = _formatTime(activity.timestamp);
    
    switch (activity.activityType) {
      case ActivityType.playing:
      case ActivityType.play:
        return '${timeStr}我玩得好开心！${activity.description}，感觉精力充沛！';
      case ActivityType.eating:
      case ActivityType.feeding:
        return '${timeStr}我在享受美食时光～${activity.description}，真是太香了！';
      case ActivityType.sleeping:
      case ActivityType.resting:
        return '${timeStr}我在休息中...${activity.description}，睡觉是我的最爱！';
      case ActivityType.exploring:
      case ActivityType.explore:
        return '${timeStr}我在探索新世界！${activity.description}，好奇心驱使着我。';
      case ActivityType.grooming:
        return '${timeStr}我在整理毛发，${activity.description}，要保持美美的样子！';
      case ActivityType.observe:
        return '${timeStr}我在观察周围，${activity.description}，总是保持警觉。';
      case ActivityType.occupy:
        return '${timeStr}这是我的地盘！${activity.description}，我要守护好这里。';
      case ActivityType.attack:
        return '${timeStr}我展现了我的威武！${activity.description}，不要小看我哦。';
      default:
        return '${timeStr}我在做一些有趣的事情～${activity.description}';
    }
  }

  /// 性格标签的第一人称描述
  String getPersonalityDescription() {
    if (_currentPet == null || _currentPet!.personalityTags.isEmpty) {
      return '我还在展现我的性格特点...';
    }
    
    final tags = _currentPet!.personalityTags;
    final descriptions = [
      '我是一个${tags.take(3).join('、')}的小家伙，这就是我的性格特色！',
      '大家都说我${tags.take(2).join('又')}，我觉得这样的我很可爱呢～',
      '我的性格比较${tags.first}，但有时候也会${tags.length > 1 ? tags[1] : '很活泼'}哦！',
      '我${tags.take(3).join('、')}，这些特点让我很特别！',
    ];
    
    return descriptions[_random.nextInt(descriptions.length)];
  }

  /// 时间相关的第一人称表达
  String getTimeBasedExpression() {
    final hour = DateTime.now().hour;
    final pet = _currentPet;
    
    if (hour >= 6 && hour < 9) {
      return pet != null && pet.personalityTags.contains('慵懒贵族') 
          ? '早上好～我还想再睡一会儿呢...' 
          : '早上好！我已经准备好迎接新的一天了！';
    } else if (hour >= 9 && hour < 12) {
      return '上午时光真美好，我精神饱满地度过每一刻！';
    } else if (hour >= 12 && hour < 14) {
      return '午餐时间到了，我的肚子开始咕咕叫了～';
    } else if (hour >= 14 && hour < 17) {
      return pet != null && pet.personalityTags.contains('慵懒贵族')
          ? '下午是我最喜欢的慵懒时光，晒晒太阳真舒服～'
          : '下午好！我在享受这美好的时光。';
    } else if (hour >= 17 && hour < 19) {
      return '傍晚了，这是我比较活跃的时候呢！';
    } else if (hour >= 19 && hour < 22) {
      return '晚上好～这是我们一起相处的温馨时光。';
    } else {
      return pet != null && pet.personalityTags.contains('温和安静')
          ? '夜深了，我要安静地休息了，晚安～'
          : '夜晚时光，我在静静地陪伴着你。';
    }
  }

  /// 情绪表达
  String getEmotionalExpression(String emotion) {
    final pet = _currentPet;
    
    switch (emotion.toLowerCase()) {
      case 'happy':
      case '开心':
        return pet != null && pet.personalityTags.contains('优雅淑女')
            ? '我心情很好呢～优雅地表达我的快乐！'
            : '我好开心啊！尾巴都要摇起来了～';
      case 'sad':
      case '难过':
        return pet != null && pet.personalityTags.contains('敏感细腻')
            ? '我有点难过...需要一些安慰和关爱。'
            : '我心情不太好，希望能得到你的陪伴。';
      case 'excited':
      case '兴奋':
        return '我超级兴奋！感觉浑身都充满了活力！';
      case 'calm':
      case '平静':
        return pet != null && pet.personalityTags.contains('温和安静')
            ? '我很平静，享受这份宁静的美好。'
            : '我现在很平静，心情很放松。';
      case 'curious':
      case '好奇':
        return '我对周围的一切都很好奇，想要探索更多！';
      default:
        return '我现在的心情...嗯，让我想想怎么表达呢～';
    }
  }

  /// 互动回应
  String getInteractionResponse(String action) {
    final pet = _currentPet;
    
    switch (action.toLowerCase()) {
      case 'pet':
      case '抚摸':
        return pet != null && pet.personalityTags.contains('亲人黏腻')
            ? '我最喜欢你的抚摸了！请继续～'
            : '你的抚摸让我很舒服，我很享受这个时刻。';
      case 'feed':
      case '喂食':
        return pet != null && pet.personalityTags.contains('爱美食')
            ? '哇！是我最爱的食物吗？我已经迫不及待了！'
            : '谢谢你给我准备的食物，我会好好享用的！';
      case 'play':
      case '玩耍':
        return '太好了！我们一起玩吧，我已经准备好了！';
      case 'call':
      case '呼唤':
        return pet != null && pet.personalityTags.contains('温和安静')
            ? '我听到你在叫我，我会乖乖过来的～'
            : '我来了！你找我有什么事吗？';
      default:
        return '我感受到了你的关注，这让我很开心！';
    }
  }

  /// 状态更新通知
  String getStatusUpdateNotification(String updateType, dynamic data) {
    switch (updateType) {
      case 'weight':
        return '我的体重更新了！现在是${data}kg，希望这个数字让你满意～';
      case 'health':
        return '我的健康档案有了新的记录，感谢你对我健康的关心！';
      case 'activity':
        return '我刚刚完成了一项活动，记录在我的生活档案里了！';
      case 'vaccination':
        return '我接种了疫苗，虽然有点疼，但为了健康这是值得的！';
      default:
        return '我的信息有了新的更新，谢谢你一直关心我！';
    }
  }

  /// 私有方法：计算年龄
  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.difference(birthDate);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return months > 0 ? '${years}岁${months}个月' : '${years}岁';
    } else {
      return '${months}个月';
    }
  }

  /// 私有方法：格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 私有方法：获取性格描述
  String _getPersonalityDescription() {
    if (_currentPet == null || _currentPet!.personalityTags.isEmpty) {
      return '各种有趣的事情';
    }
    
    final tags = _currentPet!.personalityTags;
    if (tags.contains('慵懒贵族')) return '晒太阳和睡觉';
    if (tags.contains('爱美食')) return '品尝美食';
    if (tags.contains('亲人黏腻')) return '和主人待在一起';
    if (tags.contains('优雅淑女')) return '保持优雅的姿态';
    
    return '做一些${tags.first}的事情';
  }

  /// 获取随机的日常表达
  String getRandomDailyExpression() {
    final expressions = [
      '今天也是美好的一天呢～',
      '我在这里静静地陪伴着你。',
      '生活真是充满了小确幸！',
      '每一天都有新的发现和体验。',
      '我很满足现在的生活状态。',
      '感谢你一直以来的照顾和关爱！',
      '我们一起度过的时光总是那么温馨。',
      '我希望能给你带来更多的快乐！',
    ];
    
    return expressions[_random.nextInt(expressions.length)];
  }

  /// 获取基于活动的心情表达
  String getMoodBasedOnActivity(ActivityType activityType) {
    switch (activityType) {
      case ActivityType.playing:
      case ActivityType.play:
        return '玩耍让我心情特别好！';
      case ActivityType.eating:
      case ActivityType.feeding:
        return '美食总是能让我开心起来～';
      case ActivityType.sleeping:
      case ActivityType.resting:
        return '休息让我感到很放松。';
      case ActivityType.exploring:
      case ActivityType.explore:
        return '探索新事物让我充满好奇！';
      case ActivityType.grooming:
        return '整理毛发让我感觉很舒适。';
      default:
        return '我现在的心情很不错！';
    }
  }
}