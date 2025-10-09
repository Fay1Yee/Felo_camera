import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_result.dart';

/// API结果缓存服务
/// 通过图像哈希值缓存分析结果，避免重复分析相同或相似的图像
class ResultCache {
  static ResultCache? _instance;
  static ResultCache get instance {
    _instance ??= ResultCache._();
    return _instance!;
  }
  
  ResultCache._();
  
  // 缓存配置
  static const String _cacheKeyPrefix = 'ai_result_cache_';
  static const int _maxCacheSize = 100; // 最大缓存条目数
  static const Duration _cacheExpiry = Duration(days: 7); // 缓存过期时间
  
  // 内存缓存
  final Map<String, CachedResult> _memoryCache = {};
  
  /// 获取缓存的分析结果
  Future<AIResult?> getCachedResult(File imageFile, String mode) async {
    try {
      // 1. 计算图像哈希
      final imageHash = await _calculateImageHash(imageFile);
      final cacheKey = _generateCacheKey(imageHash, mode);
      
      // 2. 检查内存缓存
      if (_memoryCache.containsKey(cacheKey)) {
        final cached = _memoryCache[cacheKey]!;
        if (!_isExpired(cached.timestamp)) {
          debugPrint('🎯 命中内存缓存: $cacheKey');
          return cached.result;
        } else {
          _memoryCache.remove(cacheKey);
        }
      }
      
      // 3. 检查持久化缓存
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);
      
      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson);
        final timestamp = DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
        
