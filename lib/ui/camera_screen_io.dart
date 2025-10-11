import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/device_config.dart';
import '../config/nothing_theme.dart';
import '../models/ai_result.dart';
import '../models/mode.dart';
import '../models/health_report.dart';
import '../models/pet_activity.dart';

import '../services/api_client.dart';
import '../services/health_analyzer.dart';
import '../services/activity_tracker.dart';
import '../services/travel_box_simulator.dart';
import '../services/realtime_analyzer.dart';
import '../services/history_manager.dart';
import '../services/performance_manager.dart';
import '../services/confidence_manager.dart';
import '../screens/settings_screen.dart';
import '../screens/history_screen.dart';
import 'overlay/top_tag.dart';
import 'overlay/yellow_frame_painter.dart';
import 'bottom_bar.dart';
import 'overlay/travel_box_painter.dart';
import '../widgets/nothing_dot_matrix.dart';
import '../widgets/nothing_linear_decoration.dart';
import '../widgets/performance_stats_widget.dart';
import '../services/preloader.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isTakingPicture = false;
  bool _isAnalyzing = false;
  bool _isRealtimeEnabled = false;

  Mode _mode = Mode.normal;
  AIResult? _result;
  // ignore: unused_field
  HealthReport? _healthReport;
  // ignore: unused_field
  PetActivity? _petActivity;
  Map<String, dynamic>? _travelBoxData;

  List<CameraDescription>? _cameras;
  List<CameraDescription> _availableCameras = [];
  final int _selectedCameraIndex = 0;
  int _currentCameraIndex = 0;

  final _apiClient = ApiClient.instance;
  final _healthAnalyzer = HealthAnalyzer.instance;
  final _activityTracker = ActivityTracker.instance;
  final _travelBoxSimulator = TravelBoxSimulator.instance;
  final _realtimeAnalyzer = RealtimeAnalyzer.instance;
  final _historyManager = HistoryManager.instance;
  final _performanceManager = PerformanceManager.instance;
  final _preloader = Preloader.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initializePerformanceManager();
    
    // 预加载相机资源
    _preloader.preloadCamera();
  }

  /// 初始化性能管理器
  Future<void> _initializePerformanceManager() async {
    await _performanceManager.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 应用生命周期管理，优化电池使用
    switch (state) {
      case AppLifecycleState.paused:
        // 应用进入后台，暂停相机和实时分析
        _pauseCameraForBackground();
        break;
      case AppLifecycleState.resumed:
        // 应用恢复前台，重新启动相机
        _resumeCameraFromBackground();
        break;
      case AppLifecycleState.detached:
        // 应用即将关闭，清理资源
        _cleanupResources();
        break;
      default:
        break;
    }
  }

  /// 暂停相机（后台优化）
  void _pauseCameraForBackground() {
    _realtimeAnalyzer.stopRealtimeAnalysis();
    _controller?.pausePreview();
  }

  /// 恢复相机（前台恢复）
  void _resumeCameraFromBackground() {
    _controller?.resumePreview();
    if (_isRealtimeEnabled) {
      _realtimeAnalyzer.startRealtimeAnalysis(
        controller: _controller!,
        onResult: (result, file) {
          if (mounted) {
            setState(() => _result = result);
          }
        },
        onError: (error) {
          debugPrint('实时分析错误: $error');
        },
      );
    }
  }

  /// 清理资源
  void _cleanupResources() {
    _performanceManager.clearAllCache();
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      return;
    }

    try {
      // 并行执行权限请求和相机列表获取，提升初始化速度
      final futures = await Future.wait([
        Permission.camera.request(),
        availableCameras(),
      ]);
      
      final cameraStatus = futures[0] as PermissionStatus;
      if (!cameraStatus.isGranted) {
        _showError('需要相机权限才能使用此功能');
        return;
      }

      _cameras = futures[1] as List<CameraDescription>;
      _availableCameras = _cameras ?? [];

      if (_availableCameras.isEmpty) {
        _showError('未找到可用的相机');
        return;
      }

      // 获取性能优化的相机配置
      final cameraConfig = _performanceManager.getOptimizedCameraConfig();
      
      _controller = CameraController(
        _availableCameras[_selectedCameraIndex],
        cameraConfig['resolution'] ?? ResolutionPreset.high,
        enableAudio: cameraConfig['enableAudio'] ?? false,
        imageFormatGroup: cameraConfig['imageFormatGroup'] ?? ImageFormatGroup.jpeg,
      );

      // 异步初始化相机控制器
      await _controller!.initialize();
      
      // 异步设置相机参数，不阻塞主流程
      _setCameraParametersAsync(cameraConfig);

      // 相机初始化完成，立即更新UI状态
      if (mounted) {
        setState(() {
          // 触发UI更新，显示相机预览
        });
      }
    } catch (e) {
      _showError('相机初始化失败: $e');
    }
  }

  /// 异步设置相机参数，不阻塞主初始化流程
  void _setCameraParametersAsync(Map<String, dynamic> cameraConfig) {
    if (cameraConfig['fps'] != null) {
      Future.microtask(() async {
        try {
          await _controller?.setExposureMode(ExposureMode.auto);
          await _controller?.setFocusMode(FocusMode.auto);
        } catch (e) {
          debugPrint('设置相机参数失败: $e');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取屏幕尺寸并进行适配
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        final adaptedSize = DeviceConfig.getAdaptedSize(screenSize);
        
        // 响应式字体大小
        final responsiveFontSize = DeviceConfig.getResponsiveFontSize(context, 16.0);
        final responsiveSpacing = DeviceConfig.getResponsiveSpacing(context, 16.0);
        
        // 计算相机预览的宽高比
        double cameraAspectRatio;
        if (kIsWeb) {
          cameraAspectRatio = DeviceConfig.aspectRatio;
        } else if (_controller != null && _controller!.value.previewSize != null) {
          final previewSize = _controller!.value.previewSize!;
          // 注意：相机预览尺寸通常是横向的，需要转换为竖向
          cameraAspectRatio = previewSize.height / previewSize.width;
        } else {
          cameraAspectRatio = DeviceConfig.aspectRatio;
        }

        // 计算相机预览区域尺寸，确保填满屏幕并保持比例
        final screenAspectRatio = adaptedSize.width / adaptedSize.height;
        Size previewDisplaySize;
        
        if (screenAspectRatio > cameraAspectRatio) {
          // 屏幕更宽，以高度为准
          previewDisplaySize = Size(
            adaptedSize.height * cameraAspectRatio,
            adaptedSize.height
          );
        } else {
          // 屏幕更高，以宽度为准
          previewDisplaySize = Size(
            adaptedSize.width,
            adaptedSize.width / cameraAspectRatio
          );
        }

        // 计算相机预览在屏幕中的位置
        final previewLeft = (adaptedSize.width - previewDisplaySize.width) / 2;

        
        // 根据屏幕比例动态调整取景框大小
        double frameWidthRatio = 0.7;
        double frameHeightRatio = 0.5;
        
        // 针对不同屏幕比例优化取景框尺寸
        if (screenAspectRatio > 0.6) { // 宽屏设备 (如iPhone Pro Max)
          frameWidthRatio = 0.65;
          frameHeightRatio = 0.45;
        } else if (screenAspectRatio < 0.5) { // 窄屏设备 (如传统Android)
          frameWidthRatio = 0.75;
          frameHeightRatio = 0.55;
        }
        
        final frameWidth = previewDisplaySize.width * frameWidthRatio;
        final frameHeight = previewDisplaySize.height * frameHeightRatio;
        
        // 精确居中计算，考虑安全区域
        final safeAreaTop = MediaQuery.of(context).padding.top;
        final safeAreaBottom = MediaQuery.of(context).padding.bottom;
        final availableHeight = adaptedSize.height - safeAreaTop - safeAreaBottom - 120; // 120为底部控制栏高度
        
        final frameLeft = previewLeft + (previewDisplaySize.width - frameWidth) / 2;
        final frameTop = safeAreaTop + (availableHeight - frameHeight) / 2;
        
        // 转换为相对于整个屏幕的坐标
        final rect = Rect.fromLTWH(
          frameLeft / adaptedSize.width,   // 相对于屏幕的左边距
          frameTop / adaptedSize.height,   // 相对于屏幕的顶部边距
          frameWidth / adaptedSize.width,  // 相对于屏幕的宽度
          frameHeight / adaptedSize.height // 相对于屏幕的高度
        );

        return Container(
          width: adaptedSize.width,
          height: adaptedSize.height,
          decoration: const BoxDecoration(
            color: NothingTheme.nothingBlack,
          ),
          child: Stack(
            children: [
              // 相机预览背景
              Container(
                width: adaptedSize.width,
                height: adaptedSize.height,
                color: NothingTheme.nothingBlack,
                child: Center(
                  child: NothingLinearDecoration(
                    type: LinearDecorationType.corners,
                    lineColor: NothingTheme.yellowAlpha60,
                    lineWidth: 2.0,
                    padding: EdgeInsets.all(responsiveSpacing),
                    child: Container(
                      width: previewDisplaySize.width,
                      height: previewDisplaySize.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                        boxShadow: NothingTheme.nothingElevatedShadow,
                      ),
                      child: Stack(
                        children: [
                          // 背景点阵效果
                          Positioned.fill(
                            child: NothingDotMatrix(
                              width: previewDisplaySize.width,
                              height: previewDisplaySize.height,
                              dotColor: NothingTheme.yellowAlpha10,
                              pattern: DotPattern.grid,
                              animated: true,
                            ),
                          ),
                          // 相机预览
                          ClipRRect(
                            borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                            child: kIsWeb
                                ? Container(
                                    color: NothingTheme.grayAlpha80,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            color: NothingTheme.grayAlpha50,
                                            size: responsiveFontSize * 2,
                                          ),
                                          const SizedBox(height: NothingTheme.spacingMedium),
                                          Text(
                                            'Web Camera Preview',
                                            style: TextStyle(
                                              color: NothingTheme.nothingWhite,
                                              fontSize: responsiveFontSize,
                                              fontWeight: NothingTheme.fontWeightRegular,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : (_controller != null && _controller!.value.isInitialized)
                                    ? ClipRect(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: SizedBox(
                                              width: previewDisplaySize.width,
                                              height: previewDisplaySize.height,
                                              child: CameraPreview(_controller!),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.black,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                 color: NothingTheme.yellowAlpha60,
                                               ),
                                              SizedBox(height: 16),
                                              Text(
                                                '正在初始化相机...',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: responsiveFontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 顶部标签
              if (_result != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + responsiveSpacing * 2,
                  left: responsiveSpacing,
                  right: responsiveSpacing,
                  child: AnimatedNothingLinearDecoration(
                    type: LinearDecorationType.border,
                    lineColor: NothingTheme.nothingYellow,
                    lineWidth: 1.5,
                    padding: EdgeInsets.zero,
                    duration: const Duration(seconds: 3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: NothingTheme.whiteAlpha90,
                        borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                        boxShadow: NothingTheme.nothingShadow,
                        border: Border.all(
                          color: NothingTheme.yellowAlpha30,
                          width: 1.5,
                        ),
                      ),
                      child: TopTag(
                        result: _result!,
                        fontSize: responsiveFontSize - 2,
                      ),
                    ),
                  ),
                ),

              // 黄色框架覆盖层
              if (_mode == Mode.normal || _mode == Mode.pet || _mode == Mode.health)
                Positioned.fill(
                  child: CustomPaint(
                    painter: YellowFramePainter(
                      mainRect: rect,
                    ),
                  ),
                ),

              // 出行箱视角覆盖层
              if (_mode == Mode.travel && _travelBoxData != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: TravelBoxPainter(
                      mainRect: Rect.fromLTWH(0.2, 0.2, 0.6, 0.6),
                    ),
                  ),
                ),

              // 旅行模式分析面板（避免展示原始JSON）
              if (_mode == Mode.travel && _travelBoxData != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 92, // 避开底部控制栏
                  child: Container(
                    padding: const EdgeInsets.all(NothingTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: NothingTheme.whiteAlpha90,
                      borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                      boxShadow: NothingTheme.nothingElevatedShadow,
                      border: Border.all(
                        color: NothingTheme.grayAlpha30,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 标题与安全等级
                        Row(
                          children: [
                            const Icon(Icons.travel_explore, size: 18, color: NothingTheme.nothingBlack),
                            const SizedBox(width: NothingTheme.spacingSmall),
                            Expanded(
                              child: Text(
                                '出行场景',
                                style: const TextStyle(
                                  fontSize: NothingTheme.fontSizeBody,
                                  fontWeight: NothingTheme.fontWeightMedium,
                                  color: NothingTheme.nothingBlack,
                                ),
                              ),
                            ),
                            _buildSafetyBadge(_travelBoxData!),
                          ],
                        ),
                        const SizedBox(height: NothingTheme.spacingSmall),
                        // 场景信息
                        _buildSceneInfoRow(_travelBoxData!),
                        const SizedBox(height: NothingTheme.spacingSmall),
                        // 建议区块
                        _buildRecommendationsSection(_travelBoxData!),
                      ],
                    ),
                  ),
                ),

              // 加载指示器
              if (_isAnalyzing)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      color: NothingTheme.blackAlpha70,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(NothingTheme.spacingLarge),
                          decoration: BoxDecoration(
                            color: NothingTheme.whiteAlpha90,
                            borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                            boxShadow: NothingTheme.nothingElevatedShadow,
                            border: Border.all(
                              color: NothingTheme.yellowAlpha30,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: NothingTheme.nothingYellow,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: NothingTheme.spacingMedium),
                              Text(
                                'AI分析中...',
                                style: TextStyle(
                                  color: NothingTheme.nothingBlack,
                                  fontSize: responsiveFontSize - 2,
                                  fontWeight: NothingTheme.fontWeightMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // 底部控制栏
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomBar(
                  current: _mode,
                  onModeChanged: _changeMode,
                  onShutter: _takePicture,
                  onCameraSwitch: (_cameras != null && _cameras!.length > 1) ? _switchCamera : null,
                  onGallerySelect: _selectFromGallery,
                ),
              ),

              // 添加顶部功能按钮栏
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Column(
                  children: [
                    // 实时分析按钮
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRealtimeEnabled 
                            ? NothingTheme.nothingYellow.withValues(alpha: 0.2)
                            : NothingTheme.blackAlpha70,
                        border: Border.all(
                          color: _isRealtimeEnabled 
                              ? NothingTheme.nothingYellow
                              : NothingTheme.grayAlpha30,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isRealtimeEnabled 
                                ? NothingTheme.yellowAlpha30
                                : NothingTheme.blackAlpha20,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: _toggleRealtimeAnalysis,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              _isRealtimeEnabled ? Icons.visibility : Icons.visibility_off,
                              color: _isRealtimeEnabled 
                                  ? NothingTheme.nothingYellow
                                  : NothingTheme.nothingWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 分析历史按钮
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NothingTheme.blackAlpha70,
                        border: Border.all(
                          color: NothingTheme.grayAlpha30,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NothingTheme.blackAlpha20,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.history,
                              color: NothingTheme.nothingWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 性能统计按钮
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NothingTheme.blackAlpha70,
                        border: Border.all(
                          color: NothingTheme.grayAlpha30,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NothingTheme.blackAlpha20,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            _showPerformanceStats();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.analytics_outlined,
                              color: NothingTheme.nothingWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 设置按钮
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NothingTheme.blackAlpha70,
                        border: Border.all(
                          color: NothingTheme.grayAlpha30,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NothingTheme.blackAlpha20,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.settings,
                              color: NothingTheme.nothingWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: NothingTheme.nothingWhite,
            ),
            const SizedBox(width: NothingTheme.spacingMedium),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 14,
                  fontWeight: NothingTheme.fontWeightRegular,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: NothingTheme.nothingBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _analyzeImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      
      // 根据模式进行不同的分析
      switch (_mode) {
        case Mode.normal:
          // 使用API客户端进行真实分析
          final result = await _apiClient.analyzeImage(imageFile, mode: 'normal');
          setState(() => _result = result);
          // 分析完成后保存到历史记录（应用置信度阈值过滤）
          await _saveToHistoryWithThreshold(imageFile, false, result);
          break;
        case Mode.health:
            final healthReport = await _healthAnalyzer.analyzeHealth(imageFile, '未知宠物', '猫');
            setState(() => _healthReport = healthReport);
            // 健康分析完成后保存到历史记录，使用模拟的AIResult
            final healthResult = AIResult(
              title: '健康检查报告',
              confidence: healthReport.healthAssessment.overallScore,
              subInfo: healthReport.healthAssessment.healthStatus,
            );
            await _saveToHistoryWithThreshold(imageFile, false, healthResult);
            break;
          case Mode.pet:
            // 使用API客户端进行宠物分析
            final result = await _apiClient.analyzeImage(imageFile, mode: 'pet');
            
            // 使用宠物信息进行活动追踪
            final activity = await _activityTracker.trackActivity(imageFile, '未知宠物');
            
            setState(() {
              _result = result;
              _petActivity = activity;
            });
            // 宠物分析完成后保存到历史记录（应用置信度阈值过滤）
            await _saveToHistoryWithThreshold(imageFile, false, result);
            break;
          case Mode.travel:
            // 使用豆包API进行出行场景分析
            final travelData = await _travelBoxSimulator.analyzeTravelSceneWithApi(imageFile);
            setState(() => _travelBoxData = travelData);
            // 旅行模式保存到历史记录，使用真实AIResult
            final travelResult = AIResult(
              title: '出行场景分析',
              confidence: travelData['metadata']?['api_response'] != null ? 90 : 60,
              subInfo: jsonEncode(travelData['metadata']?['api_response'] ?? {'note': '缺少结构化响应'}),
            );
            await _saveToHistoryWithThreshold(imageFile, false, travelResult);
            break;
      }
    } catch (e) {
      _showError('分析失败: $e');
    }
  }

  // 应用置信度阈值过滤并保存到历史记录
  Future<void> _saveToHistoryWithThreshold(File imageFile, bool isRealtime, AIResult result) async {
    try {
      // 使用新的置信度管理器
      final mode = _mode.name;
      final confidenceMetrics = ConfidenceManager.calculateMetrics(
         result.confidence,
         mode,
         hasApiResponse: result.subInfo?.isNotEmpty ?? false,
       );
      
      debugPrint('🔍 置信度分析: ${confidenceMetrics.toString()}');
      debugPrint('🔍 保存历史记录检查: 结果置信度=${result.confidence}%, 动态阈值=${confidenceMetrics.threshold}%');
      
      // 使用置信度管理器判断是否应该保存
      if (ConfidenceManager.shouldSaveToHistory(result.confidence, mode)) {
        // 创建增强的结果，包含置信度建议
        final enhancedResult = AIResult(
          title: result.title,
          confidence: result.confidence,
          subInfo: '${result.subInfo}\n\n置信度评估: ${confidenceMetrics.advice}',
        );
        
        await _historyManager.addHistory(
          result: enhancedResult,
          mode: mode,
          imagePath: imageFile.path,
          isRealtimeAnalysis: isRealtime,
        );
        debugPrint('✅ 分析结果已保存到历史记录: ${result.title} (置信度: ${result.confidence}%, 质量: ${confidenceMetrics.qualityDescription})');
      } else {
        // 置信度过低，但仍然保存并添加警告
        final warningResult = AIResult(
          title: '${result.title} ⚠️',
          confidence: result.confidence,
          subInfo: '${result.subInfo}\n\n⚠️ 置信度警告: ${confidenceMetrics.advice}',
        );
        
        await _historyManager.addHistory(
          result: warningResult,
          mode: mode,
          imagePath: imageFile.path,
          isRealtimeAnalysis: isRealtime,
        );
        debugPrint('⚠️ 分析结果置信度较低但已保存: ${result.title} (置信度: ${result.confidence}%, 质量: ${confidenceMetrics.qualityDescription})');
      }
    } catch (e) {
      debugPrint('保存历史记录失败: $e');
    }
  }

  // 保存到历史记录（保留原方法以兼容其他调用）
  Future<void> _saveToHistory(File imageFile, bool isRealtime) async {
    try {
      if (_result != null) {
        await _saveToHistoryWithThreshold(imageFile, isRealtime, _result!);
      }
    } catch (e) {
      debugPrint('保存历史记录失败: $e');
    }
  }

  // 添加摄像头切换方法
  Future<void> _switchCamera() async {
    if (kIsWeb || _cameras == null || _cameras!.length <= 1) {
      return; // Web模式或只有一个摄像头时不切换
    }

    // 移除 _isInitialized 赋值

    try {
      // 释放当前控制器
      await _controller?.dispose();
      
      // 切换到下一个摄像头
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
      final selectedCamera = _cameras![_currentCameraIndex];
      
      // 初始化新的控制器
      _controller = CameraController(selectedCamera, ResolutionPreset.medium, enableAudio: false);
      await _controller!.initialize();
      
      // 相机切换完成
    } catch (e) {
      _showError('摄像头切换失败: $e');
    }
  }

  // 添加相册选择方法
  Future<void> _selectFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // 清空上次结果并显示分析进度
        setState(() {
          _result = null;
          _healthReport = null;
          _petActivity = null;
          _travelBoxData = null;
          _isAnalyzing = true;
        });
        
        String analysisMessage = '正在分析图像...';
        switch (_mode) {
          case Mode.health:
            analysisMessage = '正在分析宠物健康状况...';
            break;
          case Mode.pet:
            analysisMessage = '正在分析宠物活动...';
            break;
          case Mode.travel:
            analysisMessage = '正在分析出行箱内容...';
            break;
          default:
            analysisMessage = '正在分析图像...';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(analysisMessage),
                ],
              ),
            ),
          );
        }
        
        // 分析图像
        await _analyzeImage(image.path);
        
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showError('选择图片失败: $e');
    }
  }

  Future<void> _takePicture() async {
    if (kIsWeb) {
      _showError('Web版本暂不支持拍照功能');
      return;
    }

    if (_controller == null || !_controller!.value.isInitialized || _isTakingPicture) {
      return;
    }

    setState(() => _isTakingPicture = true);

    try {
      final image = await _controller!.takePicture();
      
      // 将临时文件复制到应用程序内部存储目录
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = '${imagesDir.path}/$fileName';
      
      // 确保目录存在并有写入权限
      debugPrint('📁 图片保存目录: ${imagesDir.path}');
      debugPrint('📸 保存图片到: $permanentPath');
      
      final permanentFile = await File(image.path).copy(permanentPath);
      
      // 验证文件是否成功保存
      if (await permanentFile.exists()) {
        debugPrint('✅ 图片保存成功: $permanentPath');
      } else {
        debugPrint('❌ 图片保存失败: $permanentPath');
        throw Exception('图片保存失败');
      }
      
      // 清空上次结果并显示分析进度
      setState(() {
        _result = null;
        _healthReport = null;
        _petActivity = null;
        _travelBoxData = null;
        _isAnalyzing = true;
      });
      
      // 分析图像
      await _analyzeImage(permanentFile.path);
      
      setState(() {
        _isAnalyzing = false;
      });
    } catch (e) {
      _showError('拍照失败: $e');
      setState(() {
        _isAnalyzing = false;
      });
    } finally {
      setState(() => _isTakingPicture = false);
    }
  }

  void _changeMode(Mode newMode) {
    setState(() {
      _mode = newMode;
      _result = null;
      _healthReport = null;
      _petActivity = null;
      _travelBoxData = null;
    });
    
    // 为新模式预加载资源
    _preloader.preloadForMode(newMode);
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: NothingTheme.nothingWhite,
              ),
              const SizedBox(width: NothingTheme.spacingMedium),
              Expanded(
                child: Text(
                  msg,
                  style: TextStyle(
                    color: NothingTheme.nothingWhite,
                    fontSize: 14,
                    fontWeight: NothingTheme.fontWeightRegular,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: NothingTheme.nothingDarkGray,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showPerformanceStats() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: NothingTheme.blackAlpha90,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NothingTheme.blackAlpha70,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: NothingTheme.nothingWhite,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '性能统计',
                      style: TextStyle(
                        color: NothingTheme.nothingWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: NothingTheme.nothingWhite,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: const PerformanceStatsWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleRealtimeAnalysis() {
    setState(() {
      _isRealtimeEnabled = !_isRealtimeEnabled;
    });
    
    if (_isRealtimeEnabled) {
      _startRealtimeAnalysis();
    } else {
      _realtimeAnalyzer.stopRealtimeAnalysis();
      _showSnackBar('实时分析已停止');
    }
  }
  
  void _startRealtimeAnalysis() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    _realtimeAnalyzer.startRealtimeAnalysis(
      controller: _controller!,
      onResult: (result, imageFile) async {
        // 确保实时分析结果与当前选择的模式一致
        AIResult modeSpecificResult;
        
        switch (_mode) {
          case Mode.normal:
            // 使用API客户端进行普通模式分析，确保模式一致性
            modeSpecificResult = await _apiClient.analyzeImage(imageFile, mode: 'normal');
            break;
          case Mode.pet:
            // 使用API客户端进行宠物模式分析，确保模式一致性
            modeSpecificResult = await _apiClient.analyzeImage(imageFile, mode: 'pet');
            break;
          case Mode.health:
            // 使用API客户端进行健康模式分析，确保模式一致性
            modeSpecificResult = await _apiClient.analyzeImage(imageFile, mode: 'health');
            break;
          case Mode.travel:
            // 使用API客户端进行旅行模式分析，确保模式一致性
            modeSpecificResult = await _apiClient.analyzeImage(imageFile, mode: 'travel');
            break;
        }
        
        setState(() {
          _result = modeSpecificResult;
        });
        
        // 保存实时分析结果到历史记录（应用置信度阈值过滤）
        await _saveToHistoryWithThreshold(imageFile, true, modeSpecificResult);
        
        // 显示实时分析结果通知
        _showSnackBar('实时分析完成: ${modeSpecificResult.title}');
      },
      onError: (error) {
        _showSnackBar('实时分析错误: $error');
      },
      interval: const Duration(seconds: 2), // 缩短分析间隔，提高响应性
    );
    
    _showSnackBar('实时分析已启动，每2秒自动分析一次');
  }

  // 构建安全等级徽章
  Widget _buildSafetyBadge(Map<String, dynamic> travelData) {
    final scene = (travelData['scene_analysis'] as Map<String, dynamic>?) ?? {};
    final String level = (scene['safety_level'] ?? '未知').toString();

    Color color;
    IconData icon;
    switch (level) {
      case '安全':
        color = Colors.green.shade600;
        icon = Icons.check_circle_outline;
        break;
      case '需注意':
        color = Colors.orange.shade600;
        icon = Icons.warning_amber_outlined;
        break;
      case '需谨慎':
        color = Colors.red.shade600;
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.grey.shade600;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NothingTheme.spacingSmall,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            level,
            style: TextStyle(
              color: color,
              fontSize: NothingTheme.fontSizeBody,
              fontWeight: NothingTheme.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  // 场景信息行：类型、位置、天气
  Widget _buildSceneInfoRow(Map<String, dynamic> travelData) {
    final scene = (travelData['scene_analysis'] as Map<String, dynamic>?) ?? {};
    final String type = (scene['type'] ?? '未知场景').toString();
    final String location = (scene['location'] ?? '未知位置').toString();
    final String weather = (scene['weather'] ?? '未知天气').toString();

    Widget infoChip(IconData icon, String label, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NothingTheme.spacingSmall,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: NothingTheme.whiteAlpha90,
          borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
          border: Border.all(color: NothingTheme.grayAlpha30, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: NothingTheme.nothingBlack),
            const SizedBox(width: 6),
            Text(
              '$label: $value',
              style: const TextStyle(
                color: NothingTheme.nothingBlack,
                fontSize: NothingTheme.fontSizeCaption,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: NothingTheme.spacingSmall,
      runSpacing: NothingTheme.spacingSmall,
      children: [
        infoChip(Icons.category_outlined, '类型', type),
        infoChip(Icons.place_outlined, '位置', location),
        infoChip(Icons.wb_sunny_outlined, '天气', weather),
      ],
    );
  }

  // 建议区块：活动、提示、旅行建议
  Widget _buildRecommendationsSection(Map<String, dynamic> travelData) {
    final rec = (travelData['recommendations'] as Map<String, dynamic>?) ?? {};
    final List<String> activities = List<String>.from(rec['activities'] ?? const []);
    final List<String> safetyTips = List<String>.from(rec['safety_tips'] ?? const []);
    final List<String> advice = List<String>.from(rec['travel_advice'] ?? const []);

    Widget sectionTitle(String title, IconData icon) {
      return Row(
        children: [
          Icon(icon, size: 18, color: NothingTheme.nothingBlack),
          const SizedBox(width: NothingTheme.spacingSmall),
          Text(
            title,
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeBody,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.nothingBlack,
            ),
          ),
        ],
      );
    }

    Widget chip(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NothingTheme.spacingSmall,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: NothingTheme.whiteAlpha90,
          borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
          border: Border.all(color: NothingTheme.grayAlpha30, width: 1),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: NothingTheme.nothingBlack,
            fontSize: NothingTheme.fontSizeCaption,
          ),
        ),
      );
    }

    Widget emptyHint(String text) => Text(
          text,
          style: TextStyle(
            color: NothingTheme.nothingDarkGray,
            fontSize: NothingTheme.fontSizeCaption,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('推荐活动', Icons.directions_walk_outlined),
        const SizedBox(height: NothingTheme.spacingXSmall),
        activities.isNotEmpty
            ? Wrap(
                spacing: NothingTheme.spacingSmall,
                runSpacing: NothingTheme.spacingSmall,
                children: activities.map(chip).toList(),
              )
            : emptyHint('暂无活动建议'),
        const SizedBox(height: NothingTheme.spacingSmall),
        sectionTitle('安全提示', Icons.shield_outlined),
        const SizedBox(height: NothingTheme.spacingXSmall),
        safetyTips.isNotEmpty
            ? Wrap(
                spacing: NothingTheme.spacingSmall,
                runSpacing: NothingTheme.spacingSmall,
                children: safetyTips.map(chip).toList(),
              )
            : emptyHint('暂无安全提示'),
        const SizedBox(height: NothingTheme.spacingSmall),
        sectionTitle('旅行建议', Icons.map_outlined),
        const SizedBox(height: NothingTheme.spacingXSmall),
        advice.isNotEmpty
            ? Wrap(
                spacing: NothingTheme.spacingSmall,
                runSpacing: NothingTheme.spacingSmall,
                children: advice.map(chip).toList(),
              )
            : emptyHint('暂无旅行建议'),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _realtimeAnalyzer.stopRealtimeAnalysis();
    _performanceManager.dispose();
    super.dispose();
  }
}