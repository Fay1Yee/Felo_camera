import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/analysis_history.dart';
import '../models/ai_result.dart';

/// 分析历史管理服务
class HistoryManager {
  static HistoryManager? _instance;
  static HistoryManager get instance {
    _instance ??= HistoryManager._();
    return _instance!;
  }
  
  HistoryManager._();
  
  List<AnalysisHistory> _histories = [];
  File? _historyFile;
  bool _initialized = false;
  
  /// 初始化历史管理器
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      debugPrint('📁 应用程序文档目录: ${directory.path}');
      
      _historyFile = File('${directory.path}/analysis_history.json');
      debugPrint('📄 历史记录文件路径: ${_historyFile!.path}');
      
      if (await _historyFile!.exists()) {
        await _loadHistories();
      } else {
        debugPrint('📝 历史记录文件不存在，将创建新文件');
        // 创建空的历史记录文件
        await _saveHistories();
      }
      
      _initialized = true;
      debugPrint('✅ 历史记录管理器初始化完成，已加载 ${_histories.length} 条记录');
    } catch (e) {
      debugPrint('❌ 历史记录管理器初始化失败: $e');
      _initialized = true; // 即使失败也标记为已初始化，避免重复尝试
    }
  }
  
  /// 添加新的分析记录
  Future<void> addHistory({
    required AIResult result,
    required String mode,
    String? imagePath,
    bool isRealtimeAnalysis = false,
  }) async {
    if (!_initialized) await initialize();
    
    // 为移动端优化：检查图片文件是否存在，如果不存在则不保存路径
    String? validImagePath = imagePath;
    if (imagePath != null) {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('⚠️ 图片文件不存在，将不保存图片路径: $imagePath');
        validImagePath = null;
      }
    }
    
    final history = AnalysisHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      result: result,
      imagePath: validImagePath,
      mode: mode,
      isRealtimeAnalysis: isRealtimeAnalysis,
    );
    
    _histories.insert(0, history); // 最新的记录在前面
    
    // 移动端优化：限制历史记录数量，避免占用过多存储空间
    const maxHistories = 500; // 减少到500条以节省移动设备存储
    if (_histories.length > maxHistories) {
      // 删除旧记录时，同时清理对应的图片文件
      final oldHistories = _histories.skip(maxHistories).toList();
      for (final oldHistory in oldHistories) {
        if (oldHistory.imagePath != null) {
          try {
            final oldImageFile = File(oldHistory.imagePath!);
            if (await oldImageFile.exists()) {
              await oldImageFile.delete();
              debugPrint('🗑️ 清理旧图片文件: ${oldHistory.imagePath}');
            }
          } catch (e) {
            debugPrint('⚠️ 清理旧图片文件失败: $e');
          }
        }
      }
      _histories = _histories.take(maxHistories).toList();
    }
    
    await _saveHistories();
    
    debugPrint('📝 添加分析历史记录: ${result.title} (${mode}模式)');
  }
  
  /// 获取所有历史记录
  Future<List<AnalysisHistory>> getAllHistories() async {
    if (!_initialized) await initialize();
    return List.from(_histories);
  }

  /// 根据模式筛选历史记录
  Future<List<AnalysisHistory>> getHistoriesByMode(String mode) async {
    if (!_initialized) await initialize();
    return _histories.where((h) => h.mode == mode).toList();
  }

  /// 获取实时分析历史记录
  Future<List<AnalysisHistory>> getRealtimeHistories() async {
    if (!_initialized) await initialize();
    return _histories.where((h) => h.isRealtimeAnalysis).toList();
  }

  /// 获取手动拍照历史记录
  Future<List<AnalysisHistory>> getManualHistories() async {
    if (!_initialized) await initialize();
    return _histories.where((h) => !h.isRealtimeAnalysis).toList();
  }

  /// 根据日期范围筛选历史记录
  Future<List<AnalysisHistory>> getHistoriesByDateRange(DateTime start, DateTime end) async {
    if (!_initialized) await initialize();
    return _histories.where((h) => 
      h.timestamp.isAfter(start) && h.timestamp.isBefore(end)
    ).toList();
  }
  
  /// 删除指定的历史记录
  Future<void> deleteHistory(String id) async {
    // 查找要删除的记录
    final historyToDelete = _histories.firstWhere(
      (h) => h.id == id,
      orElse: () => throw Exception('历史记录不存在'),
    );
    
    // 删除对应的图片文件
    if (historyToDelete.imagePath != null) {
      try {
        final imageFile = File(historyToDelete.imagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
          debugPrint('🗑️ 删除图片文件: ${historyToDelete.imagePath}');
        }
      } catch (e) {
        debugPrint('⚠️ 删除图片文件失败: $e');
      }
    }
    
    _histories.removeWhere((h) => h.id == id);
    await _saveHistories();
    debugPrint('🗑️ 删除历史记录: $id');
  }
  
  /// 清空所有历史记录
  Future<void> clearAllHistories() async {
    // 删除所有图片文件
    for (final history in _histories) {
      if (history.imagePath != null) {
        try {
          final imageFile = File(history.imagePath!);
          if (await imageFile.exists()) {
            await imageFile.delete();
            debugPrint('🗑️ 清理图片文件: ${history.imagePath}');
          }
        } catch (e) {
          debugPrint('⚠️ 清理图片文件失败: $e');
        }
      }
    }
    
    _histories.clear();
    await _saveHistories();
    debugPrint('🗑️ 清空所有历史记录');
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
  
  /// 加载历史记录
  Future<void> _loadHistories() async {
    try {
      if (_historyFile == null || !await _historyFile!.exists()) {
        debugPrint('📝 历史记录文件不存在，创建空列表');
        _histories = [];
        return;
      }

      final content = await _historyFile!.readAsString();
      if (content.trim().isEmpty) {
        debugPrint('📝 历史记录文件为空，创建空列表');
        _histories = [];
        return;
      }

      final List<dynamic> jsonList = jsonDecode(content);
      _histories = jsonList
          .map((json) => AnalysisHistory.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📂 成功加载历史记录: ${_histories.length} 条');
      
      // 验证加载的数据
      for (int i = 0; i < _histories.length && i < 3; i++) {
        final history = _histories[i];
        debugPrint('📋 记录 ${i + 1}: ${history.result.title} (${history.mode})');
      }
      
    } catch (e) {
      debugPrint('❌ 加载历史记录失败: $e');
      debugPrint('📁 文件路径: ${_historyFile?.path}');
      _histories = []; // 确保有一个空列表
    }
  }
  
  /// 保存历史记录
  Future<void> _saveHistories() async {
    try {
      // 确保文件目录存在
      if (_historyFile != null && !await _historyFile!.parent.exists()) {
        await _historyFile!.parent.create(recursive: true);
      }
      
      final jsonList = _histories.map((h) => h.toJson()).toList();
      final content = json.encode(jsonList);
      await _historyFile!.writeAsString(content);
      
      debugPrint('💾 历史记录保存成功: ${_historyFile!.path}');
      debugPrint('📊 保存了 ${_histories.length} 条记录');
    } catch (e) {
      debugPrint('❌ 保存历史记录失败: $e');
      debugPrint('📁 文件路径: ${_historyFile?.path}');
    }
  }
  
  /// 检查是否已初始化
  bool get isInitialized => _initialized;
  
  /// 获取历史记录数量
  int get count => _histories.length;
}