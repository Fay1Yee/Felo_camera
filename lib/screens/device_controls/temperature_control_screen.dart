import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 温控设备类型
enum TemperatureDeviceType {
  airConditioner('空调', Icons.ac_unit),
  heater('加热器', Icons.local_fire_department),
  fan('风扇', Icons.air),
  thermostat('温控器', Icons.thermostat);

  const TemperatureDeviceType(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 温控模式
enum TemperatureMode {
  auto('自动', Icons.auto_mode, NothingTheme.brandPrimary),
  cool('制冷', Icons.ac_unit, NothingTheme.info),
  heat('制热', Icons.local_fire_department, NothingTheme.error),
  fan('送风', Icons.air, NothingTheme.success),
  dry('除湿', Icons.water_drop, NothingTheme.warning);

  const TemperatureMode(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 温控设备
class TemperatureDevice {
  final String id;
  final String name;
  final TemperatureDeviceType type;
  final String room;
  final bool isOnline;
  final bool isOn;
  final double currentTemp;
  final double targetTemp;
  final TemperatureMode mode;
  final int fanSpeed; // 1-5
  final bool timerEnabled;
  final DateTime? timerEndTime;
  final double powerConsumption; // kWh

  const TemperatureDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    this.isOnline = true,
    this.isOn = false,
    required this.currentTemp,
    required this.targetTemp,
    this.mode = TemperatureMode.auto,
    this.fanSpeed = 3,
    this.timerEnabled = false,
    this.timerEndTime,
    this.powerConsumption = 0.0,
  });

  TemperatureDevice copyWith({
    String? id,
    String? name,
    TemperatureDeviceType? type,
    String? room,
    bool? isOnline,
    bool? isOn,
    double? currentTemp,
    double? targetTemp,
    TemperatureMode? mode,
    int? fanSpeed,
    bool? timerEnabled,
    DateTime? timerEndTime,
    double? powerConsumption,
  }) {
    return TemperatureDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      room: room ?? this.room,
      isOnline: isOnline ?? this.isOnline,
      isOn: isOn ?? this.isOn,
      currentTemp: currentTemp ?? this.currentTemp,
      targetTemp: targetTemp ?? this.targetTemp,
      mode: mode ?? this.mode,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      timerEndTime: timerEndTime ?? this.timerEndTime,
      powerConsumption: powerConsumption ?? this.powerConsumption,
    );
  }
}

/// 温度控制界面
class TemperatureControlScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const TemperatureControlScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<TemperatureControlScreen> createState() => _TemperatureControlScreenState();
}

