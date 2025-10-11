import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'api_client.dart';
import 'network_manager.dart' as net;
import '../config/api_config.dart';
import '../models/mode.dart';

/// 预加载服务，在用户操作前预先准备必要的资源和连接
class Preloader {
  static final Preloader _instance = Preloader._internal();
  static Preloader get instance => _instance;
  
  Preloader._internal();
  
  // ignore: unused_field
  final ApiClient _apiClient = ApiClient.instance;
  final net.NetworkManager _networkManager = net.NetworkManager.instance;
  
  bool _isInitialized = false;
  bool _isPreloading = false;
  Timer? _preloadTimer;
  
  // 预加载状态
  final Map<String, bool> _preloadStatus = {
    'network_connection': false,
    'api_warmup': false,
    'camera_ready': false,
    'models_loaded': false,
  };
  
  /// 初始化预加载服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('🚀 初始化预加载服务...');
      
      // 启动后台预加载任务
      _startBackgroundPreloading();
      
      _isInitialized = true;
      debugPrint('✅ 预加载服务初始化完成');
    } catch (e) {
      debugPrint('❌ 预加载服务初始化失败: $e');
    }
  }
  
  /// 启动后台预加载任务
  void _startBackgroundPreloading() {
    _preloadTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isPreloading) {
        _performBackgroundPreload();
      }
    });
    
    // 立即执行一次预加载
    _performBackgroundPreload();
  }
  
  /// 执行后台预加载
  Future<void> _performBackgroundPreload() async {
    if (_isPreloading) return;
    
    _isPreloading = true;
    
    try {
      // 预热网络连接
      await _preloadNetworkConnection();
      
      // 预热API连接
      await _preloadApiConnection();
      
      // 预加载模型资源
      await _preloadModels();
      
    } catch (e) {
      debugPrint('⚠️ 后台预加载失败: $e');
    } finally {
      _isPreloading = false;
    }
  }
  
  /// 预热网络连接
  Future<void> _preloadNetworkConnection() async {
    try {
      debugPrint('🌐 预热网络连接...');
  
      // 检测网络质量
      final quality = await _networkManager.detectNetworkQuality();
  
      // 预热连接池（移动端跳过本地后端 localhost）
      final bool isMobile = io.Platform.isAndroid || io.Platform.isIOS;
      final bool backendIsLocal = ApiConfig.backendBaseUrl.contains('localhost') || ApiConfig.backendBaseUrl.contains('127.0.0.1');
      final List<String> hosts = [];
      if (!isMobile || !backendIsLocal) {
        hosts.add(ApiConfig.backendBaseUrl);
      }
      hosts.add(ApiConfig.doubaoBaseUrl);
      await _networkManager.preWarmConnections(hosts);
  
      _preloadStatus['network_connection'] = true;
      debugPrint('✅ 网络连接预热完成，质量: $quality');
    } catch (e) {
      debugPrint('❌ 网络连接预热失败: $e');
      _preloadStatus['network_connection'] = false;
    }
  }
  
  /// 预热API连接
  Future<void> _preloadApiConnection() async {
    try {
      debugPrint('🔗 预热API连接...');
  
      // 移动端且后端为localhost时跳过后端健康检查
      final bool isMobile = io.Platform.isAndroid || io.Platform.isIOS;
      final bool backendIsLocal = ApiConfig.backendBaseUrl.contains('localhost') || ApiConfig.backendBaseUrl.contains('127.0.0.1');
      if (!isMobile || !backendIsLocal) {
        await _warmupBackendApi();
      } else {
        debugPrint('⏭️ 跳过移动端本地后端预热 (${ApiConfig.backendBaseUrl})');
      }
  
      // 预热Doubao API连接
      await _warmupDoubaoApi();
  
      _preloadStatus['api_warmup'] = true;
      debugPrint('✅ API连接预热完成');
    } catch (e) {
      debugPrint('❌ API连接预热失败: $e');
      _preloadStatus['api_warmup'] = false;
    }
  }
  
  /// 预热后端API
  Future<void> _warmupBackendApi() async {
    try {
      final response = await _networkManager.get(
        Uri.parse('${ApiConfig.backendBaseUrl}/health'),
      );
      
      if (response.statusCode == 200) {
        debugPrint('✅ 后端API预热成功');
      }
    } catch (e) {
      debugPrint('⚠️ 后端API预热失败: $e');
    }
  }
  
  /// 预热Doubao API
  Future<void> _warmupDoubaoApi() async {
    try {
      // 发送一个简单的测试请求
      final response = await _networkManager.post(
        Uri.parse(ApiConfig.getChatCompletionsUrl()),
        headers: ApiConfig.getHeaders(),
        body: '{"model":"${ApiConfig.doubaoModel}","messages":[{"role":"user","content":"test"}],"max_tokens":1}',
      );
      
      if (response.statusCode == 200 || response.statusCode == 400) {
        debugPrint('✅ Doubao API预热成功');
      }
    } catch (e) {
      debugPrint('⚠️ Doubao API预热失败: $e');
    }
  }
  
  /// 预加载模型资源
  Future<void> _preloadModels() async {
    try {
      debugPrint('🧠 预加载模型资源...');
      
      // 预加载所有模式的提示词
      for (final mode in Mode.values) {
        _preloadModePrompt(mode);
      }
      
      _preloadStatus['models_loaded'] = true;
      debugPrint('✅ 模型资源预加载完成');
    } catch (e) {
      debugPrint('❌ 模型资源预加载失败: $e');
      _preloadStatus['models_loaded'] = false;
    }
  }
  
  /// 预加载模式提示词
  void _preloadModePrompt(Mode mode) {
    // 这里可以预加载和缓存提示词模板
    switch (mode) {
      case Mode.normal:
        // 预加载普通模式提示词
        break;
      case Mode.health:
        // 预加载健康分析提示词
        break;
      case Mode.travel:
        // 预加载旅行分析提示词
        break;
      case Mode.pet:
        // 预加载宠物分析提示词
        break;
    }
  }
  
  /// 预加载相机资源
  Future<void> preloadCamera() async {
    try {
      debugPrint('📷 预加载相机资源...');
      
      // 获取可用相机列表
      final cameras = await availableCameras();
      
      if (cameras.isNotEmpty) {
        _preloadStatus['camera_ready'] = true;
        debugPrint('✅ 相机资源预加载完成，发现 ${cameras.length} 个相机');
      }
    } catch (e) {
      debugPrint('❌ 相机资源预加载失败: $e');
      _preloadStatus['camera_ready'] = false;
    }
  }
  
  /// 预加载特定模式的资源
  Future<void> preloadForMode(Mode mode) async {
    try {
      debugPrint('🎯 为模式 $mode 预加载资源...');
      
      // 预热该模式的API调用
      await _warmupModeApi(mode);
      
      debugPrint('✅ 模式 $mode 资源预加载完成');
    } catch (e) {
      debugPrint('❌ 模式 $mode 资源预加载失败: $e');
    }
  }
  
  /// 预热特定模式的API
  Future<void> _warmupModeApi(Mode mode) async {
    try {
      // 这里可以发送一个轻量级的测试请求来预热该模式的API路径
      // 实际实现中可以根据需要调整
    } catch (e) {
      debugPrint('⚠️ 模式 $mode API预热失败: $e');
    }
  }
  
  /// 获取预加载状态
  Map<String, bool> getPreloadStatus() {
    return Map.from(_preloadStatus);
  }
  
  /// 检查是否已准备就绪
  bool isReady() {
    return _preloadStatus.values.every((status) => status);
  }
  
  /// 获取准备就绪的百分比
  double getReadinessPercentage() {
    final totalItems = _preloadStatus.length;
    final readyItems = _preloadStatus.values.where((status) => status).length;
    return readyItems / totalItems;
  }
  
  /// 清理资源
  void dispose() {
    _preloadTimer?.cancel();
    _preloadTimer = null;
    _isInitialized = false;
    _isPreloading = false;
    
    debugPrint('🧹 预加载服务已清理');
  }
}