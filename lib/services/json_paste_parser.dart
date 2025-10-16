import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/ai_result.dart';
import 'json_format_fixer.dart';

/// JSON粘贴解析结果
class JsonPasteParseResult {
  final List<JsonPasteRecord> records;
  final List<String> errors;
  final int totalLines;
  final int successCount;
  final int errorCount;

  JsonPasteParseResult({
    required this.records,
    required this.errors,
    required this.totalLines,
    required this.successCount,
    required this.errorCount,
  });
}

/// JSON粘贴记录数据模型
class JsonPasteRecord {
  final DateTime timestamp;
  final String category;
  final double confidence;
  final Map<String, dynamic> reasons;
  final List<String> tags;
  final String originalLine;

  JsonPasteRecord({
    required this.timestamp,
    required this.category,
    required this.confidence,
    required this.reasons,
    this.tags = const [],
    required this.originalLine,
  });

  /// 转换为AIResult
  AIResult toAIResult() {
    final reasonsText = reasons['reasons']?.toString() ?? '';
    final categoryDetail = reasons['category']?.toString() ?? category;
    
    return AIResult(
      title: categoryDetail.isNotEmpty ? categoryDetail : category,
      confidence: (confidence * 100).round(),
      subInfo: reasonsText.isNotEmpty ? reasonsText : null,
    );
  }
}

/// JSON粘贴格式解析器
class JsonPasteParser {
  static const String _timestampFormat = 'yyyy-MM-dd HH:mm:ss';
  static final DateFormat _dateFormatter = DateFormat(_timestampFormat);

  /// 解析JSON粘贴文本
  static JsonPasteParseResult parseJsonText(String content) {
    final lines = content.split('\n');
    final records = <JsonPasteRecord>[];
    final errors = <String>[];
    int lineNumber = 0;

    for (String line in lines) {
      lineNumber++;
      line = line.trim();
      
      // 跳过空行和标题行
      if (line.isEmpty || line.startsWith('timestamp\t')) {
        continue;
      }

      try {
        final record = _parseLine(line, lineNumber);
        if (record != null) {
          records.add(record);
        }
      } catch (e) {
        errors.add('第 $lineNumber 行: $e');
      }
    }

    return JsonPasteParseResult(
      records: records,
      errors: errors,
      totalLines: lineNumber,
      successCount: records.length,
      errorCount: errors.length,
    );
  }

  /// 解析JSON粘贴内容（带一键修正功能）
  static JsonPasteParseResult parseJsonPaste(String jsonText, {bool autoFix = true}) {
    try {
      String cleanedJson = jsonText.trim();
      List<String> fixedIssues = [];
      
      // 如果启用自动修正，先尝试修正JSON格式
      if (autoFix) {
        final fixResult = JsonFormatFixer.autoFixJson(cleanedJson);
        cleanedJson = fixResult.fixedJson;
        fixedIssues = fixResult.fixedIssues;
        
        // 如果修正后仍有错误，记录但继续尝试解析
        if (!fixResult.isValid && fixResult.remainingErrors.isNotEmpty) {
          print('JSON修正后仍有错误: ${fixResult.remainingErrors.join(', ')}');
        }
      } else {
        // 原有的简单预处理逻辑
        if (cleanedJson.startsWith('```json')) {
          cleanedJson = cleanedJson.substring(7);
        }
        if (cleanedJson.startsWith('```')) {
          cleanedJson = cleanedJson.substring(3);
        }
        if (cleanedJson.endsWith('```')) {
          cleanedJson = cleanedJson.substring(0, cleanedJson.length - 3);
        }
        cleanedJson = cleanedJson.trim();
      }
      
      // 尝试解析JSON格式数据
      try {
        final jsonData = jsonDecode(cleanedJson);
        return _parseJsonData(jsonData, fixedIssues);
      } catch (e) {
        // 如果JSON解析失败，尝试作为制表符分隔的文本处理
        return parseJsonText(cleanedJson);
      }
    } catch (e) {
      return JsonPasteParseResult(
        records: [],
        errors: ['JSON解析失败: $e'],
        totalLines: 0,
        successCount: 0,
        errorCount: 1,
      );
    }
  }

