/// 多层级行为分类体系
/// 建立科学严谨的宠物行为分类和量化判定标准

/// 行为分类层级枚举
enum BehaviorLevel {
  primary,   // 一级分类：基础行为类别
  secondary, // 二级分类：具体行为类型
  tertiary,  // 三级分类：行为细节特征
}

/// 行为强度等级
enum BehaviorIntensity {
  minimal(1, '极轻微', 0.0, 0.2),
  low(2, '轻微', 0.2, 0.4),
  moderate(3, '中等', 0.4, 0.6),
  high(4, '强烈', 0.6, 0.8),
  extreme(5, '极强烈', 0.8, 1.0);

  const BehaviorIntensity(this.level, this.description, this.minValue, this.maxValue);
  final int level;
  final String description;
  final double minValue;
  final double maxValue;

  /// 根据数值获取强度等级
  static BehaviorIntensity fromValue(double value) {
    for (final intensity in BehaviorIntensity.values) {
      if (value >= intensity.minValue && value <= intensity.maxValue) {
        return intensity;
      }
    }
    return BehaviorIntensity.moderate;
  }
}

/// 行为持续性类型
enum BehaviorDuration {
  instantaneous('瞬时', 0, 5),      // 0-5秒
  brief('短暂', 5, 30),             // 5-30秒
  short('短期', 30, 300),           // 30秒-5分钟
  medium('中期', 300, 1800),        // 5-30分钟
  long('长期', 1800, 7200),         // 30分钟-2小时
  extended('持续', 7200, double.infinity); // 2小时以上

  const BehaviorDuration(this.description, this.minSeconds, this.maxSeconds);
  final String description;
  final double minSeconds;
  final double maxSeconds;

  /// 根据持续时间获取类型
  static BehaviorDuration fromSeconds(double seconds) {
    for (final duration in BehaviorDuration.values) {
      if (seconds >= duration.minSeconds && seconds < duration.maxSeconds) {
        return duration;
      }
    }
    return BehaviorDuration.medium;
  }
}

/// 行为频率类型
enum BehaviorFrequency {
  rare('罕见', 0.0, 0.1),           // 0-10%
  occasional('偶尔', 0.1, 0.3),     // 10-30%
  regular('常规', 0.3, 0.6),        // 30-60%
  frequent('频繁', 0.6, 0.8),       // 60-80%
  constant('持续', 0.8, 1.0);       // 80-100%

  const BehaviorFrequency(this.description, this.minRatio, this.maxRatio);
  final String description;
  final double minRatio;
  final double maxRatio;

  /// 根据频率比例获取类型
  static BehaviorFrequency fromRatio(double ratio) {
    for (final frequency in BehaviorFrequency.values) {
      if (ratio >= frequency.minRatio && ratio <= frequency.maxRatio) {
        return frequency;
      }
    }
    return BehaviorFrequency.regular;
  }
}

/// 行为分类节点
class BehaviorNode {
  final String id;
  final String name;
  final String description;
  final BehaviorLevel level;
  final BehaviorNode? parent;
  final List<BehaviorNode> children;
  final List<String> keywords;
  final List<String> indicators; // 判定指标
  final Map<String, double> quantificationCriteria; // 量化标准
  final double confidenceThreshold; // 置信度阈值

  BehaviorNode({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    this.parent,
    List<BehaviorNode>? children,
    List<String>? keywords,
    List<String>? indicators,
    Map<String, double>? quantificationCriteria,
    this.confidenceThreshold = 0.7,
  }) : children = children ?? [],
       keywords = keywords ?? [],
       indicators = indicators ?? [],
       quantificationCriteria = quantificationCriteria ?? {};

  /// 添加子节点
  void addChild(BehaviorNode child) {
    children.add(child);
  }

  /// 获取所有叶子节点
  List<BehaviorNode> getLeafNodes() {
    if (children.isEmpty) {
      return [this];
    }
    
    final leaves = <BehaviorNode>[];
    for (final child in children) {
      leaves.addAll(child.getLeafNodes());
    }
    return leaves;
  }

