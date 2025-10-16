import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:doc_text/doc_text.dart';
import '../models/ai_result.dart';
import 'history_manager.dart';

/// 宠物活动数据解析器
class PetActivityParser {
  /// 解析宠物活动数据文件并添加到历史记录（基于文件路径）
  static Future<int> parseAndAddToHistory(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ 文件不存在: $filePath');
        return 0;
      }

      String content;

      // 检查文件扩展名，决定解析方式
      if (filePath.toLowerCase().endsWith('.docx') ||
          filePath.toLowerCase().endsWith('.doc')) {
        // 使用doc_text解析docx/doc文件
        try {
          final docText = DocText();
          final extractedText = await docText.extractTextFromDoc(filePath);
          if (extractedText == null) {
            debugPrint('❌ 无法从docx文件中提取文本: $filePath');
            return 0;
          }
          content = extractedText;
          debugPrint('✅ 成功从docx文件提取文本，长度: ${content.length}');
        } catch (e) {
          debugPrint('❌ 解析docx文件时出错: $e');
          return 0;
        }
      } else {
        // 对于txt、csv、json等文本文件，直接读取
        content = await file.readAsString();
      }

      // 预处理文档内容
      content = _preprocessDocumentContent(content);
      
      final lines = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      int addedCount = 0;
      int skippedCount = 0;

      for (final line in lines) {
        try {
          final record = _parseLine(line);
          if (record != null) {
            await _addRecordToHistory(record);
            addedCount++;
            debugPrint('✅ 成功解析第${addedCount}条记录: ${record.category} (${record.timestamp})');
          } else {
            skippedCount++;
            if (skippedCount <= 5) { // 只显示前5个跳过的行
              debugPrint('⏭️ 跳过行 $skippedCount: ${line.length > 100 ? line.substring(0, 100) + '...' : line}');
            }
          }
        } catch (e) {
          skippedCount++;
          debugPrint('⚠️ 解析行失败: ${line.length > 100 ? line.substring(0, 100) + '...' : line}, 错误: $e');
        }
      }

