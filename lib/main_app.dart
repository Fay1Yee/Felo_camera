import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/phone_status_bar.dart';
import 'services/history_manager.dart';
import 'models/ai_result.dart';
import 'models/analysis_history.dart';

import 'screens/today_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/travel_box_screen.dart';
import 'screens/settings_screen.dart';
import 'ui/camera_screen_io.dart' if (dart.library.html) 'ui/camera_screen_web.dart';
import 'models/mode.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const TodayScreen(),
    ProfileScreen(),
    const TravelBoxScreen(),
    const SettingsScreen(),
  ];

  final List<String> _subtitles = ['宠物管家', '宠物身份证', '设备与场景', '个人中心'];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// 初始化应用服务
  Future<void> _initializeServices() async {
    try {
      // 初始化历史记录管理器
      await HistoryManager.instance.initialize();
      debugPrint('✅ 应用服务初始化完成');
      
      // 添加测试数据
      await _addTestData();
    } catch (e) {
      debugPrint('❌ 应用服务初始化失败: $e');
    }
  }

  /// 添加测试数据
  Future<void> _addTestData() async {
    try {
      debugPrint('🔧 开始添加测试数据...');
      
      final now = DateTime.now();
      
      // 创建测试数据
      final testActivities = [
        {
           'title': '玩耍行为',
           'subInfo': '小猫在客厅里追逐玩具球，表现出很高的活跃度',
           'confidence': 95,
           'timestamp': now.subtract(const Duration(hours: 2)),
         },
         {
           'title': '休息行为', 
           'subInfo': '小猫在阳光下的猫窝里安静地睡觉',
           'confidence': 88,
           'timestamp': now.subtract(const Duration(hours: 1)),
         },
         {
           'title': '进食行为',
           'subInfo': '小猫正在吃猫粮，食欲良好',
           'confidence': 92,
           'timestamp': now.subtract(const Duration(minutes: 30)),
         },
      ];

      for (final activity in testActivities) {
        final aiResult = AIResult(
           title: activity['title'] as String,
           subInfo: activity['subInfo'] as String,
           confidence: activity['confidence'] as int,
         );

        debugPrint('📝 正在添加测试数据: ${activity['title']} - ${activity['timestamp']}');
        
        await HistoryManager.instance.addHistoryWithTimestamp(
          result: aiResult,
          mode: 'behavior',
          timestamp: activity['timestamp'] as DateTime,
        );
        
        debugPrint('✅ 成功添加: ${activity['title']}');
      }

      debugPrint('✅ 测试数据添加完成，共添加 ${testActivities.length} 条记录');
      
      // 验证数据是否成功添加
      final allHistories = await HistoryManager.instance.getAllHistories();
      debugPrint('🔍 验证: HistoryManager中现有 ${allHistories.length} 条记录');
    } catch (e) {
      debugPrint('❌ 添加测试数据失败: $e');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onCameraPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(initialMode: Mode.pet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7), // 米白主背景 - 符合设计规范
      body: Stack(
        children: [
          // 状态栏
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PhoneStatusBar(),
          ),
          
          // 顶部标题栏
          Positioned(
            top: 44,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.98),
                border: const Border(
                  bottom: BorderSide(
                    color: Color(0xFFECEFF1),
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Felo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF37474F), // 深灰 - 符合设计规范
                      ),
                    ),
                    Text(
                      _subtitles[_currentIndex],
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF78909C), // 中灰 - 符合设计规范
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 主内容区域
          Positioned(
            top: 104,
            left: 0,
            right: 0,
            bottom: 76 + 34, // 底部导航栏高度 + Home指示器高度
            child: _pages[_currentIndex],
          ),
          
          // 底部导航栏
          Positioned(
            bottom: 34, // Home指示器高度
            left: 0,
            right: 0,
            height: 76,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.98),
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFECEFF1),
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 今日标签
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: '今日',
                    ),
                    
                    // 档案标签
                    _buildNavItem(
                      index: 1,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: '档案',
                    ),
                    
                    // Pet Camera按钮（中央）
                    GestureDetector(
                      onTap: _onCameraPressed,
                      child: Container(
                        width: 56,
                        height: 56,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50), // 绿色，代表宠物
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets, // 宠物图标
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    
                    // 出行箱标签
                    _buildNavItem(
                      index: 2,
                      icon: Icons.inventory_2_outlined,
                      activeIcon: Icons.inventory_2,
                      label: '出行箱',
                    ),
                    
                    // 我的标签
                    _buildNavItem(
                      index: 3,
                      icon: Icons.account_circle_outlined,
                      activeIcon: Icons.account_circle,
                      label: '我的',
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 保留底部空间但移除指示器UI
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 34, // 保持原有高度以维持布局
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF8E1) : Colors.transparent, // 浅黄背景
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF2F5233) : const Color(0xFF90A4AE), // 墨绿色或浅灰色 - 符合设计规范
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? const Color(0xFF37474F) : const Color(0xFF78909C), // 深灰或中灰 - 符合设计规范
              ),
            ),
          ],
        ),
      ),
    );
  }
}