import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

/// 出行计划状态
enum TravelPlanStatus {
  draft('草稿', Icons.edit, NothingTheme.textSecondary),
  confirmed('已确认', Icons.check_circle, NothingTheme.success),
  inProgress('进行中', Icons.flight_takeoff, NothingTheme.brandPrimary),
  completed('已完成', Icons.done_all, NothingTheme.info),
  cancelled('已取消', Icons.cancel, NothingTheme.error);

  const TravelPlanStatus(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 行程项目
class ItineraryItem {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String category;
  final bool isCompleted;
  final List<String> notes;

  const ItineraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.category,
    this.isCompleted = false,
    this.notes = const [],
  });
}

/// 目的地信息
class DestinationInfo {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final List<String> amenities;
  final Map<String, String> contacts;
  final List<String> photos;

  const DestinationInfo({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.amenities = const [],
    this.contacts = const {},
    this.photos = const [],
  });
}

/// 注意事项
class TravelNote {
  final String id;
  final String title;
  final String content;
  final String category;
  final int priority; // 1-5, 5最高
  final bool isCompleted;
  final DateTime createdAt;

  const TravelNote({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.priority = 3,
    this.isCompleted = false,
    required this.createdAt,
  });
}

/// 出行计划详情界面
class TravelPlanDetailsScreen extends StatefulWidget {
  final String planId;
  final String petId;

  const TravelPlanDetailsScreen({
    super.key,
    required this.planId,
    required this.petId,
  });

  @override
  State<TravelPlanDetailsScreen> createState() => _TravelPlanDetailsScreenState();
}