  /// 获取完整路径
  String getFullPath() {
    if (parent == null) {
      return name;
    }
    return '${parent!.getFullPath()} > $name';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level.name,
      'keywords': keywords,
      'indicators': indicators,
      'quantificationCriteria': quantificationCriteria,
      'confidenceThreshold': confidenceThreshold,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}

/// 行为量化指标
class BehaviorQuantification {
  final String behaviorId;
  final BehaviorIntensity intensity;
  final BehaviorDuration duration;
  final BehaviorFrequency frequency;
  final double confidence;
  final Map<String, double> metrics; // 具体量化指标
  final DateTime timestamp;

  const BehaviorQuantification({
    required this.behaviorId,
    required this.intensity,
    required this.duration,
    required this.frequency,
    required this.confidence,
    required this.metrics,
    required this.timestamp,
  });

  /// 计算综合评分
  double get overallScore {
    final intensityScore = intensity.level / 5.0;
    final durationWeight = duration.index / BehaviorDuration.values.length;
    final frequencyWeight = frequency.maxRatio;
    
    return (intensityScore * 0.4 + durationWeight * 0.3 + frequencyWeight * 0.3) * confidence;
  }

  Map<String, dynamic> toJson() {
    return {
      'behaviorId': behaviorId,
      'intensity': intensity.name,
      'duration': duration.name,
      'frequency': frequency.name,
      'confidence': confidence,
      'metrics': metrics,
      'timestamp': timestamp.toIso8601String(),
      'overallScore': overallScore,
    };
  }
}

/// 行为分类体系管理器
class BehaviorHierarchyManager {
  static BehaviorHierarchyManager? _instance;
  static BehaviorHierarchyManager get instance {
    return _instance ??= BehaviorHierarchyManager._();
  }

  BehaviorHierarchyManager._() {
    _initializeHierarchy();
  }

  late final BehaviorNode _rootNode;
  final Map<String, BehaviorNode> _nodeMap = {};

  /// 初始化行为分类体系
  void _initializeHierarchy() {
    _rootNode = BehaviorNode(
      id: 'root',
      name: '宠物行为分类体系',
      description: '宠物行为的完整分类体系',
      level: BehaviorLevel.primary,
    );

    // 一级分类：基础行为类别
    final primaryCategories = [
      _createSocialBehaviorCategory(),
      _createPhysicalBehaviorCategory(),
      _createEmotionalBehaviorCategory(),
      _createCognitiveBehaviorCategory(),
      _createMaintenanceBehaviorCategory(),
    ];

    for (final category in primaryCategories) {
      _rootNode.addChild(category);
      _registerNode(category);
    }
  }

