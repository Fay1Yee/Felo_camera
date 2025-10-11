import 'dart:math';
import 'dart:ui' as ui;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';

// 模拟场景类型
enum SimulatedScene {
  petSleeping,
  petEating,
  petPlaying,
  petLookingOut,
  empty,
  petHiding,
  petRestless
}

/// 出行箱模拟器 - 生成模拟的出行箱摄像头画面
class TravelBoxSimulator {
  static final TravelBoxSimulator _instance = TravelBoxSimulator._internal();
  factory TravelBoxSimulator() => _instance;
  TravelBoxSimulator._internal();

  static TravelBoxSimulator get instance => _instance;

  final Random _random = Random();

  // 当前模拟场景
  SimulatedScene _currentScene = SimulatedScene.petSleeping;
  DateTime _lastSceneChange = DateTime.now();
  
  /// 获取当前模拟场景描述
  String getCurrentSceneDescription() {
    switch (_currentScene) {
      case SimulatedScene.petSleeping:
        return '宠物正在安静地睡觉';
      case SimulatedScene.petEating:
        return '宠物正在进食';
      case SimulatedScene.petPlaying:
        return '宠物正在玩耍';
      case SimulatedScene.petLookingOut:
        return '宠物正在观察外面';
      case SimulatedScene.empty:
        return '出行箱内空无一物';
      case SimulatedScene.petHiding:
        return '宠物躲在角落里';
      case SimulatedScene.petRestless:
        return '宠物显得有些不安';
    }
  }

