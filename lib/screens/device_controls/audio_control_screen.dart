import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 音响设备类型
enum AudioDeviceType {
  speaker('智能音箱', Icons.speaker),
  soundbar('回音壁', Icons.surround_sound),
  headphones('耳机', Icons.headphones),
  bluetooth('蓝牙音箱', Icons.bluetooth_audio),
  stereo('立体声', Icons.speaker_group);

  const AudioDeviceType(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 音响模式
enum AudioMode {
  music('音乐', Icons.music_note, NothingTheme.brandPrimary),
  movie('影院', Icons.movie, NothingTheme.info),
  game('游戏', Icons.games, NothingTheme.success),
  voice('语音', Icons.record_voice_over, NothingTheme.warning),
  sleep('睡眠', Icons.bedtime, Colors.purple);

  const AudioMode(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 音效类型
enum AudioEffect {
  bass('重低音', Icons.graphic_eq),
  treble('高音', Icons.equalizer),
  surround('环绕声', Icons.surround_sound),
  vocal('人声增强', Icons.mic),
  classical('古典', Icons.piano),
  rock('摇滚', Icons.music_video),
  jazz('爵士', Icons.music_note),
  pop('流行', Icons.queue_music);

  const AudioEffect(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 音响设备
class AudioDevice {
  final String id;
  final String name;
  final AudioDeviceType type;
  final String room;
  final bool isOnline;
  final bool isPlaying;
  final int volume; // 0-100
  final AudioMode mode;
  final AudioEffect? effect;
  final String? currentTrack;
  final String? artist;
  final Duration? duration;
  final Duration? position;
  final bool isMuted;
  final bool isShuffled;
  final bool isRepeating;
  final double powerConsumption; // W

  const AudioDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    this.isOnline = true,
    this.isPlaying = false,
    this.volume = 50,
    this.mode = AudioMode.music,
    this.effect,
    this.currentTrack,
    this.artist,
    this.duration,
    this.position,
    this.isMuted = false,
    this.isShuffled = false,
    this.isRepeating = false,
    this.powerConsumption = 0.0,
  });

  AudioDevice copyWith({
    String? id,
    String? name,
    AudioDeviceType? type,
    String? room,
    bool? isOnline,
    bool? isPlaying,
    int? volume,
    AudioMode? mode,
    AudioEffect? effect,
    String? currentTrack,
    String? artist,
    Duration? duration,
    Duration? position,
    bool? isMuted,
    bool? isShuffled,
    bool? isRepeating,
    double? powerConsumption,
  }) {
    return AudioDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      room: room ?? this.room,
      isOnline: isOnline ?? this.isOnline,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      mode: mode ?? this.mode,
      effect: effect ?? this.effect,
      currentTrack: currentTrack ?? this.currentTrack,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      isMuted: isMuted ?? this.isMuted,
      isShuffled: isShuffled ?? this.isShuffled,
      isRepeating: isRepeating ?? this.isRepeating,
      powerConsumption: powerConsumption ?? this.powerConsumption,
    );
  }
}

/// 音响控制界面
class AudioControlScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const AudioControlScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<AudioControlScreen> createState() => _AudioControlScreenState();
}

class _AudioControlScreenState extends State<AudioControlScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _playAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  List<AudioDevice> _devices = [];
  AudioDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _playAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
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

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _playAnimationController,
      curve: Curves.linear,
    ));

    _loadDevices();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _playAnimationController.dispose();
    super.dispose();
  }

  void _loadDevices() {
    // 模拟设备数据
    setState(() {
      _devices = [
        AudioDevice(
          id: '1',
          name: '客厅音箱',
          type: AudioDeviceType.speaker,
          room: '客厅',
          isOnline: true,
          isPlaying: true,
          volume: 65,
          mode: AudioMode.music,
          effect: AudioEffect.bass,
          currentTrack: '宠物摇篮曲',
          artist: '轻音乐合集',
          duration: const Duration(minutes: 3, seconds: 45),
          position: const Duration(minutes: 1, seconds: 20),
          powerConsumption: 15.0,
        ),
        AudioDevice(
          id: '2',
          name: '卧室音响',
          type: AudioDeviceType.soundbar,
          room: '卧室',
          isOnline: true,
          isPlaying: false,
          volume: 40,
          mode: AudioMode.sleep,
          effect: AudioEffect.vocal,
          currentTrack: '白噪音',
          artist: '自然之声',
          duration: const Duration(hours: 8),
          position: const Duration(minutes: 45),
          powerConsumption: 0.0,
        ),
        AudioDevice(
          id: '3',
          name: '宠物房蓝牙音箱',
          type: AudioDeviceType.bluetooth,
          room: '宠物房',
          isOnline: true,
          isPlaying: true,
          volume: 30,
          mode: AudioMode.voice,
          effect: AudioEffect.classical,
          currentTrack: '宠物训练指令',
          artist: '训练师录音',
          duration: const Duration(minutes: 10),
          position: const Duration(minutes: 2, seconds: 30),
          powerConsumption: 8.0,
        ),
        AudioDevice(
          id: '4',
          name: '书房立体声',
          type: AudioDeviceType.stereo,
          room: '书房',
          isOnline: false,
          isPlaying: false,
          volume: 80,
          mode: AudioMode.music,
          powerConsumption: 0.0,
        ),
      ];
      
      if (_devices.isNotEmpty) {
        _selectedDevice = _devices.first;
        if (_selectedDevice!.isPlaying) {
          _playAnimationController.repeat();
        }
      }
    });
  }

  void _updateDevice(AudioDevice updatedDevice) {
    setState(() {
      final index = _devices.indexWhere((d) => d.id == updatedDevice.id);
      if (index != -1) {
        _devices[index] = updatedDevice;
        if (_selectedDevice?.id == updatedDevice.id) {
          _selectedDevice = updatedDevice;
          
          if (updatedDevice.isPlaying) {
            _playAnimationController.repeat();
          } else {
            _playAnimationController.stop();
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
          '音响控制',
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
            icon: const Icon(Icons.equalizer, color: NothingTheme.textPrimary),
            onPressed: () {
              // 均衡器设置
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 设备列表
            _buildDeviceList(),
            
            // 控制面板
            if (_selectedDevice != null)
              Expanded(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildControlPanel(_selectedDevice!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          final isSelected = _selectedDevice?.id == device.id;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDevice = device;
                if (device.isPlaying) {
                  _playAnimationController.repeat();
                } else {
                  _playAnimationController.stop();
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
                        device.type.icon,
                        color: device.isPlaying ? (isSelected ? Colors.white : NothingTheme.brandPrimary) : (isSelected ? Colors.white : NothingTheme.textSecondary),
                        size: 24,
                      ),
                      if (!device.isOnline)
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
                      if (device.isPlaying)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: NothingTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    device.name,
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
                    device.isPlaying ? '播放中' : '${device.volume}%',
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.8) : NothingTheme.textSecondary,
                      fontSize: 10,
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

  Widget _buildControlPanel(AudioDevice device) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 播放器卡片
          _buildPlayerCard(device),
          const SizedBox(height: 16),
          
          // 音量控制
          _buildVolumeControl(device),
          const SizedBox(height: 16),
          
          // 音效选择
          _buildAudioEffects(device),
          const SizedBox(height: 16),
          
          // 模式选择
          _buildModeSelection(device),
          const SizedBox(height: 16),
          
          // 播放控制
          _buildPlaybackControls(device),
          const SizedBox(height: 16),
          
          // 能耗统计
          _buildPowerConsumption(device),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(AudioDevice device) {
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
        children: [
          Row(
            children: [
              // 专辑封面
              RotationTransition(
                turns: device.isPlaying ? _rotationAnimation : const AlwaysStoppedAnimation(0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: device.mode.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: device.mode.color,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    device.mode.icon,
                    color: device.mode.color,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.currentTrack ?? '未播放',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    Text(
                      device.artist ?? '未知艺术家',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: NothingTheme.textSecondary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.room,
                          style: TextStyle(
                            color: NothingTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: device.isOnline ? NothingTheme.success : NothingTheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.isOnline ? '在线' : '离线',
                          style: TextStyle(
                            color: device.isOnline ? NothingTheme.success : NothingTheme.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 播放/暂停按钮
              GestureDetector(
                onTap: device.isOnline ? () {
                  _updateDevice(device.copyWith(isPlaying: !device.isPlaying));
                } : null,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: device.isOnline ? NothingTheme.brandPrimary : NothingTheme.gray200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    device.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          
          if (device.duration != null && device.position != null) ...[
            const SizedBox(height: 20),
            
            // 进度条
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: device.position!.inSeconds.toDouble(),
                    min: 0,
                    max: device.duration!.inSeconds.toDouble(),
                    activeColor: NothingTheme.brandPrimary,
                    inactiveColor: NothingTheme.gray200,
                    onChanged: device.isOnline ? (value) {
                      _updateDevice(device.copyWith(
                        position: Duration(seconds: value.round()),
                      ));
                    } : null,
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(device.position!),
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(device.duration!),
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVolumeControl(AudioDevice device) {
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
          Row(
            children: [
              const Text(
                '音量控制',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              
              GestureDetector(
                onTap: device.isOnline ? () {
                  _updateDevice(device.copyWith(isMuted: !device.isMuted));
                } : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: device.isMuted ? NothingTheme.error.withOpacity(0.1) : NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Icon(
                    device.isMuted ? Icons.volume_off : Icons.volume_up,
                    color: device.isMuted ? NothingTheme.error : NothingTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Icon(
                Icons.volume_down,
                color: NothingTheme.textSecondary,
                size: 20,
              ),
              
              Expanded(
                child: Slider(
                  value: device.isMuted ? 0 : device.volume.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: device.isMuted ? '静音' : '${device.volume}%',
                  activeColor: NothingTheme.brandPrimary,
                  inactiveColor: NothingTheme.gray200,
                  onChanged: device.isOnline ? (value) {
                    _updateDevice(device.copyWith(
                      volume: value.round(),
                      isMuted: value == 0,
                    ));
                  } : null,
                ),
              ),
              
              Icon(
                Icons.volume_up,
                color: NothingTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioEffects(AudioDevice device) {
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
            '音效选择',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AudioEffect.values.map((effect) {
              final isSelected = device.effect == effect;
              final isEnabled = device.isOnline;
              
              return GestureDetector(
                onTap: isEnabled ? () {
                  _updateDevice(device.copyWith(effect: effect));
                } : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? NothingTheme.brandPrimary : NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        effect.icon,
                        color: isSelected ? Colors.white : (isEnabled ? NothingTheme.textPrimary : NothingTheme.textSecondary),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        effect.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isEnabled ? NothingTheme.textPrimary : NothingTheme.textSecondary),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelection(AudioDevice device) {
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
            '播放模式',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AudioMode.values.map((mode) {
              final isSelected = device.mode == mode;
              final isEnabled = device.isOnline;
              
              return GestureDetector(
                onTap: isEnabled ? () {
                  _updateDevice(device.copyWith(mode: mode));
                } : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? mode.color : NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mode.icon,
                        color: isSelected ? Colors.white : (isEnabled ? NothingTheme.textPrimary : NothingTheme.textSecondary),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mode.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isEnabled ? NothingTheme.textPrimary : NothingTheme.textSecondary),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(AudioDevice device) {
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
            '播放控制',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 随机播放
              GestureDetector(
                onTap: device.isOnline ? () {
                  _updateDevice(device.copyWith(isShuffled: !device.isShuffled));
                } : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: device.isShuffled ? NothingTheme.brandPrimary.withOpacity(0.1) : NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Icon(
                    Icons.shuffle,
                    color: device.isShuffled ? NothingTheme.brandPrimary : NothingTheme.textSecondary,
                    size: 24,
                  ),
                ),
              ),
              
              // 上一首
              GestureDetector(
                onTap: device.isOnline ? () {
                  // 上一首逻辑
                } : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Icon(
                    Icons.skip_previous,
                    color: device.isOnline ? NothingTheme.textPrimary : NothingTheme.textSecondary,
                    size: 32,
                  ),
                ),
              ),
              
              // 播放/暂停
              GestureDetector(
                onTap: device.isOnline ? () {
                  _updateDevice(device.copyWith(isPlaying: !device.isPlaying));
                } : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: device.isOnline ? NothingTheme.brandPrimary : NothingTheme.gray200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    device.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              
              // 下一首
              GestureDetector(
                onTap: device.isOnline ? () {
                  // 下一首逻辑
                } : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Icon(
                    Icons.skip_next,
                    color: device.isOnline ? NothingTheme.textPrimary : NothingTheme.textSecondary,
                    size: 32,
                  ),
                ),
              ),
              
              // 循环播放
              GestureDetector(
                onTap: device.isOnline ? () {
                  _updateDevice(device.copyWith(isRepeating: !device.isRepeating));
                } : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: device.isRepeating ? NothingTheme.success.withOpacity(0.1) : NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Icon(
                    Icons.repeat,
                    color: device.isRepeating ? NothingTheme.success : NothingTheme.textSecondary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPowerConsumption(AudioDevice device) {
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
            '能耗统计',
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
                      '当前功率',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.powerConsumption.toStringAsFixed(1)} W',
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
                      '今日用电',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(device.powerConsumption * 6 / 1000).toStringAsFixed(2)} kWh',
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
                      '预估费用',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¥${(device.powerConsumption * 6 / 1000 * 0.6).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: NothingTheme.success,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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