  /// 创建社交行为分类
  BehaviorNode _createSocialBehaviorCategory() {
    final socialBehavior = BehaviorNode(
      id: 'social',
      name: '社交行为',
      description: '与其他生物或环境的互动行为',
      level: BehaviorLevel.primary,
      parent: _rootNode,
      keywords: ['社交', '互动', '交流', '群体'],
      indicators: ['接触频率', '互动时长', '反应积极性'],
      quantificationCriteria: {
        '接触频率': 0.3,
        '互动时长': 0.4,
        '反应积极性': 0.3,
      },
    );

    // 二级分类
    final secondaryNodes = [
      BehaviorNode(
        id: 'social_friendly',
        name: '友好互动',
        description: '表现出友善和亲近的社交行为',
        level: BehaviorLevel.secondary,
        parent: socialBehavior,
        keywords: ['友好', '亲近', '温和', '接触'],
        indicators: ['主动接近', '身体接触', '温和反应'],
        quantificationCriteria: {
          '主动接近频率': 0.4,
          '身体接触时长': 0.3,
          '温和反应比例': 0.3,
        },
      ),
      BehaviorNode(
        id: 'social_aggressive',
        name: '攻击性行为',
        description: '表现出威胁或攻击性的社交行为',
        level: BehaviorLevel.secondary,
        parent: socialBehavior,
        keywords: ['攻击', '威胁', '对抗', '防御'],
        indicators: ['威胁姿态', '攻击动作', '声音威胁'],
        quantificationCriteria: {
          '威胁姿态频率': 0.4,
          '攻击动作强度': 0.4,
          '声音威胁音量': 0.2,
        },
      ),
      BehaviorNode(
        id: 'social_avoidance',
        name: '回避行为',
        description: '避免或逃离社交接触的行为',
        level: BehaviorLevel.secondary,
        parent: socialBehavior,
        keywords: ['回避', '逃离', '躲藏', '退缩'],
        indicators: ['回避频率', '逃离速度', '躲藏时长'],
        quantificationCriteria: {
          '回避频率': 0.4,
          '逃离速度': 0.3,
          '躲藏时长': 0.3,
        },
      ),
    ];

    for (final node in secondaryNodes) {
      socialBehavior.addChild(node);
      _registerNode(node);
    }

    return socialBehavior;
  }

  /// 创建身体行为分类
  BehaviorNode _createPhysicalBehaviorCategory() {
    final physicalBehavior = BehaviorNode(
      id: 'physical',
      name: '身体行为',
      description: '涉及身体运动和姿态的行为',
      level: BehaviorLevel.primary,
      parent: _rootNode,
      keywords: ['运动', '姿态', '活动', '移动'],
      indicators: ['活动强度', '运动频率', '姿态变化'],
      quantificationCriteria: {
        '活动强度': 0.4,
        '运动频率': 0.3,
        '姿态变化': 0.3,
      },
    );

    // 二级分类
    final secondaryNodes = [
      BehaviorNode(
        id: 'physical_locomotion',
        name: '移动行为',
        description: '各种形式的位置移动',
        level: BehaviorLevel.secondary,
        parent: physicalBehavior,
        keywords: ['走', '跑', '跳', '爬'],
        indicators: ['移动速度', '移动距离', '移动频率'],
        quantificationCriteria: {
          '移动速度': 0.4,
          '移动距离': 0.3,
          '移动频率': 0.3,
        },
      ),
      BehaviorNode(
        id: 'physical_posture',
        name: '姿态行为',
        description: '身体姿态和位置的调整',
        level: BehaviorLevel.secondary,
        parent: physicalBehavior,
        keywords: ['坐', '躺', '站', '蹲'],
        indicators: ['姿态稳定性', '姿态持续时间', '姿态变化频率'],
        quantificationCriteria: {
          '姿态稳定性': 0.4,
          '姿态持续时间': 0.4,
          '姿态变化频率': 0.2,
        },
      ),
      BehaviorNode(
        id: 'physical_manipulation',
        name: '操作行为',
        description: '使用身体部位操作物体',
        level: BehaviorLevel.secondary,
        parent: physicalBehavior,
        keywords: ['抓', '咬', '推', '拉'],
        indicators: ['操作精度', '操作力度', '操作成功率'],
        quantificationCriteria: {
          '操作精度': 0.4,
          '操作力度': 0.3,
          '操作成功率': 0.3,
        },
      ),
    ];

    for (final node in secondaryNodes) {
      physicalBehavior.addChild(node);
      _registerNode(node);
    }

    return physicalBehavior;
  }

