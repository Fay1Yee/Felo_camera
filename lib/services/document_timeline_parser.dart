import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/analysis_history.dart';
import '../models/ai_result.dart';
import 'api_client.dart';
import 'history_manager.dart';

/// 文档时间轴解析结果
class DocumentParseResult {
  final List<TimelineEvent> events;
  final List<String> errors;
  final String originalDocument;
  final int totalEvents;
  final int successCount;
  final int errorCount;

  DocumentParseResult({
    required this.events,
    required this.errors,
    required this.originalDocument,
    required this.totalEvents,
    required this.successCount,
    required this.errorCount,
  });
}

/// 时间轴事件数据模型
class TimelineEvent {
  final DateTime timestamp;
  final String title;
  final String content;
  final String category;
  final double confidence;
  final Map<String, dynamic> metadata;
  final List<String> tags;

  TimelineEvent({
    required this.timestamp,
    required this.title,
    required this.content,
    required this.category,
    required this.confidence,
    this.metadata = const {},
    this.tags = const [],
  });

  /// 转换为AnalysisHistory
  AnalysisHistory toAnalysisHistory() {
    final aiResult = AIResult(
      title: title, // 使用事件的实际标题
      confidence: (confidence * 100).round(),
      subInfo: content.isNotEmpty ? content : null,
    );

    return AnalysisHistory(
      id: '${timestamp.millisecondsSinceEpoch}_${title.hashCode}',
      timestamp: timestamp,
      result: aiResult,
      mode: 'document_timeline',
      isRealtimeAnalysis: false,
    );
  }

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'content': content,
      'category': category,
      'confidence': confidence,
      'metadata': metadata,
      'tags': tags,
    };
  }
}

/// 文档时间轴解析服务
class DocumentTimelineParser {
  static final DocumentTimelineParser _instance = DocumentTimelineParser._internal();
  factory DocumentTimelineParser() => _instance;
  DocumentTimelineParser._internal();

  final ApiClient _apiClient = ApiClient.instance;
  final HistoryManager _historyManager = HistoryManager.instance;

  /// 豆包模型系统提示词
  static const String _systemPrompt = '''
你是一个专业的宠物活动记录解析专家。你的任务是分析用户提供的文档内容，**严格筛选并识别其中与宠物直接相关的活动事件**，并将每个事件转换为结构化的宠物活动时间轴记录。

## 核心任务：
1. **宠物活动识别**：从文档中识别所有与宠物直接相关的活动、行为、健康状况等事件
2. **非宠物事件过滤**：严格排除与宠物无关的人类活动、环境描述、设备操作等内容
3. **事件拆分**：将复合的宠物活动拆分为多个独立的时间轴记录
4. **信息提取**：为每个宠物活动提取完整的时间、内容和类别信息
5. **结构化输出**：生成符合要求的JSON格式输出

## 重要过滤规则：
**必须包含的宠物相关事件：**
- 宠物的直接行为活动（进食、睡觉、玩耍、运动等）
- 宠物的健康状况和医疗记录
- 对宠物的护理活动（喂食、清洁、美容等）
- 宠物的训练和学习活动
- 宠物与人或其他动物的互动
- 宠物的异常行为或状况变化

**必须排除的非宠物事件：**
- 纯粹的人类活动（工作、购物、社交等）
- 环境或设备的描述（天气、房间布置、电器使用等）
- 与宠物无直接关系的日常事务
- 技术操作或系统记录
- 无宠物参与的事件描述

## 解析规则：
1. **时间信息识别**：
   - 精确识别绝对时间（如：2024年1月15日 14:30）
   - 识别相对时间（如：昨天、上周、三天前）
   - 识别时间范围（如：2024年1月-3月）
   - 对于缺失时间的事件，根据上下文推断合理时间

2. **宠物活动独立性判断**：
   - 每个具有独立意义的宠物行为、活动、健康状况都应作为单独事件
   - 同一时间的不同宠物活动可以拆分为多个事件
   - 因果关系明确的宠物活动应保持独立

3. **内容完整性**：
   - 每个宠物活动必须包含足够的上下文信息
   - 保留关键的宠物行为细节和数据
   - 确保活动描述的自包含性

4. **宠物活动类别分类**：
   - 进食活动：feeding, eating, drinking, meal
   - 运动玩耍：exercise, play, walk, run, activity
   - 休息睡眠：sleep, rest, nap, relax
   - 健康医疗：health, medical, vet, checkup, medicine
   - 清洁护理：grooming, bath, cleaning, hygiene
   - 训练学习：training, learning, behavior, discipline
   - 社交互动：social, interaction, play_with_others
   - 异常行为：abnormal, unusual, concern, problem
   - 其他活动：other

## 输出格式要求：
请严格按照以下JSON格式输出，不要包含任何其他文字：

```json
{
  "events": [
    {
      "timestamp": "2024-01-15T14:30:00",
      "title": "事件标题（简洁明确）",
      "content": "事件详细内容描述",
      "category": "事件类别",
      "confidence": 0.95,
      "metadata": {
        "source": "document",
        "original_text": "原始文档中的相关文字",
        "context": "相关上下文信息"
      },
      "tags": ["标签1", "标签2", "标签3"]
    }
  ],
  "summary": {
    "total_events": 事件总数,
    "time_range": {
      "start": "最早时间",
      "end": "最晚时间"
    },
    "categories": ["涉及的类别列表"],
    "confidence_avg": 平均置信度
  }
}
```

## 质量要求：
- 时间信息准确性：确保时间解析正确，时区处理合理
- 事件完整性：每个事件都有完整的标题、内容、类别
- 逻辑一致性：事件之间的时间顺序合理
- 置信度评估：根据时间信息的明确程度和内容完整性评估置信度

请开始解析用户提供的文档内容。
''';

