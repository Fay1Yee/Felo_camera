import 'package:flutter/foundation.dart';
import '../models/analysis_history.dart';
import '../screens/data_management/life_records_screen.dart';
import 'history_manager.dart';
import 'data_association_service.dart';

/// 一致性验证结果
class ConsistencyValidationResult {
  final bool isValid;
  final double consistencyScore; // 0-1之间的一致性评分
  final List<ConsistencyIssue> issues;
  final Map<String, dynamic> metrics;
  final DateTime validatedAt;

  const ConsistencyValidationResult({
    required this.isValid,
    required this.consistencyScore,
    required this.issues,
    required this.metrics,
    required this.validatedAt,
  });
}

/// 一致性问题
class ConsistencyIssue {
  final String id;
  final ConsistencyIssueType type;
  final String title;
  final String description;
  final ConsistencyIssueSeverity severity;
  final String? analysisHistoryId;
  final String? lifeRecordId;
  final Map<String, dynamic> details;
  final String recommendation;

  const ConsistencyIssue({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    this.analysisHistoryId,
    this.lifeRecordId,
    this.details = const {},
    required this.recommendation,
  });
}

/// 一致性问题类型
enum ConsistencyIssueType {
  timeMismatch,        // 时间不匹配
  contentMismatch,     // 内容不匹配
  confidenceMismatch,  // 置信度不匹配
  missingAssociation,  // 缺少关联
  duplicateRecord,     // 重复记录
  invalidData,         // 无效数据
  logicalInconsistency, // 逻辑不一致
}

/// 一致性问题严重程度
enum ConsistencyIssueSeverity {
  low,     // 低 - 轻微不一致，不影响使用
  medium,  // 中 - 中等不一致，可能影响体验
  high,    // 高 - 严重不一致，需要立即修复
  critical, // 严重 - 关键不一致，影响数据完整性
}

/// 数据一致性验证器
class ConsistencyValidator {
  static ConsistencyValidator? _instance;
  static ConsistencyValidator get instance {
    return _instance ??= ConsistencyValidator._();
  }
  
  ConsistencyValidator._();

