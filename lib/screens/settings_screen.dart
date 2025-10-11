import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pet_profile.dart';
import 'system_config/notification_settings_screen.dart';
import 'system_config/profile_creation_screen.dart';
import 'system_config/profile_filling_screen.dart';
import 'system_config/camera_test_screen.dart';

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
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), // 纯白色
        elevation: 0,
        title: Text(
          '设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF37474F), // 深灰文字
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color(0xFF37474F), // 深灰文字
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFECEFF1), // 浅灰分隔
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD84D), // 亮黄色
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.person,
              size: 32,
              color: const Color(0xFF37474F), // 深灰文字
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '宠物主人',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF37474F), // 深灰文字
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '管理您的宠物生活',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF78909C), // 中灰文字
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF37474F), // 深灰文字
              ),
            ),
          ),
          ...children.map((child) => child).toList(),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF42A5F5), // 蓝色
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF37474F), // 深灰文字
                  ),
                ),
                const SizedBox(height: 2),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFFD84D), // 亮黄色
            activeTrackColor: const Color(0xFFFFD84D).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFFECEFF1), // 浅灰
            inactiveTrackColor: const Color(0xFFECEFF1).withOpacity(0.5),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF42A5F5), // 蓝色
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF37474F), // 深灰文字
                    ),
                  ),
                  const SizedBox(height: 2),
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
            Icon(
              Icons.chevron_right,
              size: 16,
              color: const Color(0xFF78909C), // 中灰文字
            ),
          ],
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? const Color(0xFFEF5350) : const Color(0xFF42A5F5), // 红色/蓝色
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? const Color(0xFFEF5350) : const Color(0xFF37474F), // 红色/深灰
                    ),
                  ),
                  const SizedBox(height: 2),
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
            Icon(
              Icons.chevron_right,
              size: 16,
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
        backgroundColor: const Color(0xFFFFFFFF), // 白色背景
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '选择语言',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF37474F), // 深灰文字
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('简体中文'),
            _buildLanguageOption('繁體中文'),
            _buildLanguageOption('English'),
            _buildLanguageOption('日本語'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: const Color(0xFF78909C), // 中灰文字
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    
    return ListTile(
      title: Text(
        language,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? const Color(0xFF42A5F5) : const Color(0xFF37474F), // 蓝色/深灰
        ),
      ),
      trailing: isSelected ? Icon(
        Icons.check,
        size: 16,
        color: const Color(0xFF42A5F5), // 蓝色
      ) : null,
      onTap: () {
        setState(() => _selectedLanguage = language);
        Navigator.pop(context);
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF), // 白色背景
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '选择主题',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF37474F), // 深灰文字
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('跟随系统', Icons.brightness_auto),
            _buildThemeOption('浅色模式', Icons.brightness_high),
            _buildThemeOption('深色模式', Icons.brightness_low),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: const Color(0xFF78909C), // 中灰文字
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String theme, IconData icon) {
    final isSelected = _selectedTheme == theme;
    
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? const Color(0xFF42A5F5) : const Color(0xFF78909C), // 蓝色/中灰
      ),
      title: Text(
        theme,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? const Color(0xFF42A5F5) : const Color(0xFF37474F), // 蓝色/深灰
        ),
      ),
      trailing: isSelected ? Icon(
        Icons.check,
        size: 16,
        color: const Color(0xFF42A5F5), // 蓝色
      ) : null,
      onTap: () {
        setState(() => _selectedTheme = theme);
        Navigator.pop(context);
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF), // 白色背景
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '隐私政策',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF37474F), // 深灰文字
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            '我们重视您的隐私保护。本应用收集的数据仅用于提供更好的宠物护理服务，不会与第三方分享您的个人信息。\n\n收集的信息包括：\n• 宠物照片和视频\n• 健康记录数据\n• 使用偏好设置\n\n我们承诺：\n• 数据加密存储\n• 不会出售个人信息\n• 您可随时删除数据',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF37474F), // 深灰文字
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '我知道了',
              style: TextStyle(
                color: const Color(0xFF42A5F5), // 蓝色
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF), // 白色背景
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '清除数据',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFEF5350), // 红色
          ),
        ),
        content: Text(
          '此操作将删除所有本地数据，包括宠物照片、健康记录等。此操作不可恢复，确定要继续吗？',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF37474F), // 深灰文字
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: const Color(0xFF78909C), // 中灰文字
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            child: Text(
              '确定删除',
              style: TextStyle(
                color: const Color(0xFFEF5350), // 红色
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF), // 白色背景
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '帮助与支持',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF37474F), // 深灰文字
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('📖', '使用指南', '了解应用基本功能'),
            _buildHelpItem('❓', '常见问题', '查看常见问题解答'),
            _buildHelpItem('💬', '在线客服', '联系客服获取帮助'),
            _buildHelpItem('📧', '意见反馈', '提交使用建议'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '关闭',
              style: TextStyle(
                color: const Color(0xFF78909C), // 中灰文字
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String emoji, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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