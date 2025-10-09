import 'ai_result.dart';

/// 分析历史记录模型
class AnalysisHistory {
  final String id;
  final DateTime timestamp;
  final AIResult result;
  final String? imagePath;
  final String mode;
  final bool isRealtimeAnalysis;
  
  const AnalysisHistory({
    required this.id,
    required this.timestamp,
    required this.result,
    this.imagePath,
    required this.mode,
    this.isRealtimeAnalysis = false,
  });
  
  /// 从JSON创建实例
  factory AnalysisHistory.fromJson(Map<String, dynamic> json) {
    return AnalysisHistory(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      result: AIResult.fromJson(json['result'] as Map<String, dynamic>),
      imagePath: json['imagePath'] as String?,
      mode: json['mode'] as String,
      isRealtimeAnalysis: json['isRealtimeAnalysis'] as bool? ?? false,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'result': result.toJson(),
      'imagePath': imagePath,
      'mode': mode,
      'isRealtimeAnalysis': isRealtimeAnalysis,
    };
  }
  
  /// 创建副本
  AnalysisHistory copyWith({
    String? id,
    DateTime? timestamp,
    AIResult? result,
    String? imagePath,
    String? mode,
    bool? isRealtimeAnalysis,
  }) {
    return AnalysisHistory(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      result: result ?? this.result,
      imagePath: imagePath ?? this.imagePath,
      mode: mode ?? this.mode,
      isRealtimeAnalysis: isRealtimeAnalysis ?? this.isRealtimeAnalysis,
    );
  }
  
  @override
  String toString() {
    return 'AnalysisHistory(id: $id, timestamp: $timestamp, result: $result, mode: $mode)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisHistory &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.result == result &&
        other.imagePath == imagePath &&
        other.mode == mode &&
        other.isRealtimeAnalysis == isRealtimeAnalysis;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      id,
      timestamp,
      result,
      imagePath,
      mode,
      isRealtimeAnalysis,
    );
  }
}