        if (!_isExpired(timestamp)) {
          final result = AIResult.fromJson(cachedData['result']);
          
          // 加载到内存缓存
          _memoryCache[cacheKey] = CachedResult(
            result: result,
            timestamp: timestamp,
          );
          
          debugPrint('💾 命中持久化缓存: $cacheKey');
          return result;
        } else {
          // 删除过期缓存
          await prefs.remove(cacheKey);
        }
      }
      
      return null;
      
    } catch (e) {
      debugPrint('⚠️ 缓存读取失败: $e');
      return null;
    }
  }
  
  /// 缓存分析结果
  Future<void> cacheResult(File imageFile, String mode, AIResult result) async {
    try {
      // 1. 计算图像哈希
      final imageHash = await _calculateImageHash(imageFile);
      final cacheKey = _generateCacheKey(imageHash, mode);
      
      final cachedResult = CachedResult(
        result: result,
        timestamp: DateTime.now(),
      );
      
      // 2. 保存到内存缓存
      _memoryCache[cacheKey] = cachedResult;
      
      // 3. 保存到持久化缓存
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'result': result.toJson(),
        'timestamp': cachedResult.timestamp.millisecondsSinceEpoch,
      };
      
      await prefs.setString(cacheKey, jsonEncode(cacheData));
      
      // 4. 清理过期缓存
      await _cleanupExpiredCache();
      
      debugPrint('💾 结果已缓存: $cacheKey');
      
    } catch (e) {
      debugPrint('⚠️ 缓存保存失败: $e');
    }
  }
  
  /// 计算图像哈希值
  Future<String> _calculateImageHash(File imageFile) async {
    try {
      // 读取图像文件
      final imageBytes = await imageFile.readAsBytes();
      
      // 使用SHA-256计算哈希
      final digest = sha256.convert(imageBytes);
      return digest.toString();
      
    } catch (e) {
      debugPrint('⚠️ 图像哈希计算失败: $e');
      // 使用文件路径和修改时间作为备用标识
      final stat = await imageFile.stat();
      return '${imageFile.path}_${stat.modified.millisecondsSinceEpoch}'.hashCode.toString();
    }
  }
  
  /// 生成缓存键
  String _generateCacheKey(String imageHash, String mode) {
    return '$_cacheKeyPrefix${mode}_$imageHash';
  }
  
  /// 检查缓存是否过期
  bool _isExpired(DateTime timestamp) {
    return DateTime.now().difference(timestamp) > _cacheExpiry;
  }
  
  /// 清理过期缓存
  Future<void> _cleanupExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix)).toList();
      
      // 清理内存缓存中的过期项
      final expiredMemoryKeys = _memoryCache.entries
          .where((entry) => _isExpired(entry.value.timestamp))
          .map((entry) => entry.key)
          .toList();
      
      for (final key in expiredMemoryKeys) {
        _memoryCache.remove(key);
      }
      
      // 清理持久化缓存中的过期项
      final expiredKeys = <String>[];
      
      for (final key in keys) {
        final cachedJson = prefs.getString(key);
        if (cachedJson != null) {
          try {
            final cachedData = jsonDecode(cachedJson);
            final timestamp = DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
            
            if (_isExpired(timestamp)) {
              expiredKeys.add(key);
            }
          } catch (e) {
            // 无法解析的缓存项也删除
            expiredKeys.add(key);
          }
        }
      }
      
      // 删除过期的缓存项
      for (final key in expiredKeys) {
        await prefs.remove(key);
      }
      
      // 如果缓存项过多，删除最旧的项
      final remainingKeys = keys.where((key) => !expiredKeys.contains(key)).toList();
      if (remainingKeys.length > _maxCacheSize) {
        final keysToRemove = remainingKeys.take(remainingKeys.length - _maxCacheSize);
        for (final key in keysToRemove) {
          await prefs.remove(key);
          _memoryCache.remove(key);
        }
      }
      
      if (expiredKeys.isNotEmpty) {
        debugPrint('🧹 清理了 ${expiredKeys.length} 个过期缓存项');
      }
      
    } catch (e) {
      debugPrint('⚠️ 缓存清理失败: $e');
    }
  }
  
  /// 清空所有缓存
  Future<void> clearAllCache() async {
    try {
      _memoryCache.clear();
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix)).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      debugPrint('🧹 已清空所有缓存');
      
    } catch (e) {
      debugPrint('⚠️ 清空缓存失败: $e');
    }
  }
  
  /// 获取缓存统计信息
  Future<CacheStats> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix)).toList();
      
      int validCount = 0;
      int expiredCount = 0;
      
      for (final key in keys) {
        final cachedJson = prefs.getString(key);
        if (cachedJson != null) {
          try {
            final cachedData = jsonDecode(cachedJson);
            final timestamp = DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
            
            if (_isExpired(timestamp)) {
              expiredCount++;
            } else {
              validCount++;
            }
          } catch (e) {
            expiredCount++;
          }
        }
      }
      
      return CacheStats(
        totalCount: keys.length,
        validCount: validCount,
        expiredCount: expiredCount,
        memoryCount: _memoryCache.length,
      );
      
    } catch (e) {
      debugPrint('⚠️ 获取缓存统计失败: $e');
      return CacheStats(
        totalCount: 0,
        validCount: 0,
        expiredCount: 0,
        memoryCount: _memoryCache.length,
      );
    }
  }
  
  /// 预热缓存（可选功能）
  Future<void> preloadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix)).toList();
      
      int loadedCount = 0;
      
      for (final key in keys.take(20)) { // 只预加载前20个
        final cachedJson = prefs.getString(key);
        if (cachedJson != null) {
          try {
            final cachedData = jsonDecode(cachedJson);
            final timestamp = DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
            
            if (!_isExpired(timestamp)) {
              final result = AIResult.fromJson(cachedData['result']);
              _memoryCache[key] = CachedResult(
                result: result,
                timestamp: timestamp,
              );
              loadedCount++;
            }
          } catch (e) {
            // 忽略无法解析的缓存项
          }
        }
      }
      
      if (loadedCount > 0) {
        debugPrint('🚀 预加载了 $loadedCount 个缓存项到内存');
      }
      
    } catch (e) {
      debugPrint('⚠️ 缓存预加载失败: $e');
    }
  }
}

/// 缓存结果包装类
class CachedResult {
  final AIResult result;
  final DateTime timestamp;
  
  CachedResult({
    required this.result,
    required this.timestamp,
  });
}

/// 缓存统计信息
class CacheStats {
  final int totalCount;
  final int validCount;
  final int expiredCount;
  final int memoryCount;
  
  CacheStats({
    required this.totalCount,
    required this.validCount,
    required this.expiredCount,
    required this.memoryCount,
  });
  
  @override
  String toString() {
    return 'CacheStats(total: $totalCount, valid: $validCount, expired: $expiredCount, memory: $memoryCount)';
  }
}

/// AIResult扩展，添加JSON序列化支持
extension AIResultJson on AIResult {
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'confidence': confidence,
      'subInfo': subInfo,
    };
  }
  
  static AIResult fromJson(Map<String, dynamic> json) {
    return AIResult(
      title: json['title'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      subInfo: json['subInfo'],
    );
  }
}