  /// 解析文档并生成时间轴事件
  Future<DocumentParseResult> parseDocument(String documentContent) async {
    try {
      debugPrint('开始解析文档，内容长度: ${documentContent.length}');
      
      // 调用豆包模型进行解析
      final response = await _apiClient.analyzeText(
        documentContent,
        _systemPrompt,
      );
      
      // 解析响应
      final parseResult = _parseDoubaoResponse(response, documentContent);
      
      debugPrint('文档解析完成，识别到 ${parseResult.events.length} 个事件');
      return parseResult;
      
    } catch (e) {
      debugPrint('文档解析失败: $e');
      return DocumentParseResult(
        events: [],
        errors: ['文档解析失败: $e'],
        originalDocument: documentContent,
        totalEvents: 0,
        successCount: 0,
        errorCount: 1,
      );
    }
  }

  /// 将解析的事件插入时间轴
  Future<Map<String, dynamic>> insertEventsToTimeline(List<TimelineEvent> events) async {
    try {
      debugPrint('开始插入 ${events.length} 个事件到时间轴');
      
      final insertedEvents = <AnalysisHistory>[];
      final errors = <String>[];
      
      // 按时间排序事件
      events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      for (final event in events) {
        try {
          final history = event.toAnalysisHistory();
          await _historyManager.addHistoryWithTimestamp(
            result: history.result,
            mode: history.mode,
            timestamp: history.timestamp,
            isRealtimeAnalysis: false,
          );
          insertedEvents.add(history);
          debugPrint('成功插入事件: ${event.title} (${event.timestamp})');
        } catch (e) {
          final error = '插入事件失败: ${event.title} - $e';
          errors.add(error);
          debugPrint(error);
        }
      }
      
      return {
        'success': errors.isEmpty,
        'inserted_count': insertedEvents.length,
        'error_count': errors.length,
        'errors': errors,
        'events': insertedEvents.map((e) => e.toJson()).toList(),
        'time_range': {
          'start': events.isNotEmpty ? events.first.timestamp.toIso8601String() : null,
          'end': events.isNotEmpty ? events.last.timestamp.toIso8601String() : null,
        },
      };
      
    } catch (e) {
      debugPrint('时间轴插入失败: $e');
      return {
        'success': false,
        'error': '时间轴插入失败: $e',
        'inserted_count': 0,
        'error_count': events.length,
      };
    }
  }

  /// 解析文档并直接插入时间轴（一步完成）
  Future<Map<String, dynamic>> parseAndInsertDocument(String documentContent) async {
    try {
      // 1. 解析文档
      final parseResult = await parseDocument(documentContent);
      
      if (parseResult.events.isEmpty) {
        return {
          'success': false,
          'error': '未能从文档中识别到任何事件',
          'parse_errors': parseResult.errors,
        };
      }
      
      // 2. 插入时间轴
      final insertResult = await insertEventsToTimeline(parseResult.events);
      
      // 3. 合并结果
      return {
        'success': insertResult['success'],
        'parse_result': {
          'total_events': parseResult.totalEvents,
          'success_count': parseResult.successCount,
          'error_count': parseResult.errorCount,
          'errors': parseResult.errors,
        },
        'insert_result': insertResult,
        'summary': {
          'document_length': documentContent.length,
          'events_identified': parseResult.events.length,
          'events_inserted': insertResult['inserted_count'],
          'total_errors': parseResult.errors.length + (insertResult['errors'] as List).length,
        },
      };
      
    } catch (e) {
      debugPrint('文档解析和插入失败: $e');
      return {
        'success': false,
        'error': '文档解析和插入失败: $e',
      };
    }
  }



