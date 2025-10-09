enum Mode { normal, pet, health, travel }

extension ModeExtension on Mode {
  String get displayName {
    switch (this) {
      case Mode.normal:
        return '通用';
      case Mode.pet:
        return '宠物';
      case Mode.health:
        return '健康';
      case Mode.travel:
        return '出行';
    }
  }
}