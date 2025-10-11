import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/pet_profile.dart';

/// IoT设备类型
enum DeviceType {
  light('灯光', Icons.lightbulb_outline, '智能照明'),
  fan('风扇', Icons.air, '空气循环'),
  heater('加热器', Icons.thermostat, '温度控制'),
  camera('摄像头', Icons.videocam, '安全监控'),
  feeder('喂食器', Icons.restaurant, '自动喂食'),
  waterFountain('饮水机', Icons.water_drop, '智能饮水'),
  airPurifier('空气净化器', Icons.air, '空气净化'),
  musicPlayer('音响', Icons.music_note, '音乐播放');

  const DeviceType(this.displayName, this.icon, this.description);
  
  final String displayName;
  final IconData icon;
  final String description;
}

/// 设备状态
class DeviceStatus {
  final bool isOnline;
  final bool isEnabled;
  final double value; // 0-100 的值，如亮度、温度等
  final String status;
  final DateTime lastUpdate;

  const DeviceStatus({
    required this.isOnline,
    required this.isEnabled,
    required this.value,
    required this.status,
    required this.lastUpdate,
  });
}

/// IoT设备模型
class IoTDevice {
  final String id;
  final String name;
  final DeviceType type;
  final String room;
  final DeviceStatus status;
  final List<String> supportedActions;
  final Map<String, dynamic> properties;