  /// 创建情感行为分类
  BehaviorNode _createEmotionalBehaviorCategory() {
    final emotionalBehavior = BehaviorNode(
      id: 'emotional',
      name: '情感行为',
      description: '表达情感状态的行为',
      level: BehaviorLevel.primary,
      parent: _rootNode,
      keywords: ['情感', '情绪', '表达', '反应'],
      indicators: ['情感强度', '表达清晰度', '情感持续性'],
      quantificationCriteria: {
        '情感强度': 0.4,
        '表达清晰度': 0.3,
        '情感持续性': 0.3,
      },
    );

    // 二级分类
    final secondaryNodes = [
      BehaviorNode(
        id: 'emotional_positive',
        name: '积极情感',
        description: '表现出快乐、满足等积极情感',
        level: BehaviorLevel.secondary,
        parent: emotionalBehavior,
        keywords: ['快乐', '满足', '兴奋', '放松'],
        indicators: ['积极表现频率', '兴奋程度', '放松状态'],
        quantificationCriteria: {
          '积极表现频率': 0.4,
          '兴奋程度': 0.3,
          '放松状态': 0.3,
        },
      ),
      BehaviorNode(
        id: 'emotional_negative',
        name: '消极情感',
        description: '表现出焦虑、恐惧等消极情感',
        level: BehaviorLevel.secondary,
        parent: emotionalBehavior,
        keywords: ['焦虑', '恐惧', '紧张', '沮丧'],
        indicators: ['紧张程度', '恐惧反应', '焦虑表现'],
        quantificationCriteria: {
          '紧张程度': 0.4,
          '恐惧反应': 0.3,
          '焦虑表现': 0.3,
        },
      ),
      BehaviorNode(
        id: 'emotional_neutral',
        name: '中性情感',
        description: '情感状态平稳，无明显倾向',
        level: BehaviorLevel.secondary,
        parent: emotionalBehavior,
        keywords: ['平静', '中性', '稳定', '无反应'],
        indicators: ['情感稳定性', '反应平淡度', '状态一致性'],
        quantificationCriteria: {
          '情感稳定性': 0.5,
          '反应平淡度': 0.3,
          '状态一致性': 0.2,
        },
      ),
    ];

    for (final node in secondaryNodes) {
      emotionalBehavior.addChild(node);
      _registerNode(node);
    }

    return emotionalBehavior;
  }

  /// 创建认知行为分类
  BehaviorNode _createCognitiveBehaviorCategory() {
    final cognitiveBehavior = BehaviorNode(
      id: 'cognitive',
      name: '认知行为',
      description: '涉及学习、记忆和问题解决的行为',
      level: BehaviorLevel.primary,
      parent: _rootNode,
      keywords: ['学习', '记忆', '探索', '解决'],
      indicators: ['学习速度', '记忆保持', '问题解决能力'],
      quantificationCriteria: {
        '学习速度': 0.4,
        '记忆保持': 0.3,
        '问题解决能力': 0.3,
      },
    );

    // 二级分类
    final secondaryNodes = [
      BehaviorNode(
        id: 'cognitive_exploration',
        name: '探索行为',
        description: '主动探索和调查环境',
        level: BehaviorLevel.secondary,
        parent: cognitiveBehavior,
        keywords: ['探索', '调查', '嗅探', '观察'],
        indicators: ['探索范围', '探索时长', '探索深度'],
        quantificationCriteria: {
          '探索范围': 0.3,
          '探索时长': 0.4,
          '探索深度': 0.3,
        },
      ),
      BehaviorNode(
        id: 'cognitive_learning',
        name: '学习行为',
        description: '获取新技能或适应新环境',
        level: BehaviorLevel.secondary,
        parent: cognitiveBehavior,
        keywords: ['学习', '适应', '模仿', '训练'],
        indicators: ['学习进度', '技能掌握', '适应速度'],
        quantificationCriteria: {
          '学习进度': 0.4,
          '技能掌握': 0.4,
          '适应速度': 0.2,
        },
      ),
      BehaviorNode(
        id: 'cognitive_problem_solving',
        name: '问题解决',
        description: '面对障碍时的解决策略',
        level: BehaviorLevel.secondary,
        parent: cognitiveBehavior,
        keywords: ['解决', '策略', '创新', '尝试'],
        indicators: ['解决成功率', '策略多样性', '尝试次数'],
        quantificationCriteria: {
          '解决成功率': 0.5,
          '策略多样性': 0.3,
          '尝试次数': 0.2,
        },
      ),
    ];

    for (final node in secondaryNodes) {
      cognitiveBehavior.addChild(node);
      _registerNode(node);
    }

    return cognitiveBehavior;
  }