  /// 解析JSON数据对象
  static JsonPasteParseResult _parseJsonData(dynamic jsonData, List<String> fixedIssues) {
    final records = <JsonPasteRecord>[];
    final errors = <String>[];
    
    try {
      if (jsonData is List) {
        // 处理JSON数组
        for (int i = 0; i < jsonData.length; i++) {
          try {
            final record = _parseJsonRecord(jsonData[i], i + 1);
            if (record != null) {
              records.add(record);
            }
          } catch (e) {
            errors.add('记录 ${i + 1}: $e');
          }
        }
      } else if (jsonData is Map<String, dynamic>) {
        // 处理单个JSON对象
        try {
          final record = _parseJsonRecord(jsonData, 1);
          if (record != null) {
            records.add(record);
          }
        } catch (e) {
          errors.add('记录解析错误: $e');
        }
      } else {
        errors.add('不支持的JSON格式：应为对象或数组');
      }
      
      // 如果有修正信息，添加到错误列表中作为提示
      if (fixedIssues.isNotEmpty) {
        errors.insert(0, '已自动修正: ${fixedIssues.join(', ')}');
      }
      
      return JsonPasteParseResult(
        records: records,
        errors: errors,
        totalLines: jsonData is List ? jsonData.length : 1,
        successCount: records.length,
        errorCount: errors.length - (fixedIssues.isNotEmpty ? 1 : 0),
      );
    } catch (e) {
      return JsonPasteParseResult(
        records: [],
        errors: ['JSON数据解析失败: $e'],
        totalLines: 0,
        successCount: 0,
        errorCount: 1,
      );
    }
  }

  /// 解析单个JSON记录
  static JsonPasteRecord? _parseJsonRecord(Map<String, dynamic> data, int recordNumber) {
    // 解析时间戳
    final timestampStr = data['timestamp']?.toString() ?? data['time']?.toString();
    if (timestampStr == null || timestampStr.isEmpty) {
      throw Exception('缺少时间戳字段 (timestamp 或 time)');
    }
    final timestamp = _parseTimestamp(timestampStr);

    // 解析分类
    final category = data['category']?.toString() ?? data['type']?.toString() ?? '';
    if (category.isEmpty) {
      throw Exception('缺少分类字段 (category 或 type)');
    }

    // 解析置信度
    final confidenceValue = data['confidence'];
    double confidence;
    if (confidenceValue is num) {
      confidence = confidenceValue.toDouble();
    } else if (confidenceValue is String) {
      confidence = _parseConfidence(confidenceValue);
    } else {
      throw Exception('缺少或无效的置信度字段 (confidence)');
    }

    // 解析reasons
    final reasonsData = data['reasons'] ?? data['reason'] ?? data['details'] ?? {};
    Map<String, dynamic> reasons;
    if (reasonsData is Map<String, dynamic>) {
      reasons = reasonsData;
    } else if (reasonsData is String) {
      try {
        reasons = jsonDecode(reasonsData);
      } catch (e) {
        reasons = {'reasons': reasonsData};
      }
    } else {
      reasons = {'reasons': reasonsData.toString()};
    }

    // 生成活动标签
    final tags = _generatePetActivityTags(category, reasons, confidence);

    return JsonPasteRecord(
      timestamp: timestamp,
      category: category,
      confidence: confidence,
      reasons: reasons,
      tags: tags,
      originalLine: jsonEncode(data),
    );
  }

  /// 解析单行记录
  static JsonPasteRecord? _parseLine(String line, int lineNumber) {
    final parts = line.split('\t');
    
    if (parts.length < 4) {
      throw Exception('格式错误：应包含4个制表符分隔的字段 (timestamp\\tcategory\\tconfidence\\treasons)');
    }

    // 解析时间戳
    final timestampStr = parts[0].trim();
    final timestamp = _parseTimestamp(timestampStr);

    // 解析分类
    final category = parts[1].trim();
    if (category.isEmpty) {
      throw Exception('分类字段不能为空');
    }

    // 解析置信度
    final confidenceStr = parts[2].trim();
    final confidence = _parseConfidence(confidenceStr);

    // 解析reasons JSON
    final reasonsStr = parts[3].trim();
    final reasons = _parseReasons(reasonsStr);

    // 生成活动标签（基于宠物活动类型）
    final tags = _generatePetActivityTags(category, reasons, confidence);

    return JsonPasteRecord(
      timestamp: timestamp,
      category: category,
      confidence: confidence,
      reasons: reasons,
      tags: tags,
      originalLine: line,
    );
  }

  /// 解析时间戳
  static DateTime _parseTimestamp(String timestampStr) {
    try {
      return _dateFormatter.parse(timestampStr);
    } catch (e) {
      throw Exception('时间戳格式错误：应为 $_timestampFormat 格式，实际为 "$timestampStr"');
    }
  }

  /// 解析置信度
  static double _parseConfidence(String confidenceStr) {
    try {
      final confidence = double.parse(confidenceStr);
      if (confidence < 0.0 || confidence > 1.0) {
        throw Exception('置信度值超出范围：应在 0.0-1.0 之间，实际为 $confidence');
      }
      return confidence;
    } catch (e) {
      if (e is FormatException) {
        throw Exception('置信度格式错误：应为浮点数，实际为 "$confidenceStr"');
      }
      rethrow;
    }
  }

