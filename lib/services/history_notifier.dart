import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/analysis_history.dart';

/// 历史记录变化事件类型
enum HistoryEventType {
  added,    // 添加新记录
  deleted,  // 删除记录
  cleared,  // 清空所有记录
  updated,  // 更新记录
}

/// 历史记录变化事件
class HistoryEvent {
  final HistoryEventType type;
  final AnalysisHistory? history;
  final List<AnalysisHistory>? histories;
  final String? historyId;

  const HistoryEvent({
    required this.type,
    this.history,
    this.histories,
    this.historyId,
  });

  @override
  String toString() {
    return 'HistoryEvent(type: $type, historyId: $historyId)';
  }
}

/// 历史记录通知服务
/// 提供全局的历史记录变化通知机制，确保所有界面实时同步
class HistoryNotifier extends ChangeNotifier {
  static HistoryNotifier? _instance;
  static HistoryNotifier get instance {
    _instance ??= HistoryNotifier._();
    return _instance!;
  }

  HistoryNotifier._();

  // 历史记录变化流控制器
  final StreamController<HistoryEvent> _historyEventController = 
      StreamController<HistoryEvent>.broadcast();

  // 当前历史记录列表
  List<AnalysisHistory> _histories = [];

  /// 获取历史记录变化流
  Stream<HistoryEvent> get historyStream => _historyEventController.stream;

  /// 获取当前历史记录列表
  List<AnalysisHistory> get histories => List.unmodifiable(_histories);

  /// 获取历史记录数量
  int get count => _histories.length;

  /// 更新历史记录列表
  void updateHistories(List<AnalysisHistory> newHistories) {
    _histories = List.from(newHistories);
    notifyListeners();
    debugPrint('📊 HistoryNotifier: 历史记录列表已更新，共 ${_histories.length} 条记录');
  }

  /// 通知添加新的历史记录
  void notifyHistoryAdded(AnalysisHistory history) {
    _histories.insert(0, history); // 最新记录在前面
    final event = HistoryEvent(
      type: HistoryEventType.added,
      history: history,
    );
    _historyEventController.add(event);
    notifyListeners();
    debugPrint('📝 HistoryNotifier: 通知添加历史记录 - ${history.result.title}');
  }

  /// 通知删除历史记录
  void notifyHistoryDeleted(String historyId) {
    _histories.removeWhere((h) => h.id == historyId);
    final event = HistoryEvent(
      type: HistoryEventType.deleted,
      historyId: historyId,
    );
    _historyEventController.add(event);
    notifyListeners();
    debugPrint('🗑️ HistoryNotifier: 通知删除历史记录 - $historyId');
  }

  /// 通知清空所有历史记录
  void notifyHistoriesCleared() {
    _histories.clear();
    final event = HistoryEvent(
      type: HistoryEventType.cleared,
    );
    _historyEventController.add(event);
    notifyListeners();
    debugPrint('🗑️ HistoryNotifier: 通知清空所有历史记录');
  }

  /// 通知历史记录更新
  void notifyHistoryUpdated(AnalysisHistory updatedHistory) {
    final index = _histories.indexWhere((h) => h.id == updatedHistory.id);
    if (index != -1) {
      _histories[index] = updatedHistory;
      final event = HistoryEvent(
        type: HistoryEventType.updated,
        history: updatedHistory,
      );
      _historyEventController.add(event);
      notifyListeners();
      debugPrint('🔄 HistoryNotifier: 通知更新历史记录 - ${updatedHistory.result.title}');
    }
  }

  /// 根据模式筛选历史记录
  List<AnalysisHistory> getHistoriesByMode(String mode) {
    return _histories.where((h) => h.mode == mode).toList();
  }

  /// 获取实时分析历史记录
  List<AnalysisHistory> getRealtimeHistories() {
    return _histories.where((h) => h.isRealtimeAnalysis).toList();
  }

  /// 获取手动拍照历史记录
  List<AnalysisHistory> getManualHistories() {
    return _histories.where((h) => !h.isRealtimeAnalysis).toList();
  }

  /// 根据日期范围筛选历史记录
  List<AnalysisHistory> getHistoriesByDateRange(DateTime start, DateTime end) {
    return _histories.where((h) => 
      h.timestamp.isAfter(start) && h.timestamp.isBefore(end)
    ).toList();
  }

  /// 获取历史记录统计信息
  Map<String, dynamic> getStatistics() {
    final total = _histories.length;
    final realtimeCount = _histories.where((h) => h.isRealtimeAnalysis).length;
    final manualCount = total - realtimeCount;
    
    final modeStats = <String, int>{};
    for (final history in _histories) {
      modeStats[history.mode] = (modeStats[history.mode] ?? 0) + 1;
    }
    
    return {
      'total': total,
      'realtimeCount': realtimeCount,
      'manualCount': manualCount,
      'modeStats': modeStats,
      'oldestRecord': _histories.isNotEmpty ? _histories.last.timestamp : null,
      'newestRecord': _histories.isNotEmpty ? _histories.first.timestamp : null,
    };
  }

  @override
  void dispose() {
    _historyEventController.close();
    super.dispose();
  }
}