import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 摄像头类型
enum CameraType {
  indoor('室内摄像头', Icons.videocam),
  outdoor('室外摄像头', Icons.outdoor_grill),
  ptz('云台摄像头', Icons.threesixty),
  doorbell('门铃摄像头', Icons.doorbell),
  pet('宠物摄像头', Icons.pets);

  const CameraType(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 摄像头状态
enum CameraStatus {
  online('在线', NothingTheme.success),
  offline('离线', NothingTheme.error),
  recording('录制中', NothingTheme.warning),
  streaming('直播中', NothingTheme.info);

  const CameraStatus(this.displayName, this.color);
  
  final String displayName;
  final Color color;
}

/// 录像质量
enum VideoQuality {
  low('流畅', '480p'),
  medium('标清', '720p'),
  high('高清', '1080p'),
  ultra('超清', '4K');

  const VideoQuality(this.displayName, this.resolution);
  
  final String displayName;
  final String resolution;
}

/// 夜视模式
enum NightVisionMode {
  off('关闭', Icons.brightness_7),
  auto('自动', Icons.brightness_auto),
  on('开启', Icons.brightness_2),
  infrared('红外', Icons.visibility);

  const NightVisionMode(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 录像记录
class VideoRecord {
  final String id;
  final String title;
  final DateTime timestamp;
  final Duration duration;
  final String thumbnailUrl;
  final VideoQuality quality;
  final double fileSize; // MB
  final bool isImportant;

  const VideoRecord({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.duration,
    required this.thumbnailUrl,
    required this.quality,
    required this.fileSize,
    this.isImportant = false,
  });
}

/// 摄像头设备
class CameraDevice {
  final String id;
  final String name;
  final CameraType type;
  final String location;
  final CameraStatus status;
  final VideoQuality quality;
  final NightVisionMode nightVision;
  final bool isRecording;
  final bool isStreaming;
  final bool motionDetection;
  final bool soundDetection;
  final int batteryLevel; // 0-100, -1 for wired
  final double storageUsed; // GB
  final double storageTotal; // GB
  final List<VideoRecord> recentRecords;

  const CameraDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    this.status = CameraStatus.offline,
    this.quality = VideoQuality.high,
    this.nightVision = NightVisionMode.auto,
    this.isRecording = false,
    this.isStreaming = false,
    this.motionDetection = true,
    this.soundDetection = false,
    this.batteryLevel = -1,
    this.storageUsed = 0.0,
    this.storageTotal = 32.0,
    this.recentRecords = const [],
  });

  CameraDevice copyWith({
    String? id,
    String? name,
    CameraType? type,
    String? location,
    CameraStatus? status,
    VideoQuality? quality,
    NightVisionMode? nightVision,
    bool? isRecording,
    bool? isStreaming,
    bool? motionDetection,
    bool? soundDetection,
    int? batteryLevel,
    double? storageUsed,
    double? storageTotal,
    List<VideoRecord>? recentRecords,
  }) {
    return CameraDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      status: status ?? this.status,
      quality: quality ?? this.quality,
      nightVision: nightVision ?? this.nightVision,
      isRecording: isRecording ?? this.isRecording,
      isStreaming: isStreaming ?? this.isStreaming,
      motionDetection: motionDetection ?? this.motionDetection,
      soundDetection: soundDetection ?? this.soundDetection,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      storageUsed: storageUsed ?? this.storageUsed,
      storageTotal: storageTotal ?? this.storageTotal,
      recentRecords: recentRecords ?? this.recentRecords,
    );
  }
}

/// 摄像头控制界面
class CameraControlScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const CameraControlScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<CameraControlScreen> createState() => _CameraControlScreenState();
}

