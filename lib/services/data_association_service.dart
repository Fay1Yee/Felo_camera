import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/analysis_history.dart';
import '../screens/data_management/life_records_screen.dart';
import 'history_manager.dart';
import 'life_record_generator.dart';

/// 数据关联类型
enum AssociationType {
  direct,     // 直接关联：一个分析对应一个生活记录
  derived,    // 派生关联：从分析中推导出的生活记录
  aggregated, // 聚合关联：多个分析聚合成一个生活记录
}

/// 数据关联记录
class DataAssociation {
  final String id;
  final String analysisHistoryId;
  final String lifeRecordId;
  final AssociationType type;
  final DateTime createdAt;
  final double confidence; // 关联置信度
  final Map<String, dynamic> metadata;

  const DataAssociation({
    required this.id,
    required this.analysisHistoryId,
    required this.lifeRecordId,
    required this.type,
    required this.createdAt,
    required this.confidence,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analysisHistoryId': analysisHistoryId,
      'lifeRecordId': lifeRecordId,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'confidence': confidence,
      'metadata': metadata,
    };
  }

  factory DataAssociation.fromJson(Map<String, dynamic> json) {
    return DataAssociation(
      id: json['id'] as String,
      analysisHistoryId: json['analysisHistoryId'] as String,
      lifeRecordId: json['lifeRecordId'] as String,
      type: AssociationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AssociationType.direct,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// 关联统计信息
class AssociationStats {
  final int totalAssociations;
  final int directAssociations;
  final int derivedAssociations;
  final int aggregatedAssociations;
  final double averageConfidence;
  final DateTime? lastAssociationTime;
  final Map<String, int> associationsByMode;

  const AssociationStats({
    required this.totalAssociations,
    required this.directAssociations,
    required this.derivedAssociations,
    required this.aggregatedAssociations,
    required this.averageConfidence,
    this.lastAssociationTime,
    required this.associationsByMode,
  });
}

/// 数据关联服务
class DataAssociationService {
  static DataAssociationService? _instance;
  static DataAssociationService get instance {
    return _instance ??= DataAssociationService._();
  }
  
  DataAssociationService._();

  final List<DataAssociation> _associations = [];
  final StreamController<List<DataAssociation>> _associationsController = 
      StreamController<List<DataAssociation>>.broadcast();
  
  bool _initialized = false;

  /// 关联数据流
  Stream<List<DataAssociation>> get associationsStream => _associationsController.stream;

  /// 初始化服务
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // 这里可以从本地存储加载已有的关联数据
      // 暂时使用内存存储
      _initialized = true;
      debugPrint('✅ 数据关联服务初始化完成');
    } catch (e) {
      debugPrint('❌ 数据关联服务初始化失败: $e');
    }
  }

  /// 创建分析历史与生活记录的关联
  Future<DataAssociation> createAssociation({
    required String analysisHistoryId,
    required String lifeRecordId,
    required AssociationType type,
    double? confidence,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_initialized) await initialize();

    final association = DataAssociation(
      id: 'assoc_${DateTime.now().millisecondsSinceEpoch}',
      analysisHistoryId: analysisHistoryId,
      lifeRecordId: lifeRecordId,
      type: type,
      createdAt: DateTime.now(),
      confidence: confidence ?? 1.0,
      metadata: metadata ?? {},
    );

    _associations.add(association);
    _associationsController.add(List.from(_associations));
    
    debugPrint('🔗 创建数据关联: ${association.id}');
    return association;
  }

  /// 批量创建关联
  Future<List<DataAssociation>> createBatchAssociations(
    List<Map<String, dynamic>> associationData,
  ) async {
    final associations = <DataAssociation>[];
    
    for (final data in associationData) {
      final association = await createAssociation(
        analysisHistoryId: data['analysisHistoryId'],
        lifeRecordId: data['lifeRecordId'],
        type: data['type'] ?? AssociationType.direct,
        confidence: data['confidence'],
        metadata: data['metadata'],
      );
      associations.add(association);
    }
    
    return associations;
  }

  /// 自动生成生活记录并建立关联
  Future<List<DataAssociation>> autoGenerateAndAssociate({
    DateTime? startDate,
    DateTime? endDate,
    String? petId,
  }) async {
    if (!_initialized) await initialize();

    // 获取分析历史
    final histories = await HistoryManager.instance.getAllHistories();
    final filteredHistories = histories.where((history) {
      if (startDate != null && history.timestamp.isBefore(startDate)) return false;
      if (endDate != null && history.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();

    final associations = <DataAssociation>[];

    // 为每个分析历史生成对应的生活记录并建立关联
    for (final history in filteredHistories) {
      // 检查是否已经存在关联
      final existingAssociation = _associations.where(
        (assoc) => assoc.analysisHistoryId == history.id,
      ).firstOrNull;
      
      if (existingAssociation != null) {
        debugPrint('⚠️ 分析历史 ${history.id} 已存在关联，跳过');
        continue;
      }

      // 生成生活记录
      final generator = LifeRecordGenerator.instance;
      final lifeRecords = await generator.generateLifeRecordsFromHistory(
        startDate: history.timestamp,
        endDate: history.timestamp.add(const Duration(seconds: 1)),
        petId: petId,
      );

      if (lifeRecords.isNotEmpty) {
        final lifeRecord = lifeRecords.first;
        
        // 创建关联
        final association = await createAssociation(
          analysisHistoryId: history.id,
          lifeRecordId: lifeRecord.id,
          type: AssociationType.derived,
          confidence: _calculateAssociationConfidence(history, lifeRecord),
          metadata: {
            'generationMethod': 'auto',
            'analysisMode': history.mode,
            'recordType': lifeRecord.type.name,
          },
        );
        
        associations.add(association);
      }
    }

    debugPrint('🔗 自动生成并关联了 ${associations.length} 条记录');
    return associations;
  }

  /// 计算关联置信度
  double _calculateAssociationConfidence(AnalysisHistory history, LifeRecord record) {
    double confidence = 0.0;
    
    // 基础置信度来自分析结果
    confidence += history.result.confidence / 100.0 * 0.6;
    
    // 时间匹配度
    final timeDiff = history.timestamp.difference(record.timestamp).abs();
    if (timeDiff.inMinutes <= 5) {
      confidence += 0.3;
    } else if (timeDiff.inHours <= 1) {
      confidence += 0.2;
    } else {
      confidence += 0.1;
    }
    
    // 内容匹配度（基于标题和描述的相似性）
    if (record.title.contains(history.result.title) || 
        history.result.title.contains(record.title)) {
      confidence += 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  /// 获取指定分析历史的关联记录
  List<DataAssociation> getAssociationsByAnalysisId(String analysisHistoryId) {
    return _associations.where((assoc) => assoc.analysisHistoryId == analysisHistoryId).toList();
  }

  /// 获取指定生活记录的关联记录
  List<DataAssociation> getAssociationsByLifeRecordId(String lifeRecordId) {
    return _associations.where((assoc) => assoc.lifeRecordId == lifeRecordId).toList();
  }

  /// 获取指定类型的关联记录
  List<DataAssociation> getAssociationsByType(AssociationType type) {
    return _associations.where((assoc) => assoc.type == type).toList();
  }

  /// 获取关联统计信息
  AssociationStats getAssociationStats() {
    if (_associations.isEmpty) {
      return const AssociationStats(
        totalAssociations: 0,
        directAssociations: 0,
        derivedAssociations: 0,
        aggregatedAssociations: 0,
        averageConfidence: 0.0,
        associationsByMode: {},
      );
    }

    final directCount = _associations.where((a) => a.type == AssociationType.direct).length;
    final derivedCount = _associations.where((a) => a.type == AssociationType.derived).length;
    final aggregatedCount = _associations.where((a) => a.type == AssociationType.aggregated).length;
    
    final totalConfidence = _associations.map((a) => a.confidence).reduce((a, b) => a + b);
    final averageConfidence = totalConfidence / _associations.length;
    
    final lastAssociation = _associations.isNotEmpty 
        ? _associations.map((a) => a.createdAt).reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    // 统计各模式的关联数量（需要从分析历史中获取模式信息）
    final associationsByMode = <String, int>{};
    // 这里简化处理，实际应该查询分析历史获取模式信息
    
    return AssociationStats(
      totalAssociations: _associations.length,
      directAssociations: directCount,
      derivedAssociations: derivedCount,
      aggregatedAssociations: aggregatedCount,
      averageConfidence: averageConfidence,
      lastAssociationTime: lastAssociation,
      associationsByMode: associationsByMode,
    );
  }

  /// 删除关联
  Future<void> deleteAssociation(String associationId) async {
    _associations.removeWhere((assoc) => assoc.id == associationId);
    _associationsController.add(List.from(_associations));
    debugPrint('🗑️ 删除关联: $associationId');
  }

  /// 删除指定分析历史的所有关联
  Future<void> deleteAssociationsByAnalysisId(String analysisHistoryId) async {
    final removedCount = _associations.length;
    _associations.removeWhere((assoc) => assoc.analysisHistoryId == analysisHistoryId);
    final currentCount = _associations.length;
    
    if (removedCount != currentCount) {
      _associationsController.add(List.from(_associations));
      debugPrint('🗑️ 删除分析历史 $analysisHistoryId 的 ${removedCount - currentCount} 个关联');
    }
  }

  /// 清空所有关联
  Future<void> clearAllAssociations() async {
    _associations.clear();
    _associationsController.add(List.from(_associations));
    debugPrint('🗑️ 清空所有关联');
  }

  /// 验证关联的有效性
  Future<List<String>> validateAssociations() async {
    final invalidAssociations = <String>[];
    final allHistories = await HistoryManager.instance.getAllHistories();
    final historyIds = allHistories.map((h) => h.id).toSet();

    for (final association in _associations) {
      // 检查分析历史是否存在
      if (!historyIds.contains(association.analysisHistoryId)) {
        invalidAssociations.add(association.id);
        debugPrint('⚠️ 无效关联: ${association.id} - 分析历史不存在');
      }
      
      // 这里可以添加更多验证逻辑，比如检查生活记录是否存在等
    }

    return invalidAssociations;
  }

  /// 修复无效关联
  Future<void> repairInvalidAssociations() async {
    final invalidIds = await validateAssociations();
    for (final id in invalidIds) {
      await deleteAssociation(id);
    }
    debugPrint('🔧 修复了 ${invalidIds.length} 个无效关联');
  }

  /// 获取所有关联
  List<DataAssociation> getAllAssociations() {
    return List.from(_associations);
  }

  /// 释放资源
  void dispose() {
    _associationsController.close();
  }
}