import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_history.dart';
import '../models/ai_result.dart';
import 'history_notifier.dart';

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
      if (kIsWeb) {
        // Web平台使用SharedPreferences
        debugPrint('🌐 Web平台：使用SharedPreferences存储历史记录');
        await _loadHistoriesFromPrefs();
      } else {
        // 移动平台使用文件系统
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
      }
      
      // 初始化通知器
      HistoryNotifier.instance.updateHistories(_histories);
      
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
    await addHistoryWithTimestamp(
      result: result,
      mode: mode,
      imagePath: imagePath,
      isRealtimeAnalysis: isRealtimeAnalysis,
      timestamp: DateTime.now(),
    );
  }

  /// 添加带自定义时间戳的分析记录
  Future<void> addHistoryWithTimestamp({
    required AIResult result,
    required String mode,
    String? imagePath,
    bool isRealtimeAnalysis = false,
    DateTime? timestamp,
  }) async {
    if (!_initialized) await initialize();
    
    // 为移动端优化：在后台线程检查图片文件是否存在
    String? validImagePath = imagePath;
    if (imagePath != null) {
      final exists = await compute(_checkFileExists, imagePath);
      if (!exists) {
        debugPrint('⚠️ 图片文件不存在，将不保存图片路径: $imagePath');
        validImagePath = null;
      }
    }
    
    // 保存实际选择的模式
    final String savedMode = mode;
    final DateTime recordTimestamp = timestamp ?? DateTime.now();
    
    final history = AnalysisHistory(
      id: recordTimestamp.millisecondsSinceEpoch.toString(),
      timestamp: recordTimestamp,
      result: result,
      imagePath: validImagePath,
      mode: savedMode,
      isRealtimeAnalysis: isRealtimeAnalysis,
    );
    
    _histories.insert(0, history); // 最新的记录在前面
    
    // 移动端优化：限制历史记录数量，避免占用过多存储空间
    const maxHistories = 500; // 减少到500条以节省移动设备存储
    if (_histories.length > maxHistories) {
      // 删除旧记录时，在后台线程清理对应的图片文件
      final oldHistories = _histories.skip(maxHistories).toList();
      final imagePaths = oldHistories
          .where((h) => h.imagePath != null)
          .map((h) => h.imagePath!)
          .toList();
      
      if (imagePaths.isNotEmpty) {
        // 在后台线程清理图片文件，不阻塞主线程
        compute(_cleanupImageFiles, imagePaths).catchError((e) {
          debugPrint('⚠️ 后台清理图片文件失败: $e');
        });
      }
      
      _histories = _histories.take(maxHistories).toList();
    }
    
    await _saveHistories();
    
    // 通知添加新记录
    HistoryNotifier.instance.notifyHistoryAdded(history);
    
    debugPrint('📝 添加分析历史记录: ${result.title} ($savedMode模式)');
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
    
    // 通知删除记录
    HistoryNotifier.instance.notifyHistoryDeleted(id);
    
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
    
    // 通知清空所有记录
    HistoryNotifier.instance.notifyHistoriesCleared();
    
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

      // 在后台线程读取文件以避免主线程阻塞
      final List<dynamic> jsonList = await compute(_loadHistoriesFromFile, _historyFile!.path);
      
      if (jsonList.isEmpty) {
        debugPrint('📝 历史记录文件为空，创建空列表');
        _histories = [];
        return;
      }

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

  /// 在后台线程从文件加载历史记录
  static Future<List<dynamic>> _loadHistoriesFromFile(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      return [];
    }
    
    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return [];
    }

    return jsonDecode(content) as List<dynamic>;
  }

  /// 在后台线程检查文件是否存在
  static Future<bool> _checkFileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// 在后台线程清理图片文件
  static Future<void> _cleanupImageFiles(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      try {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
          debugPrint('🗑️ 清理旧图片文件: $imagePath');
        }
      } catch (e) {
        debugPrint('⚠️ 清理图片文件失败: $imagePath - $e');
      }
    }
  }
  
  /// 保存历史记录
  Future<void> _saveHistories() async {
    try {
      if (kIsWeb) {
        await _saveHistoriesToPrefs();
      } else {
        // 在后台线程执行文件I/O操作以避免主线程阻塞
        await compute(_saveHistoriesToFile, {
          'filePath': _historyFile!.path,
          'histories': _histories.map((h) => h.toJson()).toList(),
        });
        
        debugPrint('💾 历史记录保存成功: ${_historyFile!.path}');
        debugPrint('📊 保存了 ${_histories.length} 条记录');
      }
    } catch (e) {
      debugPrint('❌ 保存历史记录失败: $e');
      debugPrint('📁 文件路径: ${_historyFile?.path}');
    }
  }

  /// 在后台线程保存历史记录到文件
  static Future<void> _saveHistoriesToFile(Map<String, dynamic> params) async {
    final String filePath = params['filePath'];
    final List<dynamic> histories = params['histories'];
    
    final file = File(filePath);
    
    // 确保文件目录存在
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    
    final content = json.encode(histories);
    await file.writeAsString(content);
  }
  
  /// 检查是否已初始化
  bool get isInitialized => _initialized;
  
  /// 获取历史记录数量
  int get count => _histories.length;

  /// Web平台：从SharedPreferences加载历史记录
  Future<void> _loadHistoriesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString('analysis_history');
      
      if (content == null || content.trim().isEmpty) {
        debugPrint('📝 Web存储中没有历史记录，创建空列表');
        _histories = [];
        return;
      }

      final List<dynamic> jsonList = jsonDecode(content);
      _histories = jsonList
          .map((json) => AnalysisHistory.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('📂 Web平台成功加载历史记录: ${_histories.length} 条');
      
      // 验证加载的数据
      for (int i = 0; i < _histories.length && i < 3; i++) {
        final history = _histories[i];
        debugPrint('📋 记录 ${i + 1}: ${history.result.title} (${history.mode})');
      }
      
    } catch (e) {
      debugPrint('❌ Web平台加载历史记录失败: $e');
      _histories = []; // 确保有一个空列表
    }
  }

  /// Web平台：保存历史记录到SharedPreferences
  Future<void> _saveHistoriesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _histories.map((h) => h.toJson()).toList();
      final content = json.encode(jsonList);
      await prefs.setString('analysis_history', content);
      
      debugPrint('💾 Web平台历史记录保存成功');
      debugPrint('📊 保存了 ${_histories.length} 条记录');
    } catch (e) {
      debugPrint('❌ Web平台保存历史记录失败: $e');
    }
  }
}