  const IoTDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    required this.status,
    required this.supportedActions,
    required this.properties,
  });

  static List<IoTDevice> getMockDevices() {
    return [
      IoTDevice(
        id: 'light_001',
        name: '客厅主灯',
        type: DeviceType.light,
        room: '客厅',
        status: DeviceStatus(
          isOnline: true,
          isEnabled: true,
          value: 75,
          status: '正常',
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        supportedActions: ['toggle', 'brightness', 'color'],
        properties: {'brightness': 75, 'color': 'warm'},
      ),
      IoTDevice(
        id: 'fan_001',
        name: '卧室风扇',
        type: DeviceType.fan,
        room: '卧室',
        status: DeviceStatus(
          isOnline: true,
          isEnabled: false,
          value: 0,
          status: '待机',
          lastUpdate: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        supportedActions: ['toggle', 'speed', 'timer'],
        properties: {'speed': 0, 'timer': 0},
      ),
      IoTDevice(
        id: 'heater_001',
        name: '宠物加热垫',
        type: DeviceType.heater,
        room: '宠物区',
        status: DeviceStatus(
          isOnline: true,
          isEnabled: true,
          value: 28,
          status: '加热中',
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        supportedActions: ['toggle', 'temperature'],
        properties: {'temperature': 28, 'targetTemp': 30},
      ),
      IoTDevice(
        id: 'camera_001',
        name: '宠物监控',
        type: DeviceType.camera,
        room: '宠物区',
        status: DeviceStatus(
          isOnline: true,
          isEnabled: true,
          value: 100,
          status: '录制中',
          lastUpdate: DateTime.now(),
        ),
        supportedActions: ['toggle', 'record', 'snapshot'],
        properties: {'recording': true, 'nightVision': false},
      ),
      IoTDevice(
        id: 'feeder_001',
        name: '自动喂食器',
        type: DeviceType.feeder,
        room: '宠物区',
        status: DeviceStatus(
          isOnline: true,
          isEnabled: true,
          value: 60,
          status: '正常',
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        supportedActions: ['feed', 'schedule', 'portion'],
        properties: {'foodLevel': 60, 'nextFeed': '18:00'},
      ),
      IoTDevice(
        id: 'water_001',
        name: '智能饮水机',
        type: DeviceType.waterFountain,
        room: '宠物区',
        status: DeviceStatus(
          isOnline: true,
          isEnabled: true,
          value: 80,
          status: '正常',
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        supportedActions: ['toggle', 'filter', 'level'],
        properties: {'waterLevel': 80, 'filterLife': 85},
      ),
    ];
  }
}

/// 增强版设备控制面板
class EnhancedDeviceControlPanel extends StatefulWidget {
  final ScenarioMode currentScenario;
  final Function(IoTDevice, String, dynamic)? onDeviceAction;

  const EnhancedDeviceControlPanel({
    super.key,
    required this.currentScenario,
    this.onDeviceAction,
  });

  @override
  State<EnhancedDeviceControlPanel> createState() => _EnhancedDeviceControlPanelState();
}

class _EnhancedDeviceControlPanelState extends State<EnhancedDeviceControlPanel>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  List<IoTDevice> _devices = [];
  String _selectedRoom = '全部';
  DeviceType? _selectedType;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    setState(() {
      _devices = IoTDevice.getMockDevices();
    });
  }

  List<IoTDevice> get _filteredDevices {
    return _devices.where((device) {
      final roomMatch = _selectedRoom == '全部' || device.room == _selectedRoom;
      final typeMatch = _selectedType == null || device.type == _selectedType;
      return roomMatch && typeMatch;
    }).toList();
  }

  List<String> get _availableRooms {
    final rooms = _devices.map((d) => d.room).toSet().toList();
    return ['全部', ...rooms];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: NothingTheme.blackAlpha10,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildFilters(),
                  _buildDeviceGrid(),
                  _buildScenarioActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final onlineCount = _devices.where((d) => d.status.isOnline).length;
    final enabledCount = _devices.where((d) => d.status.isEnabled).length;
    
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NothingTheme.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.devices,
                  color: NothingTheme.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: NothingTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IoT设备控制',
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeLg,
                        fontWeight: NothingTheme.fontWeightSemiBold,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '在线: $onlineCount/${_devices.length} | 运行: $enabledCount',
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeSm,
                        color: NothingTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildScenarioIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioIndicator() {
    Color scenarioColor;
    switch (widget.currentScenario) {
      case ScenarioMode.home:
        scenarioColor = Colors.blue;
        break;
      case ScenarioMode.travel:
        scenarioColor = Colors.orange;
        break;
      case ScenarioMode.medical:
        scenarioColor = Colors.red;
        break;
      case ScenarioMode.urban:
        scenarioColor = Colors.green;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scenarioColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scenarioColor.withOpacity(0.3)),
      ),
      child: Text(
        widget.currentScenario.displayName,
        style: TextStyle(
          fontSize: NothingTheme.fontSizeXs,
          fontWeight: NothingTheme.fontWeightMedium,
          color: scenarioColor,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 房间筛选
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableRooms.map((room) {
                final isSelected = room == _selectedRoom;
                return Padding(
                  padding: const EdgeInsets.only(right: NothingTheme.spacingSmall),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRoom = room),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? NothingTheme.brandPrimary
                            : NothingTheme.surfaceTertiary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        room,
                        style: TextStyle(
                          fontSize: NothingTheme.fontSizeSm,
                          fontWeight: NothingTheme.fontWeightMedium,
                          color: isSelected
                              ? NothingTheme.surface
                              : NothingTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: NothingTheme.spacingMedium),
          
          // 设备类型筛选
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedType = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedType == null
                          ? NothingTheme.brandSecondary
                          : NothingTheme.surfaceTertiary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '全部类型',
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeSm,
                        fontWeight: NothingTheme.fontWeightMedium,
                        color: _selectedType == null
                            ? NothingTheme.surface
                            : NothingTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: NothingTheme.spacingSmall),
                ...DeviceType.values.map((type) {
                  final isSelected = type == _selectedType;
                  return Padding(
                    padding: const EdgeInsets.only(right: NothingTheme.spacingSmall),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? NothingTheme.brandSecondary
                              : NothingTheme.surfaceTertiary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type.icon,
                              size: 14,
                              color: isSelected
                                  ? NothingTheme.surface
                                  : NothingTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              type.displayName,
                              style: TextStyle(
                                fontSize: NothingTheme.fontSizeSm,
                                fontWeight: NothingTheme.fontWeightMedium,
                                color: isSelected
                                    ? NothingTheme.surface
                                    : NothingTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceGrid() {
    final filteredDevices = _filteredDevices;
    
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '设备列表 (${filteredDevices.length})',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightSemiBold,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: NothingTheme.spacingMedium,
              crossAxisSpacing: NothingTheme.spacingMedium,
              childAspectRatio: 1.1,
            ),
            itemCount: filteredDevices.length,
            itemBuilder: (context, index) {
              return _buildDeviceCard(filteredDevices[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(IoTDevice device) {
    final isOnline = device.status.isOnline;
    final isEnabled = device.status.isEnabled;
    
    return GestureDetector(
      onTap: () => _showDeviceDetails(device),
      child: Container(
        padding: const EdgeInsets.all(NothingTheme.spacingMedium),
        decoration: BoxDecoration(
          color: NothingTheme.surfaceTertiary,
          borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
          border: Border.all(
            color: isOnline
                ? (isEnabled ? NothingTheme.success : NothingTheme.gray300)
                : NothingTheme.error,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备头部
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? (isEnabled ? NothingTheme.success : NothingTheme.gray400)
                        : NothingTheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    device.type.icon,
                    size: 16,
                    color: NothingTheme.surface,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? NothingTheme.success : NothingTheme.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: NothingTheme.spacingSmall),
            
            // 设备名称
            Text(
              device.name,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeSm,
                fontWeight: NothingTheme.fontWeightSemiBold,
                color: NothingTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // 房间和状态
            Text(
              '${device.room} • ${device.status.status}',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeXs,
                color: NothingTheme.textSecondary,
              ),
            ),
            
            const Spacer(),
            
            // 控制按钮
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isOnline ? () => _toggleDevice(device) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? NothingTheme.warning.withOpacity(0.1)
                            : NothingTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isEnabled ? '关闭' : '开启',
                        style: TextStyle(
                          fontSize: NothingTheme.fontSizeXs,
                          fontWeight: NothingTheme.fontWeightMedium,
                          color: isEnabled ? NothingTheme.warning : NothingTheme.success,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showDeviceDetails(device),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: NothingTheme.brandPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.settings,
                      size: 12,
                      color: NothingTheme.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioActions() {
    List<Map<String, dynamic>> actions = [];
    
    switch (widget.currentScenario) {
      case ScenarioMode.home:
        actions = [
          {'title': '回家模式', 'icon': Icons.home, 'color': Colors.blue},
          {'title': '离家模式', 'icon': Icons.exit_to_app, 'color': Colors.orange},
          {'title': '睡眠模式', 'icon': Icons.bedtime, 'color': Colors.purple},
        ];
        break;
      case ScenarioMode.travel:
        actions = [
          {'title': '出行准备', 'icon': Icons.luggage, 'color': Colors.orange},
          {'title': '远程监控', 'icon': Icons.visibility, 'color': Colors.blue},
          {'title': '节能模式', 'icon': Icons.eco, 'color': Colors.green},
        ];
        break;
      case ScenarioMode.medical:
        actions = [
          {'title': '健康监测', 'icon': Icons.health_and_safety, 'color': Colors.red},
          {'title': '紧急模式', 'icon': Icons.emergency, 'color': Colors.red},
          {'title': '康复辅助', 'icon': Icons.healing, 'color': Colors.pink},
        ];
        break;
      case ScenarioMode.urban:
        actions = [
          {'title': '城市适应', 'icon': Icons.location_city, 'color': Colors.green},
          {'title': '噪音控制', 'icon': Icons.volume_down, 'color': Colors.blue},
          {'title': '空气净化', 'icon': Icons.air, 'color': Colors.cyan},
        ];
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '场景操作',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightSemiBold,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          Row(
            children: actions.map((action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: NothingTheme.spacingSmall),
                child: GestureDetector(
                  onTap: () => _executeScenarioAction(action['title']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: NothingTheme.spacingMedium,
                    ),
                    decoration: BoxDecoration(
                      color: action['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                      border: Border.all(
                        color: action['color'].withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          action['icon'],
                          color: action['color'],
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          action['title'],
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeXs,
                            fontWeight: NothingTheme.fontWeightMedium,
                            color: action['color'],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _toggleDevice(IoTDevice device) {
    // 模拟设备开关操作
    widget.onDeviceAction?.call(device, 'toggle', !device.status.isEnabled);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${device.name} 已${device.status.isEnabled ? '关闭' : '开启'}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showDeviceDetails(IoTDevice device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDeviceDetailsSheet(device),
    );
  }

  Widget _buildDeviceDetailsSheet(IoTDevice device) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(NothingTheme.radiusLg),
        ),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: NothingTheme.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 设备详情内容
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(NothingTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 设备头部信息
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: NothingTheme.brandPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          device.type.icon,
                          color: NothingTheme.brandPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: NothingTheme.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.name,
                              style: TextStyle(
                                fontSize: NothingTheme.fontSizeLg,
                                fontWeight: NothingTheme.fontWeightSemiBold,
                                color: NothingTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${device.room} • ${device.type.description}',
                              style: TextStyle(
                                fontSize: NothingTheme.fontSizeSm,
                                color: NothingTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: device.status.isOnline
                              ? NothingTheme.success.withOpacity(0.1)
                              : NothingTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          device.status.isOnline ? '在线' : '离线',
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeXs,
                            fontWeight: NothingTheme.fontWeightMedium,
                            color: device.status.isOnline
                                ? NothingTheme.success
                                : NothingTheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: NothingTheme.spacingLarge),
                  
                  // 设备控制区域
                  Text(
                    '设备控制',
                    style: TextStyle(
                      fontSize: NothingTheme.fontSizeBase,
                      fontWeight: NothingTheme.fontWeightSemiBold,
                      color: NothingTheme.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: NothingTheme.spacingMedium),
                  
                  // 根据设备类型显示不同的控制选项
                  _buildDeviceControls(device),
                  
                  const Spacer(),
                  
                  // 关闭按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NothingTheme.brandPrimary,
                        foregroundColor: NothingTheme.surface,
                        padding: const EdgeInsets.symmetric(
                          vertical: NothingTheme.spacingMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                        ),
                      ),
                      child: const Text('关闭'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceControls(IoTDevice device) {
    switch (device.type) {
      case DeviceType.light:
        return _buildLightControls(device);
      case DeviceType.fan:
        return _buildFanControls(device);
      case DeviceType.heater:
        return _buildHeaterControls(device);
      case DeviceType.camera:
        return _buildCameraControls(device);
      case DeviceType.feeder:
        return _buildFeederControls(device);
      case DeviceType.waterFountain:
        return _buildWaterFountainControls(device);
      default:
        return _buildGenericControls(device);
    }
  }

  Widget _buildLightControls(IoTDevice device) {
    return Column(
      children: [
        // 开关控制
        _buildSwitchControl('灯光开关', device.status.isEnabled),
        const SizedBox(height: NothingTheme.spacingMedium),
        
        // 亮度控制
        _buildSliderControl('亮度', device.status.value, '%'),
        const SizedBox(height: NothingTheme.spacingMedium),
        
        // 颜色模式
        _buildOptionControl('颜色模式', ['暖光', '冷光', '自然光'], '暖光'),
      ],
    );
  }

  Widget _buildFanControls(IoTDevice device) {
    return Column(
      children: [
        _buildSwitchControl('风扇开关', device.status.isEnabled),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildSliderControl('风速', device.status.value, '档'),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildOptionControl('模式', ['自然风', '睡眠风', '强风'], '自然风'),
      ],
    );
  }

  Widget _buildHeaterControls(IoTDevice device) {
    return Column(
      children: [
        _buildSwitchControl('加热器开关', device.status.isEnabled),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildSliderControl('目标温度', device.status.value, '°C'),
      ],
    );
  }

  Widget _buildCameraControls(IoTDevice device) {
    return Column(
      children: [
        _buildSwitchControl('摄像头开关', device.status.isEnabled),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildSwitchControl('录制功能', true),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildSwitchControl('夜视模式', false),
      ],
    );
  }

  Widget _buildFeederControls(IoTDevice device) {
    return Column(
      children: [
        _buildActionButton('立即喂食', Icons.restaurant, NothingTheme.brandPrimary),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildSliderControl('食物余量', device.status.value, '%'),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildOptionControl('喂食量', ['少量', '正常', '大量'], '正常'),
      ],
    );
  }

  Widget _buildWaterFountainControls(IoTDevice device) {
    return Column(
      children: [
        _buildSwitchControl('饮水机开关', device.status.isEnabled),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildSliderControl('水位', device.status.value, '%'),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildSliderControl('滤芯寿命', 85, '%'),
      ],
    );
  }

  Widget _buildGenericControls(IoTDevice device) {
    return Column(
      children: [
        _buildSwitchControl('设备开关', device.status.isEnabled),
        const SizedBox(height: NothingTheme.spacingMedium),
        _buildSliderControl('设备参数', device.status.value, ''),
      ],
    );
  }

  Widget _buildSwitchControl(String title, bool value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              color: NothingTheme.textPrimary,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            // 处理开关变化
          },
          activeColor: NothingTheme.brandPrimary,
        ),
      ],
    );
  }

  Widget _buildSliderControl(String title, double value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBase,
                color: NothingTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${value.toInt()}$unit',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBase,
                fontWeight: NothingTheme.fontWeightMedium,
                color: NothingTheme.brandPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: NothingTheme.brandPrimary,
            inactiveTrackColor: NothingTheme.gray300,
            thumbColor: NothingTheme.brandPrimary,
            overlayColor: NothingTheme.brandPrimary.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: (newValue) {
              // 处理滑块变化
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionControl(String title, List<String> options, String selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: NothingTheme.fontSizeBase,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.map((option) {
            final isSelected = option == selected;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    // 处理选项变化
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? NothingTheme.brandPrimary
                          : NothingTheme.surfaceTertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeSm,
                        fontWeight: NothingTheme.fontWeightMedium,
                        color: isSelected
                            ? NothingTheme.surface
                            : NothingTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // 处理按钮点击
        },
        icon: Icon(icon, size: 18),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: NothingTheme.surface,
          padding: const EdgeInsets.symmetric(
            vertical: NothingTheme.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
          ),
        ),
      ),
    );
  }

  void _executeScenarioAction(String actionTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('执行场景操作: $actionTitle'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}