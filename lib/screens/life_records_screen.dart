import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class LifeRecordsScreen extends StatefulWidget {
  const LifeRecordsScreen({super.key});

  @override
  State<LifeRecordsScreen> createState() => _LifeRecordsScreenState();
}

class _LifeRecordsScreenState extends State<LifeRecordsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _photoRecords = [
    {
      'id': '1',
      'date': '2024-01-15',
      'title': '公园散步',
      'description': '小白在公园里开心地奔跑，享受阳光和新鲜空气',
      'photos': ['photo1.jpg', 'photo2.jpg', 'photo3.jpg'],
      'location': '中央公园',
      'mood': 'happy',
      'weather': '晴天',
      'temperature': '22°C',
      'tags': ['运动', '户外', '开心'],
    },
    {
      'id': '2',
      'date': '2024-01-14',
      'title': '午睡时光',
      'description': '小白在阳光下安静地睡觉，表情很安详',
      'photos': ['photo4.jpg', 'photo5.jpg'],
      'location': '家里客厅',
      'mood': 'peaceful',
      'weather': '多云',
      'temperature': '20°C',
      'tags': ['休息', '室内', '安静'],
    },
    {
      'id': '3',
      'date': '2024-01-13',
      'title': '新玩具',
      'description': '小白收到了新的玩具球，非常兴奋地玩耍',
      'photos': ['photo6.jpg', 'photo7.jpg', 'photo8.jpg', 'photo9.jpg'],
      'location': '家里',
      'mood': 'excited',
      'weather': '雨天',
      'temperature': '18°C',
      'tags': ['玩具', '室内', '兴奋'],
    },
    {
      'id': '4',
      'date': '2024-01-12',
      'title': '洗澡时间',
      'description': '给小白洗澡，虽然它不太情愿但很配合',
      'photos': ['photo10.jpg', 'photo11.jpg'],
      'location': '浴室',
      'mood': 'reluctant',
      'weather': '阴天',
      'temperature': '19°C',
      'tags': ['清洁', '室内', '护理'],
    },
  ];

  final List<Map<String, dynamic>> _activityRecords = [
    {
      'id': '1',
      'date': '2024-01-15',
      'activity': '散步',
      'duration': '30分钟',
      'distance': '2.5公里',
      'calories': '120卡路里',
      'notes': '天气很好，小白很活跃，遇到了几只其他的狗狗',
      'icon': Icons.directions_walk_outlined,
      'color': NothingTheme.info,
      'intensity': 'medium',
    },
    {
      'id': '2',
      'date': '2024-01-14',
      'activity': '游戏',
      'duration': '45分钟',
      'distance': '0.8公里',
      'calories': '80卡路里',
      'notes': '在家里玩接球游戏，小白反应很快',
      'icon': Icons.sports_tennis_outlined,
      'color': NothingTheme.success,
      'intensity': 'low',
    },
    {
      'id': '3',
      'date': '2024-01-13',
      'activity': '训练',
      'duration': '20分钟',
      'distance': '0.3公里',
      'calories': '40卡路里',
      'notes': '练习坐下和握手指令，进步很大',
      'icon': Icons.school_outlined,
      'color': NothingTheme.warning,
      'intensity': 'high',
    },
    {
      'id': '4',
      'date': '2024-01-12',
      'activity': '跑步',
      'duration': '25分钟',
      'distance': '3.2公里',
      'calories': '150卡路里',
      'notes': '晨跑，小白精力充沛，跑得很快',
      'icon': Icons.directions_run_outlined,
      'color': NothingTheme.error,
      'intensity': 'high',
    },
    {
      'id': '5',
      'date': '2024-01-11',
      'activity': '游泳',
      'duration': '15分钟',
      'distance': '0.5公里',
      'calories': '90卡路里',
      'notes': '第一次游泳，小白有点紧张但表现不错',
      'icon': Icons.pool_outlined,
      'color': NothingTheme.info,
      'intensity': 'medium',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: NothingTheme.surfaceTertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: NothingTheme.textPrimary,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '生活记录',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: NothingTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 16,
                  color: Color(0xFF5352ED),
                ),
              ),
              onPressed: () {
                // TODO: 添加新记录
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: NothingTheme.textPrimary,
          unselectedLabelColor: NothingTheme.textSecondary,
          indicatorColor: NothingTheme.info,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: '照片记录'),
            Tab(text: '活动记录'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhotoRecords(),
          _buildActivityRecords(),
        ],
      ),
    );
  }

  Widget _buildPhotoRecords() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计概览卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: NothingTheme.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: Color(0xFF70A1FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '照片记录统计',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: NothingTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '记录美好时光',
                            style: TextStyle(
                              fontSize: 14,
                              color: NothingTheme.textSecondary,
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
                      child: _buildStatItem('总记录', '${_photoRecords.length}', NothingTheme.info),
                    ),
                    Container(width: 1, height: 40, color: NothingTheme.gray300),
                    Expanded(
                      child: _buildStatItem('本月', '${_photoRecords.length}', NothingTheme.success),
                    ),
                    Container(width: 1, height: 40, color: NothingTheme.gray300),
                    Expanded(
                      child: _buildStatItem('照片数', '${_photoRecords.fold(0, (sum, record) => sum + (record['photos'] as List).length)}', NothingTheme.warning),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 筛选和排序
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '记录列表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: NothingTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NothingTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NothingTheme.gray300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_outlined,
                          size: 16,
                          color: NothingTheme.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '排序',
                          style: TextStyle(
                            fontSize: 12,
                            color: NothingTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NothingTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NothingTheme.gray300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_outlined,
                          size: 16,
                          color: NothingTheme.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '筛选',
                          style: TextStyle(
                            fontSize: 12,
                            color: NothingTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 照片记录列表
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _photoRecords.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final record = _photoRecords[index];
              return _buildPhotoRecord(record);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRecords() {
    final totalDuration = _activityRecords.fold(0, (sum, record) {
      final duration = int.parse(record['duration'].replaceAll('分钟', ''));
      return sum + duration;
    });
    
    final totalDistance = _activityRecords.fold(0.0, (sum, record) {
      final distance = double.parse(record['distance'].replaceAll('公里', ''));
      return sum + distance;
    });
    
    final totalCalories = _activityRecords.fold(0, (sum, record) {
      final calories = int.parse(record['calories'].replaceAll('卡路里', ''));
      return sum + calories;
    });
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计概览卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: NothingTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.directions_run_outlined,
                        color: Color(0xFF2ED573),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '活动统计',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: NothingTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '健康运动记录',
                            style: TextStyle(
                              fontSize: 14,
                              color: NothingTheme.textSecondary,
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
                      child: _buildStatItem('总时长', '${totalDuration}分钟', NothingTheme.info),
                    ),
                    Container(width: 1, height: 40, color: NothingTheme.gray300),
                    Expanded(
                      child: _buildStatItem('总距离', '${totalDistance.toStringAsFixed(1)}公里', NothingTheme.success),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('消耗热量', '${totalCalories}卡', NothingTheme.error),
                    ),
                    Container(width: 1, height: 40, color: NothingTheme.gray300),
                    Expanded(
                      child: _buildStatItem('活动次数', '${_activityRecords.length}次', NothingTheme.warning),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 活动类型快捷筛选
          const Text(
            '活动类型',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildActivityTypeChip('全部', true),
                const SizedBox(width: 8),
                _buildActivityTypeChip('散步', false),
                const SizedBox(width: 8),
                _buildActivityTypeChip('跑步', false),
                const SizedBox(width: 8),
                _buildActivityTypeChip('游戏', false),
                const SizedBox(width: 8),
                _buildActivityTypeChip('训练', false),
                const SizedBox(width: 8),
                _buildActivityTypeChip('游泳', false),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 活动记录列表
          const Text(
            '活动记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activityRecords.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = _activityRecords[index];
              return _buildActivityRecord(record);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: NothingTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTypeChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? NothingTheme.info : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? NothingTheme.info : NothingTheme.gray300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : NothingTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPhotoRecord(Map<String, dynamic> record) {
    Color moodColor = NothingTheme.success;
    IconData moodIcon = Icons.sentiment_satisfied_outlined;
    String moodText = '满足';
    
    switch (record['mood']) {
      case 'happy':
        moodColor = NothingTheme.success;
        moodIcon = Icons.sentiment_very_satisfied_outlined;
        moodText = '开心';
        break;
      case 'peaceful':
        moodColor = NothingTheme.info;
        moodIcon = Icons.sentiment_satisfied_outlined;
        moodText = '平静';
        break;
      case 'excited':
        moodColor = NothingTheme.warning;
        moodIcon = Icons.sentiment_very_satisfied_outlined;
        moodText = '兴奋';
        break;
      case 'reluctant':
        moodColor = NothingTheme.textSecondary;
        moodIcon = Icons.sentiment_neutral_outlined;
        moodText = '不情愿';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Expanded(
                child: Text(
                  record['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: NothingTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      moodIcon,
                      color: moodColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      moodText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: moodColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record['description'],
            style: const TextStyle(
              fontSize: 14,
              color: NothingTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          // 照片网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: (record['photos'] as List).length,
            itemBuilder: (context, photoIndex) {
              return Container(
                decoration: BoxDecoration(
                  color: NothingTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NothingTheme.gray300),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: NothingTheme.textSecondary,
                  size: 24,
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // 标签
          if (record['tags'] != null && (record['tags'] as List).isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (record['tags'] as List<String>).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NothingTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5352ED),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // 详细信息
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                record['date'],
                style: const TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                record['location'],
                style: const TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.wb_sunny_outlined,
                size: 14,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${record['weather']} ${record['temperature']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRecord(Map<String, dynamic> record) {
    Color intensityColor = NothingTheme.success;
    String intensityText = '低强度';
    
    switch (record['intensity']) {
      case 'low':
        intensityColor = NothingTheme.success;
        intensityText = '低强度';
        break;
      case 'medium':
        intensityColor = NothingTheme.warning;
        intensityText = '中强度';
        break;
      case 'high':
        intensityColor = NothingTheme.error;
        intensityText = '高强度';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  color: record['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  record['icon'],
                  color: record['color'],
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
                          record['activity'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: NothingTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: intensityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            intensityText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: intensityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 12,
                          color: NothingTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record['date'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: NothingTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NothingTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActivityMetric('时长', record['duration'], Icons.timer_outlined),
                ),
                Container(width: 1, height: 30, color: NothingTheme.gray300),
                Expanded(
                  child: _buildActivityMetric('距离', record['distance'], Icons.straighten_outlined),
                ),
                Container(width: 1, height: 30, color: NothingTheme.gray300),
                Expanded(
                  child: _buildActivityMetric('热量', record['calories'], Icons.local_fire_department_outlined),
                ),
              ],
            ),
          ),
          if (record['notes'] != null && record['notes'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NothingTheme.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NothingTheme.info.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note_outlined,
                    size: 16,
                    color: Color(0xFF5352ED),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record['notes'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5352ED),
                        height: 1.4,
                      ),
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

  Widget _buildActivityMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: NothingTheme.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: NothingTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}