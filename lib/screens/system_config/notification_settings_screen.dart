import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 通知类型
enum NotificationType {
  feeding('进食提醒', Icons.restaurant, '定时提醒宠物进食'),
  exercise('运动提醒', Icons.directions_run, '提醒带宠物运动'),
  health('健康检查', Icons.favorite, '定期健康检查提醒'),
  medication('用药提醒', Icons.medical_services, '按时给药提醒'),
  grooming('美容护理', Icons.content_cut, '定期美容护理提醒'),
  vaccination('疫苗接种', Icons.vaccines, '疫苗接种时间提醒'),
  device('设备状态', Icons.devices, '设备异常状态通知'),
  emergency('紧急情况', Icons.warning, '紧急情况立即通知');

  const NotificationType(this.displayName, this.icon, this.description);
  
  final String displayName;
  final IconData icon;
  final String description;
}

/// 通知时间段
enum NotificationTimeSlot {
  morning('早晨', '06:00-10:00'),
  noon('中午', '11:00-14:00'),
  afternoon('下午', '15:00-18:00'),
  evening('晚上', '19:00-22:00'),
  night('深夜', '23:00-05:00');

  const NotificationTimeSlot(this.displayName, this.timeRange);
  
  final String displayName;
  final String timeRange;
}

/// 通知优先级
enum NotificationPriority {
  low('低', Icons.keyboard_arrow_down, NothingTheme.textSecondary),
  normal('普通', Icons.remove, NothingTheme.info),
  high('高', Icons.keyboard_arrow_up, NothingTheme.warning),
  urgent('紧急', Icons.priority_high, NothingTheme.error);

