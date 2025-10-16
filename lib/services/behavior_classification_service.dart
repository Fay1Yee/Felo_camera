import '../models/pet_activity.dart';
import '../screens/data_management/life_records_screen.dart';

/// 行为分类映射服务
/// 确保图表展示严格遵循文档定义的行动类型
class BehaviorClassificationService {
  static BehaviorClassificationService? _instance;
  static BehaviorClassificationService get instance {
    return _instance ??= BehaviorClassificationService._();
  }
  
  BehaviorClassificationService._();

  /// 获取所有文档标准分类（优先显示）
  List<String> getDocumentStandardCategories() {
    return [
      ActivityType.observe.displayName,
      ActivityType.explore.displayName,
      ActivityType.occupy.displayName,
      ActivityType.play.displayName,
      ActivityType.attack.displayName,
      ActivityType.neutral.displayName,
      ActivityType.no_pet.displayName,
    ];
  }

  /// 获取所有程序现有分类
  List<String> getProgramExistingCategories() {
    return [
      ActivityType.playing.displayName,
      ActivityType.eating.displayName,
      ActivityType.sleeping.displayName,
      ActivityType.feeding.displayName,
      ActivityType.grooming.displayName,
      ActivityType.resting.displayName,
      ActivityType.running.displayName,
      ActivityType.walking.displayName,
      ActivityType.training.displayName,
      ActivityType.socializing.displayName,
      ActivityType.exploring.displayName,
      ActivityType.other.displayName,
    ];
  }

  /// 获取所有行为类型（按文档优先级排序）
  List<String> getAllBehaviorTypes() {
    return [
      ...getDocumentStandardCategories(),
      ...getProgramExistingCategories(),
    ];
  }

  /// 将英文行为类型映射为中文显示名称
  String mapBehaviorToDisplayName(String behavior) {
    // 首先尝试直接匹配ActivityType枚举
    for (final activityType in ActivityType.values) {
      if (behavior == activityType.name || 
          behavior == activityType.displayName) {
        return activityType.displayName;
      }
    }

    // 兼容性映射（处理历史数据）
    final compatibilityMap = {
      // 英文到中文映射
      'observe': ActivityType.observe.displayName,
      'explore': ActivityType.explore.displayName,
      'occupy': ActivityType.occupy.displayName,
      'play': ActivityType.play.displayName,
      'attack': ActivityType.attack.displayName,
      'neutral': ActivityType.neutral.displayName,
      'no_pet': ActivityType.no_pet.displayName,
      'playing': ActivityType.playing.displayName,
      'eating': ActivityType.eating.displayName,
      'sleeping': ActivityType.sleeping.displayName,
      'feeding': ActivityType.feeding.displayName,
      'grooming': ActivityType.grooming.displayName,
      'resting': ActivityType.resting.displayName,
      'running': ActivityType.running.displayName,
      'walking': ActivityType.walking.displayName,
      'training': ActivityType.training.displayName,
      'socializing': ActivityType.socializing.displayName,
      'exploring': ActivityType.exploring.displayName,
      'other': ActivityType.other.displayName,
      
      // 旧版中文映射
      '观望': ActivityType.observe.displayName,
      '探索': ActivityType.explore.displayName,
      '领地': ActivityType.occupy.displayName,
      '玩耍': ActivityType.playing.displayName,
      '攻击': ActivityType.attack.displayName,
      '中性': ActivityType.neutral.displayName,
      '无宠物': ActivityType.no_pet.displayName,
      '进食': ActivityType.eating.displayName,
      '睡眠': ActivityType.sleeping.displayName,
      '喂食': ActivityType.feeding.displayName,
      '美容护理': ActivityType.grooming.displayName,
      '休息': ActivityType.resting.displayName,
      '奔跑': ActivityType.running.displayName,
      '散步': ActivityType.walking.displayName,
      '训练': ActivityType.training.displayName,
      '社交': ActivityType.socializing.displayName,
      '其他': ActivityType.other.displayName,
    };

    return compatibilityMap[behavior] ?? behavior;
  }

