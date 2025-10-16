/// 基于MBTI的宠物性格类型分类体系
/// 根据用户提供的性格类型表格建立科学的宠物性格分析模型

/// MBTI性格类型枚举
enum PetMBTIType {
  // 分析师类型 (NT)
  EACN, // 社交好奇型 (Playful Explorer)
  EAWN, // 温柔依赖型 (Gentle Companion)
  ESWN, // 警觉守望型 (Vigilant Watcher)
  ESCN, // 温顺观察型 (Calm Observer)
  
  // 外交官类型 (NF)
  EAWC, // 热情体贴型 (Energetic Guardian)
  EANC, // 自由冒险型 (Bold Wanderer)
  
  // 守护者类型 (SJ)
  SACN, // 内敛温顺型 (Soft Homebody)
  SAWN, // 敏感依恋型 (Tender Watcher)
  SSWN, // 谨慎守护型 (Careful Guardian)
  SANC, // 独立冷静型 (Solitary Thinker)
  
  // 探险家类型 (SP)
  EAWN_FRIENDLY, // 友好观察型 (Friendly Observer)
  EENC, // 探索主导型 (Curious Leader)
  SACW, // 宅家温柔型 (Cozy Companion)
  SANC_RATIONAL, // 理智猎手型 (Rational Hunter)
  ESCN_BALANCED, // 平衡型 (Balanced Spirit)
  EAWC_SUNNY, // 阳光伙伴型 (Sunny Friend)
}

/// 性格维度枚举
enum PersonalityDimension {
  energyOrientation, // 能量导向: E(外向) vs I(内向)
  informationProcessing, // 信息处理: S(感觉) vs N(直觉)
  decisionMaking, // 决策方式: T(思考) vs F(情感)
  lifestylePreference, // 生活方式: J(判断) vs P(感知)
}

/// PersonalityDimension扩展，添加displayName
extension PersonalityDimensionExtension on PersonalityDimension {
  String get displayName {
    switch (this) {
      case PersonalityDimension.energyOrientation:
        return '能量导向';
      case PersonalityDimension.informationProcessing:
        return '信息处理';
      case PersonalityDimension.decisionMaking:
        return '决策方式';
      case PersonalityDimension.lifestylePreference:
        return '生活方式';
    }
  }
}

/// 性格特征强度
enum TraitIntensity {
  weak(0.2),     // 弱
  mild(0.4),     // 轻微
  moderate(0.6), // 中等
  strong(0.8),   // 强
  extreme(1.0);  // 极强

  const TraitIntensity(this.value);
  final double value;
}

/// 宠物MBTI性格类型详细信息
class PetMBTIPersonality {
  final PetMBTIType type;
  final String code; // 4位代码，如 EACN
  final String chineseName; // 中文名称
  final String englishName; // 英文名称
  final String coreCharacteristics; // 核心性格描述
  final List<String> keywords; // 关键词标签
  final Map<PersonalityDimension, double> dimensionScores; // 各维度得分 (0.0-1.0)
  final List<String> behaviorPatterns; // 典型行为模式
  final List<String> socialTraits; // 社交特征
  final List<String> activityPreferences; // 活动偏好
  final double confidence; // 判定置信度

  const PetMBTIPersonality({
    required this.type,
    required this.code,
    required this.chineseName,
    required this.englishName,
    required this.coreCharacteristics,
    required this.keywords,
    required this.dimensionScores,
    required this.behaviorPatterns,
    required this.socialTraits,
    required this.activityPreferences,
    required this.confidence,
  });

  /// 获取性格类型的详细描述
  String get detailedDescription {
    return '$chineseName ($englishName): $coreCharacteristics';
  }

  /// 获取主要关键词（前3个）
  List<String> get primaryKeywords {
    return keywords.take(3).toList();
  }

  /// 判断是否为外向型
  bool get isExtroverted {
    return dimensionScores[PersonalityDimension.energyOrientation]! > 0.5;
  }

  /// 判断是否为直觉型
  bool get isIntuitive {
    return dimensionScores[PersonalityDimension.informationProcessing]! > 0.5;
  }

  /// 判断是否为情感型
  bool get isFeeling {
    return dimensionScores[PersonalityDimension.decisionMaking]! > 0.5;
  }