  /// 验证分析历史与生活记录的一致性
  Future<ConsistencyValidationResult> validateConsistency({
    List<AnalysisHistory>? analysisHistories,
    List<LifeRecord>? lifeRecords,
    List<DataAssociation>? associations,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final issues = <ConsistencyIssue>[];
    final metrics = <String, dynamic>{};

    // 获取数据
    final histories = analysisHistories ?? await _getAnalysisHistories(startDate, endDate);
    final records = lifeRecords ?? await _getLifeRecords(startDate, endDate);
    final assocs = associations ?? DataAssociationService.instance.getAllAssociations();

    // 执行各种一致性检查
    issues.addAll(await _validateTimeConsistency(histories, records, assocs));
    issues.addAll(await _validateContentConsistency(histories, records, assocs));
    issues.addAll(await _validateAssociationConsistency(histories, records, assocs));
    issues.addAll(await _validateDataIntegrity(histories, records));
    issues.addAll(await _validateLogicalConsistency(histories, records));

    // 计算指标
    metrics.addAll(_calculateMetrics(histories, records, assocs, issues));

    // 计算总体一致性评分
    final consistencyScore = _calculateConsistencyScore(issues, metrics);

    return ConsistencyValidationResult(
      isValid: consistencyScore >= 0.7 && !issues.any((i) => i.severity == ConsistencyIssueSeverity.critical),
      consistencyScore: consistencyScore,
      issues: issues,
      metrics: metrics,
      validatedAt: DateTime.now(),
    );
  }

  /// 验证时间一致性
  Future<List<ConsistencyIssue>> _validateTimeConsistency(
    List<AnalysisHistory> histories,
    List<LifeRecord> records,
    List<DataAssociation> associations,
  ) async {
    final issues = <ConsistencyIssue>[];

    for (final assoc in associations) {
      final history = histories.firstWhere(
        (h) => h.id == assoc.analysisHistoryId,
        orElse: () => throw StateError('Analysis history not found'),
      );
      
      final record = records.firstWhere(
        (r) => r.id == assoc.lifeRecordId,
        orElse: () => throw StateError('Life record not found'),
      );

      // 检查时间差异
      final timeDifference = history.timestamp.difference(record.timestamp).abs();
      
      if (timeDifference.inHours > 2) {
        issues.add(ConsistencyIssue(
          id: 'time_mismatch_${assoc.id}',
          type: ConsistencyIssueType.timeMismatch,
          title: '时间不匹配',
          description: '分析历史记录与生活记录的时间差异过大（${timeDifference.inHours}小时）',
          severity: timeDifference.inHours > 24 
              ? ConsistencyIssueSeverity.high 
              : ConsistencyIssueSeverity.medium,
          analysisHistoryId: history.id,
          lifeRecordId: record.id,
          details: {
            'historyTime': history.timestamp.toIso8601String(),
            'recordTime': record.timestamp.toIso8601String(),
            'timeDifferenceHours': timeDifference.inHours,
          },
          recommendation: '调整生活记录的时间戳，使其与分析历史记录更接近',
        ));
      }
    }

    return issues;
  }

  /// 验证内容一致性
  Future<List<ConsistencyIssue>> _validateContentConsistency(
    List<AnalysisHistory> histories,
    List<LifeRecord> records,
    List<DataAssociation> associations,
  ) async {
    final issues = <ConsistencyIssue>[];

    for (final assoc in associations) {
      final history = histories.firstWhere(
        (h) => h.id == assoc.analysisHistoryId,
        orElse: () => throw StateError('Analysis history not found'),
      );
      
      final record = records.firstWhere(
        (r) => r.id == assoc.lifeRecordId,
        orElse: () => throw StateError('Life record not found'),
      );

      // 检查内容相关性
      final contentSimilarity = _calculateContentSimilarity(history, record);
      
      if (contentSimilarity < 0.5) {
        issues.add(ConsistencyIssue(
          id: 'content_mismatch_${assoc.id}',
          type: ConsistencyIssueType.contentMismatch,
          title: '内容不匹配',
          description: '分析结果与生活记录内容相关性较低（${(contentSimilarity * 100).toStringAsFixed(1)}%）',
          severity: contentSimilarity < 0.3 
              ? ConsistencyIssueSeverity.high 
              : ConsistencyIssueSeverity.medium,
          analysisHistoryId: history.id,
          lifeRecordId: record.id,
          details: {
            'contentSimilarity': contentSimilarity,
            'historyTitle': history.result.title,
            'recordTitle': record.title,
            'historyMode': history.mode,
            'recordType': record.type.toString(),
          },
          recommendation: '重新生成生活记录，确保内容与分析结果更匹配',
        ));
      }

      // 检查置信度一致性
      if (history.result.confidence < 60 && assoc.confidence > 0.8) {
        issues.add(ConsistencyIssue(
          id: 'confidence_mismatch_${assoc.id}',
          type: ConsistencyIssueType.confidenceMismatch,
          title: '置信度不匹配',
          description: '低置信度的分析结果（${history.result.confidence}%）产生了高置信度的关联（${(assoc.confidence * 100).toStringAsFixed(1)}%）',
          severity: ConsistencyIssueSeverity.medium,
          analysisHistoryId: history.id,
          lifeRecordId: record.id,
          details: {
            'analysisConfidence': history.result.confidence,
            'associationConfidence': assoc.confidence,
          },
          recommendation: '降低关联置信度或重新评估分析结果',
        ));
      }
    }

    return issues;
  }

  /// 验证关联一致性
  Future<List<ConsistencyIssue>> _validateAssociationConsistency(
    List<AnalysisHistory> histories,
    List<LifeRecord> records,
    List<DataAssociation> associations,
  ) async {
    final issues = <ConsistencyIssue>[];

    // 检查缺失的关联
    for (final history in histories) {
      final hasAssociation = associations.any((a) => a.analysisHistoryId == history.id);
      
      if (!hasAssociation && history.result.confidence > 70) {
        issues.add(ConsistencyIssue(
          id: 'missing_association_${history.id}',
          type: ConsistencyIssueType.missingAssociation,
          title: '缺少关联',
          description: '高置信度的分析记录（${history.result.confidence}%）没有对应的生活记录关联',
          severity: ConsistencyIssueSeverity.medium,
          analysisHistoryId: history.id,
          details: {
            'analysisConfidence': history.result.confidence,
            'analysisTitle': history.result.title,
            'analysisMode': history.mode,
          },
          recommendation: '为此分析记录生成对应的生活记录',
        ));
      }
    }

    // 检查重复关联
    final associationGroups = <String, List<DataAssociation>>{};
    for (final assoc in associations) {
      final key = '${assoc.analysisHistoryId}_${assoc.lifeRecordId}';
      associationGroups[key] = (associationGroups[key] ?? [])..add(assoc);
    }

    for (final entry in associationGroups.entries) {
      if (entry.value.length > 1) {
        issues.add(ConsistencyIssue(
          id: 'duplicate_association_${entry.key}',
          type: ConsistencyIssueType.duplicateRecord,
          title: '重复关联',
          description: '同一对分析历史和生活记录存在${entry.value.length}个重复关联',
          severity: ConsistencyIssueSeverity.low,
          details: {
            'duplicateCount': entry.value.length,
            'associationIds': entry.value.map((a) => a.id).toList(),
          },
          recommendation: '删除重复的关联记录，保留置信度最高的一个',
        ));
      }
    }

    return issues;
  }

  /// 验证数据完整性
  Future<List<ConsistencyIssue>> _validateDataIntegrity(
    List<AnalysisHistory> histories,
    List<LifeRecord> records,
  ) async {
    final issues = <ConsistencyIssue>[];

    // 检查分析历史数据完整性
    for (final history in histories) {
      if (history.result.title.isEmpty) {
        issues.add(ConsistencyIssue(
          id: 'invalid_history_${history.id}',
          type: ConsistencyIssueType.invalidData,
          title: '无效分析数据',
          description: '分析历史记录缺少标题',
          severity: ConsistencyIssueSeverity.high,
          analysisHistoryId: history.id,
          recommendation: '修复或删除无效的分析历史记录',
        ));
      }

      if (history.result.confidence < 0 || history.result.confidence > 100) {
        issues.add(ConsistencyIssue(
          id: 'invalid_confidence_${history.id}',
          type: ConsistencyIssueType.invalidData,
          title: '无效置信度',
          description: '分析结果的置信度超出有效范围（${history.result.confidence}%）',
          severity: ConsistencyIssueSeverity.high,
          analysisHistoryId: history.id,
          recommendation: '修正置信度值到0-100范围内',
        ));
      }
    }

    // 检查生活记录数据完整性
    for (final record in records) {
      if (record.title.isEmpty) {
        issues.add(ConsistencyIssue(
          id: 'invalid_record_${record.id}',
          type: ConsistencyIssueType.invalidData,
          title: '无效生活记录',
          description: '生活记录缺少标题',
          severity: ConsistencyIssueSeverity.high,
          lifeRecordId: record.id,
          recommendation: '修复或删除无效的生活记录',
        ));
      }

      if (record.duration != null) {
        final duration = record.duration!;
        if (duration.isNegative) {
          issues.add(ConsistencyIssue(
            id: 'invalid_duration_${record.id}',
            type: ConsistencyIssueType.invalidData,
            title: '无效持续时间',
            description: '生活记录的持续时间为负值',
            severity: ConsistencyIssueSeverity.medium,
            lifeRecordId: record.id,
            recommendation: '修正持续时间为正值或null',
          ));
        }
      }
    }

    return issues;
  }

  /// 验证逻辑一致性
  Future<List<ConsistencyIssue>> _validateLogicalConsistency(
    List<AnalysisHistory> histories,
    List<LifeRecord> records,
  ) async {
    final issues = <ConsistencyIssue>[];

    // 检查时间逻辑一致性
    final sortedHistories = List<AnalysisHistory>.from(histories)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    for (int i = 0; i < sortedHistories.length - 1; i++) {
      final current = sortedHistories[i];
      final next = sortedHistories[i + 1];
      
      // 检查是否有时间重叠的冲突活动
      if (current.timestamp.isAtSameMomentAs(next.timestamp) && 
          current.mode != next.mode) {
        issues.add(ConsistencyIssue(
          id: 'logical_conflict_${current.id}_${next.id}',
          type: ConsistencyIssueType.logicalInconsistency,
          title: '逻辑冲突',
          description: '同一时间存在不同模式的分析记录',
          severity: ConsistencyIssueSeverity.medium,
          details: {
            'firstAnalysis': current.result.title,
            'secondAnalysis': next.result.title,
            'timestamp': current.timestamp.toIso8601String(),
          },
          recommendation: '检查并修正时间冲突的分析记录',
        ));
      }
    }

    // 检查活动强度逻辑
    for (final record in records) {
      if (record.intensity == ActivityIntensity.high && 
          record.duration != null) {
        final duration = record.duration!;
        if (duration.inMinutes < 5) {
          issues.add(ConsistencyIssue(
            id: 'intensity_duration_conflict_${record.id}',
            type: ConsistencyIssueType.logicalInconsistency,
            title: '强度与持续时间不匹配',
            description: '高强度活动的持续时间过短（${duration.inMinutes}分钟）',
            severity: ConsistencyIssueSeverity.low,
            lifeRecordId: record.id,
            recommendation: '调整活动强度或持续时间以保持逻辑一致性',
          ));
        }
      }
    }

    return issues;
  }

  /// 计算内容相似度
  double _calculateContentSimilarity(AnalysisHistory history, LifeRecord record) {
    final historyText = '${history.result.title} ${history.result.subInfo ?? ''}'.toLowerCase();
    final recordText = '${record.title} ${record.description}'.toLowerCase();
    
    // 简单的关键词匹配算法
    final historyWords = historyText.split(' ').where((w) => w.length > 2).toSet();
    final recordWords = recordText.split(' ').where((w) => w.length > 2).toSet();
    
    if (historyWords.isEmpty || recordWords.isEmpty) return 0.0;
    
    final intersection = historyWords.intersection(recordWords);
    final union = historyWords.union(recordWords);
    
    return intersection.length / union.length;
  }

  /// 计算指标
  Map<String, dynamic> _calculateMetrics(
    List<AnalysisHistory> histories,
    List<LifeRecord> records,
    List<DataAssociation> associations,
    List<ConsistencyIssue> issues,
  ) {
    return {
      'totalAnalysisHistories': histories.length,
      'totalLifeRecords': records.length,
      'totalAssociations': associations.length,
      'totalIssues': issues.length,
      'criticalIssues': issues.where((i) => i.severity == ConsistencyIssueSeverity.critical).length,
      'highSeverityIssues': issues.where((i) => i.severity == ConsistencyIssueSeverity.high).length,
      'mediumSeverityIssues': issues.where((i) => i.severity == ConsistencyIssueSeverity.medium).length,
      'lowSeverityIssues': issues.where((i) => i.severity == ConsistencyIssueSeverity.low).length,
      'associationCoverage': histories.isNotEmpty 
          ? associations.length / histories.length 
          : 0.0,
      'averageAssociationConfidence': associations.isNotEmpty
          ? associations.map((a) => a.confidence).reduce((a, b) => a + b) / associations.length
          : 0.0,
      'averageAnalysisConfidence': histories.isNotEmpty
          ? histories.map((h) => h.result.confidence).reduce((a, b) => a + b) / histories.length
          : 0.0,
    };
  }

  /// 计算一致性评分
  double _calculateConsistencyScore(List<ConsistencyIssue> issues, Map<String, dynamic> metrics) {
    double score = 1.0;
    
    // 根据问题严重程度扣分
    for (final issue in issues) {
      switch (issue.severity) {
        case ConsistencyIssueSeverity.critical:
          score -= 0.3;
          break;
        case ConsistencyIssueSeverity.high:
          score -= 0.2;
          break;
        case ConsistencyIssueSeverity.medium:
          score -= 0.1;
          break;
        case ConsistencyIssueSeverity.low:
          score -= 0.05;
          break;
      }
    }
    
    // 根据关联覆盖率调整
    final associationCoverage = metrics['associationCoverage'] as double;
    if (associationCoverage < 0.5) {
      score -= (0.5 - associationCoverage) * 0.4;
    }
    
    // 根据平均置信度调整
    final avgConfidence = (metrics['averageAnalysisConfidence'] as double) / 100.0;
    if (avgConfidence < 0.7) {
      score -= (0.7 - avgConfidence) * 0.2;
    }
    
    return score.clamp(0.0, 1.0);
  }

  /// 获取分析历史数据
  Future<List<AnalysisHistory>> _getAnalysisHistories(DateTime? startDate, DateTime? endDate) async {
    if (startDate != null && endDate != null) {
      return await HistoryManager.instance.getHistoriesByDateRange(startDate, endDate);
    }
    return await HistoryManager.instance.getAllHistories();
  }

  /// 获取生活记录数据（模拟实现）
  Future<List<LifeRecord>> _getLifeRecords(DateTime? startDate, DateTime? endDate) async {
    // 这里应该从实际的生活记录存储中获取数据
    // 目前返回空列表，实际实现时需要连接到生活记录数据源
    return [];
  }

  /// 自动修复一致性问题
  Future<List<String>> autoFixIssues(List<ConsistencyIssue> issues) async {
    final fixedIssues = <String>[];
    
    for (final issue in issues) {
      try {
        switch (issue.type) {
          case ConsistencyIssueType.duplicateRecord:
            // 自动删除重复关联
            if (await _fixDuplicateAssociations(issue)) {
              fixedIssues.add(issue.id);
            }
            break;
            
          case ConsistencyIssueType.invalidData:
            // 自动修复无效数据
            if (await _fixInvalidData(issue)) {
              fixedIssues.add(issue.id);
            }
            break;
            
          case ConsistencyIssueType.missingAssociation:
            // 自动创建缺失的关联
            if (await _fixMissingAssociation(issue)) {
              fixedIssues.add(issue.id);
            }
            break;
            
          default:
            // 其他类型的问题需要手动修复
            break;
        }
      } catch (e) {
        debugPrint('Failed to fix issue ${issue.id}: $e');
      }
    }
    
    return fixedIssues;
  }

  /// 修复重复关联
  Future<bool> _fixDuplicateAssociations(ConsistencyIssue issue) async {
    try {
      final associationIds = issue.details['associationIds'] as List<String>;
      if (associationIds.length <= 1) return false;
      
      // 保留第一个，删除其余的
      for (int i = 1; i < associationIds.length; i++) {
        DataAssociationService.instance.deleteAssociation(associationIds[i]);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 修复无效数据
  Future<bool> _fixInvalidData(ConsistencyIssue issue) async {
    // 这里可以实现一些简单的数据修复逻辑
    // 例如修正置信度范围、清理空标题等
    return false; // 暂时返回false，需要具体实现
  }

  /// 修复缺失关联
  Future<bool> _fixMissingAssociation(ConsistencyIssue issue) async {
    try {
      if (issue.analysisHistoryId == null) return false;
      
      // 这里可以调用生活记录生成器为分析历史创建对应的生活记录
      // 然后建立关联
      return false; // 暂时返回false，需要具体实现
    } catch (e) {
      return false;
    }
  }
}