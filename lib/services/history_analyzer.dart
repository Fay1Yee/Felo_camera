import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/analysis_history.dart';
import 'api_client.dart';
import 'network_manager.dart';

/// 历史记录分析服务
/// 专门用于处理历史记录中的信息和用户主动上传的记录信息
class HistoryAnalyzer {
  static final HistoryAnalyzer _instance = HistoryAnalyzer._internal();
  factory HistoryAnalyzer() => _instance;
  HistoryAnalyzer._internal();

  final ApiClient _apiClient = ApiClient.instance;

  /// 分析历史记录趋势
  /// 
  /// [historyList] 历史分析记录列表
  /// [analysisType] 分析类型：'trend', 'summary', 'insights'
  Future<Map<String, dynamic>> analyzeHistoryTrend(
    List<AnalysisHistory> historyList,
    String analysisType,
  ) async {
    try {
      // 构建历史数据摘要
      final historyData = _buildHistoryDataSummary(historyList);
      
      // 构建分析提示词
      final prompt = _buildHistoryAnalysisPrompt(historyData, analysisType);
      
      // 使用历史记录专用模型进行分析
      final response = await _analyzeWithHistoryModel(prompt);
      
      return {
        'success': true,
        'analysisType': analysisType,
        'result': response,
        'processedRecords': historyList.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('历史记录趋势分析失败: $e');
      return {
        'success': false,
        'error': e.toString(),
        'analysisType': analysisType,
      };
    }
  }

  /// 分析用户上传的记录信息
  /// 
  /// [imagePath] 图片路径
  /// [userNotes] 用户备注
  /// [context] 上下文信息（如相关历史记录）
  Future<Map<String, dynamic>> analyzeUserUploadedRecord(
    String imagePath,
    String? userNotes,
    Map<String, dynamic>? context,
  ) async {
    try {
      // 使用历史记录专用模型分析图片和信息
      final imageFile = File(imagePath);
      final result = await _apiClient.analyzeImage(
        imageFile,
        mode: 'history', // 使用历史记录模式
        modelKey: ApiConfig.historyModelKey,
      );
      
      return {
        'success': true,
        'result': result,
        'userNotes': userNotes,
        'hasContext': context != null,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('用户上传记录分析失败: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 生成历史记录洞察报告
  /// 
  /// [historyList] 历史记录列表
  /// [timeRange] 时间范围（天数）
  Future<Map<String, dynamic>> generateInsightsReport(
    List<AnalysisHistory> historyList,
    int timeRange,
  ) async {
    try {
      // 过滤指定时间范围内的记录
      final filteredHistory = _filterHistoryByTimeRange(historyList, timeRange);
      
      if (filteredHistory.isEmpty) {
        return {
          'success': false,
          'error': '指定时间范围内没有历史记录',
        };
      }

      // 分析不同类型的洞察
      final trendAnalysis = await analyzeHistoryTrend(filteredHistory, 'trend');
      final summaryAnalysis = await analyzeHistoryTrend(filteredHistory, 'summary');
      final insightsAnalysis = await analyzeHistoryTrend(filteredHistory, 'insights');

      return {
        'success': true,
        'timeRange': timeRange,
        'recordCount': filteredHistory.length,
        'trend': trendAnalysis,
        'summary': summaryAnalysis,
        'insights': insightsAnalysis,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('生成洞察报告失败: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 构建历史数据摘要
  Map<String, dynamic> _buildHistoryDataSummary(List<AnalysisHistory> historyList) {
    final summary = <String, dynamic>{
      'totalRecords': historyList.length,
      'dateRange': {
        'start': historyList.isNotEmpty ? historyList.first.timestamp : null,
        'end': historyList.isNotEmpty ? historyList.last.timestamp : null,
      },
      'modeDistribution': <String, int>{},
      'confidenceStats': <String, double>{},
      'recentRecords': [],
    };

    if (historyList.isEmpty) return summary;

    // 统计模式分布
    final modeCount = <String, int>{};
    final confidenceValues = <double>[];

    for (final record in historyList) {
      final mode = record.mode;
      modeCount[mode] = (modeCount[mode] ?? 0) + 1;
      
      // 从AIResult中获取置信度
      confidenceValues.add(record.result.confidence.toDouble());
    }

    summary['modeDistribution'] = modeCount;

    // 计算置信度统计
    if (confidenceValues.isNotEmpty) {
      confidenceValues.sort();
      summary['confidenceStats'] = {
        'average': confidenceValues.reduce((a, b) => a + b) / confidenceValues.length,
        'min': confidenceValues.first,
        'max': confidenceValues.last,
        'median': confidenceValues[confidenceValues.length ~/ 2],
      };
    }

    // 最近的记录（最多10条）
    summary['recentRecords'] = historyList
        .take(10)
        .map((record) => {
              'timestamp': record.timestamp.toIso8601String(),
              'mode': record.mode,
              'confidence': record.result.confidence,
              'result': record.result.title, // 使用AIResult的title
            })
        .toList();

    return summary;
  }

  /// 构建历史分析提示词
  String _buildHistoryAnalysisPrompt(Map<String, dynamic> historyData, String analysisType) {
    final basePrompt = '''
你是一个专业的数据分析师，请分析以下历史记录数据：

历史数据摘要：
${jsonEncode(historyData)}

''';

    switch (analysisType) {
      case 'trend':
        return basePrompt + '''
请分析数据趋势，包括：
1. 使用模式的变化趋势
2. 置信度的变化趋势
3. 时间分布特征
4. 异常值或特殊模式

请用简洁明了的语言总结趋势特点。
''';

      case 'summary':
        return basePrompt + '''
请提供数据摘要，包括：
1. 总体使用情况概述
2. 主要使用的分析模式
3. 整体分析质量评估
4. 关键数据指标

请用简洁的语言总结主要发现。
''';

      case 'insights':
        return basePrompt + '''
请提供深度洞察，包括：
1. 用户行为模式分析
2. 使用习惯和偏好
3. 潜在的改进建议
4. 预测性见解

请提供有价值的洞察和建议。
''';

      default:
        return basePrompt + '请分析这些历史数据并提供有用的见解。';
    }
  }



  /// 使用历史记录专用模型进行分析（通过后端API）
  Future<String> _analyzeWithHistoryModel(String prompt) async {
    try {
      // 调用后端的历史分析API进行文本分析
      // 创建一个包含提示词的请求
      final networkManager = NetworkManager.instance;
       final response = await networkManager.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/analyze-history-text'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
          'analysis_type': 'text_analysis',
        }),
        timeout: const Duration(seconds: 15),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['analysis'] ?? '分析完成';
      } else {
        throw Exception('后端历史分析API请求失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🚨 历史记录模型分析错误: $e');
      
      // 降级处理：返回基础分析结果
      return '''
基于历史记录分析：

通过分析提供的历史数据，发现了以下关键信息：

1. **数据概览**：已处理的历史记录数据
2. **基础统计**：记录数量和时间分布
3. **模式识别**：识别出的基本使用模式
4. **建议**：基于数据的基础建议

注：由于网络或服务问题，当前使用基础分析模式。
''';
    }
  }

  /// 按时间范围过滤历史记录
  List<AnalysisHistory> _filterHistoryByTimeRange(List<AnalysisHistory> historyList, int timeRange) {
    final cutoffDate = DateTime.now().subtract(Duration(days: timeRange));
    
    return historyList.where((record) {
      return record.timestamp.isAfter(cutoffDate);
    }).toList();
  }
}