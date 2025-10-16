import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pet_profile.dart';
import '../utils/responsive_helper.dart';
import 'system_config/notification_settings_screen.dart';
import 'system_config/profile_creation_screen.dart';
import 'system_config/profile_filling_screen.dart';
import 'system_config/camera_test_screen.dart';
import 'system_config/test_add_sample_data_screen.dart';
import 'permission_test_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;
  bool _enableHapticFeedback = true;
  bool _enableAutoSave = true;
  bool _enableRealTimeAnalysis = true;
  bool _enableDataSync = false;
  bool _enableLocationServices = false;
  String _selectedLanguage = '简体中文';
  String _selectedTheme = '跟随系统';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // 浅灰背景
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 24,
              desktop: 32,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面标题
              Text(
                '我的',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 20),
              ResponsiveContainer(
                mobilePadding: EdgeInsets.zero,
                tabletPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                desktopPadding: const EdgeInsets.symmetric(horizontal: 48.0),
                mobileMaxWidth: double.infinity,
                tabletMaxWidth: 700,
                desktopMaxWidth: 800,
                child: Column(
                  children: [
                    _buildUserProfile(),
                    const SizedBox(height: 16),
                    _buildSettingsSection(
                      title: '系统配置',
                      children: [
                        _buildActionItem(
                          icon: Icons.notifications_outlined,
                          title: '通知设置',
                          subtitle: '管理应用通知偏好',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationSettingsScreen(
                                petId: '', // 默认空字符串，后续可根据实际需求传入有效 petId
                                currentScenario: ScenarioMode.home,
                              ),
                            ),
                          ),
                        ),
                        _buildActionItem(
                          icon: Icons.pets,
                          title: '创建宠物档案',
                          subtitle: '添加新的宠物信息',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileCreationScreen(
                              currentScenario: ScenarioMode.home,
                            )),
                          ),
                        ),
                        _buildActionItem(
                          icon: Icons.edit_outlined,
                          title: '完善宠物档案',
                          subtitle: '编辑现有宠物信息',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileFillingScreen()),
                          ),
                        ),
                        _buildActionItem(
                          icon: Icons.camera_alt_outlined,
                          title: '相机测试',
                          subtitle: '测试和校准相机功能',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CameraTestScreen()),
                          ),
                        ),
                        _buildActionItem(
                          icon: Icons.security_outlined,
                          title: '权限管理',
                          subtitle: '管理应用权限设置',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PermissionTestScreen()),
                          ),
                        ),
                        _buildActionItem(
                          icon: Icons.bug_report_outlined,
                          title: '添加测试数据',
                          subtitle: '添加示例宠物活动数据用于调试',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TestAddSampleDataScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsSection(
                      title: '应用设置',
                      children: [
                        _buildSwitchItem(
                          icon: Icons.notifications_outlined,
                          title: '推送通知',
                          subtitle: '接收重要提醒和更新',
                          value: _enableNotifications,
                          onChanged: (value) => setState(() => _enableNotifications = value),
                        ),
                        _buildSwitchItem(
                          icon: Icons.vibration,
                          title: '触觉反馈',
                          subtitle: '操作时的震动反馈',
                          value: _enableHapticFeedback,
                          onChanged: (value) => setState(() => _enableHapticFeedback = value),
                        ),
                        _buildSwitchItem(
                          icon: Icons.save_outlined,
                          title: '自动保存',
                          subtitle: '自动保存拍摄的照片',
                          value: _enableAutoSave,
                          onChanged: (value) => setState(() => _enableAutoSave = value),
                        ),
                        _buildSwitchItem(
                          icon: Icons.analytics_outlined,
                          title: '实时分析',
                          subtitle: '开启AI实时行为分析',
                          value: _enableRealTimeAnalysis,
                          onChanged: (value) => setState(() => _enableRealTimeAnalysis = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsSection(
                      title: '个性化',
                      children: [
                        _buildSelectItem(
                          icon: Icons.language,
                          title: '语言',
                          subtitle: _selectedLanguage,
                          onTap: () => _showLanguageDialog(),
                        ),
                        _buildSelectItem(
                          icon: Icons.palette_outlined,
                          title: '主题',
                          subtitle: _selectedTheme,
                          onTap: () => _showThemeDialog(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsSection(
                      title: '数据与隐私',
                      children: [
                        _buildSwitchItem(
                          icon: Icons.sync,
                          title: '数据同步',
                          subtitle: '同步数据到云端',
                          value: _enableDataSync,
                          onChanged: (value) => setState(() => _enableDataSync = value),
                        ),
                        _buildSwitchItem(
                          icon: Icons.location_on_outlined,
                          title: '位置服务',
                          subtitle: '记录宠物活动位置',
                          value: _enableLocationServices,
                          onChanged: (value) => setState(() => _enableLocationServices = value),
                        ),
                        _buildActionItem(
                          icon: Icons.privacy_tip_outlined,
                          title: '隐私政策',
                          subtitle: '查看隐私保护条款',
                          onTap: () => _showPrivacyPolicy(),
                        ),
                        _buildActionItem(
                          icon: Icons.delete_outline,
                          title: '清除数据',
                          subtitle: '删除所有本地数据',
                          onTap: () => _showClearDataDialog(),
                          isDestructive: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsSection(
                      title: '关于',
                      children: [
                        _buildActionItem(
                          icon: Icons.info_outline,
                          title: '应用版本',
                          subtitle: 'v1.0.0 (Build 1)',
                          onTap: () {},
                        ),
                        _buildActionItem(
                          icon: Icons.help_outline,
                          title: '帮助与支持',
                          subtitle: '获取使用帮助',
                          onTap: () => _showHelpDialog(),
                        ),
                        _buildActionItem(
                          icon: Icons.star_outline,
                          title: '评价应用',
                          subtitle: '在App Store中评价',
                          onTap: () => _rateApp(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 20,
          tablet: 24,
          desktop: 28,
        ),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // 白色背景
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
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
              Icons.person,
              size: ResponsiveHelper.getResponsiveWidth(
                context,
                mobile: 32,
                tablet: 38,
                desktop: 44,
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
                  '宠物主人',
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
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 4,
                    tablet: 6,
                    desktop: 8,
                  ),
                ),
                Text(
                  '管理您的宠物生活',
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
          ),
          Icon(
            Icons.chevron_right,
            size: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
            color: const Color(0xFF78909C), // 中灰文字
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // 白色背景
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF37474F), // 深灰文字
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
          vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 40, tablet: 44, desktop: 48),
              height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 40, tablet: 44, desktop: 48),
              decoration: BoxDecoration(
                color: isDestructive 
                  ? const Color(0xFFFFEBEE) // 浅红色背景
                  : const Color(0xFFF5F5F0), // 浅米色背景
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getResponsiveSpacing(context, mobile: 20, tablet: 22, desktop: 24),
                color: isDestructive 
                  ? const Color(0xFFE53935) // 红色图标
                  : const Color(0xFF37474F), // 深灰图标
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                      fontWeight: FontWeight.w500,
                      color: isDestructive 
                        ? const Color(0xFFE53935) // 红色文字
                        : const Color(0xFF37474F), // 深灰文字
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 2, tablet: 3, desktop: 4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                      color: const Color(0xFF78909C), // 中灰文字
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: ResponsiveHelper.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20),
              color: const Color(0xFF78909C), // 中灰文字
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
        vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 40, tablet: 44, desktop: 48),
            height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 40, tablet: 44, desktop: 48),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F0), // 浅米色背景
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: ResponsiveHelper.getResponsiveSpacing(context, mobile: 20, tablet: 22, desktop: 24),
              color: const Color(0xFF37474F), // 深灰图标
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF37474F), // 深灰文字
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 2, tablet: 3, desktop: 4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                    color: const Color(0xFF78909C), // 中灰文字
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50), // 绿色
            inactiveThumbColor: const Color(0xFFBDBDBD), // 灰色
            inactiveTrackColor: const Color(0xFFE0E0E0), // 浅灰色
          ),
        ],
      ),
    );
  }

  Widget _buildSelectItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
          vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 40, tablet: 44, desktop: 48),
              height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 40, tablet: 44, desktop: 48),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F0), // 浅米色背景
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getResponsiveSpacing(context, mobile: 20, tablet: 22, desktop: 24),
                color: const Color(0xFF37474F), // 深灰图标
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF37474F), // 深灰文字
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 2, tablet: 3, desktop: 4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                      color: const Color(0xFF78909C), // 中灰文字
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: ResponsiveHelper.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20),
              color: const Color(0xFF78909C), // 中灰文字
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('简体中文'),
              leading: Radio<String>(
                value: '简体中文',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('跟随系统'),
              leading: Radio<String>(
                value: '跟随系统',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() => _selectedTheme = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('浅色模式'),
              leading: Radio<String>(
                value: '浅色模式',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() => _selectedTheme = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('深色模式'),
              leading: Radio<String>(
                value: '深色模式',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() => _selectedTheme = value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '我们重视您的隐私权。本应用收集的数据仅用于提供更好的服务体验，不会与第三方分享您的个人信息。\n\n'
            '收集的数据包括：\n'
            '• 宠物基本信息\n'
            '• 健康记录\n'
            '• 行为分析数据\n'
            '• 使用偏好设置\n\n'
            '您可以随时删除这些数据或联系我们了解更多信息。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除数据'),
        content: const Text('此操作将删除所有本地数据，包括宠物档案、健康记录和设置。此操作不可撤销，确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE53935), // 红色文字
            ),
            child: const Text('确定删除'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帮助与支持'),
        content: const SingleChildScrollView(
          child: Text(
            '常见问题：\n\n'
            'Q: 如何添加宠物档案？\n'
            'A: 点击"创建宠物档案"按钮，按照提示填写宠物信息。\n\n'
            'Q: 相机无法正常工作？\n'
            'A: 请检查相机权限设置，或使用"相机测试"功能进行诊断。\n\n'
            'Q: 如何备份数据？\n'
            'A: 开启"数据同步"功能，数据将自动备份到云端。\n\n'
            '如需更多帮助，请联系客服：support@felocamera.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    // TODO: 实现清除数据功能
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('数据已清除'),
        backgroundColor: const Color(0xFF66BB6A), // 绿色
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _rateApp() {
    // TODO: 实现应用评价功能
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('感谢您的支持！'),
        backgroundColor: const Color(0xFF42A5F5), // 蓝色
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}