class _TravelPlanDetailsScreenState extends State<TravelPlanDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  TravelPlanStatus _planStatus = TravelPlanStatus.confirmed;
  DestinationInfo? _destination;
  List<ItineraryItem> _itinerary = [];
  List<TravelNote> _notes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _loadPlanData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadPlanData() {
    // 模拟数据加载
    setState(() {
      _destination = const DestinationInfo(
        name: '青岛海滨度假村',
        address: '山东省青岛市崂山区海尔路1号',
        latitude: 36.0986,
        longitude: 120.3719,
        description: '位于海边的宠物友好度假村，提供专业的宠物照护服务和丰富的娱乐设施。',
        amenities: ['宠物游泳池', '宠物美容', '24小时兽医', '宠物餐厅', '户外运动场'],
        contacts: {
          '前台': '+86-532-1234567',
          '宠物服务': '+86-532-1234568',
          '紧急联系': '+86-532-1234569',
        },
      );

      _itinerary = [
        ItineraryItem(
          id: '1',
          title: '出发前准备',
          description: '检查宠物健康状况，准备出行用品',
          startTime: DateTime.now().add(const Duration(days: 1, hours: 8)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
          location: '家中',
          category: '准备',
        ),
        ItineraryItem(
          id: '2',
          title: '前往目的地',
          description: '乘坐高铁前往青岛，全程约4小时',
          startTime: DateTime.now().add(const Duration(days: 1, hours: 12)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 16)),
          location: '北京南站 → 青岛站',
          category: '交通',
        ),
        ItineraryItem(
          id: '3',
          title: '入住度假村',
          description: '办理入住手续，熟悉环境',
          startTime: DateTime.now().add(const Duration(days: 1, hours: 17)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 19)),
          location: '青岛海滨度假村',
          category: '住宿',
        ),
        ItineraryItem(
          id: '4',
          title: '海滨散步',
          description: '带宠物在海边散步，适应新环境',
          startTime: DateTime.now().add(const Duration(days: 2, hours: 7)),
          endTime: DateTime.now().add(const Duration(days: 2, hours: 9)),
          location: '度假村海滩',
          category: '活动',
        ),
        ItineraryItem(
          id: '5',
          title: '宠物游泳体验',
          description: '在专业宠物游泳池进行游泳训练',
          startTime: DateTime.now().add(const Duration(days: 2, hours: 14)),
          endTime: DateTime.now().add(const Duration(days: 2, hours: 16)),
          location: '度假村宠物游泳池',
          category: '活动',
        ),
      ];

      _notes = [
        TravelNote(
          id: '1',
          title: '疫苗证明',
          content: '确保携带最新的疫苗接种证明和健康证书',
          category: '健康',
          priority: 5,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        TravelNote(
          id: '2',
          title: '紧急药品',
          content: '准备常用药品：止泻药、消炎药、创可贴等',
          category: '健康',
          priority: 4,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        TravelNote(
          id: '3',
          title: '食物准备',
          content: '携带足够的日常食物，避免突然更换饮食',
          category: '饮食',
          priority: 4,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TravelNote(
          id: '4',
          title: '天气关注',
          content: '关注目的地天气变化，准备相应的保暖或防晒用品',
          category: '环境',
          priority: 3,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        TravelNote(
          id: '5',
          title: '联系方式',
          content: '保存当地宠物医院和紧急联系人的电话号码',
          category: '安全',
          priority: 5,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
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
          '出行计划详情',
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
            icon: const Icon(Icons.edit, color: NothingTheme.textPrimary),
            onPressed: () {
              // 编辑计划
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: NothingTheme.textPrimary),
            onPressed: () {
              // 分享计划
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: NothingTheme.textPrimary,
          unselectedLabelColor: NothingTheme.textSecondary,
          indicatorColor: NothingTheme.brandPrimary,
          tabs: const [
            Tab(text: '行程安排'),
            Tab(text: '目的地'),
            Tab(text: '注意事项'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 计划状态卡片
            _buildPlanStatusCard(),
            
            // Tab内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildItineraryTab(),
                  _buildDestinationTab(),
                  _buildNotesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _planStatus.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            ),
            child: Icon(
              _planStatus.icon,
              color: _planStatus.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '计划状态',
                  style: TextStyle(
                    color: NothingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _planStatus.displayName,
                  style: TextStyle(
                    color: _planStatus.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: NothingTheme.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            ),
            child: Text(
              '3天2夜',
              style: const TextStyle(
                color: NothingTheme.brandPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _itinerary.length,
      itemBuilder: (context, index) {
        final item = _itinerary[index];
        return _buildItineraryItem(item, index);
      },
    );
  }

  Widget _buildItineraryItem(ItineraryItem item, int index) {
    final isLast = index == _itinerary.length - 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.isCompleted ? NothingTheme.success : NothingTheme.brandPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: NothingTheme.gray200,
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // 内容
          Expanded(
            child: Container(
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
                          item.title,
                          style: const TextStyle(
                            color: NothingTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(item.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            color: _getCategoryColor(item.category),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    item.description,
                    style: TextStyle(
                      color: NothingTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: NothingTheme.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}',
                        style: TextStyle(
                          color: NothingTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                      Expanded(
                        child: Text(
                          item.location,
                          style: TextStyle(
                            color: NothingTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationTab() {
    if (_destination == null) {
      return const Center(
        child: Text('暂无目的地信息'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本信息
          Container(
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
                Text(
                  _destination!.name,
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: NothingTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _destination!.address,
                        style: TextStyle(
                          color: NothingTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Text(
                  _destination!.description,
                  style: TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 设施服务
          Container(
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
                  '设施服务',
                  style: TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _destination!.amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: NothingTheme.brandPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                      ),
                      child: Text(
                        amenity,
                        style: const TextStyle(
                          color: NothingTheme.brandPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 联系方式
          Container(
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
                  '联系方式',
                  style: TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                for (final contact in _destination!.contacts.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          child: Text(
                            contact.key,
                            style: TextStyle(
                              color: NothingTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            contact.value,
                            style: const TextStyle(
                              color: NothingTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.phone,
                            color: NothingTheme.brandPrimary,
                            size: 18,
                          ),
                          onPressed: () {
                            // 拨打电话
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notes.length + 1,
      itemBuilder: (context, index) {
        if (index == _notes.length) {
          return _buildAddNoteButton();
        }
        return _buildNoteItem(_notes[index]);
      },
    );
  }

  Widget _buildNoteItem(TravelNote note) {
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
                  note.title,
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(note.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < note.priority; i++)
                      Icon(
                        Icons.star,
                        color: _getPriorityColor(note.priority),
                        size: 10,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            note.content,
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(note.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Text(
                  note.category,
                  style: TextStyle(
                    color: _getCategoryColor(note.category),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(note.createdAt),
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddNoteButton() {
    return GestureDetector(
      onTap: () {
        // 添加新注意事项
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NothingTheme.surface,
          borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
          border: Border.all(
            color: NothingTheme.brandPrimary.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: NothingTheme.brandPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              '添加注意事项',
              style: TextStyle(
                color: NothingTheme.brandPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '准备':
      case '健康':
        return NothingTheme.success;
      case '交通':
      case '安全':
        return NothingTheme.error;
      case '住宿':
      case '饮食':
        return NothingTheme.brandPrimary;
      case '活动':
      case '环境':
        return NothingTheme.info;
      default:
        return NothingTheme.textSecondary;
    }
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 5) return NothingTheme.error;
    if (priority >= 4) return NothingTheme.warning;
    if (priority >= 3) return NothingTheme.info;
    return NothingTheme.textSecondary;
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}