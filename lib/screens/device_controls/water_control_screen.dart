import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 饮水器类型
enum WaterDeviceType {
  fountain('循环饮水机', Icons.water_drop),
  smart('智能饮水器', Icons.smart_toy),
  gravity('重力饮水器', Icons.arrow_downward),
  filter('过滤饮水器', Icons.filter_alt);

  const WaterDeviceType(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 饮水器状态
enum WaterDeviceStatus {
  online('在线', NothingTheme.success),
  offline('离线', NothingTheme.error),
  pumping('补水中', NothingTheme.warning),
  lowWater('水位不足', NothingTheme.error),
  filterExpired('滤芯过期', NothingTheme.warning),
  maintenance('维护中', NothingTheme.info);

  const WaterDeviceStatus(this.displayName, this.color);
  
  final String displayName;
  final Color color;
}

/// 水质等级
enum WaterQuality {
  excellent('优秀', NothingTheme.success),
  good('良好', NothingTheme.info),
  fair('一般', NothingTheme.warning),
  poor('较差', NothingTheme.error);

  const WaterQuality(this.displayName, this.color);
  
  final String displayName;
  final Color color;
}

/// 饮水记录
class DrinkingRecord {
  final String id;
  final DateTime timestamp;
  final double amount; // ml
  final Duration duration;
  final double waterTemperature; // 摄氏度
  final WaterQuality quality;

  const DrinkingRecord({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.duration,
    this.waterTemperature = 25.0,
    this.quality = WaterQuality.good,
  });
}

/// 水质检测数据
class WaterQualityData {
  final DateTime timestamp;
  final double ph; // pH值
  final double tds; // 总溶解固体 (ppm)
  final double temperature; // 温度 (°C)
  final double chlorine; // 余氯 (mg/L)
  final WaterQuality overallQuality;

  const WaterQualityData({
    required this.timestamp,
    required this.ph,
    required this.tds,
    required this.temperature,
    required this.chlorine,
    required this.overallQuality,
  });
}

/// 滤芯信息
class FilterInfo {
  final String id;
  final String name;
  final DateTime installDate;
  final int lifespanDays;
  final double usagePercent; // 0-100
  final bool needsReplacement;

  const FilterInfo({
    required this.id,
    required this.name,
    required this.installDate,
    this.lifespanDays = 90,
    this.usagePercent = 0.0,
    this.needsReplacement = false,
  });

  int get remainingDays {
    final usedDays = DateTime.now().difference(installDate).inDays;
    return (lifespanDays - usedDays).clamp(0, lifespanDays);
  }

  bool get isExpiringSoon => remainingDays <= 7;
}

/// 饮水器设备
class WaterDevice {
  final String id;
  final String name;
  final WaterDeviceType type;
  final String location;
  final WaterDeviceStatus status;
  final double currentWaterLevel; // 0-100%
  final double waterCapacity; // ml
  final int batteryLevel; // 0-100, -1 for wired
  final bool autoRefill;
  final bool pumpEnabled;
  final bool ledEnabled;
  final FilterInfo? filter;
  final WaterQualityData? latestQuality;
  final List<DrinkingRecord> recentRecords;

  const WaterDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    this.status = WaterDeviceStatus.offline,
    this.currentWaterLevel = 0.0,
    this.waterCapacity = 2000.0,
    this.batteryLevel = -1,
    this.autoRefill = true,
    this.pumpEnabled = true,
    this.ledEnabled = true,
    this.filter,
    this.latestQuality,
    this.recentRecords = const [],
  });

