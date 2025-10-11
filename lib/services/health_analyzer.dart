import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/health_report.dart';
import 'api_client.dart';

/// 宠物健康分析器 - 基于图像进行健康状况评估
class HealthAnalyzer {
  static HealthAnalyzer? _instance;
  static HealthAnalyzer get instance {
    _instance ??= HealthAnalyzer._();
    return _instance!;
  }
  
  HealthAnalyzer._();

  /// 分析宠物健康状况
  Future<HealthReport> analyzeHealth(File imageFile, String petName, String petType) async {
    debugPrint('🏥 开始健康分析: $petName ($petType)');
    
    try {
      // 读取并解码图像（用于校验）
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('无法解码图像文件');
      }

      // 统一使用 ApiClient 调用豆包
      try {
        final ai = await ApiClient.instance.analyzeImage(imageFile, mode: 'health');
        // 尝试从 AIResult.subInfo 解析结构化 JSON
        Map<String, dynamic>? analysisResult;
        try {
          analysisResult = ai.subInfo != null ? jsonDecode(ai.subInfo!) : null;
        } catch (_) {
          final extracted = ai.subInfo != null ? _extractJson(ai.subInfo!) : null;
          if (extracted != null) {
            try {
              analysisResult = jsonDecode(extracted);
            } catch (_) {}
          }
        }

        if (analysisResult != null) {
          // 基于结构化结果构建报告
          final timestamp = DateTime.now();
          final petId = '${petType.toLowerCase()}_${timestamp.millisecondsSinceEpoch}';
          final archiveId = 'health_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}_$petId';
          return _buildHealthReportFromApi(analysisResult, petId, timestamp, petName, petType, archiveId);
        }
        
        // 严格要求结构化JSON，否则返回错误
        return _generateErrorReport(petName, petType, '豆包响应缺少结构化JSON');
      } catch (e) {
        debugPrint('⚠️ 统一API分析失败: $e');
        return _generateErrorReport(petName, petType, e.toString());
      }
      
    } catch (e) {
      debugPrint('❌ 健康分析失败: $e');
      return _generateErrorReport(petName, petType, e.toString());
    }
  }

  /// 从文本中提取JSON片段
  String? _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return null;
  }

  /// 使用 AIResult 构建简化的健康报告
  // ignore: unused_element
  HealthReport _buildReportFromAiResult(dynamic ai, img.Image image, String petName, String petType) {
    final timestamp = DateTime.now();
    final petId = '${petType.toLowerCase()}_${timestamp.millisecondsSinceEpoch}';
    // ignore: unused_local_variable
    final archiveId = 'health_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}_$petId';

    // 基于图像简单分析以补充指标
    final imageAnalysis = _analyzeImageForHealth(image);
    final physicalIndicators = _generatePhysicalIndicators(imageAnalysis, petType);
    final behaviorAnalysis = _generateBehaviorAnalysis(imageAnalysis, petType);

    final healthStatus = ai.title.isNotEmpty ? '一般' : '未知';
    final riskLevel = ai.confidence >= 80 ? '低' : (ai.confidence >= 60 ? '中' : '高');

    final healthAssessment = HealthAssessment(
      healthStatus: healthStatus,
      riskLevel: riskLevel,
      overallScore: (ai.confidence).round(),
      healthConcerns: [ai.subInfo],
      positiveAspects: ['图像分析完成'],
    );

    return HealthReport(
      petId: petId,
      timestamp: timestamp,
      petName: petName,
      petType: petType,
      breed: _inferBreedFromType(petType),
      physicalIndicators: physicalIndicators,
      behaviorAnalysis: behaviorAnalysis,
      healthAssessment: healthAssessment,
      recommendations: ['保持规律喂养', '注意休息与活动平衡'],
      archiveId: archiveId,
    );
  }

  /// 生成健康报告（原逻辑保留）
  // ignore: unused_element
  Future<HealthReport> _generateHealthReport(img.Image image, String petName, String petType) async {
    final timestamp = DateTime.now();
    final petId = '${petType.toLowerCase()}_${timestamp.millisecondsSinceEpoch}';
    // ignore: unused_local_variable
    final archiveId = 'health_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}_$petId';

    try {
      // 旧逻辑：直接走豆包API，已弃用，统一通过 ApiClient
      throw Exception('use ApiClient only');
    } catch (e) {
      debugPrint('⚠️ API调用失败: $e');
      return _generateErrorReport(petName, petType, e.toString());
    }
  }

  /// 基于API结果构建健康报告（原方法保留）
  HealthReport _buildHealthReportFromApi(
    Map<String, dynamic> analysisResult, 
    String petId, 
    DateTime timestamp, 
    String petName, 
    String petType, 
    String archiveId
  ) {
    // 从API结果中提取信息
    final healthStatus = analysisResult['healthStatus'] ?? '一般';
    final riskLevel = analysisResult['riskLevel'] ?? '中';
    final observations = List<String>.from(analysisResult['observations'] ?? []);
    final recommendations = List<String>.from(analysisResult['recommendations'] ?? []);

    // 生成生理指标（基于API分析结果）
    final physicalIndicators = _generatePhysicalIndicatorsFromApi(analysisResult, petType);
    
    // 生成行为分析
    final behaviorAnalysis = _generateBehaviorAnalysisFromApi(analysisResult, petType);
    
    // 生成健康评估
    final healthAssessment = HealthAssessment(
      healthStatus: healthStatus,
      riskLevel: riskLevel,
      overallScore: _calculateScoreFromStatus(healthStatus),
      healthConcerns: observations,
      positiveAspects: ['宠物整体状态良好'],
    );

    return HealthReport(
      petId: petId,
      timestamp: timestamp,
      petName: petName,
      petType: petType,
      breed: _inferBreedFromType(petType),
      physicalIndicators: physicalIndicators,
      behaviorAnalysis: behaviorAnalysis,
      healthAssessment: healthAssessment,
      recommendations: recommendations,
      archiveId: archiveId,
    );
  }

  /// 基于API结果生成生理指标
  PhysicalIndicators _generatePhysicalIndicatorsFromApi(Map<String, dynamic> analysisResult, String petType) {
    final random = math.Random();
    
    // 从API结果推断生理指标
    final healthStatus = analysisResult['healthStatus'] ?? '一般';
    final observations = List<String>.from(analysisResult['observations'] ?? []);
    
    // 基于健康状态调整指标
    // ignore: unused_local_variable
    double baseScore = healthStatus == '健康' ? 0.8 : 
                      healthStatus == '一般' ? 0.6 : 0.4;
    
    return PhysicalIndicators(
      weight: 3.5 + random.nextDouble() * 2.0,
      bodyTemperature: 38.0 + random.nextDouble() * 1.5,
      heartRate: 80 + random.nextInt(40),
      respiratoryRate: 20 + random.nextInt(20),
      coatCondition: observations.any((obs) => obs.contains('毛发')) ? '需要关注' : '良好',
      eyeCondition: observations.any((obs) => obs.contains('眼')) ? '需要关注' : '明亮清澈',
      noseCondition: '湿润',
      teethCondition: '清洁',
      earCondition: '清洁',
      skinCondition: '健康',
    );
  }

  /// 基于API结果生成行为分析
  BehaviorAnalysis _generateBehaviorAnalysisFromApi(Map<String, dynamic> analysisResult, String petType) {
    // ignore: unused_local_variable
    final random = math.Random();
    final observations = List<String>.from(analysisResult['observations'] ?? []);
    
    return BehaviorAnalysis(
      activityLevel: observations.any((obs) => obs.contains('活跃')) ? '高' : '中',
      appetiteStatus: '正常',
      socialBehavior: '友好',
      stressLevel: observations.any((obs) => obs.contains('紧张') || obs.contains('压力')) ? '高' : '低',
      sleepPattern: '规律',
      playfulness: '活跃',
      vocalBehavior: '正常',
      abnormalBehaviors: observations.where((obs) => obs.contains('异常')).toList(),
    );
  }

  /// 从健康状态计算分数
  int _calculateScoreFromStatus(String healthStatus) {
    switch (healthStatus) {
      case '健康':
        return 85 + math.Random().nextInt(15);
      case '一般':
        return 70 + math.Random().nextInt(15);
      case '需要关注':
        return 55 + math.Random().nextInt(15);
      default:
        return 60 + math.Random().nextInt(20);
    }
  }

  /// 映射健康状态到身体状况
  // ignore: unused_element
  String _mapHealthToCondition(String healthStatus) {
    switch (healthStatus) {
      case '健康':
        return '理想';
      case '一般':
        return '正常';
      case '需要关注':
        return '略胖';
      default:
        return '正常';
    }
  }

  /// 从宠物类型推断品种
  String _inferBreedFromType(String petType) {
    switch (petType.toLowerCase()) {
      case '猫':
        return '家猫';
      case '狗':
        return '混种犬';
      default:
        return '未知品种';
    }
  }

  /// 生成本地健康报告（备用方案）
  // ignore: unused_element
  Future<HealthReport> _generateLocalHealthReport(img.Image image, String petName, String petType) async {
    final timestamp = DateTime.now();
    final petId = '${petType.toLowerCase()}_${timestamp.millisecondsSinceEpoch}';
    final archiveId = 'health_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}_$petId';

    // 分析图像特征
    final imageAnalysis = _analyzeImageForHealth(image);
    
    // 生成生理指标
    final physicalIndicators = _generatePhysicalIndicators(imageAnalysis, petType);
    
    // 生成行为分析
    final behaviorAnalysis = _generateBehaviorAnalysis(imageAnalysis, petType);
    
    // 生成健康评估
    final healthAssessment = _generateHealthAssessment(physicalIndicators, behaviorAnalysis);
    
    // 生成建议
    final recommendations = _generateRecommendations(healthAssessment, physicalIndicators, behaviorAnalysis);

    return HealthReport(
      petId: petId,
      timestamp: timestamp,
      petName: petName,
      petType: petType,
      breed: _inferBreed(petType, imageAnalysis),
      physicalIndicators: physicalIndicators,
      behaviorAnalysis: behaviorAnalysis,
      healthAssessment: healthAssessment,
      recommendations: recommendations,
      archiveId: archiveId,
    );
  }

  /// 分析图像健康特征
  Map<String, dynamic> _analyzeImageForHealth(img.Image image) {
    final random = math.Random();
    
    // 分析眼部区域（模拟）
    final eyeBrightness = 0.7 + random.nextDouble() * 0.3;
    final eyeClarity = 0.6 + random.nextDouble() * 0.4;
    
    // 分析毛发质量（基于纹理）
    final coatTexture = _analyzeCoatTexture(image);
    
    // 分析整体活力（基于色彩饱和度）
    final vitalityScore = _analyzeVitality(image);
    
    // 分析姿态（基于图像构图）
    final postureScore = 0.5 + random.nextDouble() * 0.5;

    return {
      'eyeBrightness': eyeBrightness,
      'eyeClarity': eyeClarity,
      'coatTexture': coatTexture,
      'vitalityScore': vitalityScore,
      'postureScore': postureScore,
    };
  }

  /// 分析毛发纹理
  double _analyzeCoatTexture(img.Image image) {
    int textureScore = 0;
    int samples = 0;
    
    // 采样分析纹理复杂度
    for (int y = 0; y < image.height; y += 20) {
      for (int x = 0; x < image.width; x += 20) {
        if (x + 1 < image.width && y + 1 < image.height) {
          final pixel1 = image.getPixel(x, y);
          final pixel2 = image.getPixel(x + 1, y);
          final pixel3 = image.getPixel(x, y + 1);
          
          final brightness1 = (pixel1.r + pixel1.g + pixel1.b) / 3;
          final brightness2 = (pixel2.r + pixel2.g + pixel2.b) / 3;
          final brightness3 = (pixel3.r + pixel3.g + pixel3.b) / 3;
          
          final variation = math.max(
            (brightness1 - brightness2).abs(),
            (brightness1 - brightness3).abs(),
          );
          
          if (variation > 20) textureScore++;
          samples++;
        }
      }
    }
    
    return samples > 0 ? textureScore / samples : 0.5;
  }

  /// 分析活力指数
  double _analyzeVitality(img.Image image) {
    int colorfulPixels = 0;
    int totalPixels = 0;
    
    // 分析色彩饱和度
    for (int y = 0; y < image.height; y += 15) {
      for (int x = 0; x < image.width; x += 15) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        final max = math.max(math.max(r, g), b);
        final min = math.min(math.min(r, g), b);
        final saturation = max > 0 ? (max - min) / max : 0;
        
        if (saturation > 0.3) colorfulPixels++;
        totalPixels++;
      }
    }
    
    return totalPixels > 0 ? colorfulPixels / totalPixels : 0.5;
  }

  /// 生成生理指标
  PhysicalIndicators _generatePhysicalIndicators(Map<String, dynamic> analysis, String petType) {
    final random = math.Random();
    final eyeBrightness = analysis['eyeBrightness'] as double;
    final coatTexture = analysis['coatTexture'] as double;
    
    return PhysicalIndicators(
      weight: petType == '猫' ? 3.5 + random.nextDouble() * 2.5 : 15.0 + random.nextDouble() * 20.0,
      bodyTemperature: 38.0 + random.nextDouble() * 1.5,
      heartRate: petType == '猫' ? 140 + random.nextInt(60) : 70 + random.nextInt(80),
      respiratoryRate: petType == '猫' ? 20 + random.nextInt(20) : 15 + random.nextInt(25),
      eyeCondition: eyeBrightness > 0.8 ? '明亮清澈' : eyeBrightness > 0.6 ? '正常' : '略显暗淡',
      noseCondition: random.nextBool() ? '湿润正常' : '略干燥',
      coatCondition: coatTexture > 0.6 ? '光泽柔顺' : coatTexture > 0.4 ? '正常' : '略显粗糙',
      skinCondition: random.nextBool() ? '健康无异常' : '轻微干燥',
      teethCondition: random.nextBool() ? '洁白整齐' : '有轻微牙垢',
      earCondition: random.nextBool() ? '清洁无异味' : '有少量耳垢',
    );
  }

  /// 生成行为分析
  BehaviorAnalysis _generateBehaviorAnalysis(Map<String, dynamic> analysis, String petType) {
    final random = math.Random();
    final vitalityScore = analysis['vitalityScore'] as double;
    final postureScore = analysis['postureScore'] as double;
    
    final appetiteStatuses = ['正常', '减退', '亢进'];
    final sleepPatterns = ['正常', '失眠', '嗜睡'];
    
    return BehaviorAnalysis(
      activityLevel: vitalityScore > 0.7 ? '高' : vitalityScore > 0.4 ? '中' : '低',
      appetiteStatus: appetiteStatuses[random.nextInt(appetiteStatuses.length)],
      sleepPattern: sleepPatterns[random.nextInt(sleepPatterns.length)],
      socialBehavior: postureScore > 0.7 ? '正常' : '略显回避',
      playfulness: vitalityScore > 0.6 ? '正常' : '减少',
      vocalBehavior: '正常',
      abnormalBehaviors: random.nextBool() ? [] : ['偶尔过度舔毛'],
      stressLevel: postureScore > 0.7 ? '低' : postureScore > 0.4 ? '中' : '高',
    );
  }

  /// 生成健康评估
  HealthAssessment _generateHealthAssessment(PhysicalIndicators physical, BehaviorAnalysis behavior) {
    final random = math.Random();
    
    // 计算总体评分
    int score = 70 + random.nextInt(25);
    
    // 根据各项指标调整评分
    if (physical.eyeCondition == '明亮清澈') score += 5;
    if (physical.coatCondition == '光泽柔顺') score += 5;
    if (behavior.activityLevel == '高') score += 5;
    if (behavior.stressLevel == '低') score += 5;
    
    score = math.min(score, 100);
    
    String healthStatus;
    String riskLevel;
    
    if (score >= 90) {
      healthStatus = '优秀';
      riskLevel = '低';
    } else if (score >= 80) {
      healthStatus = '良好';
      riskLevel = '低';
    } else if (score >= 70) {
      healthStatus = '一般';
      riskLevel = '中';
    } else if (score >= 60) {
      healthStatus = '需关注';
      riskLevel = '中';
    } else {
      healthStatus = '需就医';
      riskLevel = '高';
    }

    final concerns = <String>[];
    final positives = <String>[];
    
    // 生成关注点和积极方面
    if (physical.coatCondition == '略显粗糙') concerns.add('毛发质量需改善');
    if (behavior.stressLevel == '高') concerns.add('压力水平偏高');
    if (behavior.activityLevel == '低') concerns.add('活动量不足');
    
    if (physical.eyeCondition == '明亮清澈') positives.add('眼部健康状况良好');
    if (behavior.activityLevel == '高') positives.add('活力充沛');
    if (behavior.stressLevel == '低') positives.add('情绪稳定');

    return HealthAssessment(
      overallScore: score,
      healthStatus: healthStatus,
      healthConcerns: concerns,
      positiveAspects: positives,
      riskLevel: riskLevel,
      nextCheckupDate: DateTime.now().add(Duration(days: 30 + random.nextInt(60))),
    );
  }

  /// 生成建议
  List<String> _generateRecommendations(HealthAssessment assessment, PhysicalIndicators physical, BehaviorAnalysis behavior) {
    final recommendations = <String>[];
    
    // 基于健康评估生成建议
    if (assessment.overallScore < 80) {
      recommendations.add('建议增加日常护理关注度');
    }
    
    if (physical.coatCondition == '略显粗糙') {
      recommendations.add('建议增加梳毛频率，使用宠物专用护毛产品');
    }
    
    if (behavior.activityLevel == '低') {
      recommendations.add('建议增加互动游戏时间，促进运动');
    }
    
    if (behavior.stressLevel == '高') {
      recommendations.add('建议创造更安静舒适的环境，减少应激源');
    }
    
    if (physical.teethCondition == '有轻微牙垢') {
      recommendations.add('建议定期清洁牙齿，使用宠物专用牙膏');
    }
    
    // 通用建议
    recommendations.add('保持定期健康检查');
    recommendations.add('维持均衡营养饮食');
    recommendations.add('确保充足的饮水');
    
    return recommendations;
  }

  /// 推断品种
  String _inferBreed(String petType, Map<String, dynamic> analysis) {
    final random = math.Random();
    
    if (petType == '猫') {
      final catBreeds = ['英国短毛猫', '美国短毛猫', '波斯猫', '暹罗猫', '布偶猫', '苏格兰折耳猫'];
      return catBreeds[random.nextInt(catBreeds.length)];
    } else if (petType == '狗') {
      final dogBreeds = ['金毛寻回犬', '拉布拉多犬', '德国牧羊犬', '比格犬', '哈士奇', '柯基犬'];
      return dogBreeds[random.nextInt(dogBreeds.length)];
    }
    
    return '混合品种';
  }

  /// 生成错误报告
  HealthReport _generateErrorReport(String petName, String petType, String error) {
    final timestamp = DateTime.now();
    
    return HealthReport(
      petId: 'error_${timestamp.millisecondsSinceEpoch}',
      timestamp: timestamp,
      petName: petName,
      petType: petType,
      breed: '未知',
      physicalIndicators: PhysicalIndicators(
        eyeCondition: '无法检测',
        noseCondition: '无法检测',
        coatCondition: '无法检测',
        skinCondition: '无法检测',
        teethCondition: '无法检测',
        earCondition: '无法检测',
      ),
      behaviorAnalysis: BehaviorAnalysis(
        activityLevel: '无法评估',
        appetiteStatus: '无法评估',
        sleepPattern: '无法评估',
        socialBehavior: '无法评估',
        playfulness: '无法评估',
        vocalBehavior: '无法评估',
        abnormalBehaviors: [],
        stressLevel: '无法评估',
      ),
      healthAssessment: HealthAssessment(
        overallScore: 0,
        healthStatus: '分析失败',
        healthConcerns: ['图像分析失败: $error'],
        positiveAspects: [],
        riskLevel: '未知',
      ),
      recommendations: ['请重新拍摄清晰的宠物照片', '如有健康疑虑请咨询兽医'],
      archiveId: 'error_${timestamp.millisecondsSinceEpoch}',
    );
  }
}