  /// 获取场景相关的环境数据
  Map<String, dynamic> getEnvironmentData() {
    return {
      'temperature': 20 + _random.nextDouble() * 10, // 20-30°C
      'humidity': 40 + _random.nextDouble() * 20, // 40-60%
      'lightLevel': _getLightLevel(),
      'noiseLevel': _getNoiseLevel(),
      'vibration': _getVibrationLevel(),
      'airQuality': 'good',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  double _getLightLevel() {
    switch (_currentScene) {
      case SimulatedScene.petSleeping:
        return 10 + _random.nextDouble() * 20; // 较暗
      case SimulatedScene.petEating:
      case SimulatedScene.petPlaying:
        return 50 + _random.nextDouble() * 30; // 中等亮度
      case SimulatedScene.petLookingOut:
        return 70 + _random.nextDouble() * 30; // 较亮
      default:
        return 30 + _random.nextDouble() * 40;
    }
  }

  double _getNoiseLevel() {
    switch (_currentScene) {
      case SimulatedScene.petSleeping:
      case SimulatedScene.empty:
        return _random.nextDouble() * 20; // 很安静
      case SimulatedScene.petEating:
        return 20 + _random.nextDouble() * 30; // 中等
      case SimulatedScene.petPlaying:
      case SimulatedScene.petRestless:
        return 40 + _random.nextDouble() * 40; // 较吵
      default:
        return 15 + _random.nextDouble() * 25;
    }
  }

  double _getVibrationLevel() {
    switch (_currentScene) {
      case SimulatedScene.petSleeping:
      case SimulatedScene.empty:
        return _random.nextDouble() * 5; // 很稳定
      case SimulatedScene.petPlaying:
      case SimulatedScene.petRestless:
        return 10 + _random.nextDouble() * 20; // 有震动
      default:
        return 2 + _random.nextDouble() * 8;
    }
  }

  /// 更新模拟场景（定期调用）
  void updateScene() {
    final now = DateTime.now();
    final timeSinceLastChange = now.difference(_lastSceneChange).inMinutes;
    
    // 每5-15分钟随机切换场景
    if (timeSinceLastChange > 5 + _random.nextInt(10)) {
      _changeScene();
      _lastSceneChange = now;
    }
  }

  void _changeScene() {
    final scenes = SimulatedScene.values;
    SimulatedScene newScene;
    
    do {
      newScene = scenes[_random.nextInt(scenes.length)];
    } while (newScene == _currentScene);
    
    _currentScene = newScene;
  }

  /// 生成模拟的摄像头画面数据
  Future<Uint8List> generateSimulatedFrame() async {
    // 创建一个简单的模拟画面
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(640, 480);
    
    // 背景
    final backgroundPaint = Paint()..color = _getBackgroundColor();
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    // 绘制模拟内容
    _drawSimulatedContent(canvas, size);
    
    // 添加时间戳
    _drawTimestamp(canvas, size);
    
    // 添加环境信息
    _drawEnvironmentInfo(canvas, size);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  Color _getBackgroundColor() {
    switch (_currentScene) {
      case SimulatedScene.petSleeping:
        return const Color(0xFF2D2D2D); // 深灰色
      case SimulatedScene.petEating:
        return const Color(0xFF3D3D3D); // 中灰色
      case SimulatedScene.petPlaying:
        return const Color(0xFF4D4D4D); // 浅灰色
      case SimulatedScene.empty:
        return const Color(0xFF1D1D1D); // 很深的灰色
      default:
        return const Color(0xFF3D3D3D);
    }
  }

  void _drawSimulatedContent(Canvas canvas, Size size) {
    final paint = Paint();
    
    switch (_currentScene) {
      case SimulatedScene.petSleeping:
        // 绘制睡觉的宠物轮廓
        paint.color = const Color(0xFF8B4513);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.6, size.height * 0.7),
            width: 120,
            height: 80,
          ),
          paint,
        );
        break;
        
      case SimulatedScene.petEating:
        // 绘制进食的宠物和食盆
        paint.color = const Color(0xFF8B4513);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.6),
            width: 100,
            height: 90,
          ),
          paint,
        );
        // 食盆
        paint.color = const Color(0xFF666666);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.3, size.height * 0.8),
            width: 60,
            height: 20,
          ),
          paint,
        );
        break;
        
      case SimulatedScene.petPlaying:
        // 绘制玩耍的宠物和玩具
        paint.color = const Color(0xFF8B4513);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.4, size.height * 0.5),
            width: 90,
            height: 100,
          ),
          paint,
        );
        // 玩具球
        paint.color = const Color(0xFFFF6B6B);
        canvas.drawCircle(
          Offset(size.width * 0.7, size.height * 0.7),
          25,
          paint,
        );
        break;
        
      case SimulatedScene.petLookingOut:
        // 绘制观察的宠物
        paint.color = const Color(0xFF8B4513);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.2, size.height * 0.4),
            width: 80,
            height: 120,
          ),
          paint,
        );
        break;
        
      case SimulatedScene.empty:
        // 空的出行箱，只有一些阴影
        paint.color = const Color(0xFF111111);
        canvas.drawRect(
          Rect.fromLTWH(size.width * 0.1, size.height * 0.8, size.width * 0.8, 20),
          paint,
        );
        break;
        
      case SimulatedScene.petHiding:
        // 躲在角落的宠物
        paint.color = const Color(0xFF654321);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.15, size.height * 0.85),
            width: 70,
            height: 50,
          ),
          paint,
        );
        break;
        
      case SimulatedScene.petRestless:
        // 不安的宠物，多个位置的模糊轮廓
        paint.color = const Color(0xFF8B4513).withValues(alpha: 0.7);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.3, size.height * 0.5),
            width: 85,
            height: 95,
          ),
          paint,
        );
        paint.color = const Color(0xFF8B4513).withValues(alpha: 0.5);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.6, size.height * 0.6),
            width: 80,
            height: 90,
          ),
          paint,
        );
        break;
    }
  }

  void _drawTimestamp(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: DateTime.now().toString().substring(0, 19),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, size.height - 25));
  }

  void _drawEnvironmentInfo(Canvas canvas, Size size) {
    final env = getEnvironmentData();
    final info = '${env['temperature'].toStringAsFixed(1)}°C | ${env['humidity'].toStringAsFixed(0)}% | 光照:${env['lightLevel'].toStringAsFixed(0)}';
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: info,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 10));
  }

  /// 获取模拟的分析结果
  Map<String, dynamic> getSimulatedAnalysis() {
    final env = getEnvironmentData();
    
    return {
      'scene': _currentScene.toString().split('.').last,
      'description': getCurrentSceneDescription(),
      'environment': env,
      'petStatus': _getPetStatus(),
      'recommendations': _getRecommendations(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _getPetStatus() {
    switch (_currentScene) {
      case SimulatedScene.petSleeping:
        return {
          'activity': 'resting',
          'stress_level': 'low',
          'comfort': 'high',
          'health_indicators': ['stable_breathing', 'relaxed_posture']
        };
      case SimulatedScene.petEating:
        return {
          'activity': 'feeding',
          'stress_level': 'low',
          'comfort': 'medium',
          'health_indicators': ['good_appetite', 'normal_eating_behavior']
        };
      case SimulatedScene.petPlaying:
        return {
          'activity': 'playing',
          'stress_level': 'low',
          'comfort': 'high',
          'health_indicators': ['active', 'playful', 'energetic']
        };
      case SimulatedScene.petRestless:
        return {
          'activity': 'restless',
          'stress_level': 'high',
          'comfort': 'low',
          'health_indicators': ['anxious', 'unsettled']
        };
      default:
        return {
          'activity': 'calm',
          'stress_level': 'medium',
          'comfort': 'medium',
          'health_indicators': ['stable']
        };
    }
  }

  List<String> _getRecommendations() {
    switch (_currentScene) {
      case SimulatedScene.petRestless:
        return ['检查出行箱温度', '提供安抚玩具', '考虑短暂休息'];
      case SimulatedScene.empty:
        return ['确认宠物安全', '检查出行箱门锁'];
      case SimulatedScene.petHiding:
        return ['给予宠物更多时间适应', '保持环境安静'];
      default:
        return ['继续监控', '保持当前环境'];
    }
  }

  /// 使用豆包API分析真实图像的旅行场景
  Future<Map<String, dynamic>> analyzeTravelSceneWithApi(File imageFile) async {
    try {
      final ai = await ApiClient.instance.analyzeImage(imageFile, mode: 'travel');
      Map<String, dynamic>? analysis;
      if (ai.subInfo != null) {
        try {
          analysis = jsonDecode(ai.subInfo!);
        } catch (_) {
          final extracted = _extractJson(ai.subInfo!);
          if (extracted != null) {
            try { analysis = jsonDecode(extracted); } catch (_) {}
          }
        }
      }

      if (analysis != null) {
        // 转换API结果为应用格式
        return _convertApiResultToAppFormat(analysis);
      }

      throw StateError('豆包响应缺少结构化JSON');
    } catch (e) {
      debugPrint('⚠️ 出行场景分析失败: $e');
      return {
        'error': true,
        'message': e.toString(),
      };
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

  /// 转换API结果为应用格式
  Map<String, dynamic> _convertApiResultToAppFormat(Map<String, dynamic> apiResult) {
    final sceneType = apiResult['sceneType'] ?? '未知场景';
    final location = apiResult['location'] ?? '未知位置';
    final weather = apiResult['weather'] ?? '未知天气';
    final activities = List<String>.from(apiResult['activities'] ?? []);
    final safetyTips = List<String>.from(apiResult['safetyTips'] ?? []);

    return {
      'scene_analysis': {
        'type': sceneType,
        'location': location,
        'weather': weather,
        'safety_level': _assessSafetyLevel(safetyTips),
      },
      'recommendations': {
        'activities': activities,
        'safety_tips': safetyTips,
        'travel_advice': _generateTravelAdvice(sceneType, weather),
      },
      'metadata': {
        'analysis_source': 'doubao_api',
        'timestamp': DateTime.now().toIso8601String(),
        'api_response': apiResult,
      }
    };
  }

  /// 评估安全等级
  String _assessSafetyLevel(List<String> safetyTips) {
    if (safetyTips.isEmpty) return '安全';
    if (safetyTips.length <= 2) return '需注意';
    return '需谨慎';
  }

  /// 生成旅行建议
  List<String> _generateTravelAdvice(String sceneType, String weather) {
    List<String> advice = [];
    
    // 基于场景类型的建议
    if (sceneType.contains('室外')) {
      advice.add('确保宠物有足够的水和遮阴');
    }
    if (sceneType.contains('室内')) {
      advice.add('保持室内通风良好');
    }
    
    // 基于天气的建议
    if (weather.contains('热') || weather.contains('晴')) {
      advice.add('避免在高温时段外出');
    }
    if (weather.contains('雨') || weather.contains('湿')) {
      advice.add('准备防雨用品');
    }
    if (weather.contains('冷') || weather.contains('寒')) {
      advice.add('注意保暖措施');
    }
    
    return advice.isEmpty ? ['保持正常护理'] : advice;
  }

  /// 获取场景推荐（回退方法）
  // ignore: unused_element
  Map<String, dynamic> _getRecommendationsForScene() {
    return {
      'scene_analysis': {
        'type': '模拟场景',
        'location': '未知',
        'weather': '未知',
        'safety_level': '安全',
      },
      'recommendations': {
        'activities': ['继续监控宠物状态'],
        'safety_tips': ['保持出行箱通风', '定期检查宠物状态'],
        'travel_advice': ['保持正常护理'],
      },
      'metadata': {
        'analysis_source': 'simulator_fallback',
        'timestamp': DateTime.now().toIso8601String(),
      }
    };
  }
}