class _CameraControlScreenState extends State<CameraControlScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _recordingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  List<CameraDevice> _cameras = [];
  CameraDevice? _selectedCamera;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _recordingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _recordingController,
      curve: Curves.easeInOut,
    ));

    _loadCameras();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recordingController.dispose();
    super.dispose();
  }

  void _loadCameras() {
    // 模拟摄像头数据
    setState(() {
      _cameras = [
        CameraDevice(
          id: '1',
          name: '客厅摄像头',
          type: CameraType.indoor,
          location: '客厅',
          status: CameraStatus.online,
          quality: VideoQuality.high,
          nightVision: NightVisionMode.auto,
          isRecording: false,
          isStreaming: true,
          motionDetection: true,
          soundDetection: false,
          batteryLevel: -1,
          storageUsed: 12.5,
          storageTotal: 32.0,
          recentRecords: [
            VideoRecord(
              id: '1',
              title: '宠物活动记录',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              duration: const Duration(minutes: 15),
              thumbnailUrl: '',
              quality: VideoQuality.high,
              fileSize: 125.0,
              isImportant: true,
            ),
          ],
        ),
        CameraDevice(
          id: '2',
          name: '宠物房云台',
          type: CameraType.ptz,
          location: '宠物房',
          status: CameraStatus.recording,
          quality: VideoQuality.ultra,
          nightVision: NightVisionMode.on,
          isRecording: true,
          isStreaming: false,
          motionDetection: true,
          soundDetection: true,
          batteryLevel: 85,
          storageUsed: 8.2,
          storageTotal: 64.0,
          recentRecords: [
            VideoRecord(
              id: '2',
              title: '夜间监控',
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
              duration: const Duration(hours: 1, minutes: 20),
              thumbnailUrl: '',
              quality: VideoQuality.ultra,
              fileSize: 480.0,
            ),
          ],
        ),
        CameraDevice(
          id: '3',
          name: '阳台户外摄像头',
          type: CameraType.outdoor,
          location: '阳台',
          status: CameraStatus.online,
          quality: VideoQuality.medium,
          nightVision: NightVisionMode.infrared,
          isRecording: false,
          isStreaming: false,
          motionDetection: false,
          soundDetection: false,
          batteryLevel: 45,
          storageUsed: 24.8,
          storageTotal: 32.0,
        ),
        CameraDevice(
          id: '4',
          name: '门口摄像头',
          type: CameraType.doorbell,
          location: '门口',
          status: CameraStatus.offline,
          quality: VideoQuality.high,
          nightVision: NightVisionMode.auto,
          batteryLevel: 15,
          storageUsed: 5.2,
          storageTotal: 16.0,
        ),
      ];
      
      if (_cameras.isNotEmpty) {
        _selectedCamera = _cameras.first;
        if (_selectedCamera!.isRecording) {
          _recordingController.repeat(reverse: true);
        }
      }
    });
  }

  void _updateCamera(CameraDevice updatedCamera) {
    setState(() {
      final index = _cameras.indexWhere((c) => c.id == updatedCamera.id);
      if (index != -1) {
        _cameras[index] = updatedCamera;
        if (_selectedCamera?.id == updatedCamera.id) {
          _selectedCamera = updatedCamera;
          
          if (updatedCamera.isRecording) {
            _recordingController.repeat(reverse: true);
          } else {
            _recordingController.stop();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        title: const Text(
          '摄像头控制',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NothingTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view, color: NothingTheme.textPrimary),
            onPressed: () {
              // 多画面视图
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 摄像头列表
            _buildCameraList(),
            
            // 标签页
            _buildTabBar(),
            
            // 内容区域
            if (_selectedCamera != null)
              Expanded(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildTabContent(_selectedCamera!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraList() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _cameras.length,
        itemBuilder: (context, index) {
          final camera = _cameras[index];
          final isSelected = _selectedCamera?.id == camera.id;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCamera = camera;
                if (camera.isRecording) {
                  _recordingController.repeat(reverse: true);
                } else {
                  _recordingController.stop();
                }
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? NothingTheme.brandPrimary : NothingTheme.surface,
                borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: NothingTheme.blackAlpha05,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Icon(
                        camera.type.icon,
                        color: isSelected ? Colors.white : camera.status.color,
                        size: 24,
                      ),
                      if (camera.status == CameraStatus.offline)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: NothingTheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      if (camera.isRecording)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: NothingTheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    camera.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : NothingTheme.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    camera.status.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.8) : camera.status.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['实时监控', '录像回放', '设备设置'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _currentTabIndex == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? NothingTheme.brandPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : NothingTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(CameraDevice camera) {
    switch (_currentTabIndex) {
      case 0:
        return _buildLiveView(camera);
      case 1:
        return _buildRecordingsView(camera);
      case 2:
        return _buildSettingsView(camera);
      default:
        return _buildLiveView(camera);
    }
  }

  Widget _buildLiveView(CameraDevice camera) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 视频预览区域
          _buildVideoPreview(camera),
          const SizedBox(height: 16),
          
          // 控制按钮
          _buildControlButtons(camera),
          const SizedBox(height: 16),
          
          // 云台控制
          if (camera.type == CameraType.ptz)
            _buildPTZControls(camera),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(CameraDevice camera) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
      ),
      child: Stack(
        children: [
          // 视频占位符
          Center(
            child: camera.status == CameraStatus.offline
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off,
                        color: Colors.white.withOpacity(0.5),
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '摄像头离线',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    Icons.play_circle_outline,
                    color: Colors.white.withOpacity(0.8),
                    size: 64,
                  ),
          ),
          
          // 状态指示器
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: camera.status.color,
                borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (camera.isRecording)
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (camera.isRecording) const SizedBox(width: 4),
                  Text(
                    camera.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 画质指示器
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
              ),
              child: Text(
                camera.quality.resolution,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // 夜视模式指示器
          if (camera.nightVision != NightVisionMode.off)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Icon(
                  camera.nightVision.icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(CameraDevice camera) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 录制按钮
        _buildControlButton(
          icon: camera.isRecording ? Icons.stop : Icons.fiber_manual_record,
          label: camera.isRecording ? '停止录制' : '开始录制',
          color: camera.isRecording ? NothingTheme.error : NothingTheme.brandPrimary,
          onTap: camera.status != CameraStatus.offline ? () {
            _updateCamera(camera.copyWith(
              isRecording: !camera.isRecording,
              status: camera.isRecording ? CameraStatus.online : CameraStatus.recording,
            ));
          } : null,
        ),
        
        // 截图按钮
        _buildControlButton(
          icon: Icons.camera_alt,
          label: '截图',
          color: NothingTheme.info,
          onTap: camera.status != CameraStatus.offline ? () {
            // 截图逻辑
          } : null,
        ),
        
        // 对讲按钮
        _buildControlButton(
          icon: Icons.mic,
          label: '对讲',
          color: NothingTheme.success,
          onTap: camera.status != CameraStatus.offline ? () {
            // 对讲逻辑
          } : null,
        ),
        
        // 全屏按钮
        _buildControlButton(
          icon: Icons.fullscreen,
          label: '全屏',
          color: NothingTheme.warning,
          onTap: camera.status != CameraStatus.offline ? () {
            // 全屏逻辑
          } : null,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: onTap != null ? color.withOpacity(0.1) : NothingTheme.gray100,
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
            ),
            child: Icon(
              icon,
              color: onTap != null ? color : NothingTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: onTap != null ? NothingTheme.textPrimary : NothingTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPTZControls(CameraDevice camera) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '云台控制',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // 方向控制
          Center(
            child: Container(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  // 上
                  Positioned(
                    top: 0,
                    left: 40,
                    child: _buildPTZButton(Icons.keyboard_arrow_up, () {}),
                  ),
                  // 下
                  Positioned(
                    bottom: 0,
                    left: 40,
                    child: _buildPTZButton(Icons.keyboard_arrow_down, () {}),
                  ),
                  // 左
                  Positioned(
                    left: 0,
                    top: 40,
                    child: _buildPTZButton(Icons.keyboard_arrow_left, () {}),
                  ),
                  // 右
                  Positioned(
                    right: 0,
                    top: 40,
                    child: _buildPTZButton(Icons.keyboard_arrow_right, () {}),
                  ),
                  // 中心
                  Positioned(
                    left: 40,
                    top: 40,
                    child: _buildPTZButton(Icons.home, () {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 缩放控制
          Row(
            children: [
              Expanded(
                child: _buildPTZButton(Icons.zoom_out, () {}),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPTZButton(Icons.zoom_in, () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPTZButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: NothingTheme.brandPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
        ),
        child: Icon(
          icon,
          color: NothingTheme.brandPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRecordingsView(CameraDevice camera) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 存储信息
          _buildStorageInfo(camera),
          const SizedBox(height: 16),
          
          // 录像列表
          _buildRecordingsList(camera),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(CameraDevice camera) {
    final usagePercent = camera.storageUsed / camera.storageTotal;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '存储空间',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已使用',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${camera.storageUsed.toStringAsFixed(1)} GB',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '总容量',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${camera.storageTotal.toStringAsFixed(0)} GB',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使用率',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(usagePercent * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: usagePercent > 0.8 ? NothingTheme.error : NothingTheme.success,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          LinearProgressIndicator(
            value: usagePercent,
            backgroundColor: NothingTheme.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(
              usagePercent > 0.8 ? NothingTheme.error : NothingTheme.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingsList(CameraDevice camera) {
    if (camera.recentRecords.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: NothingTheme.surface,
          borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        ),
        child: Column(
          children: [
            Icon(
              Icons.video_library_outlined,
              color: NothingTheme.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              '暂无录像',
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近录像',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ...camera.recentRecords.map((record) => _buildRecordingItem(record)),
      ],
    );
  }

  Widget _buildRecordingItem(VideoRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 缩略图
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: NothingTheme.gray200,
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              color: NothingTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.title,
                        style: const TextStyle(
                          color: NothingTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (record.isImportant)
                      const Icon(
                        Icons.star,
                        color: NothingTheme.warning,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Text(
                      _formatDateTime(record.timestamp),
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(record.duration),
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${record.fileSize.toStringAsFixed(0)}MB',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: const Icon(Icons.more_vert, color: NothingTheme.textSecondary),
            onPressed: () {
              // 更多操作
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(CameraDevice camera) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 设备信息
          _buildDeviceInfo(camera),
          const SizedBox(height: 16),
          
          // 视频设置
          _buildVideoSettings(camera),
          const SizedBox(height: 16),
          
          // 检测设置
          _buildDetectionSettings(camera),
          const SizedBox(height: 16),
          
          // 电池信息
          if (camera.batteryLevel >= 0)
            _buildBatteryInfo(camera),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(CameraDevice camera) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '设备信息',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('设备名称', camera.name),
          _buildInfoRow('设备类型', camera.type.displayName),
          _buildInfoRow('安装位置', camera.location),
          _buildInfoRow('连接状态', camera.status.displayName),
          _buildInfoRow('设备ID', camera.id),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: NothingTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSettings(CameraDevice camera) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '视频设置',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // 画质选择
          _buildSettingRow(
            '画质',
            camera.quality.displayName,
            () {
              // 画质选择
            },
          ),
          
          // 夜视模式
          _buildSettingRow(
            '夜视模式',
            camera.nightVision.displayName,
            () {
              // 夜视模式选择
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionSettings(CameraDevice camera) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '检测设置',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // 移动检测
          _buildSwitchRow(
            '移动检测',
            camera.motionDetection,
            (value) {
              _updateCamera(camera.copyWith(motionDetection: value));
            },
          ),
          
          // 声音检测
          _buildSwitchRow(
            '声音检测',
            camera.soundDetection,
            (value) {
              _updateCamera(camera.copyWith(soundDetection: value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: NothingTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: NothingTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: NothingTheme.brandPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryInfo(CameraDevice camera) {
    final batteryColor = camera.batteryLevel > 50
        ? NothingTheme.success
        : camera.batteryLevel > 20
            ? NothingTheme.warning
            : NothingTheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '电池信息',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(
                Icons.battery_std,
                color: batteryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '电量 ${camera.batteryLevel}%',
                      style: TextStyle(
                        color: batteryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    LinearProgressIndicator(
                      value: camera.batteryLevel / 100,
                      backgroundColor: NothingTheme.gray200,
                      valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}