  /// 创建维护行为分类
  BehaviorNode _createMaintenanceBehaviorCategory() {
    final maintenanceBehavior = BehaviorNode(
      id: 'maintenance',
      name: '维护行为',
      description: '维持身体健康和基本需求的行为',
      level: BehaviorLevel.primary,
      parent: _rootNode,
      keywords: ['维护', '健康', '需求', '生理'],
      indicators: ['维护频率', '维护质量', '需求满足度'],
      quantificationCriteria: {
        '维护频率': 0.3,
        '维护质量': 0.4,
        '需求满足度': 0.3,
      },
    );

    // 二级分类
    final secondaryNodes = [
      BehaviorNode(
        id: 'maintenance_feeding',
        name: '进食行为',
        description: '获取和消费食物',
        level: BehaviorLevel.secondary,
        parent: maintenanceBehavior,
        keywords: ['进食', '饮水', '咀嚼', '吞咽'],
        indicators: ['进食量', '进食速度', '食物偏好'],
        quantificationCriteria: {
          '进食量': 0.4,
          '进食速度': 0.3,
          '食物偏好': 0.3,
        },
      ),
      BehaviorNode(
        id: 'maintenance_grooming',
        name: '梳理行为',
        description: '清洁和维护身体',
        level: BehaviorLevel.secondary,
        parent: maintenanceBehavior,
        keywords: ['梳理', '清洁', '舔毛', '抓挠'],
        indicators: ['梳理频率', '梳理时长', '清洁彻底度'],
        quantificationCriteria: {
          '梳理频率': 0.3,
          '梳理时长': 0.4,
          '清洁彻底度': 0.3,
        },
      ),
      BehaviorNode(
        id: 'maintenance_resting',
        name: '休息行为',
        description: '睡眠和恢复体力',
        level: BehaviorLevel.secondary,
        parent: maintenanceBehavior,
        keywords: ['睡眠', '休息', '放松', '恢复'],
        indicators: ['睡眠时长', '睡眠质量', '休息频率'],
        quantificationCriteria: {
          '睡眠时长': 0.4,
          '睡眠质量': 0.4,
          '休息频率': 0.2,
        },
      ),
    ];

    for (final node in secondaryNodes) {
      maintenanceBehavior.addChild(node);
      _registerNode(node);
    }

    return maintenanceBehavior;
  }

  /// 注册节点到映射表
  void _registerNode(BehaviorNode node) {
    _nodeMap[node.id] = node;
    for (final child in node.children) {
      _registerNode(child);
    }
  }

  /// 获取根节点
  BehaviorNode get rootNode => _rootNode;

  /// 根据ID获取节点
  BehaviorNode? getNodeById(String id) {
    return _nodeMap[id];
  }

  /// 获取所有一级分类
  List<BehaviorNode> getPrimaryCategories() {
    return _rootNode.children;
  }

  /// 获取所有叶子节点
  List<BehaviorNode> getAllLeafNodes() {
    return _rootNode.getLeafNodes();
  }

  /// 根据关键词搜索节点
  List<BehaviorNode> searchByKeywords(List<String> keywords) {
    final results = <BehaviorNode>[];
    
    for (final node in _nodeMap.values) {
      for (final keyword in keywords) {
        if (node.keywords.any((k) => k.contains(keyword)) ||
            node.name.contains(keyword) ||
            node.description.contains(keyword)) {
          results.add(node);
          break;
        }
      }
    }
    
    return results;
  }

  /// 获取完整的分类体系JSON
  Map<String, dynamic> getHierarchyJson() {
    return _rootNode.toJson();
  }
}