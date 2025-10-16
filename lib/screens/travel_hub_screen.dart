import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

/// 出行状态
enum TravelStatus {
  preparing('准备中', Icons.luggage, NothingTheme.warning),
  traveling('出行中', Icons.flight_takeoff, NothingTheme.success),
  arrived('已到达', Icons.location_on, NothingTheme.brandPrimary),
  returning('返程中', Icons.flight_land, NothingTheme.info);

  const TravelStatus(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 设备连接状态
class DeviceConnection {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final bool isConnected;
  final int signalStrength; // 0-100
  final double batteryLevel; // 0-100
  final DateTime lastUpdate;

  const DeviceConnection({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.isConnected,
    required this.signalStrength,
    required this.batteryLevel,
    required this.lastUpdate,
  });
}

/// 位置信息
class LocationInfo {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;
  final double accuracy;
  final DateTime timestamp;

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    required this.accuracy,
    required this.timestamp,
  });
}

/// 出行中枢界面
class TravelHubScreen extends StatefulWidget {
  final String petId;

  const TravelHubScreen({
    super.key,
    required this.petId,
  });

  @override
  State<TravelHubScreen> createState() => _TravelHubScreenState();
}

class _TravelHubScreenState extends State<TravelHubScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TravelStatus _currentStatus = TravelStatus.preparing;
  LocationInfo? _currentLocation;
  List<DeviceConnection> _deviceConnections = [];

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _loadTravelData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadTravelData() {
    // 模拟数据加载
    setState(() {
      _currentLocation = LocationInfo(
        latitude: 39.9042,
        longitude: 116.4074,
        address: '北京市朝阳区建国门外大街1号',
        city: '北京',
        country: '中国',
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      _deviceConnections = [
        DeviceConnection(
          deviceId: 'tb001',
          deviceName: '出行箱主机',
          deviceType: 'TravelBox',
          isConnected: true,
          signalStrength: 85,
          batteryLevel: 78,
          lastUpdate: DateTime.now().subtract(const Duration(seconds: 30)),
        ),
        DeviceConnection(
          deviceId: 'cam001',
          deviceName: '宠物摄像头',
          deviceType: 'Camera',
          isConnected: true,
          signalStrength: 92,
          batteryLevel: 65,
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        DeviceConnection(
          deviceId: 'feed001',
          deviceName: '智能喂食器',
          deviceType: 'Feeder',
          isConnected: false,
          signalStrength: 0,
          batteryLevel: 45,
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        DeviceConnection(
          deviceId: 'water001',
          deviceName: '智能饮水机',
          deviceType: 'WaterFountain',
          isConnected: true,
          signalStrength: 78,
          batteryLevel: 88,
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ];
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
          '出行中枢',
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
            icon: const Icon(Icons.refresh, color: NothingTheme.textPrimary),
            onPressed: _loadTravelData,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: NothingTheme.textPrimary),
            onPressed: () {
              // 跳转到出行设置页面
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 出行状态卡片
                _buildTravelStatusCard(),
                const SizedBox(height: 16),

                // 位置信息卡片
                if (_currentLocation != null) ...[
                  _buildLocationCard(),
                  const SizedBox(height: 16),
                ],

                // 设备连接状态
                _buildDeviceConnectionsCard(),
                const SizedBox(height: 16),

                // 快捷操作
                _buildQuickActionsCard(),
                const SizedBox(height: 16),

                // 出行统计
                _buildTravelStatsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTravelStatusCard() {
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _currentStatus.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Icon(
                  _currentStatus.icon,
                  color: _currentStatus.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前状态',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentStatus.displayName,
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _currentStatus.color,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Text(
                  '实时更新',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 状态切换按钮
          Row(
            children: TravelStatus.values.map((status) {
              final isSelected = status == _currentStatus;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentStatus = status;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? status.color.withOpacity(0.1)
                          : NothingTheme.gray100,
                      borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                      border: isSelected
                          ? Border.all(color: status.color, width: 1)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          status.icon,
                          color: isSelected ? status.color : NothingTheme.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.displayName,
                          style: TextStyle(
                            color: isSelected ? status.color : NothingTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
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
              const Icon(
                Icons.location_on,
                color: NothingTheme.brandPrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '当前位置',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NothingTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: NothingTheme.success,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '精度 ${_currentLocation!.accuracy.toStringAsFixed(1)}m',
                      style: TextStyle(
                        color: NothingTheme.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            _currentLocation!.address,
            style: const TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_currentLocation!.city}, ${_currentLocation!.country}',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '纬度',
                        style: TextStyle(
                          color: NothingTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentLocation!.latitude.toStringAsFixed(4),
                        style: const TextStyle(
                          color: NothingTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '经度',
                        style: TextStyle(
                          color: NothingTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentLocation!.longitude.toStringAsFixed(4),
                        style: const TextStyle(
                          color: NothingTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceConnectionsCard() {
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
              const Icon(
                Icons.devices,
                color: NothingTheme.brandPrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '设备连接',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_deviceConnections.where((d) => d.isConnected).length}/${_deviceConnections.length} 在线',
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          for (final device in _deviceConnections) _buildDeviceItem(device),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(DeviceConnection device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: device.isConnected 
            ? NothingTheme.success.withOpacity(0.05)
            : NothingTheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
        border: Border.all(
          color: device.isConnected 
              ? NothingTheme.success.withOpacity(0.2)
              : NothingTheme.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: device.isConnected ? NothingTheme.success : NothingTheme.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName,
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  device.deviceType,
                  style: TextStyle(
                    color: NothingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (device.isConnected) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.signal_cellular_alt,
                      color: _getSignalColor(device.signalStrength),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${device.signalStrength}%',
                      style: TextStyle(
                        color: _getSignalColor(device.signalStrength),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.battery_std,
                      color: _getBatteryColor(device.batteryLevel),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${device.batteryLevel.toInt()}%',
                      style: TextStyle(
                        color: _getBatteryColor(device.batteryLevel),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            Text(
              '离线',
              style: TextStyle(
                color: NothingTheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    final actions = [
      {'title': '出行计划', 'icon': Icons.map, 'color': NothingTheme.brandPrimary},
      {'title': '设备控制', 'icon': Icons.settings_remote, 'color': NothingTheme.info},
      {'title': '紧急联系', 'icon': Icons.emergency, 'color': NothingTheme.error},
      {'title': '位置分享', 'icon': Icons.share_location, 'color': NothingTheme.success},
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
            '快捷操作',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return GestureDetector(
                onTap: () {
                  // 处理快捷操作点击
                  _handleQuickAction(action['title'] as String);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                    border: Border.all(
                      color: (action['color'] as Color).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          action['title'] as String,
                          style: TextStyle(
                            color: action['color'] as Color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTravelStatsCard() {
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
            '出行统计',
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
                child: _buildStatItem('总出行次数', '12', '次', NothingTheme.brandPrimary),
              ),
              Expanded(
                child: _buildStatItem('总出行时长', '48', '小时', NothingTheme.info),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('平均出行时长', '4', '小时', NothingTheme.success),
              ),
              Expanded(
                child: _buildStatItem('最远距离', '520', '公里', NothingTheme.warning),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(int strength) {
    if (strength >= 80) return NothingTheme.success;
    if (strength >= 50) return NothingTheme.warning;
    return NothingTheme.error;
  }

  Color _getBatteryColor(double level) {
    if (level >= 50) return NothingTheme.success;
    if (level >= 20) return NothingTheme.warning;
    return NothingTheme.error;
  }

  void _handleQuickAction(String actionTitle) {
    switch (actionTitle) {
      case '出行计划':
        // 跳转到出行计划页面
        break;
      case '设备控制':
        // 跳转到设备控制页面
        break;
      case '紧急联系':
        // 显示紧急联系对话框
        break;
      case '位置分享':
        // 分享当前位置
        break;
    }
  }
}