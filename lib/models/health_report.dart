/// 宠物健康报告数据模型
class HealthReport {
  final String petId;
  final DateTime timestamp;
  final String petName;
  final String petType; // 猫、狗等
  final String breed; // 品种
  
  // 生理指标
  final PhysicalIndicators physicalIndicators;
  
  // 行为特征
  final BehaviorAnalysis behaviorAnalysis;
  
  // 健康评估
  final HealthAssessment healthAssessment;
  
  // 建议和归档
  final List<String> recommendations;
  final String archiveId;

  HealthReport({
    required this.petId,
    required this.timestamp,
    required this.petName,
    required this.petType,
    required this.breed,
    required this.physicalIndicators,
    required this.behaviorAnalysis,
    required this.healthAssessment,
    required this.recommendations,
    required this.archiveId,
  });

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'timestamp': timestamp.toIso8601String(),
      'petName': petName,
      'petType': petType,
      'breed': breed,
      'physicalIndicators': physicalIndicators.toJson(),
      'behaviorAnalysis': behaviorAnalysis.toJson(),
      'healthAssessment': healthAssessment.toJson(),
      'recommendations': recommendations,
      'archiveId': archiveId,
    };
  }

  factory HealthReport.fromJson(Map<String, dynamic> json) {
    return HealthReport(
      petId: json['petId'],
      timestamp: DateTime.parse(json['timestamp']),
      petName: json['petName'],
      petType: json['petType'],
      breed: json['breed'],
      physicalIndicators: PhysicalIndicators.fromJson(json['physicalIndicators']),
      behaviorAnalysis: BehaviorAnalysis.fromJson(json['behaviorAnalysis']),
      healthAssessment: HealthAssessment.fromJson(json['healthAssessment']),
      recommendations: List<String>.from(json['recommendations']),
      archiveId: json['archiveId'],
    );
  }
}

/// 生理指标
class PhysicalIndicators {
  final double? weight; // 体重 (kg)
  final double? bodyTemperature; // 体温 (°C)
  final int? heartRate; // 心率 (bpm)
  final int? respiratoryRate; // 呼吸频率 (次/分钟)
  final String eyeCondition; // 眼部状况
  final String noseCondition; // 鼻部状况
  final String coatCondition; // 毛发状况
  final String skinCondition; // 皮肤状况
  final String teethCondition; // 牙齿状况
  final String earCondition; // 耳部状况

  PhysicalIndicators({
    this.weight,
    this.bodyTemperature,
    this.heartRate,
    this.respiratoryRate,
    required this.eyeCondition,
    required this.noseCondition,
    required this.coatCondition,
    required this.skinCondition,
    required this.teethCondition,
    required this.earCondition,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'bodyTemperature': bodyTemperature,
      'heartRate': heartRate,
      'respiratoryRate': respiratoryRate,
      'eyeCondition': eyeCondition,
      'noseCondition': noseCondition,
      'coatCondition': coatCondition,
      'skinCondition': skinCondition,
      'teethCondition': teethCondition,
      'earCondition': earCondition,
    };
  }

  factory PhysicalIndicators.fromJson(Map<String, dynamic> json) {
    return PhysicalIndicators(
      weight: json['weight']?.toDouble(),
      bodyTemperature: json['bodyTemperature']?.toDouble(),
      heartRate: json['heartRate'],
      respiratoryRate: json['respiratoryRate'],
      eyeCondition: json['eyeCondition'],
      noseCondition: json['noseCondition'],
      coatCondition: json['coatCondition'],
      skinCondition: json['skinCondition'],
      teethCondition: json['teethCondition'],
      earCondition: json['earCondition'],
    );
  }
}

/// 行为特征分析
class BehaviorAnalysis {
  final String activityLevel; // 活动水平: 低、中、高
  final String appetiteStatus; // 食欲状况: 正常、减退、亢进
  final String sleepPattern; // 睡眠模式: 正常、失眠、嗜睡
  final String socialBehavior; // 社交行为: 正常、回避、过度亲近
  final String playfulness; // 玩耍性: 正常、减少、过度
  final String vocalBehavior; // 发声行为: 正常、过多、过少
  final List<String> abnormalBehaviors; // 异常行为列表
  final String stressLevel; // 压力水平: 低、中、高

  BehaviorAnalysis({
    required this.activityLevel,
    required this.appetiteStatus,
    required this.sleepPattern,
    required this.socialBehavior,
    required this.playfulness,
    required this.vocalBehavior,
    required this.abnormalBehaviors,
    required this.stressLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'activityLevel': activityLevel,
      'appetiteStatus': appetiteStatus,
      'sleepPattern': sleepPattern,
      'socialBehavior': socialBehavior,
      'playfulness': playfulness,
      'vocalBehavior': vocalBehavior,
      'abnormalBehaviors': abnormalBehaviors,
      'stressLevel': stressLevel,
    };
  }

  factory BehaviorAnalysis.fromJson(Map<String, dynamic> json) {
    return BehaviorAnalysis(
      activityLevel: json['activityLevel'],
      appetiteStatus: json['appetiteStatus'],
      sleepPattern: json['sleepPattern'],
      socialBehavior: json['socialBehavior'],
      playfulness: json['playfulness'],
      vocalBehavior: json['vocalBehavior'],
      abnormalBehaviors: List<String>.from(json['abnormalBehaviors']),
      stressLevel: json['stressLevel'],
    );
  }
}

/// 健康评估
class HealthAssessment {
  final int overallScore; // 总体健康评分 (0-100)
  final String healthStatus; // 健康状态: 优秀、良好、一般、需关注、需就医
  final List<String> healthConcerns; // 健康关注点
  final List<String> positiveAspects; // 积极方面
  final String riskLevel; // 风险等级: 低、中、高
  final DateTime? nextCheckupDate; // 下次检查建议日期

  HealthAssessment({
    required this.overallScore,
    required this.healthStatus,
    required this.healthConcerns,
    required this.positiveAspects,
    required this.riskLevel,
    this.nextCheckupDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'healthStatus': healthStatus,
      'healthConcerns': healthConcerns,
      'positiveAspects': positiveAspects,
      'riskLevel': riskLevel,
      'nextCheckupDate': nextCheckupDate?.toIso8601String(),
    };
  }

  factory HealthAssessment.fromJson(Map<String, dynamic> json) {
    return HealthAssessment(
      overallScore: json['overallScore'],
      healthStatus: json['healthStatus'],
      healthConcerns: List<String>.from(json['healthConcerns']),
      positiveAspects: List<String>.from(json['positiveAspects']),
      riskLevel: json['riskLevel'],
      nextCheckupDate: json['nextCheckupDate'] != null 
          ? DateTime.parse(json['nextCheckupDate']) 
          : null,
    );
  }
}