import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 喂食器类型
enum FeederType {
  automatic('自动喂食器', Icons.schedule),
  smart('智能喂食器', Icons.smart_toy),
  gravity('重力喂食器', Icons.arrow_downward),
  puzzle('益智喂食器', Icons.extension);

  const FeederType(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 喂食器状态
enum FeederStatus {
  online('在线', NothingTheme.success),
  offline('离线', NothingTheme.error),
  feeding('喂食中', NothingTheme.warning),
  empty('食物不足', NothingTheme.error),
  maintenance('维护中', NothingTheme.info);

  const FeederStatus(this.displayName, this.color);
  
  final String displayName;
  final Color color;
}

/// 食物类型
enum FoodType {
  dry('干粮', Icons.grain),
  wet('湿粮', Icons.water_drop),
  treat('零食', Icons.cookie),
  supplement('营养品', Icons.medication);

  const FoodType(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// 喂食记录
class FeedingRecord {
  final String id;
  final DateTime timestamp;
  final double amount; // 克
  final FoodType foodType;
  final String foodName;
  final bool isScheduled;
  final bool isCompleted;
  final String? notes;

  const FeedingRecord({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.foodType,
    required this.foodName,
    this.isScheduled = false,
    this.isCompleted = true,
    this.notes,
  });
}

/// 喂食计划
class FeedingSchedule {
  final String id;
  final String name;
  final TimeOfDay time;
  final double amount; // 克
  final FoodType foodType;
  final String foodName;
  final List<int> weekdays; // 1-7, 1=Monday
  final bool isEnabled;

  const FeedingSchedule({
    required this.id,
    required this.name,
    required this.time,
    required this.amount,
    required this.foodType,
    required this.foodName,
    this.weekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.isEnabled = true,
  });

  FeedingSchedule copyWith({
    String? id,
    String? name,
    TimeOfDay? time,
    double? amount,
    FoodType? foodType,
    String? foodName,
    List<int>? weekdays,
    bool? isEnabled,
  }) {
    return FeedingSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      amount: amount ?? this.amount,
      foodType: foodType ?? this.foodType,
      foodName: foodName ?? this.foodName,
      weekdays: weekdays ?? this.weekdays,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// 食物库存
class FoodInventory {
  final String id;
  final String name;
  final FoodType type;
  final double currentAmount; // 克
  final double totalCapacity; // 克
  final DateTime? expiryDate;
  final double caloriesPerGram;
  final String brand;
  final String? imageUrl;

  const FoodInventory({
    required this.id,
    required this.name,
    required this.type,
    required this.currentAmount,
    required this.totalCapacity,
    this.expiryDate,
    this.caloriesPerGram = 3.5,
    this.brand = '',
    this.imageUrl,
  });

  double get usagePercent => currentAmount / totalCapacity;
  
  bool get isLow => usagePercent < 0.2;
  
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7;
  }
}

/// 喂食器设备
class FeederDevice {
  final String id;
  final String name;
  final FeederType type;
  final String location;
  final FeederStatus status;
  final double currentFoodLevel; // 0-100%
  final int batteryLevel; // 0-100, -1 for wired
  final List<FeedingSchedule> schedules;
  final List<FeedingRecord> recentRecords;
  final FoodInventory? currentFood;

  const FeederDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    this.status = FeederStatus.offline,
    this.currentFoodLevel = 0.0,
    this.batteryLevel = -1,
    this.schedules = const [],
    this.recentRecords = const [],
    this.currentFood,
  });

  FeederDevice copyWith({
    String? id,
    String? name,
    FeederType? type,
    String? location,
    FeederStatus? status,
    double? currentFoodLevel,
    int? batteryLevel,
    List<FeedingSchedule>? schedules,
    List<FeedingRecord>? recentRecords,
    FoodInventory? currentFood,
  }) {
    return FeederDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      status: status ?? this.status,
      currentFoodLevel: currentFoodLevel ?? this.currentFoodLevel,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      schedules: schedules ?? this.schedules,
      recentRecords: recentRecords ?? this.recentRecords,
      currentFood: currentFood ?? this.currentFood,
    );
  }
}

/// 喂食控制界面
class FeedingControlScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const FeedingControlScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<FeedingControlScreen> createState() => _FeedingControlScreenState();
}

class _FeedingControlScreenState extends State<FeedingControlScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _feedingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  List<FeederDevice> _feeders = [];
  FeederDevice? _selectedFeeder;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _feedingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
      parent: _feedingController,
      curve: Curves.linear,
    ));

    _loadFeeders();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _feedingController.dispose();
    super.dispose();
  }

  void _loadFeeders() {
    // 模拟喂食器数据
    setState(() {
      _feeders = [
        FeederDevice(
          id: '1',
          name: '客厅自动喂食器',
          type: FeederType.automatic,
          location: '客厅',
          status: FeederStatus.online,
          currentFoodLevel: 75.0,
          batteryLevel: -1,
          currentFood: const FoodInventory(
            id: '1',
            name: '皇家猫粮成猫粮',
            type: FoodType.dry,
            currentAmount: 1500.0,
            totalCapacity: 2000.0,
            brand: '皇家',
            caloriesPerGram: 4.2,
          ),
          schedules: [
            const FeedingSchedule(
              id: '1',
              name: '早餐',
              time: TimeOfDay(hour: 7, minute: 30),
              amount: 50.0,
              foodType: FoodType.dry,
              foodName: '皇家猫粮成猫粮',
            ),
            const FeedingSchedule(
              id: '2',
              name: '晚餐',
              time: TimeOfDay(hour: 18, minute: 0),
              amount: 60.0,
              foodType: FoodType.dry,
              foodName: '皇家猫粮成猫粮',
            ),
          ],
          recentRecords: [
            FeedingRecord(
              id: '1',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              amount: 50.0,
              foodType: FoodType.dry,
              foodName: '皇家猫粮成猫粮',
              isScheduled: true,
              isCompleted: true,
            ),
          ],
        ),
        FeederDevice(
          id: '2',
          name: '智能湿粮喂食器',
          type: FeederType.smart,
          location: '厨房',
          status: FeederStatus.online,
          currentFoodLevel: 30.0,
          batteryLevel: 68,
          currentFood: const FoodInventory(
            id: '2',
            name: '希尔思湿粮',
            type: FoodType.wet,
            currentAmount: 300.0,
            totalCapacity: 1000.0,
            brand: '希尔思',
            caloriesPerGram: 1.2,
          ),
          schedules: [
            const FeedingSchedule(
              id: '3',
              name: '午餐湿粮',
              time: TimeOfDay(hour: 12, minute: 0),
              amount: 85.0,
              foodType: FoodType.wet,
              foodName: '希尔思湿粮',
              weekdays: [1, 3, 5, 7],
            ),
          ],
        ),
        FeederDevice(
          id: '3',
          name: '零食投放器',
          type: FeederType.puzzle,
          location: '阳台',
          status: FeederStatus.empty,
          currentFoodLevel: 5.0,
          batteryLevel: 25,
          currentFood: const FoodInventory(
            id: '3',
            name: '冻干小鱼干',
            type: FoodType.treat,
            currentAmount: 50.0,
            totalCapacity: 500.0,
            brand: '妙修',
            caloriesPerGram: 5.8,
          ),
        ),
      ];
      
      if (_feeders.isNotEmpty) {
        _selectedFeeder = _feeders.first;
      }
    });
  }

  void _updateFeeder(FeederDevice updatedFeeder) {
    setState(() {
      final index = _feeders.indexWhere((f) => f.id == updatedFeeder.id);
      if (index != -1) {
        _feeders[index] = updatedFeeder;
        if (_selectedFeeder?.id == updatedFeeder.id) {
          _selectedFeeder = updatedFeeder;
        }
      }
    });
  }

  void _startFeeding() {
    if (_selectedFeeder?.status == FeederStatus.online) {
      _feedingController.repeat();
      
      // 模拟喂食过程
      Future.delayed(const Duration(seconds: 3), () {
        _feedingController.stop();
        _feedingController.reset();
        
        // 添加喂食记录
        final newRecord = FeedingRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          amount: 30.0,
          foodType: _selectedFeeder!.currentFood?.type ?? FoodType.dry,
          foodName: _selectedFeeder!.currentFood?.name ?? '未知食物',
          isScheduled: false,
          isCompleted: true,
          notes: '手动喂食',
        );
        
        final updatedRecords = [newRecord, ..._selectedFeeder!.recentRecords];
        _updateFeeder(_selectedFeeder!.copyWith(
          recentRecords: updatedRecords,
          currentFoodLevel: (_selectedFeeder!.currentFoodLevel - 5).clamp(0, 100),
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
          '喂食控制',
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
              // 添加喂食器
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 喂食器列表
            _buildFeederList(),
            
            // 标签页
            _buildTabBar(),
            
            // 内容区域
            if (_selectedFeeder != null)
              Expanded(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildTabContent(_selectedFeeder!),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _selectedFeeder?.status == FeederStatus.online
          ? FloatingActionButton(
              onPressed: _startFeeding,
              backgroundColor: NothingTheme.brandPrimary,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }

  Widget _buildFeederList() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _feeders.length,
        itemBuilder: (context, index) {
          final feeder = _feeders[index];
          final isSelected = _selectedFeeder?.id == feeder.id;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFeeder = feeder;
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
                        feeder.type.icon,
                        color: isSelected ? Colors.white : feeder.status.color,
                        size: 24,
                      ),
                      if (feeder.status == FeederStatus.empty || feeder.status == FeederStatus.offline)
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
                    feeder.name,
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
                    feeder.status.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.8) : feeder.status.color,
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
    final tabs = ['设备状态', '喂食计划', '喂食记录', '食物管理'];
    
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
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(FeederDevice feeder) {
    switch (_currentTabIndex) {
      case 0:
        return _buildStatusView(feeder);
      case 1:
        return _buildScheduleView(feeder);
      case 2:
        return _buildRecordsView(feeder);
      case 3:
        return _buildFoodManagementView(feeder);
      default:
        return _buildStatusView(feeder);
    }
  }

  Widget _buildStatusView(FeederDevice feeder) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 设备状态卡片
          _buildDeviceStatusCard(feeder),
          const SizedBox(height: 16),
          
          // 食物余量
          _buildFoodLevelCard(feeder),
          const SizedBox(height: 16),
          
          // 电池信息
          if (feeder.batteryLevel >= 0)
            _buildBatteryCard(feeder),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusCard(FeederDevice feeder) {
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
                  color: feeder.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Icon(
                  feeder.type.icon,
                  color: feeder.status.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feeder.name,
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
                            color: feeder.status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          feeder.status.displayName,
                          style: TextStyle(
                            color: feeder.status.color,
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
                child: _buildStatusItem('设备类型', feeder.type.displayName),
              ),
              Expanded(
                child: _buildStatusItem('安装位置', feeder.location),
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

  Widget _buildFoodLevelCard(FeederDevice feeder) {
    final levelColor = feeder.currentFoodLevel > 50
        ? NothingTheme.success
        : feeder.currentFoodLevel > 20
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
                feeder.currentFood?.type.icon ?? Icons.pets,
                color: levelColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '食物余量',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (feeder.currentFood != null)
                      Text(
                        feeder.currentFood!.name,
                        style: TextStyle(
                          color: NothingTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              
              Text(
                '${feeder.currentFoodLevel.toStringAsFixed(0)}%',
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
            value: feeder.currentFoodLevel / 100,
            backgroundColor: NothingTheme.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(levelColor),
          ),
          const SizedBox(height: 12),
          
          if (feeder.currentFood != null)
            Row(
              children: [
                Expanded(
                  child: _buildFoodInfo(
                    '当前重量',
                    '${feeder.currentFood!.currentAmount.toStringAsFixed(0)}g',
                  ),
                ),
                Expanded(
                  child: _buildFoodInfo(
                    '总容量',
                    '${feeder.currentFood!.totalCapacity.toStringAsFixed(0)}g',
                  ),
                ),
                Expanded(
                  child: _buildFoodInfo(
                    '品牌',
                    feeder.currentFood!.brand,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFoodInfo(String label, String value) {
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
        const SizedBox(height: 2),
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

  Widget _buildBatteryCard(FeederDevice feeder) {
    final batteryColor = feeder.batteryLevel > 50
        ? NothingTheme.success
        : feeder.batteryLevel > 20
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
                Text(
                  '电池电量',
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                
                LinearProgressIndicator(
                  value: feeder.batteryLevel / 100,
                  backgroundColor: NothingTheme.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          Text(
            '${feeder.batteryLevel}%',
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

  Widget _buildScheduleView(FeederDevice feeder) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '喂食计划',
                  style: TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: NothingTheme.brandPrimary),
                onPressed: () {
                  // 添加计划
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (feeder.schedules.isEmpty)
            _buildEmptySchedule()
          else
            ...feeder.schedules.map((schedule) => _buildScheduleItem(schedule)),
        ],
      ),
    );
  }

  Widget _buildEmptySchedule() {
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
            Icons.schedule,
            color: NothingTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无喂食计划',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // 添加计划
            },
            child: const Text('添加计划'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(FeedingSchedule schedule) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule.name,
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: schedule.isEnabled,
                onChanged: (value) {
                  // 更新计划状态
                },
                activeColor: NothingTheme.brandPrimary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: NothingTheme.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              
              Icon(
                schedule.foodType.icon,
                color: NothingTheme.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${schedule.amount.toStringAsFixed(0)}g',
                style: const TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            schedule.foodName,
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          
          // 重复日期
          Wrap(
            spacing: 4,
            children: [1, 2, 3, 4, 5, 6, 7].map((day) {
              final isSelected = schedule.weekdays.contains(day);
              final dayNames = ['一', '二', '三', '四', '五', '六', '日'];
              
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? NothingTheme.brandPrimary : NothingTheme.gray200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    dayNames[day - 1],
                    style: TextStyle(
                      color: isSelected ? Colors.white : NothingTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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

  Widget _buildRecordsView(FeederDevice feeder) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '喂食记录',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          if (feeder.recentRecords.isEmpty)
            _buildEmptyRecords()
          else
            ...feeder.recentRecords.map((record) => _buildRecordItem(record)),
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
            '暂无喂食记录',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(FeedingRecord record) {
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
              color: record.foodType == FoodType.dry
                  ? NothingTheme.warning.withOpacity(0.1)
                  : record.foodType == FoodType.wet
                      ? NothingTheme.info.withOpacity(0.1)
                      : NothingTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            ),
            child: Icon(
              record.foodType.icon,
              color: record.foodType == FoodType.dry
                  ? NothingTheme.warning
                  : record.foodType == FoodType.wet
                      ? NothingTheme.info
                      : NothingTheme.success,
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
                    Expanded(
                      child: Text(
                        record.foodName,
                        style: const TextStyle(
                          color: NothingTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (record.isScheduled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: NothingTheme.brandPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                        ),
                        child: Text(
                          '定时',
                          style: TextStyle(
                            color: NothingTheme.brandPrimary,
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
                      '${record.amount.toStringAsFixed(0)}g',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                if (record.notes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      record.notes!,
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodManagementView(FeederDevice feeder) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '食物管理',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          if (feeder.currentFood != null)
            _buildCurrentFoodCard(feeder.currentFood!),
          
          const SizedBox(height: 16),
          
          // 营养分析
          _buildNutritionAnalysis(feeder),
        ],
      ),
    );
  }

  Widget _buildCurrentFoodCard(FoodInventory food) {
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
                  color: food.type == FoodType.dry
                      ? NothingTheme.warning.withOpacity(0.1)
                      : food.type == FoodType.wet
                          ? NothingTheme.info.withOpacity(0.1)
                          : NothingTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
                child: Icon(
                  food.type.icon,
                  color: food.type == FoodType.dry
                      ? NothingTheme.warning
                      : food.type == FoodType.wet
                          ? NothingTheme.info
                          : NothingTheme.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${food.brand} · ${food.type.displayName}',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
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
                child: _buildFoodDetail('当前重量', '${food.currentAmount.toStringAsFixed(0)}g'),
              ),
              Expanded(
                child: _buildFoodDetail('总容量', '${food.totalCapacity.toStringAsFixed(0)}g'),
              ),
              Expanded(
                child: _buildFoodDetail('热量', '${food.caloriesPerGram.toStringAsFixed(1)} kcal/g'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (food.expiryDate != null)
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: food.isExpiringSoon ? NothingTheme.error : NothingTheme.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '保质期至：${_formatDate(food.expiryDate!)}',
                  style: TextStyle(
                    color: food.isExpiringSoon ? NothingTheme.error : NothingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (food.isExpiringSoon)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NothingTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                    ),
                    child: Text(
                      '即将过期',
                      style: TextStyle(
                        color: NothingTheme.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFoodDetail(String label, String value) {
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionAnalysis(FeederDevice feeder) {
    // 计算今日摄入
    final today = DateTime.now();
    final todayRecords = feeder.recentRecords.where((record) {
      return record.timestamp.year == today.year &&
          record.timestamp.month == today.month &&
          record.timestamp.day == today.day;
    }).toList();

    final totalAmount = todayRecords.fold<double>(0, (sum, record) => sum + record.amount);
    final totalCalories = feeder.currentFood != null
        ? totalAmount * feeder.currentFood!.caloriesPerGram
        : 0.0;

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
            '今日营养摄入',
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
                child: _buildNutritionItem(
                  '食物重量',
                  '${totalAmount.toStringAsFixed(0)}g',
                  Icons.scale,
                  NothingTheme.info,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  '热量摄入',
                  '${totalCalories.toStringAsFixed(0)} kcal',
                  Icons.local_fire_department,
                  NothingTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  '喂食次数',
                  '${todayRecords.length}次',
                  Icons.restaurant,
                  NothingTheme.success,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  '定时喂食',
                  '${todayRecords.where((r) => r.isScheduled).length}次',
                  Icons.schedule,
                  NothingTheme.brandPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, IconData icon, Color color) {
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}