  /// 判断是否为感知型
  bool get isPerceiving {
    return dimensionScores[PersonalityDimension.lifestylePreference]! > 0.5;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'code': code,
      'chineseName': chineseName,
      'englishName': englishName,
      'coreCharacteristics': coreCharacteristics,
      'keywords': keywords,
      'dimensionScores': dimensionScores.map((k, v) => MapEntry(k.name, v)),
      'behaviorPatterns': behaviorPatterns,
      'socialTraits': socialTraits,
      'activityPreferences': activityPreferences,
      'confidence': confidence,
    };
  }

  factory PetMBTIPersonality.fromJson(Map<String, dynamic> json) {
    return PetMBTIPersonality(
      type: PetMBTIType.values.firstWhere((e) => e.name == json['type']),
      code: json['code'],
      chineseName: json['chineseName'],
      englishName: json['englishName'],
      coreCharacteristics: json['coreCharacteristics'],
      keywords: List<String>.from(json['keywords']),
      dimensionScores: Map<PersonalityDimension, double>.fromEntries(
        (json['dimensionScores'] as Map<String, dynamic>).entries.map(
          (e) => MapEntry(
            PersonalityDimension.values.firstWhere((d) => d.name == e.key),
            e.value.toDouble(),
          ),
        ),
      ),
      behaviorPatterns: List<String>.from(json['behaviorPatterns']),
      socialTraits: List<String>.from(json['socialTraits']),
      activityPreferences: List<String>.from(json['activityPreferences']),
      confidence: json['confidence'].toDouble(),
    );
  }
}