  /// 获取行为类型的图标
  String getBehaviorIcon(String behavior) {
    final displayName = mapBehaviorToDisplayName(behavior);
    
    // 根据ActivityType枚举获取图标
    for (final activityType in ActivityType.values) {
      if (displayName == activityType.displayName) {
        return activityType.emoji;
      }
    }

    return '🐾'; // 默认图标
  }

  /// 获取行为类型的颜色
  String getBehaviorColor(String behavior) {
    final displayName = mapBehaviorToDisplayName(behavior);
    
    // 文档标准分类使用主色调
    if (getDocumentStandardCategories().contains(displayName)) {
      final index = getDocumentStandardCategories().indexOf(displayName);
      final colors = [
        '#FF6B6B', // 观望行为 - 红色
        '#4ECDC4', // 探索行为 - 青色
        '#45B7D1', // 领地行为 - 蓝色
        '#96CEB4', // 玩耍行为 - 绿色
        '#FFEAA7', // 攻击行为 - 黄色
        '#DDA0DD', // 无特定行为 - 紫色
        '#A0A0A0', // 无宠物 - 灰色
      ];
      return colors[index % colors.length];
    }
    
    // 程序现有分类使用辅助色调
    final index = getProgramExistingCategories().indexOf(displayName);
    if (index >= 0) {
      final colors = [
        '#74B9FF', // 玩耍 - 浅蓝
        '#FD79A8', // 进食 - 粉色
        '#6C5CE7', // 睡觉 - 紫色
        '#A29BFE', // 休息 - 淡紫
        '#FD79A8', // 运动 - 橙色
        '#FDCB6E', // 静止 - 黄色
        '#E17055', // 发声 - 橙红
        '#00B894', // 梳理 - 绿色
        '#00CEC9', // 探索 - 青绿
        '#E84393', // 社交 - 玫红
        '#FF7675', // 警戒 - 红色
        '#636E72', // 其他 - 灰色
      ];
      return colors[index % colors.length];
    }
    
    return '#636E72'; // 默认灰色
  }

  /// 检查行为类型是否为文档标准分类
  bool isDocumentStandardCategory(String behavior) {
    final displayName = mapBehaviorToDisplayName(behavior);
    return getDocumentStandardCategories().contains(displayName);
  }

  /// 检查行为类型是否为程序现有分类
  bool isProgramExistingCategory(String behavior) {
    final displayName = mapBehaviorToDisplayName(behavior);
    return getProgramExistingCategories().contains(displayName);
  }

  /// 获取行为类型的分类标签
  String getBehaviorCategoryLabel(String behavior) {
    if (isDocumentStandardCategory(behavior)) {
      return '文档标准';
    } else if (isProgramExistingCategory(behavior)) {
      return '现有程序';
    }
    return '';
  }

  /// 根据标签获取记录类型
  RecordType getRecordTypeFromTags(List<String> tags, String mode) {
    // 检查标签中是否包含标准化的行为类型
    for (String tag in tags) {
      final displayName = mapBehaviorToDisplayName(tag);
      
      if (displayName == ActivityType.eating.displayName) return RecordType.feeding;
       if (displayName == ActivityType.playing.displayName) return RecordType.play;
       if (displayName == ActivityType.sleeping.displayName || 
           displayName == ActivityType.resting.displayName) return RecordType.sleep;
       if (displayName == ActivityType.running.displayName || 
           displayName == ActivityType.walking.displayName) return RecordType.exercise;
       if (displayName == ActivityType.grooming.displayName) return RecordType.grooming;
       if (displayName == ActivityType.socializing.displayName) return RecordType.social;
      
      // 检查原始标签
      if (tag.contains('健康检查')) return RecordType.health;
    }
    
    // 基于模式的默认类型
    switch (mode) {
      case 'health': return RecordType.health;
      case 'pet': return RecordType.play;
      case 'travel': return RecordType.exercise;
      default: return RecordType.other;
    }
  }
}