  const NotificationPriority(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 通知设置项
class NotificationSetting {
  final NotificationType type;
  final bool enabled;
  final List<NotificationTimeSlot> timeSlots;
  final NotificationPriority priority;
  final bool sound;
  final bool vibration;
  final bool showOnLockScreen;
  final int advanceMinutes; // 提前多少分钟提醒
  final List<int> repeatDays; // 重复的星期几 (1-7, 1=周一)

  const NotificationSetting({
    required this.type,
    required this.enabled,
    required this.timeSlots,
    required this.priority,
    required this.sound,
    required this.vibration,
    required this.showOnLockScreen,
    required this.advanceMinutes,
    required this.repeatDays,
  });

  NotificationSetting copyWith({
    NotificationType? type,
    bool? enabled,
    List<NotificationTimeSlot>? timeSlots,
    NotificationPriority? priority,
    bool? sound,
    bool? vibration,
    bool? showOnLockScreen,
    int? advanceMinutes,
    List<int>? repeatDays,
  }) {
    return NotificationSetting(
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      timeSlots: timeSlots ?? this.timeSlots,
      priority: priority ?? this.priority,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      showOnLockScreen: showOnLockScreen ?? this.showOnLockScreen,
      advanceMinutes: advanceMinutes ?? this.advanceMinutes,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}

/// 全局通知设置
class GlobalNotificationSettings {
  final bool masterSwitch;
  final bool doNotDisturb;
  final TimeOfDay doNotDisturbStart;
  final TimeOfDay doNotDisturbEnd;
  final bool groupNotifications;
  final int maxNotificationsPerHour;
  final bool smartDelivery; // 智能推送时间

  const GlobalNotificationSettings({
    required this.masterSwitch,
    required this.doNotDisturb,
    required this.doNotDisturbStart,
    required this.doNotDisturbEnd,
    required this.groupNotifications,
    required this.maxNotificationsPerHour,
    required this.smartDelivery,
  });

  GlobalNotificationSettings copyWith({
    bool? masterSwitch,
    bool? doNotDisturb,
    TimeOfDay? doNotDisturbStart,
    TimeOfDay? doNotDisturbEnd,
    bool? groupNotifications,
    int? maxNotificationsPerHour,
    bool? smartDelivery,
  }) {
    return GlobalNotificationSettings(
      masterSwitch: masterSwitch ?? this.masterSwitch,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      doNotDisturbStart: doNotDisturbStart ?? this.doNotDisturbStart,
      doNotDisturbEnd: doNotDisturbEnd ?? this.doNotDisturbEnd,
      groupNotifications: groupNotifications ?? this.groupNotifications,
      maxNotificationsPerHour: maxNotificationsPerHour ?? this.maxNotificationsPerHour,
      smartDelivery: smartDelivery ?? this.smartDelivery,
    );
  }
}

/// 通知设置界面
class NotificationSettingsScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const NotificationSettingsScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  GlobalNotificationSettings _globalSettings = const GlobalNotificationSettings(
    masterSwitch: true,
    doNotDisturb: true,
    doNotDisturbStart: TimeOfDay(hour: 22, minute: 0),
    doNotDisturbEnd: TimeOfDay(hour: 7, minute: 0),
    groupNotifications: true,
    maxNotificationsPerHour: 5,
    smartDelivery: true,
  );

  List<NotificationSetting> _notificationSettings = [];
  int _currentTabIndex = 0;

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

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _loadNotificationSettings();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadNotificationSettings() {
    // 模拟通知设置数据
    setState(() {
      _notificationSettings = [
        const NotificationSetting(
          type: NotificationType.feeding,
          enabled: true,
          timeSlots: [NotificationTimeSlot.morning, NotificationTimeSlot.evening],
          priority: NotificationPriority.high,
          sound: true,
          vibration: true,
          showOnLockScreen: true,
          advanceMinutes: 15,
          repeatDays: [1, 2, 3, 4, 5, 6, 7], // 每天
        ),
        const NotificationSetting(
          type: NotificationType.exercise,
          enabled: true,
          timeSlots: [NotificationTimeSlot.afternoon],
          priority: NotificationPriority.normal,
          sound: true,
          vibration: false,
          showOnLockScreen: true,
          advanceMinutes: 30,
          repeatDays: [1, 2, 3, 4, 5], // 工作日
        ),
        const NotificationSetting(
          type: NotificationType.health,
          enabled: true,
          timeSlots: [NotificationTimeSlot.morning],
          priority: NotificationPriority.normal,
          sound: false,
          vibration: true,
          showOnLockScreen: false,
          advanceMinutes: 60,
          repeatDays: [7], // 每周日
        ),
        const NotificationSetting(
          type: NotificationType.medication,
          enabled: false,
          timeSlots: [NotificationTimeSlot.morning, NotificationTimeSlot.evening],
          priority: NotificationPriority.urgent,
          sound: true,
          vibration: true,
          showOnLockScreen: true,
          advanceMinutes: 5,
          repeatDays: [1, 2, 3, 4, 5, 6, 7],
        ),
        const NotificationSetting(
          type: NotificationType.grooming,
          enabled: true,
          timeSlots: [NotificationTimeSlot.afternoon],
          priority: NotificationPriority.low,
          sound: false,
          vibration: false,
          showOnLockScreen: false,
          advanceMinutes: 120,
          repeatDays: [6], // 每周六
        ),
        const NotificationSetting(
          type: NotificationType.vaccination,
          enabled: true,
          timeSlots: [NotificationTimeSlot.morning],
          priority: NotificationPriority.high,
          sound: true,
          vibration: true,
          showOnLockScreen: true,
          advanceMinutes: 1440, // 提前一天
          repeatDays: [],
        ),
        const NotificationSetting(
          type: NotificationType.device,
          enabled: true,
          timeSlots: [],
          priority: NotificationPriority.normal,
          sound: true,
          vibration: true,
          showOnLockScreen: true,
          advanceMinutes: 0,
          repeatDays: [],
        ),
        const NotificationSetting(
          type: NotificationType.emergency,
          enabled: true,
          timeSlots: [],
          priority: NotificationPriority.urgent,
          sound: true,
          vibration: true,
          showOnLockScreen: true,
          advanceMinutes: 0,
          repeatDays: [],
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
          '通知设置',
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
            icon: const Icon(Icons.restore, color: NothingTheme.textPrimary),
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 主开关
            _buildMasterSwitch(),
            
            // 标签页
            _buildTabBar(),
            
            // 内容区域
            Expanded(
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: _buildTabContent(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterSwitch() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _globalSettings.masterSwitch 
                  ? NothingTheme.success.withOpacity(0.1)
                  : NothingTheme.gray300.withOpacity(0.1),
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
            ),
            child: Icon(
              _globalSettings.masterSwitch ? Icons.notifications_active : Icons.notifications_off,
              color: _globalSettings.masterSwitch ? NothingTheme.success : NothingTheme.gray400,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '通知总开关',
                  style: TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _globalSettings.masterSwitch ? '所有通知已启用' : '所有通知已关闭',
                  style: TextStyle(
                    color: NothingTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          Switch(
            value: _globalSettings.masterSwitch,
            onChanged: (value) {
              setState(() {
                _globalSettings = _globalSettings.copyWith(masterSwitch: value);
              });
            },
            activeColor: NothingTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['通知类型', '全局设置', '免打扰'];
    
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
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    if (!_globalSettings.masterSwitch) {
      return _buildDisabledView();
    }

    switch (_currentTabIndex) {
      case 0:
        return _buildNotificationTypesView();
      case 1:
        return _buildGlobalSettingsView();
      case 2:
        return _buildDoNotDisturbView();
      default:
        return _buildNotificationTypesView();
    }
  }

  Widget _buildDisabledView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            color: NothingTheme.gray400,
            size: 64,
          ),
          const SizedBox(height: 16),
          
          const Text(
            '通知已关闭',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            '请开启通知总开关以配置具体设置',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypesView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '通知类型',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._notificationSettings.map((setting) => _buildNotificationSettingCard(setting)),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingCard(NotificationSetting setting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: setting.priority.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Icon(
                  setting.type.icon,
                  color: setting.priority.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting.type.displayName,
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      setting.type.description,
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              Switch(
                value: setting.enabled,
                onChanged: (value) {
                  setState(() {
                    final index = _notificationSettings.indexOf(setting);
                    _notificationSettings[index] = setting.copyWith(enabled: value);
                  });
                },
                activeColor: NothingTheme.success,
              ),
            ],
          ),
          
          if (setting.enabled) ...[
            const SizedBox(height: 16),
            
            // 优先级
            Row(
              children: [
                Icon(
                  setting.priority.icon,
                  color: setting.priority.color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '优先级: ${setting.priority.displayName}',
                  style: TextStyle(
                    color: setting.priority.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const Spacer(),
                
                if (setting.advanceMinutes > 0)
                  Text(
                    '提前${_formatAdvanceTime(setting.advanceMinutes)}',
                    style: TextStyle(
                      color: NothingTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 通知选项
            Row(
              children: [
                _buildNotificationOption('声音', setting.sound, Icons.volume_up),
                const SizedBox(width: 16),
                _buildNotificationOption('震动', setting.vibration, Icons.vibration),
                const SizedBox(width: 16),
                _buildNotificationOption('锁屏显示', setting.showOnLockScreen, Icons.lock_open),
              ],
            ),
            
            if (setting.timeSlots.isNotEmpty) ...[
              const SizedBox(height: 12),
              
              // 时间段
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: setting.timeSlots.map((slot) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NothingTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                    ),
                    child: Text(
                      '${slot.displayName} ${slot.timeRange}',
                      style: TextStyle(
                        color: NothingTheme.info,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            
            if (setting.repeatDays.isNotEmpty) ...[
              const SizedBox(height: 12),
              
              // 重复天数
              Row(
                children: [
                  Text(
                    '重复: ',
                    style: TextStyle(
                      color: NothingTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatRepeatDays(setting.repeatDays),
                    style: const TextStyle(
                      color: NothingTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // 配置按钮
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showNotificationDetailSettings(setting),
                child: Text(
                  '详细设置',
                  style: TextStyle(
                    color: NothingTheme.info,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationOption(String label, bool enabled, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: enabled ? NothingTheme.success : NothingTheme.gray400,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: enabled ? NothingTheme.success : NothingTheme.gray400,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalSettingsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '全局设置',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // 通知分组
          _buildGlobalSettingCard(
            '通知分组',
            '将相同类型的通知合并显示',
            Icons.group_work,
            _globalSettings.groupNotifications,
            (value) {
              setState(() {
                _globalSettings = _globalSettings.copyWith(groupNotifications: value);
              });
            },
          ),
          
          // 智能推送
          _buildGlobalSettingCard(
            '智能推送时间',
            '根据使用习惯选择最佳推送时间',
            Icons.psychology,
            _globalSettings.smartDelivery,
            (value) {
              setState(() {
                _globalSettings = _globalSettings.copyWith(smartDelivery: value);
              });
            },
          ),
          
          // 频率限制
          Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: NothingTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                      ),
                      child: Icon(
                        Icons.speed,
                        color: NothingTheme.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '通知频率限制',
                            style: TextStyle(
                              color: NothingTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '每小时最多${_globalSettings.maxNotificationsPerHour}条通知',
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
                const SizedBox(height: 16),
                
                Slider(
                  value: _globalSettings.maxNotificationsPerHour.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '${_globalSettings.maxNotificationsPerHour}条/小时',
                  onChanged: (value) {
                    setState(() {
                      _globalSettings = _globalSettings.copyWith(
                        maxNotificationsPerHour: value.round(),
                      );
                    });
                  },
                  activeColor: NothingTheme.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalSettingCard(
    String title,
    String description,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: NothingTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            ),
            child: Icon(
              icon,
              color: NothingTheme.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: NothingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: NothingTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildDoNotDisturbView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '免打扰设置',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // 免打扰开关
          Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _globalSettings.doNotDisturb 
                        ? NothingTheme.warning.withOpacity(0.1)
                        : NothingTheme.gray300.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Icon(
                    _globalSettings.doNotDisturb ? Icons.do_not_disturb_on : Icons.do_not_disturb_off,
                    color: _globalSettings.doNotDisturb ? NothingTheme.warning : NothingTheme.gray400,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '免打扰模式',
                        style: TextStyle(
                          color: NothingTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _globalSettings.doNotDisturb 
                            ? '${_formatTimeOfDay(_globalSettings.doNotDisturbStart)} - ${_formatTimeOfDay(_globalSettings.doNotDisturbEnd)}'
                            : '已关闭',
                        style: TextStyle(
                          color: NothingTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Switch(
                  value: _globalSettings.doNotDisturb,
                  onChanged: (value) {
                    setState(() {
                      _globalSettings = _globalSettings.copyWith(doNotDisturb: value);
                    });
                  },
                  activeColor: NothingTheme.warning,
                ),
              ],
            ),
          ),
          
          // 时间设置
          if (_globalSettings.doNotDisturb) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                    '免打扰时间段',
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
                              '开始时间',
                              style: TextStyle(
                                color: NothingTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            GestureDetector(
                              onTap: () => _selectTime(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: NothingTheme.gray300),
                                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                                ),
                                child: Text(
                                  _formatTimeOfDay(_globalSettings.doNotDisturbStart),
                                  style: const TextStyle(
                                    color: NothingTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '结束时间',
                              style: TextStyle(
                                color: NothingTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            GestureDetector(
                              onTap: () => _selectTime(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: NothingTheme.gray300),
                                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                                ),
                                child: Text(
                                  _formatTimeOfDay(_globalSettings.doNotDisturbEnd),
                                  style: const TextStyle(
                                    color: NothingTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 例外设置
            Container(
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
                    '免打扰例外',
                    style: TextStyle(
                      color: NothingTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    '以下类型的通知将忽略免打扰设置：',
                    style: TextStyle(
                      color: NothingTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...NotificationType.values
                      .where((type) => type == NotificationType.emergency || type == NotificationType.device)
                      .map((type) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            type.icon,
                            color: NothingTheme.error,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            type.displayName,
                            style: TextStyle(
                              color: NothingTheme.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showNotificationDetailSettings(NotificationSetting setting) {
    // 显示详细设置对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${setting.type.displayName}设置'),
        content: const Text('详细设置功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? _globalSettings.doNotDisturbStart 
          : _globalSettings.doNotDisturbEnd,
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _globalSettings = _globalSettings.copyWith(doNotDisturbStart: picked);
        } else {
          _globalSettings = _globalSettings.copyWith(doNotDisturbEnd: picked);
        }
      });
    }
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要重置所有通知设置为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadNotificationSettings(); // 重新加载默认设置
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已重置为默认设置'),
                  backgroundColor: NothingTheme.success,
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _formatAdvanceTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}分钟';
    } else if (minutes < 1440) {
      return '${(minutes / 60).round()}小时';
    } else {
      return '${(minutes / 1440).round()}天';
    }
  }

  String _formatRepeatDays(List<int> days) {
    if (days.length == 7) return '每天';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) return '工作日';
    if (days.length == 2 && days.contains(6) && days.contains(7)) return '周末';
    
    final dayNames = ['一', '二', '三', '四', '五', '六', '日'];
    return days.map((day) => '周${dayNames[day - 1]}').join('、');
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}