  /// 解析reasons JSON
  static Map<String, dynamic> _parseReasons(String reasonsStr) {
    String jsonStr = reasonsStr;
    
    // 处理```json包装的情况
    if (reasonsStr.startsWith('```json') && reasonsStr.endsWith('```')) {
      jsonStr = reasonsStr.substring(7, reasonsStr.length - 3).trim();
    }

    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('reasons字段必须是JSON对象格式');
      }

      final reasons = decoded;
      
      // 验证必需字段
      _validateReasonsFields(reasons);
      
      return reasons;
    } catch (e) {
      if (e is FormatException) {
        throw Exception('reasons字段JSON格式错误：$e');
      }
      rethrow;
    }
  }

  /// 验证reasons字段
  static void _validateReasonsFields(Map<String, dynamic> reasons) {
    // 验证category字段
    if (!reasons.containsKey('category')) {
      throw Exception('reasons JSON缺少必需字段：category');
    }
    if (reasons['category'] is! String || (reasons['category'] as String).isEmpty) {
      throw Exception('reasons.category必须是非空字符串');
    }

    // 验证confidence字段
    if (!reasons.containsKey('confidence')) {
      throw Exception('reasons JSON缺少必需字段：confidence');
    }
    final confidence = reasons['confidence'];
    if (confidence is! num) {
      throw Exception('reasons.confidence必须是数字');
    }
    if (confidence < 0.0 || confidence > 1.0) {
      throw Exception('reasons.confidence值超出范围：应在 0.0-1.0 之间');
    }

    // 验证reasons字段
    if (!reasons.containsKey('reasons')) {
      throw Exception('reasons JSON缺少必需字段：reasons');
    }
    if (reasons['reasons'] is! String || (reasons['reasons'] as String).isEmpty) {
      throw Exception('reasons.reasons必须是非空字符串');
    }
  }

  /// 生成宠物活动标签（基于宠物活动类型的自动标签生成）
  static List<String> _generatePetActivityTags(String category, Map<String, dynamic> reasons, double confidence) {
    final tags = <String>[];
    
    // 基于分类生成宠物活动标签
    final categoryLower = category.toLowerCase();
    
    // 宠物状态标签
    if (categoryLower.contains('no_pet') || categoryLower.contains('无宠物')) {
      tags.add('无宠物');
    } else if (categoryLower.contains('pet') || categoryLower.contains('宠物')) {
      tags.add('宠物存在');
    }
    
    // 宠物活动类型标签
    if (categoryLower.contains('eat') || categoryLower.contains('食') || categoryLower.contains('进食')) {
      tags.add('进食活动');
    }
    if (categoryLower.contains('sleep') || categoryLower.contains('睡') || categoryLower.contains('休息')) {
      tags.add('睡眠休息');
    }
    if (categoryLower.contains('play') || categoryLower.contains('玩') || categoryLower.contains('游戏')) {
      tags.add('玩耍游戏');
    }
    if (categoryLower.contains('drink') || categoryLower.contains('水') || categoryLower.contains('饮水')) {
      tags.add('饮水活动');
    }
    if (categoryLower.contains('exercise') || categoryLower.contains('运动') || categoryLower.contains('锻炼')) {
      tags.add('运动锻炼');
    }
    if (categoryLower.contains('walk') || categoryLower.contains('散步') || categoryLower.contains('遛')) {
      tags.add('散步遛弯');
    }
    if (categoryLower.contains('groom') || categoryLower.contains('梳理') || categoryLower.contains('清洁')) {
      tags.add('清洁梳理');
    }
    if (categoryLower.contains('toilet') || categoryLower.contains('厕所') || categoryLower.contains('排便')) {
      tags.add('排便如厕');
    }

    // 基于置信度生成标签
    if (confidence >= 0.9) {
      tags.add('高置信度');
    } else if (confidence >= 0.7) {
      tags.add('中置信度');
    } else if (confidence >= 0.5) {
      tags.add('中低置信度');
    } else {
      tags.add('低置信度');
    }

    // 基于详细分类生成标签
    final categoryDetail = reasons['category']?.toString().toLowerCase() ?? '';
    if (categoryDetail.contains('normal') || categoryDetail.contains('正常')) {
      tags.add('正常行为');
    } else if (categoryDetail.contains('abnormal') || categoryDetail.contains('异常')) {
      tags.add('异常行为');
    }
    if (categoryDetail.contains('health') || categoryDetail.contains('健康')) {
      tags.add('健康相关');
    }
    if (categoryDetail.contains('behavior') || categoryDetail.contains('行为')) {
      tags.add('行为分析');
    }
    if (categoryDetail.contains('activity') || categoryDetail.contains('活动')) {
      tags.add('活动监测');
    }

    // 基于原因文本生成更多宠物相关标签
    final reasonsText = reasons['reasons']?.toString().toLowerCase() ?? '';
    
    // 宠物类型标签
    if (reasonsText.contains('cat') || reasonsText.contains('猫')) {
      tags.add('猫咪');
    }
    if (reasonsText.contains('dog') || reasonsText.contains('狗')) {
      tags.add('狗狗');
    }
    
    // 环境和物品标签
    if (reasonsText.contains('food') || reasonsText.contains('食物') || reasonsText.contains('食盆')) {
      tags.add('食物相关');
    }
    if (reasonsText.contains('water') || reasonsText.contains('水') || reasonsText.contains('水盆')) {
      tags.add('饮水相关');
    }
    if (reasonsText.contains('toy') || reasonsText.contains('玩具') || reasonsText.contains('球')) {
      tags.add('玩具互动');
    }
    if (reasonsText.contains('bed') || reasonsText.contains('窝') || reasonsText.contains('垫子')) {
      tags.add('休息区域');
    }
    if (reasonsText.contains('door') || reasonsText.contains('门') || reasonsText.contains('外出')) {
      tags.add('出入活动');
    }
    if (reasonsText.contains('litter') || reasonsText.contains('猫砂') || reasonsText.contains('厕所')) {
      tags.add('如厕区域');
    }
    
    // 行为状态标签
    if (reasonsText.contains('alert') || reasonsText.contains('警觉') || reasonsText.contains('警告')) {
      tags.add('警觉状态');
    }
    if (reasonsText.contains('calm') || reasonsText.contains('平静') || reasonsText.contains('安静')) {
      tags.add('平静状态');
    }
    if (reasonsText.contains('active') || reasonsText.contains('活跃') || reasonsText.contains('兴奋')) {
      tags.add('活跃状态');
    }
    if (reasonsText.contains('lazy') || reasonsText.contains('懒散') || reasonsText.contains('慵懒')) {
      tags.add('慵懒状态');
    }
    
    // 时间相关标签
    if (reasonsText.contains('morning') || reasonsText.contains('早上') || reasonsText.contains('上午')) {
      tags.add('上午时段');
    }
    if (reasonsText.contains('afternoon') || reasonsText.contains('下午')) {
      tags.add('下午时段');
    }
    if (reasonsText.contains('evening') || reasonsText.contains('晚上') || reasonsText.contains('夜晚')) {
      tags.add('晚上时段');
    }
    if (reasonsText.contains('night') || reasonsText.contains('深夜') || reasonsText.contains('夜间')) {
      tags.add('夜间时段');
    }

    // 健康相关标签
    if (reasonsText.contains('sick') || reasonsText.contains('病') || reasonsText.contains('不适')) {
      tags.add('健康异常');
    }
    if (reasonsText.contains('healthy') || reasonsText.contains('健康') || reasonsText.contains('良好')) {
      tags.add('健康良好');
    }
    
    // 情绪相关标签
    if (reasonsText.contains('happy') || reasonsText.contains('开心') || reasonsText.contains('愉快')) {
      tags.add('愉快情绪');
    }
    if (reasonsText.contains('sad') || reasonsText.contains('伤心') || reasonsText.contains('沮丧')) {
      tags.add('低落情绪');
    }
    if (reasonsText.contains('stress') || reasonsText.contains('压力') || reasonsText.contains('紧张')) {
      tags.add('紧张压力');
    }

    return tags.toSet().toList(); // 去重
  }

  /// 验证JSON粘贴记录格式
  static List<String> validateFormat(String content) {
    final errors = <String>[];
    final lines = content.split('\n');
    int lineNumber = 0;

    for (String line in lines) {
      lineNumber++;
      line = line.trim();
      
      if (line.isEmpty || line.startsWith('timestamp\t')) {
        continue;
      }

      try {
        _parseLine(line, lineNumber);
      } catch (e) {
        errors.add('第 $lineNumber 行: $e');
      }
    }

    return errors;
  }

  /// 生成格式示例
  static String generateFormatExample() {
    final now = DateTime.now();
    final timestamp1 = _dateFormatter.format(now.subtract(const Duration(hours: 2)));
    final timestamp2 = _dateFormatter.format(now.subtract(const Duration(hours: 1)));
    
    return '''timestamp\tcategory\tconfidence\treasons
$timestamp1\tno_pet\t0.5\t```json
{
  "category": "无宠物",
  "confidence": 1.0,
  "reasons": "在提供的图像中未检测到猫的存在，画面主要展示了一只狗和室内环境。"
}
```
$timestamp2\tpet\t0.95\t```json
{
  "category": "宠物进食行为",
  "confidence": 0.95,
  "reasons": "检测到宠物在食盆附近的正常进食行为，动作自然流畅"
}
```''';
  }
}