import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../config/device_config.dart';

/// 移动端性能管理器
/// 负责内存管理、电池优化和资源控制
class PerformanceManager {
  static final PerformanceManager _instance = PerformanceManager._internal();
  factory PerformanceManager() => _instance;
  PerformanceManager._internal();

  static PerformanceManager get instance => _instance;

  // 性能监控参数
  Timer? _memoryMonitorTimer;
  Timer? _batteryOptimizationTimer;
  bool _isLowPowerMode = false;
  int _currentMemoryUsage = 0;
  
  // 缓存管理
  final Map<String, DateTime> _imageCache = {};
  final Map<String, dynamic> _analysisCache = {};
  
  /// 初始化性能管理器
  Future<void> initialize() async {
    await _startMemoryMonitoring();
    await _enableBatteryOptimization();
    _setupLowPowerModeDetection();
  }

  /// 启动内存监控
  Future<void> _startMemoryMonitoring() async {
    _memoryMonitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkMemoryUsage();
      _cleanupCache();
    });
  }

  /// 检查内存使用情况
  void _checkMemoryUsage() {
    // 简化的内存检查，实际应用中可以使用更精确的方法
    if (_imageCache.length > 50) {
      _cleanupOldImages();
    }
    
    if (_analysisCache.length > 100) {
      _cleanupOldAnalysis();
    }
  }

  /// 清理旧图片缓存
  void _cleanupOldImages() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    _imageCache.forEach((key, timestamp) {
      if (now.difference(timestamp).inHours > 24) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _imageCache.remove(key);
      // 删除对应的文件
      _deleteImageFile(key);
    }
  }

  /// 清理旧分析结果缓存
  void _cleanupOldAnalysis() {
    if (_analysisCache.length > 100) {
      final keys = _analysisCache.keys.toList();
      // 保留最新的50个结果
      for (int i = 0; i < keys.length - 50; i++) {
        _analysisCache.remove(keys[i]);
      }
    }
  }

  /// 删除图片文件
  Future<void> _deleteImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('删除图片文件失败: $e');
    }
  }

  /// 启用电池优化
  Future<void> _enableBatteryOptimization() async {
    _batteryOptimizationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _optimizeBatteryUsage();
    });
  }

  /// 优化电池使用
  void _optimizeBatteryUsage() {
    if (_isLowPowerMode) {
      // 低电量模式下的优化策略
      _reduceCameraQuality();
      _limitBackgroundProcessing();
    }
  }

  /// 设置低电量模式检测
  void _setupLowPowerModeDetection() {
    // 这里可以通过battery_plus插件获取电池状态
    // 简化实现，假设电量低于20%时启用低电量模式
  }

  /// 降低相机质量
  void _reduceCameraQuality() {
    // 在低电量模式下降低相机分辨率和帧率
    // 这需要在相机初始化时应用
  }

  /// 限制后台处理
  void _limitBackgroundProcessing() {
    // 减少实时分析频率
    // 延迟非关键任务
  }

  /// 获取优化的相机配置
  Map<String, dynamic> getOptimizedCameraConfig() {
    if (_isLowPowerMode || DeviceConfig.isLowEndDevice()) {
      return {
        'resolution': ResolutionPreset.medium,
        'fps': 24,
        'enableAudio': false,
        'imageFormatGroup': ImageFormatGroup.jpeg,
      };
    } else {
      return {
        'resolution': ResolutionPreset.high,
        'fps': 30,
        'enableAudio': false,
        'imageFormatGroup': ImageFormatGroup.jpeg,
      };
    }
  }

  /// 压缩图片以节省内存和存储
  Future<File> compressImage(File originalFile) async {
    try {
      // 使用设备配置中的压缩质量
      final quality = DeviceConfig.imageCompressionQuality;
      
      // 这里应该使用image压缩库，简化实现
      // 实际应用中可以使用flutter_image_compress
      return originalFile;
    } catch (e) {
      debugPrint('图片压缩失败: $e');
      return originalFile;
    }
  }

  /// 缓存分析结果
  void cacheAnalysisResult(String imageHash, dynamic result) {
    _analysisCache[imageHash] = {
      'result': result,
      'timestamp': DateTime.now(),
    };
  }

  /// 获取缓存的分析结果
  dynamic getCachedAnalysisResult(String imageHash) {
    final cached = _analysisCache[imageHash];
    if (cached != null) {
      final timestamp = cached['timestamp'] as DateTime;
      // 缓存有效期1小时
      if (DateTime.now().difference(timestamp).inHours < 1) {
        return cached['result'];
      } else {
        _analysisCache.remove(imageHash);
      }
    }
    return null;
  }

  /// 设置低电量模式
  void setLowPowerMode(bool enabled) {
    _isLowPowerMode = enabled;
    if (enabled) {
      _optimizeBatteryUsage();
    }
  }

  /// 清理所有缓存
  Future<void> clearAllCache() async {
    // 清理图片缓存
    for (final imagePath in _imageCache.keys) {
      await _deleteImageFile(imagePath);
    }
    _imageCache.clear();
    
    // 清理分析结果缓存
    _analysisCache.clear();
  }

  /// 获取内存使用统计
  Map<String, int> getMemoryStats() {
    return {
      'imageCacheCount': _imageCache.length,
      'analysisCacheCount': _analysisCache.length,
      'estimatedMemoryUsage': _currentMemoryUsage,
    };
  }

  /// 清理缓存
  void _cleanupCache() {
    final now = DateTime.now();
    
    // 清理超过1小时的图片缓存
    _imageCache.removeWhere((key, timestamp) {
      final shouldRemove = now.difference(timestamp).inHours > 1;
      if (shouldRemove) {
        _deleteImageFile(key);
      }
      return shouldRemove;
    });
    
    // 清理超过30分钟的分析缓存
    _analysisCache.removeWhere((key, value) {
      final timestamp = value['timestamp'] as DateTime;
      return now.difference(timestamp).inMinutes > 30;
    });
  }

  /// 销毁性能管理器
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _batteryOptimizationTimer?.cancel();
    clearAllCache();
  }
}