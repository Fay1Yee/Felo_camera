import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 记录类型
enum RecordType {
  feeding('喂食', Icons.restaurant, NothingTheme.warning),
  drinking('饮水', Icons.water_drop, NothingTheme.info),
  exercise('运动', Icons.directions_run, NothingTheme.success),
  sleep('睡眠', Icons.bedtime, NothingTheme.accentPrimary),
  play('玩耍', Icons.sports_esports, NothingTheme.brandAccent),
  health('健康', Icons.favorite, NothingTheme.error),
  grooming('美容', Icons.content_cut, NothingTheme.accentTertiary),
  training('训练', Icons.school, NothingTheme.info),
  social('社交', Icons.pets, NothingTheme.success),
  other('其他', Icons.more_horiz, NothingTheme.gray500);

  const RecordType(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 活动强度
enum ActivityIntensity {
  low('低', NothingTheme.success),
  medium('中', NothingTheme.warning),
  high('高', NothingTheme.error);

  const ActivityIntensity(this.displayName, this.color);
  
  final String displayName;
  final Color color;
}

/// 情绪状态
enum MoodState {
  happy('开心', Icons.sentiment_very_satisfied, NothingTheme.success),
  normal('正常', Icons.sentiment_satisfied, NothingTheme.info),
  tired('疲惫', Icons.sentiment_neutral, NothingTheme.warning),
  anxious('焦虑', Icons.sentiment_dissatisfied, NothingTheme.brandAccent),
  sad('沮丧', Icons.sentiment_very_dissatisfied, NothingTheme.error);

  const MoodState(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 生活记录
class LifeRecord {
  final String id;
  final RecordType type;
  final DateTime timestamp;
  final String title;
  final String? description;
  final Duration? duration;
  final ActivityIntensity? intensity;
  final MoodState? mood;
  final double? value; // 数值记录（如体重、温度等）
  final String? unit; // 单位
  final List<String> tags;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const LifeRecord({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.title,
    this.description,
    this.duration,
    this.intensity,
    this.mood,
    this.value,
    this.unit,
    this.tags = const [],
    this.imageUrl,
    this.metadata,
  });

  LifeRecord copyWith({
    String? id,
    RecordType? type,
    DateTime? timestamp,
    String? title,
    String? description,
    Duration? duration,
    ActivityIntensity? intensity,
    MoodState? mood,
    double? value,
    String? unit,
    List<String>? tags,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return LifeRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      mood: mood ?? this.mood,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 健康指标
class HealthMetric {
  final String id;
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;
  final double? normalMin;
  final double? normalMax;
  final String? note;

  const HealthMetric({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.normalMin,
    this.normalMax,
    this.note,
  });

  bool get isNormal {
    if (normalMin == null || normalMax == null) return true;
    return value >= normalMin! && value <= normalMax!;
  }

  Color get statusColor {
    if (!isNormal) return NothingTheme.error;
    return NothingTheme.success;
  }
}

/// 行为模式
class BehaviorPattern {
  final String id;
  final String name;
  final RecordType type;
  final int frequency; // 频次/周
  final Duration averageDuration;
  final List<int> preferredHours; // 偏好时间段
  final double consistency; // 一致性 0-1
  final String trend; // 趋势：increasing, decreasing, stable

  const BehaviorPattern({
    required this.id,
    required this.name,
    required this.type,
    required this.frequency,
    required this.averageDuration,
    required this.preferredHours,
    required this.consistency,
    required this.trend,
  });

  Color get trendColor {
    switch (trend) {
      case 'increasing':
        return NothingTheme.success;
      case 'decreasing':
        return NothingTheme.error;
      default:
        return NothingTheme.info;
    }
  }

  String get trendText {
    switch (trend) {
      case 'increasing':
        return '上升';
      case 'decreasing':
        return '下降';
      default:
        return '稳定';
    }
  }
}

/// 生活记录界面
class LifeRecordsScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const LifeRecordsScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<LifeRecordsScreen> createState() => _LifeRecordsScreenState();
}

class _LifeRecordsScreenState extends State<LifeRecordsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  List<LifeRecord> _lifeRecords = [];
  List<HealthMetric> _healthMetrics = [];
  List<BehaviorPattern> _behaviorPatterns = [];
  int _currentTabIndex = 0;
  DateTime _selectedDate = DateTime.now();

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

    _loadLifeRecords();
    _loadHealthMetrics();
    _loadBehaviorPatterns();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadLifeRecords() {
    // 模拟生活记录数据
    setState(() {
      _lifeRecords = [
        LifeRecord(
          id: '1',
          type: RecordType.feeding,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          title: '早餐时间',
          description: '吃了狗粮和鸡胸肉',
          duration: const Duration(minutes: 15),
          mood: MoodState.happy,
          value: 200,
          unit: 'g',
          tags: ['狗粮', '鸡胸肉'],
        ),
        LifeRecord(
          id: '2',
          type: RecordType.exercise,
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          title: '晨间散步',
          description: '在公园散步，遇到了其他狗狗',
          duration: const Duration(minutes: 45),
          intensity: ActivityIntensity.medium,
          mood: MoodState.happy,
          tags: ['散步', '公园', '社交'],
        ),
        LifeRecord(
          id: '3',
          type: RecordType.drinking,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          title: '饮水',
          value: 150,
          unit: 'ml',
          mood: MoodState.normal,
        ),
        LifeRecord(
          id: '4',
          type: RecordType.sleep,
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          title: '夜间睡眠',
          duration: const Duration(hours: 8),
          mood: MoodState.normal,
          tags: ['深度睡眠'],
        ),
        LifeRecord(
          id: '5',
          type: RecordType.play,
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          title: '玩具时间',
          description: '和球玩了很久',
          duration: const Duration(minutes: 30),
          intensity: ActivityIntensity.high,
          mood: MoodState.happy,
          tags: ['球', '室内'],
        ),
      ];
    });
  }

  void _loadHealthMetrics() {
    // 模拟健康指标数据
    setState(() {
      _healthMetrics = [
        HealthMetric(
          id: '1',
          name: '体重',
          value: 25.5,
          unit: 'kg',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          normalMin: 24.0,
          normalMax: 27.0,
        ),
        HealthMetric(
          id: '2',
          name: '体温',
          value: 38.2,
          unit: '°C',
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          normalMin: 37.5,
          normalMax: 39.0,
        ),
        HealthMetric(
          id: '3',
          name: '心率',
          value: 85,
          unit: 'bpm',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          normalMin: 70,
          normalMax: 120,
        ),
        HealthMetric(
          id: '4',
          name: '呼吸频率',
          value: 22,
          unit: '/min',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          normalMin: 15,
          normalMax: 30,
        ),
      ];
    });
  }

  void _loadBehaviorPatterns() {
    // 模拟行为模式数据
    setState(() {
      _behaviorPatterns = [
        const BehaviorPattern(
          id: '1',
          name: '进食习惯',
          type: RecordType.feeding,
          frequency: 14, // 每周14次
          averageDuration: Duration(minutes: 12),
          preferredHours: [7, 12, 18], // 7点、12点、18点
          consistency: 0.85,
          trend: 'stable',
        ),
        const BehaviorPattern(
          id: '2',
          name: '运动模式',
          type: RecordType.exercise,
          frequency: 7, // 每周7次
          averageDuration: Duration(minutes: 40),
          preferredHours: [8, 17], // 8点、17点
          consistency: 0.72,
          trend: 'increasing',
        ),
        const BehaviorPattern(
          id: '3',
          name: '睡眠规律',
          type: RecordType.sleep,
          frequency: 7, // 每周7次
          averageDuration: Duration(hours: 8),
          preferredHours: [22], // 22点开始
          consistency: 0.90,
          trend: 'stable',
        ),
        const BehaviorPattern(
          id: '4',
          name: '玩耍时间',
          type: RecordType.play,
          frequency: 10, // 每周10次
          averageDuration: Duration(minutes: 25),
          preferredHours: [10, 15, 20], // 10点、15点、20点
          consistency: 0.65,
          trend: 'decreasing',
        ),
      ];
    });
  }

  void _addNewRecord() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddRecordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        title: const Text(
          '生活记录',
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
            icon: const Icon(Icons.calendar_today, color: NothingTheme.textPrimary),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: NothingTheme.textPrimary),
            onPressed: _addNewRecord,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 日期选择器
            _buildDateSelector(),
            
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

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Icon(
                    Icons.calendar_today,
                    color: NothingTheme.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  // 今日记录统计
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NothingTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                    ),
                    child: Text(
                      '${_getTodayRecordsCount()}条',
                      style: TextStyle(
                        color: NothingTheme.info,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildTabBar() {
    final tabs = ['今日记录', '健康指标', '行为模式'];
    
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
    switch (_currentTabIndex) {
      case 0:
        return _buildRecordsView();
      case 1:
        return _buildHealthView();
      case 2:
        return _buildPatternsView();
      default:
        return _buildRecordsView();
    }
  }

  Widget _buildRecordsView() {
    final todayRecords = _lifeRecords.where((record) {
      return _isSameDay(record.timestamp, _selectedDate);
    }).toList();

    todayRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 记录统计
          _buildRecordStats(todayRecords),
          const SizedBox(height: 16),
          
          // 记录列表
          if (todayRecords.isEmpty)
            _buildEmptyRecords()
          else
            ...todayRecords.map((record) => _buildRecordItem(record)),
        ],
      ),
    );
  }

  Widget _buildRecordStats(List<LifeRecord> records) {
    final typeStats = <RecordType, int>{};
    for (final record in records) {
      typeStats[record.type] = (typeStats[record.type] ?? 0) + 1;
    }

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
                Icons.analytics,
                color: NothingTheme.info,
                size: 24,
              ),
              const SizedBox(width: 12),
              
              const Text(
                '今日统计',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const Spacer(),
              
              Text(
                '共${records.length}条记录',
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (typeStats.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: typeStats.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: entry.key.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.key.icon,
                        color: entry.key.color,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${entry.key.displayName} ${entry.value}',
                        style: TextStyle(
                          color: entry.key.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Text(
              '暂无记录',
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 14,
              ),
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
            Icons.note_add,
            color: NothingTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            '今日暂无记录',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _addNewRecord,
            child: const Text('添加记录'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(LifeRecord record) {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: record.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Icon(
                  record.type.icon,
                  color: record.type.color,
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
                          record.title,
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
                            color: record.type.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                          ),
                          child: Text(
                            record.type.displayName,
                            style: TextStyle(
                              color: record.type.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    Text(
                      _formatTime(record.timestamp),
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (record.mood != null)
                Icon(
                  record.mood!.icon,
                  color: record.mood!.color,
                  size: 20,
                ),
            ],
          ),
          
          if (record.description != null) ...[
            const SizedBox(height: 12),
            Text(
              record.description!,
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // 详细信息
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (record.duration != null)
                _buildRecordDetail(
                  Icons.schedule,
                  _formatDuration(record.duration!),
                  NothingTheme.info,
                ),
              if (record.value != null)
                _buildRecordDetail(
                  Icons.straighten,
                  '${record.value!.toStringAsFixed(1)}${record.unit ?? ''}',
                  NothingTheme.success,
                ),
              if (record.intensity != null)
                _buildRecordDetail(
                  Icons.fitness_center,
                  record.intensity!.displayName,
                  record.intensity!.color,
                ),
            ],
          ),
          
          if (record.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: record.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: NothingTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordDetail(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '健康指标',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // 健康指标网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _healthMetrics.length,
            itemBuilder: (context, index) {
              return _buildHealthMetricCard(_healthMetrics[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricCard(HealthMetric metric) {
    return Container(
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: metric.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              
              Expanded(
                child: Text(
                  metric.name,
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            '${metric.value.toStringAsFixed(1)} ${metric.unit}',
            style: TextStyle(
              color: metric.statusColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          
          if (metric.normalMin != null && metric.normalMax != null)
            Text(
              '正常范围: ${metric.normalMin!.toStringAsFixed(1)}-${metric.normalMax!.toStringAsFixed(1)} ${metric.unit}',
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          
          const Spacer(),
          
          Text(
            _formatDateTime(metric.timestamp),
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '行为模式',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._behaviorPatterns.map((pattern) => _buildPatternCard(pattern)),
        ],
      ),
    );
  }

  Widget _buildPatternCard(BehaviorPattern pattern) {
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
                  color: pattern.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Icon(
                  pattern.type.icon,
                  color: pattern.type.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pattern.name,
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pattern.type.displayName,
                      style: TextStyle(
                        color: pattern.type.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pattern.trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      pattern.trend == 'increasing'
                          ? Icons.trending_up
                          : pattern.trend == 'decreasing'
                              ? Icons.trending_down
                              : Icons.trending_flat,
                      color: pattern.trendColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pattern.trendText,
                      style: TextStyle(
                        color: pattern.trendColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildPatternStat(
                  '频次',
                  '${pattern.frequency}/周',
                  Icons.repeat,
                ),
              ),
              Expanded(
                child: _buildPatternStat(
                  '平均时长',
                  _formatDuration(pattern.averageDuration),
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildPatternStat(
                  '一致性',
                  '${(pattern.consistency * 100).toStringAsFixed(0)}%',
                  Icons.analytics,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 偏好时间段
          Text(
            '偏好时间: ${pattern.preferredHours.map((h) => '${h}:00').join(', ')}',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: NothingTheme.info,
          size: 16,
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
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: NothingTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAddRecordSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NothingTheme.radiusLg),
        ),
      ),
      child: Column(
        children: [
          // 顶部拖拽条
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: NothingTheme.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '添加记录',
                  style: TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 记录类型选择
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: RecordType.values.length,
                    itemBuilder: (context, index) {
                      final type = RecordType.values[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // 这里可以导航到具体的添加记录页面
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: type.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                            border: Border.all(
                              color: type.color.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                type.icon,
                                color: type.color,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                type.displayName,
                                style: TextStyle(
                                  color: type.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  int _getTodayRecordsCount() {
    return _lifeRecords.where((record) {
      return _isSameDay(record.timestamp, _selectedDate);
    }).length;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return '今天';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${_formatTime(dateTime)}';
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