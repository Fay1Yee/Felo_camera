import 'package:flutter/material.dart';
import '../ui/camera_screen.dart';
import '../utils/responsive_helper.dart';
import 'health_screen.dart';
import 'reminder_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7), // 米白主背景
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 32,
                ),
                vertical: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF), // 纯白卡片
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFECEFF1), // 浅灰分隔
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Felo Camera',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF37474F), // 深灰文字
                        ),
                      ),
                      Text(
                        '我的智能档案',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                          color: const Color(0xFF78909C), // 中灰文字
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: const Color(0xFF90A4AE), // 浅灰辅助
                          size: ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          ),
                        ),
                        onPressed: () {
                          // TODO: 打开通知页面
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.person_outline,
                          color: const Color(0xFF90A4AE), // 浅灰辅助
                          size: ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 主要内容区域
            Expanded(
              child: _currentIndex == 0 ? _buildHomeContent() : IndexedStack(
                index: _currentIndex - 1,
                children: const [
                  HealthScreen(),
                  ReminderScreen(),
                  HistoryScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // 底部导航栏
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // 纯白卡片
          border: Border(
            top: BorderSide(
              color: const Color(0xFFECEFF1), // 浅灰分隔
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 24,
                desktop: 32,
              ),
              vertical: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: '首页',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.favorite_outline,
                  activeIcon: Icons.favorite,
                  label: '健康',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: '提醒',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: '记录',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 32,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 宠物状态卡片
            _buildPetStatusCard(),
            
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 32,
              ),
            ),
            
            // 今日重点卡片
            _buildTodayHighlightCard(),
            
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 32,
              ),
            ),
            
            // 功能快捷入口
            _buildQuickActions(),
            
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 32,
              ),
            ),
            
            // AI相机按钮
            _buildAICameraButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPetStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 20,
          tablet: 24,
          desktop: 28,
        ),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // 纯白卡片
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 12,
            tablet: 16,
            desktop: 20,
          ),
        ),
        border: Border.all(
          color: const Color(0xFFECEFF1), // 浅灰分隔
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 60,
                  tablet: 70,
                  desktop: 80,
                ),
                height: ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 60,
                  tablet: 70,
                  desktop: 80,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD84D), // 亮黄色
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveWidth(
                      context,
                      mobile: 30,
                      tablet: 35,
                      desktop: 40,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.pets,
                  size: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 30,
                    tablet: 35,
                    desktop: 40,
                  ),
                  color: const Color(0xFF37474F), // 深灰文字
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '泡泡',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF37474F), // 深灰文字
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        mobile: 4,
                        tablet: 6,
                        desktop: 8,
                      ),
                    ),
                    Text(
                      '布偶猫 • 2岁 • 雌性',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                        color: const Color(0xFF78909C), // 中灰文字
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                  vertical: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 4,
                    tablet: 6,
                    desktop: 8,
                  ),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // 浅绿背景
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  border: Border.all(
                    color: const Color(0xFF4CAF50), // 中绿色
                    width: 1,
                  ),
                ),
                child: Text(
                  '健康',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2F5233), // 墨绿色
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),
          // 性格词云
          Wrap(
            spacing: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
            runSpacing: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
            children: [
              _buildPersonalityTag('温柔', false),
              _buildPersonalityTag('聪明伶俐', true),
              _buildPersonalityTag('爱玩耍', false),
              _buildPersonalityTag('超级黏人', true, isLarge: true),
              _buildPersonalityTag('小吃货', false),
              _buildPersonalityTag('好奇宝宝', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityTag(String text, bool isYellow, {bool isLarge = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: isLarge ? 12 : 8,
          tablet: isLarge ? 14 : 10,
          desktop: isLarge ? 16 : 12,
        ),
        vertical: ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: isLarge ? 8 : 4,
          tablet: isLarge ? 10 : 6,
          desktop: isLarge ? 12 : 8,
        ),
      ),
      decoration: BoxDecoration(
        color: isYellow ? const Color(0xFFFFF8E1) : const Color(0xFFF5F5F0), // 浅黄/浅米色
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: isLarge ? 16 : 12,
            tablet: isLarge ? 18 : 14,
            desktop: isLarge ? 20 : 16,
          ),
          fontWeight: isLarge ? FontWeight.w600 : FontWeight.w500,
          color: isYellow ? const Color(0xFF37474F) : const Color(0xFF78909C),
        ),
      ),
    );
  }

  Widget _buildTodayHighlightCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 20,
          tablet: 24,
          desktop: 28,
        ),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // 浅黄卡片
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 12,
            tablet: 16,
            desktop: 20,
          ),
        ),
        border: Border.all(
          color: const Color(0xFFFFD84D), // 亮黄色
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                height: ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD84D), // 亮黄色
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveWidth(
                      context,
                      mobile: 4,
                      tablet: 5,
                      desktop: 6,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
              ),
              Text(
                '我今天的表现',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF37474F), // 深灰文字
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          Text(
            '我今天表现很棒！已经完成了晨间散步，食欲正常，情绪很活跃。主人记得下午给我补充水分哦～',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
              color: const Color(0xFF37474F), // 深灰文字
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷功能',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF37474F), // 深灰文字
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.favorite,
                title: '我的健康管理',
                subtitle: '我的体检记录',
                color: const Color(0xFF2F5233), // 墨绿色
                backgroundColor: const Color(0xFFE8F5E9), // 浅绿背景
                onTap: () => _onItemTapped(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.flight_takeoff,
                title: '我的出行工具',
                subtitle: '我的旅行助手',
                color: const Color(0xFF37474F), // 深灰文字
                backgroundColor: const Color(0xFFFFF8E1), // 浅黄背景
                onTap: () {
                  // TODO: 打开出行工具
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.person,
                title: '我的档案',
                subtitle: '我的详细信息',
                color: const Color(0xFF78909C), // 中灰文字
                backgroundColor: const Color(0xFFFFFFFF), // 白色背景
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: '我的生活记录',
                subtitle: '我的成长轨迹',
                color: const Color(0xFF78909C), // 中灰文字
                backgroundColor: const Color(0xFFFFFFFF), // 白色背景
                onTap: () => _onItemTapped(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFECEFF1), // 浅灰分隔
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF37474F), // 深灰文字
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF78909C), // 中灰文字
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAICameraButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        },
        child: Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD84D), // 亮黄色
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD84D).withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 24,
                color: const Color(0xFF37474F), // 深灰文字
              ),
              const SizedBox(width: 8),
              Text(
                'AI 智能相机',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF37474F), // 深灰文字
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF8E1) : Colors.transparent, // 浅黄背景
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF2F5233) : const Color(0xFF90A4AE), // 墨绿色/浅灰辅助
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF2F5233) : const Color(0xFF90A4AE), // 墨绿色/浅灰辅助
              ),
            ),
          ],
        ),
      ),
    );
  }
}