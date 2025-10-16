import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/ai_result.dart';

/// 时间轴记录解析结果
class TimelineParseResult {
  final List<TimelineRecord> records;
  final List<String> errors;
  final int totalLines;
  final int successCount;
  final int errorCount;

  TimelineParseResult({
    required this.records,
    required this.errors,
    required this.totalLines,
    required this.successCount,
    required this.errorCount,
  });
}

/// 时间轴记录数据模型
class TimelineRecord {
  final DateTime timestamp;
  final String category;
  final double confidence;
  final Map<String, dynamic> reasons;
  final List<String> tags;
  final String originalLine;

  TimelineRecord({
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

/// JSON格式时间轴记录解析器
class TimelineRecordParser {
  static const String _timestampFormat = 'yyyy-MM-dd HH:mm:ss';
  static final DateFormat _dateFormatter = DateFormat(_timestampFormat);

  /// 解析时间轴记录文本
  static TimelineParseResult parseTimelineText(String content) {
    final lines = content.split('\n');
    final records = <TimelineRecord>[];
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

    return TimelineParseResult(
      records: records,
      errors: errors,
      totalLines: lineNumber,
      successCount: records.length,
      errorCount: errors.length,
    );
  }

  /// 解析单行记录
  static TimelineRecord? _parseLine(String line, int lineNumber) {
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

    // 生成活动标签
    final tags = _generateActivityTags(category, reasons, confidence);

    return TimelineRecord(
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

  /// 生成活动标签
  static List<String> _generateActivityTags(String category, Map<String, dynamic> reasons, double confidence) {
    final tags = <String>[];
    
    // 基于分类生成标签
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('eat') || categoryLower.contains('食')) {
      tags.add('进食');
    }
    if (categoryLower.contains('sleep') || categoryLower.contains('睡')) {
      tags.add('睡眠');
    }
    if (categoryLower.contains('play') || categoryLower.contains('玩')) {
      tags.add('玩耍');
    }
    if (categoryLower.contains('drink') || categoryLower.contains('水')) {
      tags.add('饮水');
    }
    if (categoryLower.contains('exercise') || categoryLower.contains('运动')) {
      tags.add('运动');
    }
    if (categoryLower.contains('walk') || categoryLower.contains('散步')) {
      tags.add('散步');
    }
    if (categoryLower.contains('rest') || categoryLower.contains('休息')) {
      tags.add('休息');
    }

    // 基于置信度生成标签
    if (confidence >= 0.9) {
      tags.add('高置信度');
    } else if (confidence >= 0.7) {
      tags.add('中置信度');
    } else {
      tags.add('低置信度');
    }

    // 基于详细分类生成标签
    final categoryDetail = reasons['category']?.toString().toLowerCase() ?? '';
    if (categoryDetail.contains('normal') || categoryDetail.contains('正常')) {
      tags.add('正常');
    } else if (categoryDetail.contains('abnormal') || categoryDetail.contains('异常')) {
      tags.add('异常');
    }
    if (categoryDetail.contains('pet') || categoryDetail.contains('宠物')) {
      tags.add('宠物');
    }
    if (categoryDetail.contains('health') || categoryDetail.contains('健康')) {
      tags.add('健康');
    }
    if (categoryDetail.contains('behavior') || categoryDetail.contains('行为')) {
      tags.add('行为');
    }
    if (categoryDetail.contains('activity') || categoryDetail.contains('活动')) {
      tags.add('活动');
    }

    // 基于原因文本生成更多标签
    final reasonsText = reasons['reasons']?.toString().toLowerCase() ?? '';
    if (reasonsText.contains('alert') || reasonsText.contains('警告')) {
      tags.add('警告');
    }
    if (reasonsText.contains('urgent') || reasonsText.contains('紧急')) {
      tags.add('紧急');
    }
    if (reasonsText.contains('food') || reasonsText.contains('食物') || reasonsText.contains('食盆')) {
      tags.add('进食');
    }
    if (reasonsText.contains('water') || reasonsText.contains('水') || reasonsText.contains('水盆')) {
      tags.add('饮水');
    }
    if (reasonsText.contains('toy') || reasonsText.contains('玩具') || reasonsText.contains('球')) {
      tags.add('玩耍');
    }
    if (reasonsText.contains('bed') || reasonsText.contains('窝') || reasonsText.contains('睡')) {
      tags.add('睡眠');
    }
    if (reasonsText.contains('door') || reasonsText.contains('门') || reasonsText.contains('外出')) {
      tags.add('外出');
    }
    if (reasonsText.contains('toilet') || reasonsText.contains('厕所') || reasonsText.contains('排便')) {
      tags.add('排便');
    }
    if (reasonsText.contains('groom') || reasonsText.contains('梳理') || reasonsText.contains('清洁')) {
      tags.add('清洁');
    }

    return tags.toSet().toList(); // 去重
  }

  /// 验证时间轴记录格式
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
$timestamp1\tpet\t0.95\t```json
{
  "category": "宠物进食行为",
  "confidence": 0.95,
  "reasons": "检测到宠物在食盆附近的正常进食行为，动作自然流畅"
}
```
$timestamp2\tnormal\t0.87\t```json
{
  "category": "正常活动",
  "confidence": 0.87,
  "reasons": "宠物在客厅区域进行日常活动，行为模式正常"
}
```''';
  }
}