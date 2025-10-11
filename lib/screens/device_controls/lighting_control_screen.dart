import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 照明设备类型
enum LightingDeviceType {
  bulb('智能灯泡', Icons.lightbulb),
  strip('灯带', Icons.linear_scale),
  ceiling('吸顶灯', Icons.light),
  floor('落地灯', Icons.emoji_objects),
  table('台灯', Icons.lightbulb_outline);

  const LightingDeviceType(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 照明模式
enum LightingMode {
  manual('手动', Icons.touch_app, NothingTheme.textPrimary),
  auto('自动', Icons.auto_mode, NothingTheme.brandPrimary),
  schedule('定时', Icons.schedule, NothingTheme.info),
  scene('场景', Icons.palette, NothingTheme.success);

  const LightingMode(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 照明场景
enum LightingScene {
  bright('明亮', Icons.wb_sunny, Colors.yellow),
  warm('温馨', Icons.wb_incandescent, Colors.orange),
  relax('放松', Icons.bedtime, Colors.purple),
  focus('专注', Icons.visibility, Colors.blue),
  sleep('睡眠', Icons.nightlight, Colors.indigo),
  party('派对', Icons.celebration, Colors.pink);

  const LightingScene(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 照明设备
class LightingDevice {
  final String id;
  final String name;
  final LightingDeviceType type;
  final String room;
  final bool isOnline;
  final bool isOn;
  final int brightness; // 0-100
  final Color color;
  final int colorTemperature; // 2700K-6500K
  final LightingMode mode;
  final LightingScene? scene;
  final bool scheduleEnabled;
  final TimeOfDay? scheduleOnTime;
  final TimeOfDay? scheduleOffTime;
  final double powerConsumption; // W

  const LightingDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    this.isOnline = true,
    this.isOn = false,
    this.brightness = 100,
    this.color = Colors.white,
    this.colorTemperature = 4000,
    this.mode = LightingMode.manual,
    this.scene,
    this.scheduleEnabled = false,
    this.scheduleOnTime,
    this.scheduleOffTime,
    this.powerConsumption = 0.0,
  });

  LightingDevice copyWith({
    String? id,
    String? name,
    LightingDeviceType? type,
    String? room,
    bool? isOnline,
    bool? isOn,
    int? brightness,
    Color? color,
    int? colorTemperature,
    LightingMode? mode,
    LightingScene? scene,
    bool? scheduleEnabled,
    TimeOfDay? scheduleOnTime,
    TimeOfDay? scheduleOffTime,
    double? powerConsumption,
  }) {
    return LightingDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      room: room ?? this.room,
      isOnline: isOnline ?? this.isOnline,
      isOn: isOn ?? this.isOn,
      brightness: brightness ?? this.brightness,
      color: color ?? this.color,
      colorTemperature: colorTemperature ?? this.colorTemperature,
      mode: mode ?? this.mode,
      scene: scene ?? this.scene,
      scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
      scheduleOnTime: scheduleOnTime ?? this.scheduleOnTime,
      scheduleOffTime: scheduleOffTime ?? this.scheduleOffTime,
      powerConsumption: powerConsumption ?? this.powerConsumption,
    );
  }
}

/// 照明控制界面
class LightingControlScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const LightingControlScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<LightingControlScreen> createState() => _LightingControlScreenState();
}

class _LightingControlScreenState extends State<LightingControlScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<LightingDevice> _devices = [];
  LightingDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _loadDevices();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadDevices() {
    // 模拟设备数据
    setState(() {
      _devices = [
        const LightingDevice(
          id: '1',
          name: '客厅主灯',
          type: LightingDeviceType.ceiling,
          room: '客厅',
          isOnline: true,
          isOn: true,
          brightness: 80,
          color: Colors.white,
          colorTemperature: 4000,
          mode: LightingMode.auto,
          scene: LightingScene.bright,
          powerConsumption: 12.0,
        ),
        const LightingDevice(
          id: '2',
          name: '卧室台灯',
          type: LightingDeviceType.table,
          room: '卧室',
          isOnline: true,
          isOn: false,
          brightness: 60,
          color: Colors.orange,
          colorTemperature: 3000,
          mode: LightingMode.schedule,
          scene: LightingScene.warm,
          scheduleEnabled: true,
          scheduleOnTime: TimeOfDay(hour: 19, minute: 0),
          scheduleOffTime: TimeOfDay(hour: 23, minute: 0),
          powerConsumption: 0.0,
        ),
        const LightingDevice(
          id: '3',
          name: '宠物房灯带',
          type: LightingDeviceType.strip,
          room: '宠物房',
          isOnline: true,
          isOn: true,
          brightness: 40,
          color: Colors.purple,
          colorTemperature: 3500,
          mode: LightingMode.scene,
          scene: LightingScene.relax,
          powerConsumption: 8.0,
        ),
        const LightingDevice(
          id: '4',
          name: '阳台落地灯',
          type: LightingDeviceType.floor,
          room: '阳台',
          isOnline: false,
          isOn: false,
          brightness: 100,
          color: Colors.white,
          colorTemperature: 5000,
          mode: LightingMode.manual,
          powerConsumption: 0.0,
        ),
      ];
      
      if (_devices.isNotEmpty) {
        _selectedDevice = _devices.first;
      }
    });
  }

  void _updateDevice(LightingDevice updatedDevice) {
    setState(() {
      final index = _devices.indexWhere((d) => d.id == updatedDevice.id);
      if (index != -1) {
        _devices[index] = updatedDevice;
        if (_selectedDevice?.id == updatedDevice.id) {
          _selectedDevice = updatedDevice;
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
          '照明控制',
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
            icon: const Icon(Icons.settings, color: NothingTheme.textPrimary),
            onPressed: () {
              // 设置
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
                        color: device.isOn ? (isSelected ? Colors.white : device.color) : (isSelected ? Colors.white : NothingTheme.textSecondary),
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
                    device.isOn ? '${device.brightness}%' : '关闭',
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

  Widget _buildControlPanel(LightingDevice device) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 设备状态卡片
          _buildDeviceStatusCard(device),
          const SizedBox(height: 16),
          
          // 亮度控制
          _buildBrightnessControl(device),
          const SizedBox(height: 16),
          
          // 颜色控制
          _buildColorControl(device),
          const SizedBox(height: 16),
          
          // 色温控制
          _buildColorTemperatureControl(device),
          const SizedBox(height: 16),
          
          // 场景选择
          _buildSceneSelection(device),
          const SizedBox(height: 16),
          
          // 定时控制
          _buildScheduleControl(device),
          const SizedBox(height: 16),
          
          // 能耗统计
          _buildPowerConsumption(device),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusCard(LightingDevice device) {
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: device.isOn ? device.color.withOpacity(0.2) : NothingTheme.gray100,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Icon(
                  device.type.icon,
                  color: device.isOn ? device.color : NothingTheme.textSecondary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: NothingTheme.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.room,
                          style: TextStyle(
                            color: NothingTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        Container(
                          width: 8,
                          height: 8,
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
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Switch(
                value: device.isOn,
                onChanged: device.isOnline ? (value) {
                  _updateDevice(device.copyWith(isOn: value));
                } : null,
                activeColor: NothingTheme.brandPrimary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '亮度',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.brightness}%',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                width: 1,
                height: 40,
                color: NothingTheme.gray200,
              ),
              
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '色温',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.colorTemperature}K',
                      style: const TextStyle(
                        color: NothingTheme.brandPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                width: 1,
                height: 40,
                color: NothingTheme.gray200,
              ),
              
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '模式',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.mode.displayName,
                      style: TextStyle(
                        color: device.mode.color,
                        fontSize: 16,
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

  Widget _buildBrightnessControl(LightingDevice device) {
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
            '亮度调节',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Icon(
                Icons.brightness_low,
                color: NothingTheme.textSecondary,
                size: 20,
              ),
              
              Expanded(
                child: Slider(
                  value: device.brightness.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${device.brightness}%',
                  activeColor: NothingTheme.brandPrimary,
                  inactiveColor: NothingTheme.gray200,
                  onChanged: device.isOn && device.isOnline ? (value) {
                    _updateDevice(device.copyWith(brightness: value.round()));
                  } : null,
                ),
              ),
              
              Icon(
                Icons.brightness_high,
                color: NothingTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorControl(LightingDevice device) {
    final colors = [
      Colors.white,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
    ];

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
            '颜色选择',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((color) {
              final isSelected = device.color.value == color.value;
              final isEnabled = device.isOn && device.isOnline;
              
              return GestureDetector(
                onTap: isEnabled ? () {
                  _updateDevice(device.copyWith(color: color));
                } : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? NothingTheme.brandPrimary : NothingTheme.gray200,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: NothingTheme.brandPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.black54,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTemperatureControl(LightingDevice device) {
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
            '色温调节',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Column(
                children: [
                  Icon(
                    Icons.wb_incandescent,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '暖光',
                    style: TextStyle(
                      color: NothingTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              
              Expanded(
                child: Slider(
                  value: device.colorTemperature.toDouble(),
                  min: 2700,
                  max: 6500,
                  divisions: 38,
                  label: '${device.colorTemperature}K',
                  activeColor: NothingTheme.brandPrimary,
                  inactiveColor: NothingTheme.gray200,
                  onChanged: device.isOn && device.isOnline ? (value) {
                    _updateDevice(device.copyWith(colorTemperature: value.round()));
                  } : null,
                ),
              ),
              
              Column(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '冷光',
                    style: TextStyle(
                      color: NothingTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSceneSelection(LightingDevice device) {
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
            '场景模式',
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
            children: LightingScene.values.map((scene) {
              final isSelected = device.scene == scene;
              final isEnabled = device.isOn && device.isOnline;
              
              return GestureDetector(
                onTap: isEnabled ? () {
                  _updateDevice(device.copyWith(
                    scene: scene,
                    mode: LightingMode.scene,
                  ));
                } : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? scene.color : NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        scene.icon,
                        color: isSelected ? Colors.white : (isEnabled ? NothingTheme.textPrimary : NothingTheme.textSecondary),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        scene.displayName,
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

  Widget _buildScheduleControl(LightingDevice device) {
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
                '定时开关',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Switch(
                value: device.scheduleEnabled,
                onChanged: device.isOnline ? (value) {
                  _updateDevice(device.copyWith(
                    scheduleEnabled: value,
                    mode: value ? LightingMode.schedule : LightingMode.manual,
                  ));
                } : null,
                activeColor: NothingTheme.brandPrimary,
              ),
            ],
          ),
          
          if (device.scheduleEnabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // 选择开启时间
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NothingTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: NothingTheme.success,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '开启时间',
                            style: TextStyle(
                              color: NothingTheme.success,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            device.scheduleOnTime?.format(context) ?? '未设置',
                            style: TextStyle(
                              color: NothingTheme.success,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // 选择关闭时间
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NothingTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bedtime,
                            color: NothingTheme.error,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '关闭时间',
                            style: TextStyle(
                              color: NothingTheme.error,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            device.scheduleOffTime?.format(context) ?? '未设置',
                            style: TextStyle(
                              color: NothingTheme.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPowerConsumption(LightingDevice device) {
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
                      '${(device.powerConsumption * 8 / 1000).toStringAsFixed(2)} kWh',
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
                      '¥${(device.powerConsumption * 8 / 1000 * 0.6).toStringAsFixed(2)}',
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
}