      debugPrint('✅ 解析完成: 成功添加 $addedCount 条记录，跳过 $skippedCount 行');
      return addedCount;
    } catch (e) {
      debugPrint('❌ 解析文件失败: $e');
      return 0;
    }
  }

  /// 解析宠物活动数据文件并添加到历史记录（基于字节数据，解决Scoped Storage限制）
  static Future<int> parseAndAddToHistoryFromBytes(
    Uint8List fileBytes,
    String fileName,
    String? mimeType,
  ) async {
    try {
      String content;

      // 根据文件扩展名或MIME类型决定解析方式
      final fileExtension = fileName.toLowerCase().split('.').last;

      if (fileExtension == 'docx' ||
          fileExtension == 'doc' ||
          (mimeType != null && mimeType.contains('officedocument'))) {
        // 对于docx/doc文件，需要先保存到临时文件再解析
        try {
          // 创建临时文件
          final tempDir = Directory.systemTemp;
          final tempFile = File(
            '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
          );
          await tempFile.writeAsBytes(fileBytes);

          // 使用doc_text解析
          final docText = DocText();
          final extractedText = await docText.extractTextFromDoc(tempFile.path);

          // 清理临时文件
          if (await tempFile.exists()) {
            await tempFile.delete();
          }

          if (extractedText == null) {
            debugPrint('❌ 无法从docx文件中提取文本');
            return 0;
          }
          content = extractedText;
          debugPrint('✅ 成功从docx文件提取文本，长度: ${content.length}');
        } catch (e) {
          debugPrint('❌ 解析docx文件时出错: $e');
          return 0;
        }
      } else {
        // 对于txt、csv、json等文本文件，直接从字节数据解码
        try {
          content = utf8.decode(fileBytes);
        } catch (e) {
          // 如果UTF-8解码失败，尝试其他编码
          try {
            content = latin1.decode(fileBytes);
          } catch (e2) {
            debugPrint('❌ 无法解码文件内容: $e2');
            return 0;
          }
        }
      }

      // 预处理文档内容
      content = _preprocessDocumentContent(content);
      
      debugPrint('📄 预处理后的文档内容预览（前500字符）:');
      debugPrint(content.length > 500 ? content.substring(0, 500) + '...' : content);

      final lines = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      debugPrint('📊 找到 ${lines.length} 行非空数据');
      
      int addedCount = 0;
      int skippedCount = 0;

      for (final line in lines) {
        try {
          final record = _parseLine(line);
          if (record != null) {
            await _addRecordToHistory(record);
            addedCount++;
            debugPrint('✅ 成功解析第${addedCount}条记录: ${record.category} (${record.timestamp})');
          } else {
            skippedCount++;
            if (skippedCount <= 5) { // 只显示前5个跳过的行
              debugPrint('⏭️ 跳过行 $skippedCount: ${line.length > 100 ? line.substring(0, 100) + '...' : line}');
            }
          }
        } catch (e) {
          skippedCount++;
          debugPrint('⚠️ 解析行失败: ${line.length > 100 ? line.substring(0, 100) + '...' : line}, 错误: $e');
        }
      }

      debugPrint('✅ 解析完成（从字节数据）: 成功添加 $addedCount 条记录，跳过 $skippedCount 行');
      return addedCount;
    } catch (e) {
      debugPrint('❌ 解析文件失败（从字节数据）: $e');
      return 0;
    }
  }

  /// 解析单行数据（智能解析，支持多种格式）
  static PetActivityRecord? _parseLine(String line) {
    // 跳过空行和注释行
    line = line.trim();
    if (line.isEmpty || line.startsWith('#') || line.startsWith('//')) {
      return null;
    }

    // 尝试多种分隔符
    List<String> parts = [];
    
    // 首先尝试制表符分隔
    if (line.contains('\t')) {
      parts = line.split('\t');
    }
    // 然后尝试逗号分隔
    else if (line.contains(',')) {
      parts = _parseCSVLine(line);
    }
    // 最后尝试空格分隔（至少4个部分）
    else if (line.split(RegExp(r'\s+')).length >= 4) {
      parts = line.split(RegExp(r'\s+'));
    }
    // 尝试解析结构化文本格式
    else {
      return _parseStructuredLine(line);
    }

    if (parts.length < 4) {
      debugPrint('⚠️ 行格式不正确，期望至少4个字段，实际${parts.length}个: $line');
      return null;
    }

    try {
      // 解析时间戳
      final timestamp = DateTime.parse(parts[0].trim());

      // 解析类别
      final category = parts[1].trim();

      // 解析置信度
      final confidence = double.parse(parts[2].trim());
      if (confidence < 0.0 || confidence > 1.0) {
        debugPrint('⚠️ 置信度超出范围 [0.0, 1.0]: $confidence');
        return null;
      }

      // 解析原因（JSON格式）
      String reasonsText = parts[3].trim();

      // 处理可能的 ```json 包装
      if (reasonsText.startsWith('```json')) {
        reasonsText = reasonsText.substring(7);
      }
      if (reasonsText.endsWith('```')) {
        reasonsText = reasonsText.substring(0, reasonsText.length - 3);
      }

      final reasonsJson = jsonDecode(reasonsText) as Map<String, dynamic>;

      return PetActivityRecord(
        timestamp: timestamp,
        category: category,
        confidence: confidence,
        reasons: reasonsJson,
        originalLine: line,
      );
    } catch (e) {
      debugPrint('⚠️ 解析行数据失败: $line, 错误: $e');
      return null;
    }
  }

  /// 预处理文档内容，提取和格式化宠物活动数据
  static String _preprocessDocumentContent(String content) {
    // 移除多余的空白字符
    content = content.replaceAll(RegExp(r'\r\n'), '\n');
    content = content.replaceAll(RegExp(r'\r'), '\n');
    
    // 处理表格格式（Word文档中的表格可能用制表符分隔）
    content = content.replaceAll(RegExp(r'\s{2,}'), '\t');
    
    // 处理可能的标题行
    final lines = content.split('\n');
    final processedLines = <String>[];
    
    for (String line in lines) {
      line = line.trim();
      
      // 跳过明显的标题行
      if (line.toLowerCase().contains('timestamp') && 
          line.toLowerCase().contains('category') &&
          line.toLowerCase().contains('confidence')) {
        continue;
      }
      
      // 跳过中文标题行
      if (line.contains('时间戳') && 
          line.contains('类别') &&
          line.contains('置信度')) {
        continue;
      }
      
      // 处理可能的分隔符问题
      if (line.contains('|')) {
        line = line.replaceAll('|', '\t');
      }
      
      // 处理多个空格为制表符
      line = line.replaceAll(RegExp(r'\s{3,}'), '\t');
      
      if (line.isNotEmpty) {
        processedLines.add(line);
      }
    }
    
    return processedLines.join('\n');
  }

  /// 解析CSV格式的行（处理引号包围的字段）
  static List<String> _parseCSVLine(String line) {
    final List<String> parts = [];
    bool inQuotes = false;
    String currentPart = '';
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        parts.add(currentPart.trim());
        currentPart = '';
      } else {
        currentPart += char;
      }
    }
    
    if (currentPart.isNotEmpty) {
      parts.add(currentPart.trim());
    }
    
    return parts;
  }

  /// 解析结构化文本格式（如：时间戳: xxx, 类别: xxx, 置信度: xxx, 原因: xxx）
  static PetActivityRecord? _parseStructuredLine(String line) {
    try {
      // 尝试匹配结构化格式
      final timestampMatch = RegExp(r'时间戳?\s*[:：]\s*([^\s,，]+)').firstMatch(line);
      final categoryMatch = RegExp(r'类别\s*[:：]\s*([^\s,，]+)').firstMatch(line);
      final confidenceMatch = RegExp(r'置信度\s*[:：]\s*([\d.]+)').firstMatch(line);
      final reasonsMatch = RegExp(r'原因\s*[:：]\s*(\{.*\})').firstMatch(line);

      if (timestampMatch == null || categoryMatch == null || 
          confidenceMatch == null || reasonsMatch == null) {
        
        // 尝试英文格式
        final timestampMatchEn = RegExp(r'timestamp\s*[:：]\s*([^\s,，]+)', caseSensitive: false).firstMatch(line);
        final categoryMatchEn = RegExp(r'category\s*[:：]\s*([^\s,，]+)', caseSensitive: false).firstMatch(line);
        final confidenceMatchEn = RegExp(r'confidence\s*[:：]\s*([\d.]+)', caseSensitive: false).firstMatch(line);
        final reasonsMatchEn = RegExp(r'reasons?\s*[:：]\s*(\{.*\})', caseSensitive: false).firstMatch(line);

        if (timestampMatchEn == null || categoryMatchEn == null || 
            confidenceMatchEn == null || reasonsMatchEn == null) {
          return null;
        }

        return _createRecordFromMatches(
          timestampMatchEn.group(1)!,
          categoryMatchEn.group(1)!,
          confidenceMatchEn.group(1)!,
          reasonsMatchEn.group(1)!,
          line,
        );
      }

      return _createRecordFromMatches(
        timestampMatch.group(1)!,
        categoryMatch.group(1)!,
        confidenceMatch.group(1)!,
        reasonsMatch.group(1)!,
        line,
      );
    } catch (e) {
      debugPrint('⚠️ 解析结构化行失败: $line, 错误: $e');
      return null;
    }
  }

  /// 从匹配的字段创建记录
  static PetActivityRecord? _createRecordFromMatches(
    String timestampStr,
    String category,
    String confidenceStr,
    String reasonsStr,
    String originalLine,
  ) {
    try {
      final timestamp = DateTime.parse(timestampStr.trim());
      final confidence = double.parse(confidenceStr.trim());
      
      if (confidence < 0.0 || confidence > 1.0) {
        debugPrint('⚠️ 置信度超出范围 [0.0, 1.0]: $confidence');
        return null;
      }

      // 处理可能的 ```json 包装
      String cleanReasonsStr = reasonsStr.trim();
      if (cleanReasonsStr.startsWith('```json')) {
        cleanReasonsStr = cleanReasonsStr.substring(7);
      }
      if (cleanReasonsStr.endsWith('```')) {
        cleanReasonsStr = cleanReasonsStr.substring(0, cleanReasonsStr.length - 3);
      }

      final reasonsJson = jsonDecode(cleanReasonsStr) as Map<String, dynamic>;

      return PetActivityRecord(
        timestamp: timestamp,
        category: category.trim(),
        confidence: confidence,
        reasons: reasonsJson,
        originalLine: originalLine,
      );
    } catch (e) {
      debugPrint('⚠️ 创建记录失败: $originalLine, 错误: $e');
      return null;
    }
  }

  /// 将解析的记录添加到历史记录
  static Future<void> _addRecordToHistory(PetActivityRecord record) async {
    // 生成活动标题
    final title = _generateActivityTitle(record.category, record.reasons);

    // 生成活动描述
    final content = _generateActivityContent(
      record.category,
      record.reasons,
      record.confidence,
    );

    // 生成标签
    final tags = _generateActivityTags(
      record.category,
      record.reasons,
      record.confidence,
    );

    // 创建活动事件
    final event = ActivityEvent(
      title: title,
      content: content,
      timestamp: record.timestamp,
      category: record.category,
      confidence: record.confidence,
      tags: tags,
      metadata: {
        'source': 'pet_activity_data',
        'original_line': record.originalLine,
        'reasons': record.reasons,
      },
    );

    // 创建AI结果
    final aiResult = AIResult(
      title: title,
      confidence: (record.confidence * 100).round(),
      subInfo: '置信度: ${(record.confidence * 100).toStringAsFixed(1)}%',
      multipleEvents: [event],
    );

    // 添加到历史记录
    await HistoryManager.instance.addHistoryWithTimestamp(
      result: aiResult,
      mode: 'pet_activity',
      timestamp: record.timestamp,
      isRealtimeAnalysis: false,
    );
  }

  /// 生成活动标题
  static String _generateActivityTitle(
    String category,
    Map<String, dynamic> reasons,
  ) {
    switch (category) {
      case 'no_pet':
        return '无宠物活动';
      case 'observed':
        return '观察到宠物';
      case 'explore':
        return '探索活动';
      case 'feeding':
        return '进食活动';
      case 'sleeping':
        return '休息睡眠';
      case 'playing':
        return '玩耍活动';
      case 'grooming':
        return '清洁护理';
      default:
        return '宠物活动 - $category';
    }
  }

  /// 生成活动内容描述
  static String _generateActivityContent(
    String category,
    Map<String, dynamic> reasons,
    double confidence,
  ) {
    final buffer = StringBuffer();

    // 基础描述 - 与timestampcategoryconfidencereasons2025.docx文档标准一致
    switch (category) {
      case 'observe':
        buffer.write('宠物正在进行观望行为');
        break;
      case 'explore':
        buffer.write('宠物正在进行探索行为');
        break;
      case 'occupy':
        buffer.write('宠物正在进行领地行为');
        break;
      case 'play':
        buffer.write('宠物正在进行玩耍行为');
        break;
      case 'attack':
        buffer.write('宠物正在进行攻击行为');
        break;
      case 'neutral':
        buffer.write('宠物处于中性状态');
        break;
      case 'no_pet':
        buffer.write('监控区域内未检测到宠物活动');
        break;
      default:
        buffer.write('检测到宠物行为：$category');
    }

    // 添加详细原因
    if (reasons.containsKey('reasons') && reasons['reasons'] is String) {
      buffer.write('。${reasons['reasons']}');
    }

    // 添加置信度信息
    buffer.write('（置信度：${(confidence * 100).toStringAsFixed(1)}%）');

    return buffer.toString();
  }

  /// 生成活动标签
  static List<String> _generateActivityTags(
    String category,
    Map<String, dynamic> reasons,
    double confidence,
  ) {
    final tags = <String>[category];

    // 根据置信度添加标签
    if (confidence >= 0.9) {
      tags.add('高置信度');
    } else if (confidence >= 0.7) {
      tags.add('中等置信度');
    } else {
      tags.add('低置信度');
    }

    // 根据类别添加相关标签 - 与timestampcategoryconfidencereasons2025.docx文档标准一致
    switch (category) {
      case 'observe':
        tags.addAll(['观望', '警觉']);
        break;
      case 'explore':
        tags.addAll(['探索', '活跃']);
        break;
      case 'occupy':
        tags.addAll(['领地', '占据']);
        break;
      case 'play':
        tags.addAll(['玩耍', '游戏']);
        break;
      case 'attack':
        tags.addAll(['攻击', '攻击性']);
        break;
      case 'neutral':
        tags.addAll(['中性', '静止']);
        break;
      case 'no_pet':
        tags.addAll(['监控', '无活动']);
        break;
    }

    return tags;
  }
}

/// 宠物活动记录数据模型
class PetActivityRecord {
  final DateTime timestamp;
  final String category;
  final double confidence;
  final Map<String, dynamic> reasons;
  final String originalLine;

  const PetActivityRecord({
    required this.timestamp,
    required this.category,
    required this.confidence,
    required this.reasons,
    required this.originalLine,
  });

  @override
  String toString() {
    return 'PetActivityRecord(timestamp: $timestamp, category: $category, confidence: $confidence)';
  }
}