  WaterDevice copyWith({
    String? id,
    String? name,
    WaterDeviceType? type,
    String? location,
    WaterDeviceStatus? status,
    double? currentWaterLevel,
    double? waterCapacity,
    int? batteryLevel,
    bool? autoRefill,
    bool? pumpEnabled,
    bool? ledEnabled,
    FilterInfo? filter,
    WaterQualityData? latestQuality,
    List<DrinkingRecord>? recentRecords,
  }) {
    return WaterDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      status: status ?? this.status,
      currentWaterLevel: currentWaterLevel ?? this.currentWaterLevel,
      waterCapacity: waterCapacity ?? this.waterCapacity,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      autoRefill: autoRefill ?? this.autoRefill,
      pumpEnabled: pumpEnabled ?? this.pumpEnabled,
      ledEnabled: ledEnabled ?? this.ledEnabled,
      filter: filter ?? this.filter,
      latestQuality: latestQuality ?? this.latestQuality,
      recentRecords: recentRecords ?? this.recentRecords,
    );
  }

  double get currentWaterAmount => waterCapacity * (currentWaterLevel / 100);
}

/// 饮水控制界面
class WaterControlScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const WaterControlScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<WaterControlScreen> createState() => _WaterControlScreenState();
}

class _WaterControlScreenState extends State<WaterControlScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pumpController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _waveAnimation;

  List<WaterDevice> _waterDevices = [];
  WaterDevice? _selectedDevice;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pumpController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pumpController,
      curve: Curves.easeInOut,
    ));

    _loadWaterDevices();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pumpController.dispose();
    super.dispose();
  }

  void _loadWaterDevices() {
    // 模拟饮水器数据
    setState(() {
      _waterDevices = [
        WaterDevice(
          id: '1',
          name: '客厅循环饮水机',
          type: WaterDeviceType.fountain,
          location: '客厅',
          status: WaterDeviceStatus.online,
          currentWaterLevel: 85.0,
          waterCapacity: 3000.0,
          batteryLevel: -1,
          autoRefill: true,
          pumpEnabled: true,
          ledEnabled: true,
          filter: FilterInfo(
            id: '1',
            name: '活性炭滤芯',
            installDate: DateTime.now().subtract(const Duration(days: 45)),
            lifespanDays: 90,
            usagePercent: 50.0,
          ),
          latestQuality: WaterQualityData(
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            ph: 7.2,
            tds: 120.0,
            temperature: 24.5,
            chlorine: 0.1,
            overallQuality: WaterQuality.excellent,
          ),
          recentRecords: [
            DrinkingRecord(
              id: '1',
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              amount: 150.0,
              duration: const Duration(minutes: 3),
              waterTemperature: 24.5,
              quality: WaterQuality.excellent,
            ),
            DrinkingRecord(
              id: '2',
              timestamp: DateTime.now().subtract(const Duration(hours: 4)),
              amount: 200.0,
              duration: const Duration(minutes: 5),
              waterTemperature: 24.8,
              quality: WaterQuality.excellent,
            ),
          ],
        ),
        WaterDevice(
          id: '2',
          name: '智能饮水器',
          type: WaterDeviceType.smart,
          location: '卧室',
          status: WaterDeviceStatus.online,
          currentWaterLevel: 45.0,
          waterCapacity: 2000.0,
          batteryLevel: 72,
          autoRefill: false,
          pumpEnabled: false,
          ledEnabled: true,
          latestQuality: WaterQualityData(
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            ph: 6.8,
            tds: 180.0,
            temperature: 25.2,
            chlorine: 0.2,
            overallQuality: WaterQuality.good,
          ),
        ),
        WaterDevice(
          id: '3',
          name: '户外饮水器',
          type: WaterDeviceType.gravity,
          location: '阳台',
          status: WaterDeviceStatus.lowWater,
          currentWaterLevel: 15.0,
          waterCapacity: 1500.0,
          batteryLevel: 35,
          autoRefill: false,
          pumpEnabled: false,
          ledEnabled: false,
        ),
      ];
      
      if (_waterDevices.isNotEmpty) {
        _selectedDevice = _waterDevices.first;
        if (_selectedDevice!.status == WaterDeviceStatus.pumping) {
          _pumpController.repeat();
        }
      }
    });
  }

  void _updateDevice(WaterDevice updatedDevice) {
    setState(() {
      final index = _waterDevices.indexWhere((d) => d.id == updatedDevice.id);
      if (index != -1) {
        _waterDevices[index] = updatedDevice;
        if (_selectedDevice?.id == updatedDevice.id) {
          _selectedDevice = updatedDevice;
          
          if (updatedDevice.status == WaterDeviceStatus.pumping) {
            _pumpController.repeat();
          } else {
            _pumpController.stop();
          }
        }
      }
    });
  }

  void _startRefill() {
    if (_selectedDevice?.status == WaterDeviceStatus.online || 
        _selectedDevice?.status == WaterDeviceStatus.lowWater) {
      _updateDevice(_selectedDevice!.copyWith(
        status: WaterDeviceStatus.pumping,
      ));
      
      // 模拟补水过程
      Future.delayed(const Duration(seconds: 5), () {
        _updateDevice(_selectedDevice!.copyWith(
          status: WaterDeviceStatus.online,
          currentWaterLevel: (_selectedDevice!.currentWaterLevel + 20).clamp(0, 100),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        title: const Text(
          '饮水控制',
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
            icon: const Icon(Icons.add, color: NothingTheme.textPrimary),
            onPressed: () {
              // 添加饮水器
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 饮水器列表
            _buildDeviceList(),
            
            // 标签页
            _buildTabBar(),
            
            // 内容区域
            if (_selectedDevice != null)
              Expanded(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildTabContent(_selectedDevice!),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _selectedDevice != null && 
          (_selectedDevice!.status == WaterDeviceStatus.online || 
           _selectedDevice!.status == WaterDeviceStatus.lowWater)
          ? FloatingActionButton(
              onPressed: _startRefill,
              backgroundColor: NothingTheme.info,
              child: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_waveAnimation.value * 0.1),
                    child: const Icon(
                      Icons.water_drop,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }

  Widget _buildDeviceList() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _waterDevices.length,
        itemBuilder: (context, index) {
          final device = _waterDevices[index];
          final isSelected = _selectedDevice?.id == device.id;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDevice = device;
                if (device.status == WaterDeviceStatus.pumping) {
                  _pumpController.repeat();
                } else {
                  _pumpController.stop();
                }
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? NothingTheme.info : NothingTheme.surface,
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
                        color: isSelected ? Colors.white : device.status.color,
                        size: 24,
                      ),
                      if (device.status == WaterDeviceStatus.lowWater || 
                          device.status == WaterDeviceStatus.offline)
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
                    device.status.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.8) : device.status.color,
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
    final tabs = ['设备状态', '水质检测', '饮水记录', '设备设置'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final title = entry.value;
            final isSelected = _currentTabIndex == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? NothingTheme.info : Colors.transparent,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : NothingTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(WaterDevice device) {
    switch (_currentTabIndex) {
      case 0:
        return _buildStatusView(device);
      case 1:
        return _buildQualityView(device);
      case 2:
        return _buildRecordsView(device);
      case 3:
        return _buildSettingsView(device);
      default:
        return _buildStatusView(device);
    }
  }

  Widget _buildStatusView(WaterDevice device) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 设备状态卡片
          _buildDeviceStatusCard(device),
          const SizedBox(height: 16),
          
          // 水位信息
          _buildWaterLevelCard(device),
          const SizedBox(height: 16),
          
          // 滤芯信息
          if (device.filter != null)
            _buildFilterCard(device.filter!),
          
          // 电池信息
          if (device.batteryLevel >= 0)
            const SizedBox(height: 16),
          if (device.batteryLevel >= 0)
            _buildBatteryCard(device),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusCard(WaterDevice device) {
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: device.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Icon(
                  device.type.icon,
                  color: device.status.color,
                  size: 24,
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
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: device.status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          device.status.displayName,
                          style: TextStyle(
                            color: device.status.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStatusItem('设备类型', device.type.displayName),
              ),
              Expanded(
                child: _buildStatusItem('安装位置', device.location),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: NothingTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterLevelCard(WaterDevice device) {
    final levelColor = device.currentWaterLevel > 50
        ? NothingTheme.info
        : device.currentWaterLevel > 20
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
          Row(
            children: [
              Icon(
                Icons.water_drop,
                color: levelColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '水位状态',
                      style: TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.currentWaterAmount.toStringAsFixed(0)}ml / ${device.waterCapacity.toStringAsFixed(0)}ml',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              Text(
                '${device.currentWaterLevel.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: levelColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          LinearProgressIndicator(
            value: device.currentWaterLevel / 100,
            backgroundColor: NothingTheme.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(levelColor),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildWaterInfo('当前水量', '${device.currentWaterAmount.toStringAsFixed(0)}ml'),
              ),
              Expanded(
                child: _buildWaterInfo('总容量', '${device.waterCapacity.toStringAsFixed(0)}ml'),
              ),
              Expanded(
                child: _buildWaterInfo('剩余天数', _calculateRemainingDays(device)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: NothingTheme.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _calculateRemainingDays(WaterDevice device) {
    // 基于历史饮水记录估算剩余天数
    if (device.recentRecords.isEmpty) return '未知';
    
    final dailyConsumption = device.recentRecords
        .fold<double>(0, (sum, record) => sum + record.amount) / 7; // 假设7天平均
    
    if (dailyConsumption <= 0) return '未知';
    
    final remainingDays = (device.currentWaterAmount / dailyConsumption).floor();
    return '${remainingDays}天';
  }

  Widget _buildFilterCard(FilterInfo filter) {
    final filterColor = filter.needsReplacement
        ? NothingTheme.error
        : filter.isExpiringSoon
            ? NothingTheme.warning
            : NothingTheme.success;

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
              Icon(
                Icons.filter_alt,
                color: filterColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '滤芯状态',
                      style: TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filter.name,
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (filter.needsReplacement)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NothingTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Text(
                    '需更换',
                    style: TextStyle(
                      color: NothingTheme.error,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          LinearProgressIndicator(
            value: filter.usagePercent / 100,
            backgroundColor: NothingTheme.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(filterColor),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildFilterInfo('使用天数', '${filter.lifespanDays - filter.remainingDays}天'),
              ),
              Expanded(
                child: _buildFilterInfo('剩余天数', '${filter.remainingDays}天'),
              ),
              Expanded(
                child: _buildFilterInfo('使用率', '${filter.usagePercent.toStringAsFixed(0)}%'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: NothingTheme.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryCard(WaterDevice device) {
    final batteryColor = device.batteryLevel > 50
        ? NothingTheme.success
        : device.batteryLevel > 20
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
      child: Row(
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
                const Text(
                  '电池电量',
                  style: TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                
                LinearProgressIndicator(
                  value: device.batteryLevel / 100,
                  backgroundColor: NothingTheme.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          Text(
            '${device.batteryLevel}%',
            style: TextStyle(
              color: batteryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityView(WaterDevice device) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '水质检测',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          if (device.latestQuality != null)
            _buildQualityCard(device.latestQuality!)
          else
            _buildNoQualityData(),
        ],
      ),
    );
  }

  Widget _buildQualityCard(WaterQualityData quality) {
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: quality.overallQuality.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: quality.overallQuality.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '水质状态',
                      style: TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quality.overallQuality.displayName,
                      style: TextStyle(
                        color: quality.overallQuality.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              Text(
                _formatDateTime(quality.timestamp),
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 水质参数
          Row(
            children: [
              Expanded(
                child: _buildQualityParameter(
                  'pH值',
                  quality.ph.toStringAsFixed(1),
                  _getPhColor(quality.ph),
                ),
              ),
              Expanded(
                child: _buildQualityParameter(
                  'TDS',
                  '${quality.tds.toStringAsFixed(0)} ppm',
                  _getTdsColor(quality.tds),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQualityParameter(
                  '温度',
                  '${quality.temperature.toStringAsFixed(1)}°C',
                  NothingTheme.info,
                ),
              ),
              Expanded(
                child: _buildQualityParameter(
                  '余氯',
                  '${quality.chlorine.toStringAsFixed(2)} mg/L',
                  _getChlorineColor(quality.chlorine),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityParameter(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPhColor(double ph) {
    if (ph >= 6.5 && ph <= 8.5) return NothingTheme.success;
    if (ph >= 6.0 && ph <= 9.0) return NothingTheme.warning;
    return NothingTheme.error;
  }

  Color _getTdsColor(double tds) {
    if (tds <= 150) return NothingTheme.success;
    if (tds <= 300) return NothingTheme.warning;
    return NothingTheme.error;
  }

  Color _getChlorineColor(double chlorine) {
    if (chlorine <= 0.5) return NothingTheme.success;
    if (chlorine <= 1.0) return NothingTheme.warning;
    return NothingTheme.error;
  }

  Widget _buildNoQualityData() {
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
            Icons.science,
            color: NothingTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无水质数据',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // 开始检测
            },
            child: const Text('开始检测'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsView(WaterDevice device) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日统计
          _buildTodayStats(device),
          const SizedBox(height: 16),
          
          const Text(
            '饮水记录',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          if (device.recentRecords.isEmpty)
            _buildEmptyRecords()
          else
            ...device.recentRecords.map((record) => _buildRecordItem(record)),
        ],
      ),
    );
  }

  Widget _buildTodayStats(WaterDevice device) {
    // 计算今日饮水量
    final today = DateTime.now();
    final todayRecords = device.recentRecords.where((record) {
      return record.timestamp.year == today.year &&
          record.timestamp.month == today.month &&
          record.timestamp.day == today.day;
    }).toList();

    final totalAmount = todayRecords.fold<double>(0, (sum, record) => sum + record.amount);
    final drinkingTimes = todayRecords.length;

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
            '今日饮水统计',
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
                child: _buildStatItem(
                  '饮水量',
                  '${totalAmount.toStringAsFixed(0)}ml',
                  Icons.water_drop,
                  NothingTheme.info,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '饮水次数',
                  '${drinkingTimes}次',
                  Icons.repeat,
                  NothingTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecords() {
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
            Icons.history,
            color: NothingTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无饮水记录',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(DrinkingRecord record) {
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: record.quality.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            ),
            child: Icon(
              Icons.water_drop,
              color: record.quality.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${record.amount.toStringAsFixed(0)}ml',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: record.quality.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                      ),
                      child: Text(
                        record.quality.displayName,
                        style: TextStyle(
                          color: record.quality.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                    const SizedBox(width: 12),
                    Text(
                      '持续${_formatDuration(record.duration)}',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${record.waterTemperature.toStringAsFixed(1)}°C',
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
        ],
      ),
    );
  }

  Widget _buildSettingsView(WaterDevice device) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 设备信息
          _buildDeviceInfo(device),
          const SizedBox(height: 16),
          
          // 功能设置
          _buildFunctionSettings(device),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(WaterDevice device) {
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
          
          _buildInfoRow('设备名称', device.name),
          _buildInfoRow('设备类型', device.type.displayName),
          _buildInfoRow('安装位置', device.location),
          _buildInfoRow('连接状态', device.status.displayName),
          _buildInfoRow('设备ID', device.id),
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

  Widget _buildFunctionSettings(WaterDevice device) {
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
            '功能设置',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // 自动补水
          _buildSwitchRow(
            '自动补水',
            device.autoRefill,
            (value) {
              _updateDevice(device.copyWith(autoRefill: value));
            },
          ),
          
          // 水泵功能
          _buildSwitchRow(
            '水泵循环',
            device.pumpEnabled,
            (value) {
              _updateDevice(device.copyWith(pumpEnabled: value));
            },
          ),
          
          // LED指示灯
          _buildSwitchRow(
            'LED指示灯',
            device.ledEnabled,
            (value) {
              _updateDevice(device.copyWith(ledEnabled: value));
            },
          ),
        ],
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
            activeColor: NothingTheme.info,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes.remainder(60)}分钟';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分钟';
    } else {
      return '${duration.inSeconds}秒';
    }
  }
}