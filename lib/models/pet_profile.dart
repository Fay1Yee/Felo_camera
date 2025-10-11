/// 宠物档案数据模型
/// 基于Design System Foundations的宠物ID卡概念
class PetProfile {
  final String id;
  final String name;
  final String type; // 猫、狗等
  final String breed; // 品种
  final String gender; // 性别
  final DateTime birthDate;
  final double weight; // 体重 (kg)
  final String color; // 毛色
  final String avatarUrl; // 头像URL
  final String chipId; // 芯片ID
  final String registrationNumber; // 登记号
  final List<String> personalityTags; // 性格标签
  final PetHealthInfo healthInfo;
  final PetOwnerInfo ownerInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.birthDate,
    required this.weight,
    required this.color,
    required this.avatarUrl,
    required this.chipId,
    required this.registrationNumber,
    required this.personalityTags,
    required this.healthInfo,
    required this.ownerInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 计算年龄
  String get age {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    
    if (years > 0) {
      return months > 0 ? '$years岁$months个月' : '$years岁';
    } else {
      return '$months个月';
    }
  }

  /// 获取性格标签显示文本
  List<String> get displayPersonalityTags {
    return personalityTags.take(4).toList(); // 最多显示4个标签
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'weight': weight,
      'color': color,
      'avatarUrl': avatarUrl,
      'chipId': chipId,
      'registrationNumber': registrationNumber,
      'personalityTags': personalityTags,
      'healthInfo': healthInfo.toJson(),
      'ownerInfo': ownerInfo.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      breed: json['breed'],
      gender: json['gender'],
      birthDate: DateTime.parse(json['birthDate']),
      weight: json['weight'].toDouble(),
      color: json['color'],
      avatarUrl: json['avatarUrl'],
      chipId: json['chipId'],
      registrationNumber: json['registrationNumber'],
      personalityTags: List<String>.from(json['personalityTags']),
      healthInfo: PetHealthInfo.fromJson(json['healthInfo']),
      ownerInfo: PetOwnerInfo.fromJson(json['ownerInfo']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// 创建副本
  PetProfile copyWith({
    String? name,
    String? type,
    String? breed,
    String? gender,
    DateTime? birthDate,
    double? weight,
    String? color,
    String? avatarUrl,
    String? chipId,
    String? registrationNumber,
    List<String>? personalityTags,
    PetHealthInfo? healthInfo,
    PetOwnerInfo? ownerInfo,
  }) {
    return PetProfile(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      chipId: chipId ?? this.chipId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      personalityTags: personalityTags ?? this.personalityTags,
      healthInfo: healthInfo ?? this.healthInfo,
      ownerInfo: ownerInfo ?? this.ownerInfo,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// 宠物健康信息
class PetHealthInfo {
  final bool isNeutered; // 是否绝育
  final List<String> allergies; // 过敏源
  final List<String> medications; // 当前用药
  final String veterinarian; // 兽医
  final String veterinaryClinic; // 兽医诊所
  final DateTime? lastCheckup; // 最后体检时间
  final DateTime? nextCheckup; // 下次体检时间
  final List<VaccinationRecord> vaccinations; // 疫苗记录

  PetHealthInfo({
    required this.isNeutered,
    required this.allergies,
    required this.medications,
    required this.veterinarian,
    required this.veterinaryClinic,
    this.lastCheckup,
    this.nextCheckup,
    required this.vaccinations,
  });

  Map<String, dynamic> toJson() {
    return {
      'isNeutered': isNeutered,
      'allergies': allergies,
      'medications': medications,
      'veterinarian': veterinarian,
      'veterinaryClinic': veterinaryClinic,
      'lastCheckup': lastCheckup?.toIso8601String(),
      'nextCheckup': nextCheckup?.toIso8601String(),
      'vaccinations': vaccinations.map((v) => v.toJson()).toList(),
    };
  }

  factory PetHealthInfo.fromJson(Map<String, dynamic> json) {
    return PetHealthInfo(
      isNeutered: json['isNeutered'],
      allergies: List<String>.from(json['allergies']),
      medications: List<String>.from(json['medications']),
      veterinarian: json['veterinarian'],
      veterinaryClinic: json['veterinaryClinic'],
      lastCheckup: json['lastCheckup'] != null ? DateTime.parse(json['lastCheckup']) : null,
      nextCheckup: json['nextCheckup'] != null ? DateTime.parse(json['nextCheckup']) : null,
      vaccinations: (json['vaccinations'] as List).map((v) => VaccinationRecord.fromJson(v)).toList(),
    );
  }
}

/// 疫苗记录
class VaccinationRecord {
  final String name; // 疫苗名称
  final DateTime date; // 接种日期
  final DateTime? nextDue; // 下次接种时间
  final String veterinarian; // 接种兽医
  final String batchNumber; // 批次号

  VaccinationRecord({
    required this.name,
    required this.date,
    this.nextDue,
    required this.veterinarian,
    required this.batchNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'nextDue': nextDue?.toIso8601String(),
      'veterinarian': veterinarian,
      'batchNumber': batchNumber,
    };
  }

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      name: json['name'],
      date: DateTime.parse(json['date']),
      nextDue: json['nextDue'] != null ? DateTime.parse(json['nextDue']) : null,
      veterinarian: json['veterinarian'],
      batchNumber: json['batchNumber'],
    );
  }
}

/// 宠物主人信息
class PetOwnerInfo {
  final String name; // 主人姓名
  final String phone; // 联系电话
  final String email; // 邮箱
  final String address; // 地址
  final String emergencyContact; // 紧急联系人
  final String emergencyPhone; // 紧急联系电话

  PetOwnerInfo({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.emergencyContact,
    required this.emergencyPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
    };
  }

  factory PetOwnerInfo.fromJson(Map<String, dynamic> json) {
    return PetOwnerInfo(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
    );
  }
}

/// 场景模式枚举
enum ScenarioMode {
  home,    // 居家模式
  travel,  // 出行模式
  medical, // 医疗模式
  urban,   // 城市管理模式
}

extension ScenarioModeExtension on ScenarioMode {
  String get displayName {
    switch (this) {
      case ScenarioMode.home:
        return '居家模式';
      case ScenarioMode.travel:
        return '出行模式';
      case ScenarioMode.medical:
        return '医疗模式';
      case ScenarioMode.urban:
        return '城市管理';
    }
  }

  String get icon {
    switch (this) {
      case ScenarioMode.home:
        return '🏠';
      case ScenarioMode.travel:
        return '✈️';
      case ScenarioMode.medical:
        return '🏥';
      case ScenarioMode.urban:
        return '🏙️';
    }
  }

  String get description {
    switch (this) {
      case ScenarioMode.home:
        return '日常居家生活管理';
      case ScenarioMode.travel:
        return '出行旅游场景管理';
      case ScenarioMode.medical:
        return '医疗健康监护';
      case ScenarioMode.urban:
        return '城市公共场所管理';
    }
  }
}