class _TemperatureControlScreenState extends State<TemperatureControlScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<TemperatureDevice> _devices = [];
  TemperatureDevice? _selectedDevice;

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
        const TemperatureDevice(
          id: '1',
          name: '客厅空调',
          type: TemperatureDeviceType.airConditioner,
          room: '客厅',
          isOnline: true,
          isOn: true,
          currentTemp: 24.5,
          targetTemp: 26.0,
          mode: TemperatureMode.cool,
          fanSpeed: 3,
          powerConsumption: 1.2,
        ),
        const TemperatureDevice(
          id: '2',
          name: '卧室空调',
          type: TemperatureDeviceType.airConditioner,
          room: '卧室',
          isOnline: true,
          isOn: false,
          currentTemp: 25.8,
          targetTemp: 24.0,
          mode: TemperatureMode.auto,
          fanSpeed: 2,
          powerConsumption: 0.0,
        ),
        TemperatureDevice(
          id: '3',
          name: '宠物房加热器',
          type: TemperatureDeviceType.heater,
          room: '宠物房',
          isOnline: true,
          isOn: true,
          currentTemp: 22.3,
          targetTemp: 23.0,
          mode: TemperatureMode.heat,
          fanSpeed: 1,
          timerEnabled: true,
          timerEndTime: DateTime.now().add(const Duration(hours: 2)),
          powerConsumption: 0.8,
        ),
        const TemperatureDevice(
          id: '4',
          name: '阳台风扇',
          type: TemperatureDeviceType.fan,
          room: '阳台',
          isOnline: false,
          isOn: false,
          currentTemp: 28.1,
          targetTemp: 26.0,
          mode: TemperatureMode.fan,
          fanSpeed: 4,
          powerConsumption: 0.0,
        ),
      ];
      
      if (_devices.isNotEmpty) {
        _selectedDevice = _devices.first;
      }
    });
  }

  void _updateDevice(TemperatureDevice updatedDevice) {
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
          '温度控制',
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
                        color: isSelected ? Colors.white : NothingTheme.textPrimary,
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
                    '${device.currentTemp.toStringAsFixed(1)}°C',
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

  Widget _buildControlPanel(TemperatureDevice device) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 设备状态卡片
          _buildDeviceStatusCard(device),
          const SizedBox(height: 16),
          
          // 温度控制
          _buildTemperatureControl(device),
          const SizedBox(height: 16),
          
          // 模式选择
          _buildModeSelection(device),
          const SizedBox(height: 16),
          
          // 风速控制
          if (device.type != TemperatureDeviceType.thermostat)
            _buildFanSpeedControl(device),
          const SizedBox(height: 16),
          
          // 定时器
          _buildTimerControl(device),
          const SizedBox(height: 16),
          
          // 能耗统计
          _buildPowerConsumption(device),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusCard(TemperatureDevice device) {
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
                  color: device.isOn ? NothingTheme.brandPrimary.withOpacity(0.1) : NothingTheme.gray100,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Icon(
                  device.type.icon,
                  color: device.isOn ? NothingTheme.brandPrimary : NothingTheme.textSecondary,
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
                      '当前温度',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.currentTemp.toStringAsFixed(1)}°C',
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
                      '目标温度',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.targetTemp.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        color: NothingTheme.brandPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
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

  Widget _buildTemperatureControl(TemperatureDevice device) {
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
            '温度调节',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              IconButton(
                onPressed: device.isOn && device.isOnline ? () {
                  final newTemp = (device.targetTemp - 1).clamp(16.0, 30.0);
                  _updateDevice(device.copyWith(targetTemp: newTemp));
                } : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: NothingTheme.gray100,
                  foregroundColor: NothingTheme.textPrimary,
                ),
              ),
              
              Expanded(
                child: Slider(
                  value: device.targetTemp,
                  min: 16.0,
                  max: 30.0,
                  divisions: 14,
                  label: '${device.targetTemp.toStringAsFixed(1)}°C',
                  activeColor: NothingTheme.brandPrimary,
                  inactiveColor: NothingTheme.gray200,
                  onChanged: device.isOn && device.isOnline ? (value) {
                    _updateDevice(device.copyWith(targetTemp: value));
                  } : null,
                ),
              ),
              
              IconButton(
                onPressed: device.isOn && device.isOnline ? () {
                  final newTemp = (device.targetTemp + 1).clamp(16.0, 30.0);
                  _updateDevice(device.copyWith(targetTemp: newTemp));
                } : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: NothingTheme.gray100,
                  foregroundColor: NothingTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelection(TemperatureDevice device) {
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
            '运行模式',
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
            children: TemperatureMode.values.map((mode) {
              final isSelected = device.mode == mode;
              final isEnabled = device.isOn && device.isOnline;
              
              return GestureDetector(
                onTap: isEnabled ? () {
                  _updateDevice(device.copyWith(mode: mode));
                } : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildFanSpeedControl(TemperatureDevice device) {
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
            '风速控制',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: device.isOn && device.isOnline ? () {
                      _updateDevice(device.copyWith(fanSpeed: i));
                    } : null,
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: device.fanSpeed >= i ? NothingTheme.brandPrimary : NothingTheme.gray100,
                        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                      ),
                      child: Center(
                        child: Text(
                          '$i',
                          style: TextStyle(
                            color: device.fanSpeed >= i ? Colors.white : NothingTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerControl(TemperatureDevice device) {
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
                '定时关闭',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Switch(
                value: device.timerEnabled,
                onChanged: device.isOn && device.isOnline ? (value) {
                  _updateDevice(device.copyWith(
                    timerEnabled: value,
                    timerEndTime: value ? DateTime.now().add(const Duration(hours: 1)) : null,
                  ));
                } : null,
                activeColor: NothingTheme.brandPrimary,
              ),
            ],
          ),
          
          if (device.timerEnabled && device.timerEndTime != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NothingTheme.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: NothingTheme.brandPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '将在 ${_formatDuration(device.timerEndTime!.difference(DateTime.now()))} 后关闭',
                    style: const TextStyle(
                      color: NothingTheme.brandPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPowerConsumption(TemperatureDevice device) {
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
                      '${device.powerConsumption.toStringAsFixed(1)} kW',
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
                      '${(device.powerConsumption * 8).toStringAsFixed(1)} kWh',
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
                      '¥${(device.powerConsumption * 8 * 0.6).toStringAsFixed(2)}',
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
    if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes.remainder(60)}分钟';
    } else {
      return '${duration.inMinutes}分钟';
    }
  }
}