/// 宠物MBTI性格类型数据库
class PetMBTIDatabase {
  static const Map<PetMBTIType, PetMBTIPersonality> _personalities = {
    PetMBTIType.EACN: PetMBTIPersonality(
      type: PetMBTIType.EACN,
      code: 'EACN',
      chineseName: '社交好奇型',
      englishName: 'Playful Explorer',
      coreCharacteristics: '活跃、外向、亲人、放松',
      keywords: ['好奇', '社交', '自信'],
      dimensionScores: {
        PersonalityDimension.energyOrientation: 0.8, // 外向
        PersonalityDimension.informationProcessing: 0.7, // 直觉
        PersonalityDimension.decisionMaking: 0.6, // 情感
        PersonalityDimension.lifestylePreference: 0.7, // 感知
      },
      behaviorPatterns: ['主动探索环境', '喜欢与人互动', '对新事物好奇'],
      socialTraits: ['友善', '活跃', '容易亲近'],
      activityPreferences: ['户外探索', '社交游戏', '新环境适应'],
      confidence: 0.9,
    ),

    PetMBTIType.EAWN: PetMBTIPersonality(
      type: PetMBTIType.EAWN,
      code: 'EAWN',
      chineseName: '温柔依赖型',
      englishName: 'Gentle Companion',
      coreCharacteristics: '外向、亲人、敏感',
      keywords: ['撒娇', '依恋', '警觉'],
      dimensionScores: {
        PersonalityDimension.energyOrientation: 0.7, // 外向
        PersonalityDimension.informationProcessing: 0.3, // 感觉
        PersonalityDimension.decisionMaking: 0.8, // 情感
        PersonalityDimension.lifestylePreference: 0.6, // 感知
      },
      behaviorPatterns: ['寻求关注', '依赖主人', '情感敏感'],
      socialTraits: ['温柔', '黏人', '需要安全感'],
      activityPreferences: ['陪伴活动', '温和游戏', '舒适环境'],
      confidence: 0.85,
    ),

    PetMBTIType.ESWN: PetMBTIPersonality(
      type: PetMBTIType.ESWN,
      code: 'ESWN',
      chineseName: '警觉守望型',
      englishName: 'Vigilant Watcher',
      coreCharacteristics: '稳定、亲人、警觉',
      keywords: ['通讯', '忠诚', '谨慎'],
      dimensionScores: {
        PersonalityDimension.energyOrientation: 0.6, // 外向
        PersonalityDimension.informationProcessing: 0.2, // 感觉
        PersonalityDimension.decisionMaking: 0.4, // 思考
        PersonalityDimension.lifestylePreference: 0.3, // 判断
      },
      behaviorPatterns: ['保持警觉', '守护行为', '观察环境'],
      socialTraits: ['忠诚', '谨慎', '保护性强'],
      activityPreferences: ['巡逻', '守护', '观察'],
      confidence: 0.8,
    ),

    PetMBTIType.ESCN: PetMBTIPersonality(
      type: PetMBTIType.ESCN,
      code: 'ESCN',
      chineseName: '温顺观察型',
      englishName: 'Calm Observer',
      coreCharacteristics: '稳定、安静、放松',
      keywords: ['平和', '观察者'],
      dimensionScores: {
        PersonalityDimension.energyOrientation: 0.6, // 外向
        PersonalityDimension.informationProcessing: 0.2, // 感觉
        PersonalityDimension.decisionMaking: 0.3, // 思考
        PersonalityDimension.lifestylePreference: 0.7, // 感知
      },
      behaviorPatterns: ['安静观察', '温和反应', '稳定情绪'],
      socialTraits: ['平和', '温顺', '不争不抢'],
      activityPreferences: ['安静活动', '观察', '休息'],
      confidence: 0.75,
    ),

    PetMBTIType.EAWC: PetMBTIPersonality(
      type: PetMBTIType.EAWC,
      code: 'EAWC',
      chineseName: '热情体贴型',
      englishName: 'Energetic Guardian',
      coreCharacteristics: '活跃、亲人、规律',
      keywords: ['阳光', '活力', '亲近'],
      dimensionScores: {
        PersonalityDimension.energyOrientation: 0.8, // 外向
        PersonalityDimension.informationProcessing: 0.3, // 感觉
        PersonalityDimension.decisionMaking: 0.7, // 情感
        PersonalityDimension.lifestylePreference: 0.2, // 判断
      },
      behaviorPatterns: ['热情互动', '规律作息', '关爱他人'],
      socialTraits: ['热情', '体贴', '有规律'],
      activityPreferences: ['互动游戏', '规律运动', '社交活动'],
      confidence: 0.85,
    ),

    PetMBTIType.EANC: PetMBTIPersonality(
      type: PetMBTIType.EANC,
      code: 'EANC',
      chineseName: '自由冒险型',
      englishName: 'Bold Wanderer',
      coreCharacteristics: '活跃、独立、好奇',
      keywords: ['探索', '自信', '独行'],
      dimensionScores: {
        PersonalityDimension.energyOrientation: 0.8, // 外向
        PersonalityDimension.informationProcessing: 0.7, // 直觉
        PersonalityDimension.decisionMaking: 0.4, // 思考
        PersonalityDimension.lifestylePreference: 0.8, // 感知
      },
      behaviorPatterns: ['独立探索', '冒险精神', '自主决策'],
      socialTraits: ['独立', '自信', '冒险'],
      activityPreferences: ['探险', '独立活动', '新挑战'],
      confidence: 0.8,
    ),

    // 继续添加其他类型...
    PetMBTIType.SACN: PetMBTIPersonality(
      type: PetMBTIType.SACN,
      code: 'SACN',
      chineseName: '内敛温顺型',
      englishName: 'Soft Homebody',
      coreCharacteristics: '安静、温顺、放松',
      keywords: ['宅家', '温和', '依恋'],
      dimensionScores: {
        PersonalityDimension.energyOrientation: 0.2, // 内向
        PersonalityDimension.informationProcessing: 0.3, // 感觉
        PersonalityDimension.decisionMaking: 0.7, // 情感
        PersonalityDimension.lifestylePreference: 0.7, // 感知
      },
      behaviorPatterns: ['喜欢安静', '温和互动', '居家活动'],
      socialTraits: ['内敛', '温顺', '居家'],
      activityPreferences: ['室内活动', '安静游戏', '舒适环境'],
      confidence: 0.8,
    ),
  };

  /// 获取所有性格类型
  static List<PetMBTIPersonality> getAllPersonalities() {
    return _personalities.values.toList();
  }

  /// 根据类型获取性格信息
  static PetMBTIPersonality? getPersonalityByType(PetMBTIType type) {
    return _personalities[type];
  }

  /// 根据代码获取性格信息
  static PetMBTIPersonality? getPersonalityByCode(String code) {
    return _personalities.values.firstWhere(
      (p) => p.code == code,
      orElse: () => throw ArgumentError('未找到性格类型: $code'),
    );
  }

  /// 获取所有性格类型代码
  static List<String> getAllCodes() {
    return _personalities.values.map((p) => p.code).toList();
  }

  /// 获取所有中文名称
  static List<String> getAllChineseNames() {
    return _personalities.values.map((p) => p.chineseName).toList();
  }

  /// 根据类型获取性格信息（别名方法）
  static PetMBTIPersonality? getPersonality(PetMBTIType type) {
    return getPersonalityByType(type);
  }
}