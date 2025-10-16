import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import '../../utils/responsive_helper.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import '../../main_app.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.pets,
      title: '欢迎使用',
      subtitle: '为您的宠物提供全方位智能照护',
      features: [
        OnboardingFeature(icon: Icons.health_and_safety, title: '智能健康管理'),
        OnboardingFeature(icon: Icons.psychology, title: 'AI 行为识别'),
        OnboardingFeature(icon: Icons.build, title: '出行工具集成'),
        OnboardingFeature(icon: Icons.folder, title: '证件资料管理'),
      ],
    ),
    OnboardingPage(
      icon: Icons.person_outline,
      title: '第一步',
      subtitle: '建立档案',
      description: '为您的宠物创建专属健康档案',
      features: [
        OnboardingFeature(icon: Icons.edit_note, title: '基础信息登记'),
        OnboardingFeature(icon: Icons.medical_services, title: '疫苗健康记录'),
        OnboardingFeature(icon: Icons.trending_up, title: '成长数据追踪'),
        OnboardingFeature(icon: Icons.sync, title: '多端同步共享'),
      ],
    ),
    OnboardingPage(
      icon: Icons.camera_alt_outlined,
      title: '核心功能',
      subtitle: 'AI 相机',
      description: '智能识别宠物状态与行为',
      features: [
        OnboardingFeature(icon: Icons.analytics, title: '健康状况分析'),
        OnboardingFeature(icon: Icons.visibility, title: '行为模式识别'),
        OnboardingFeature(icon: Icons.mood, title: '情绪状态检测'),
        OnboardingFeature(icon: Icons.report, title: '异常警报提醒'),
      ],
    ),
    OnboardingPage(
      icon: Icons.eco_outlined,
      title: '智能设备',
      subtitle: '出行工具',
      description: '出行箱监控与资料包管理',
      features: [
        OnboardingFeature(icon: Icons.monitor, title: '实时环境监控'),
        OnboardingFeature(icon: Icons.tune, title: '智能模式调节'),
        OnboardingFeature(icon: Icons.inventory, title: '证件资料包'),
        OnboardingFeature(icon: Icons.settings, title: '检疫信息管理'),
      ],
    ),
  ];

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
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 最后一页，跳转到今日页面
      Navigator.of(context).pushReplacementWithFadeSlideTransition(
        const MainApp(),
      );
    }
  }

  void _skipToLogin() {
    Navigator.of(context).pushReplacementWithFadeSlideTransition(
      const LoginScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ResponsiveContainer(
              mobilePadding: EdgeInsets.zero,
              tabletPadding: const EdgeInsets.symmetric(horizontal: 48.0),
              desktopPadding: const EdgeInsets.symmetric(horizontal: 64.0),
              mobileMaxWidth: double.infinity,
              tabletMaxWidth: 700,
              desktopMaxWidth: 600,
              child: Column(
                children: [
                  // 顶部Logo
                  _buildHeader(),
                  
                  // 页面内容
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _buildPageContent(_pages[index]);
                      },
                    ),
                  ),
                  
                  // 底部按钮和指示器
                  _buildBottomSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 24.0,
          tablet: 32.0,
          desktop: 40.0,
        ),
        vertical: ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 20.0,
          tablet: 24.0,
          desktop: 28.0,
        ),
      ),
      child: Row(
        children: [
          Text(
            'Felo',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            '跳过',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 24.0,
          tablet: 32.0,
          desktop: 48.0,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 40,
              tablet: 48,
              desktop: 56,
            ),
          ),
          
          // 图标
          Container(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 120,
              tablet: 140,
              desktop: 160,
            ),
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 120,
              tablet: 140,
              desktop: 160,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFB74D),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: ResponsiveHelper.getResponsiveWidth(
                context,
                mobile: 50,
                tablet: 58,
                desktop: 66,
              ),
              color: const Color(0xFF5D4037),
            ),
          ),
          
          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 40,
              tablet: 48,
              desktop: 56,
            ),
          ),
          
          // 标题和副标题
          if (page.title.isNotEmpty)
            Text(
              page.title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                color: const Color(0xFF999999),
              ),
            ),
          
          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
          ),
          
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          
          if (page.description != null) ...[
            SizedBox(
              height: ResponsiveHelper.getResponsiveHeight(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Text(
              page.description!,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 40,
              tablet: 48,
              desktop: 56,
            ),
          ),
          
          // 功能列表
          Expanded(
            child: ListView.builder(
              itemCount: page.features.length,
              itemBuilder: (context, index) {
                return _buildFeatureItem(page.features[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(OnboardingFeature feature) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 16,
          tablet: 18,
          desktop: 20,
        ),
      ),
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 20,
          tablet: 24,
          desktop: 28,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: const Color(0xFF4CAF50),
            size: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 20,
              tablet: 22,
              desktop: 24,
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          Expanded(
            child: Text(
              feature.title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 24,
          tablet: 32,
          desktop: 40,
        ),
      ),
      child: Column(
        children: [
          // 页面指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 4,
                    tablet: 5,
                    desktop: 6,
                  ),
                ),
                width: _currentPage == index 
                    ? ResponsiveHelper.getResponsiveWidth(
                        context,
                        mobile: 24,
                        tablet: 28,
                        desktop: 32,
                      )
                    : ResponsiveHelper.getResponsiveWidth(
                        context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? const Color(0xFFFF9800) 
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 32,
              tablet: 40,
              desktop: 48,
            ),
          ),
          
          // 按钮
          SizedBox(
            width: double.infinity,
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 56,
              tablet: 60,
              desktop: 64,
            ),
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == _pages.length - 1 ? '开始使用' : '下一步',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                      fontWeight: FontWeight.w600,
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
                  Icon(
                    Icons.arrow_forward,
                    size: ResponsiveHelper.getResponsiveWidth(
                      context,
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_currentPage == _pages.length - 1) ...[
            SizedBox(
              height: ResponsiveHelper.getResponsiveHeight(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.getResponsiveHeight(
                context,
                mobile: 56,
                tablet: 60,
                desktop: 64,
              ),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementWithFadeSlideTransition(
                    const ProfileSetupScreen(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF666666),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveSpacing(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                  ),
                ),
                child: Text(
                  '立即创建档案',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? description;
  final List<OnboardingFeature> features;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.description,
    required this.features,
  });
}

class OnboardingFeature {
  final IconData icon;
  final String title;

  OnboardingFeature({
    required this.icon,
    required this.title,
  });
}