  /// 过滤非宠物相关事件
  List<TimelineEvent> _filterPetRelatedEvents(List<TimelineEvent> events) {
    // 宠物相关关键词
    final petKeywords = [
      // 动物名称
      '猫', '狗', '宠物', '小猫', '小狗', '猫咪', '狗狗', '毛孩', '毛球',
      // 宠物行为
      '进食', '吃', '喝', '睡觉', '休息', '玩耍', '游戏', '跑', '跳', '爬',
      '叫', '吠', '喵', '呼噜', '摇尾巴', '舔', '咬', '抓', '挠',
      // 宠物护理
      '喂食', '喂', '梳毛', '洗澡', '清洁', '美容', '修剪', '驱虫', '疫苗',
      // 宠物用品
      '猫粮', '狗粮', '猫砂', '玩具', '猫窝', '狗窝', '牵引绳', '项圈',
      // 宠物健康
      '体检', '看病', '医院', '兽医', '生病', '健康', '体重', '体温',
      // 宠物训练
      '训练', '学习', '坐下', '握手', '过来', '等待', '听话',
    ];

    // 非宠物关键词（需要排除的）
    final nonPetKeywords = [
      // 纯人类活动
      '上班', '工作', '开会', '购物', '做饭', '洗衣', '打扫', '看电视',
      '上网', '聊天', '电话', '短信', '邮件', '社交', '朋友', '同事',
      // 技术设备
      '电脑', '手机', '软件', '系统', '网络', 'wifi', '蓝牙', '充电',
      '安装', '更新', '下载', '上传', '备份', '重启',
      // 环境描述
      '天气', '温度', '湿度', '空调', '暖气', '灯光', '窗户', '门',
      '房间', '客厅', '卧室', '厨房', '卫生间', '阳台',
    ];

    final filteredEvents = <TimelineEvent>[];
    final filteredOutEvents = <String>[];

    for (final event in events) {
      final content = '${event.title} ${event.content}'.toLowerCase();
      
      // 检查是否包含宠物相关关键词
      bool hasPetKeywords = petKeywords.any((keyword) => content.contains(keyword));
      
      // 检查是否包含非宠物关键词
      bool hasNonPetKeywords = nonPetKeywords.any((keyword) => content.contains(keyword));
      
      // 如果包含宠物关键词且不主要是非宠物内容，则保留
      if (hasPetKeywords && !hasNonPetKeywords) {
        filteredEvents.add(event);
      } else if (hasPetKeywords && hasNonPetKeywords) {
        // 如果同时包含宠物和非宠物关键词，检查宠物关键词的比重
        final petCount = petKeywords.where((keyword) => content.contains(keyword)).length;
        final nonPetCount = nonPetKeywords.where((keyword) => content.contains(keyword)).length;
        
        if (petCount > nonPetCount) {
          filteredEvents.add(event);
        } else {
          filteredOutEvents.add('${event.title} - 非宠物内容占主导');
        }
      } else {
        filteredOutEvents.add('${event.title} - 无宠物相关内容');
      }
    }

    if (filteredOutEvents.isNotEmpty) {
      debugPrint('过滤掉 ${filteredOutEvents.length} 个非宠物相关事件:');
      for (final filtered in filteredOutEvents) {
        debugPrint('  - $filtered');
      }
    }

    debugPrint('保留 ${filteredEvents.length} 个宠物相关事件');
    return filteredEvents;
  }

  /// 解析豆包模型响应
  DocumentParseResult _parseDoubaoResponse(String response, String originalDocument) {
    try {
      // 清理响应内容，移除可能的markdown代码块标记
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();
      
      final jsonData = json.decode(cleanResponse) as Map<String, dynamic>;
      final eventsJson = jsonData['events'] as List<dynamic>;
      
      final allEvents = eventsJson
          .map((eventJson) => TimelineEvent.fromJson(eventJson as Map<String, dynamic>))
          .toList();
      
      // 过滤非宠物相关事件
      final petRelatedEvents = _filterPetRelatedEvents(allEvents);
      
      return DocumentParseResult(
        events: petRelatedEvents,
        errors: [],
        originalDocument: originalDocument,
        totalEvents: allEvents.length,
        successCount: petRelatedEvents.length,
        errorCount: allEvents.length - petRelatedEvents.length,
      );
      
    } catch (e) {
      debugPrint('解析豆包响应失败: $e');
      debugPrint('原始响应: $response');
      
      return DocumentParseResult(
        events: [],
        errors: ['解析豆包响应失败: $e'],
        originalDocument: originalDocument,
        totalEvents: 0,
        successCount: 0,
        errorCount: 1,
      );
    }
  }
}