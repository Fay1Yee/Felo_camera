import 'dart:convert';
import '../models/ai_result.dart';
import '../models/analysis_history.dart';

class PetActivityParser {
  /// 解析宠物活动数据格式: timestamp category confidence reasons
  /// 示例: 2025-01-20 14:30:00 eating 0.95 {"location": "kitchen", "duration": "5min"}
  static List<AnalysisHistory> parseActivityData(String content) {
    final List<AnalysisHistory> histories = [];
    final lines = content.split('\n');

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      try {
        final history = _parseActivityLine(line);
        if (history != null) {
          histories.add(history);
        }
      } catch (e) {
        print('解析行失败: $line, 错误: $e');
        continue;
      }
    }

    return histories;
  }

  static AnalysisHistory? _parseActivityLine(String line) {
    // 解析格式: timestamp category confidence reasons
    // 支持制表符分隔和空格分隔
    final parts = line.contains('\t') ? line.split('\t') : line.split(' ');
    if (parts.length < 4) return null;

    // 解析时间戳 (第一部分: 完整时间戳)
    final timestampStr = parts[0];

    DateTime? timestamp;
    try {
      timestamp = DateTime.parse(timestampStr.replaceAll(' ', 'T'));
    } catch (e) {
      print('时间戳解析失败: $timestampStr');
      return null;
    }

    // 解析类别
    final category = parts[1];

    // 解析置信度
    double confidence;
    try {
      confidence = double.parse(parts[2]);
    } catch (e) {
      print('置信度解析失败: ${parts[2]}');
      return null;
    }

    // 解析原因 (第四部分是JSON)
    String reasonsStr = '';
    if (parts.length > 3) {
      reasonsStr = parts[3];
    }

    Map<String, dynamic>? reasonsJson;
    try {
      if (reasonsStr.isNotEmpty && reasonsStr.startsWith('{')) {
        reasonsJson = jsonDecode(reasonsStr);
      }
    } catch (e) {
      print('JSON解析失败: $reasonsStr');
    }

    // 生成活动标题和描述
    final activityInfo = _generateActivityInfo(
      category,
      confidence,
      reasonsJson,
    );

    // 创建AIResult
    final aiResult = AIResult(
      title: activityInfo['title']!,
      subInfo: activityInfo['description'],
      confidence: (confidence * 100).toInt(), // 转换为0-100的整数
    );

    // 创建AnalysisHistory
    return AnalysisHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + category,
      result: aiResult,
      timestamp: timestamp,
      imagePath: null, // 宠物活动数据通常没有图片
      mode: 'pet_activity', // 添加必需的mode参数
    );
  }

  static Map<String, dynamic> _generateActivityInfo(
    String category,
    double confidence,
    Map<String, dynamic>? reasons,
  ) {
    String title;
    String? description;
    List<String> tags = [category];

    // 根据类别生成标题和描述 - 与timestampcategoryconfidencereasons2025.docx文档标准一致
    switch (category.toLowerCase()) {
      case 'observe':
        title = '观望行为';
        description = '宠物保持警觉，注视某个方向';
        tags.addAll(['观望', '警觉']);
        break;
      case 'explore':
        title = '探索行为';
        description = '宠物主动移动、嗅探、巡视环境';
        tags.addAll(['探索', '巡视']);
        break;
      case 'occupy':
        title = '领地行为';
        description = '宠物长时间占据某个位置，表现领地行为';
        tags.addAll(['领地', '占据']);
        break;
      case 'play':
        title = '玩耍行为';
        description = '宠物进行游戏、嬉戏活动';
        tags.addAll(['玩耍', '游戏']);
        break;
      case 'attack':
        title = '攻击行为';
        description = '宠物表现出攻击性行为';
        tags.addAll(['攻击', '攻击性']);
        break;
      case 'neutral':
        title = '中性行为';
        description = '宠物处于静止或无明显行为状态';
        tags.addAll(['中性', '静止']);
        break;
      case 'no_pet':
        title = '无宠物活动';
        description = '监控区域内未检测到宠物';
        tags.addAll(['无宠物', '未检测']);
        break;
      default:
        title = '${category}行为';
        description = '宠物正在进行${category}行为';
        tags.add('其他行为');
    }

    // 添加置信度信息
    if (confidence >= 0.9) {
      tags.add('高置信度');
    } else if (confidence >= 0.7) {
      tags.add('中等置信度');
    } else {
      tags.add('低置信度');
    }

    // 从reasons中提取额外信息
    if (reasons != null) {
      if (reasons.containsKey('location')) {
        description = '$description，位置：${reasons['location']}';
        tags.add('位置:${reasons['location']}');
      }
      if (reasons.containsKey('duration')) {
        description = '$description，持续时间：${reasons['duration']}';
        tags.add('时长:${reasons['duration']}');
      }
      if (reasons.containsKey('intensity')) {
        description = '$description，强度：${reasons['intensity']}';
        tags.add('强度:${reasons['intensity']}');
      }
    }

    return {'title': title, 'description': description, 'tags': tags};
  }
}