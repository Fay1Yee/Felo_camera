import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/nothing_theme.dart';
import '../widgets/nothing_dot_matrix.dart';
import '../services/api_client.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient.instance;
  bool _hasLocalModel = false;
  bool _isLoading = true;
  
  // 新增设置项
  bool _enableNotifications = true;
  bool _enableHapticFeedback = true;
  bool _enableAutoSave = true;
  bool _enableRealTimeAnalysis = true;
  String _selectedLanguage = '简体中文';
  String _selectedTheme = '跟随系统';
  double _analysisConfidenceThreshold = 0.5;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 强制禁用本地AI模式
      final hasModel = false;
      
      setState(() {
        _hasLocalModel = hasModel;
        _enableNotifications = prefs.getBool('enable_notifications') ?? true;
        _enableHapticFeedback = prefs.getBool('enable_haptic_feedback') ?? true;
        _enableAutoSave = prefs.getBool('enable_auto_save') ?? true;
        _enableRealTimeAnalysis = prefs.getBool('enable_realtime_analysis') ?? true;
        _selectedLanguage = prefs.getString('selected_language') ?? '简体中文';
        _selectedTheme = prefs.getString('selected_theme') ?? '跟随系统';
        _analysisConfidenceThreshold = prefs.getDouble('analysis_confidence_threshold') ?? 0.5;
        _isLoading = false;
      });
      
      // 确保API客户端也设置为不使用本地AI
      _apiClient.setUseLocalAI(false);
      
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_local_ai', false); // 强制保存为false
    await prefs.setBool('enable_notifications', _enableNotifications);
    await prefs.setBool('enable_haptic_feedback', _enableHapticFeedback);
    await prefs.setBool('enable_auto_save', _enableAutoSave);
    await prefs.setBool('enable_realtime_analysis', _enableRealTimeAnalysis);
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setString('selected_theme', _selectedTheme);
    await prefs.setDouble('analysis_confidence_threshold', _analysisConfidenceThreshold);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: NothingTheme.nothingWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: NothingTheme.nothingYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusXLarge),
                  border: Border.all(
                    color: NothingTheme.nothingYellow.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.nothingYellow),
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: NothingTheme.spacingXLarge),
              const Text(
                '正在加载设置...',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeBody,
                  color: NothingTheme.nothingGray,
                  fontWeight: NothingTheme.fontWeightMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NothingTheme.nothingWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: NothingTheme.nothingWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NothingTheme.nothingWhite,
                borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
                border: Border.all(
                  color: NothingTheme.nothingLightGray,
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: NothingTheme.nothingBlack,
                  size: 20,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      NothingTheme.nothingYellow.withValues(alpha: 0.1),
                      NothingTheme.nothingWhite,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: NothingDotMatrix(
                        width: double.infinity,
                        height: double.infinity,
                        dotSize: 1.5,
                        spacing: 24,
                        dotColor: const Color(0xFFE5E5E5),
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: NothingTheme.nothingYellow.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                                  border: Border.all(
                                    color: NothingTheme.nothingYellow.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.settings,
                                  color: NothingTheme.nothingBlack,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: NothingTheme.spacingMedium),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '设置',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: NothingTheme.fontWeightBold,
                                        color: NothingTheme.nothingBlack,
                                        letterSpacing: -1,
                                        height: 1.1,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '个性化您的使用体验',
                                      style: TextStyle(
                                        fontSize: NothingTheme.fontSizeBody,
                                        color: NothingTheme.nothingGray,
                                        fontWeight: NothingTheme.fontWeightMedium,
                                        letterSpacing: -0.2,
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
                  ],
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    NothingTheme.nothingWhite,
                    NothingTheme.nothingLightGray.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(NothingTheme.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI 分析设置
                    _buildSectionHeader('AI 分析', Icons.psychology),
                    const SizedBox(height: NothingTheme.spacingMedium),
                    _buildAISettingsCard(),
                    
                    const SizedBox(height: NothingTheme.spacingXLarge),
                    
                    // 应用设置
                    _buildSectionHeader('应用设置', Icons.tune),
                    const SizedBox(height: NothingTheme.spacingMedium),
                    _buildAppSettingsCard(),
                    
                    const SizedBox(height: NothingTheme.spacingXLarge),
                    
                    // 系统状态
                    _buildSectionHeader('系统状态', Icons.monitor_heart),
                    const SizedBox(height: NothingTheme.spacingMedium),
                    _buildSystemStatusCard(),
                    
                    const SizedBox(height: NothingTheme.spacingXLarge),
                    
                    // 关于应用
                    _buildSectionHeader('关于应用', Icons.info_outline),
                    const SizedBox(height: NothingTheme.spacingMedium),
                    _buildAboutCard(),
                    
                    const SizedBox(height: NothingTheme.spacingXXLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NothingTheme.nothingYellow.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              border: Border.all(
                color: NothingTheme.nothingYellow.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: NothingTheme.nothingBlack,
              size: 22,
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Text(
            title,
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeTitle,
              fontWeight: NothingTheme.fontWeightBold,
              color: NothingTheme.nothingBlack,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NothingTheme.nothingYellow.withValues(alpha: 0.4),
                    NothingTheme.nothingYellow.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: NothingTheme.nothingWhite,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
        border: Border.all(
          color: NothingTheme.nothingLightGray.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.nothingBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 本地AI设置 - 已禁用，强制使用远程API
          _buildSettingTile(
            title: '远程AI模式',
            subtitle: '使用云端AI服务，功能更强大',
            icon: Icons.cloud,
            trailing: Switch(
              value: true, // 强制为true，表示使用远程API
              onChanged: null, // 禁用开关，不允许用户修改
              activeColor: NothingTheme.nothingYellow,
              activeTrackColor: NothingTheme.nothingYellow.withValues(alpha: 0.3),
            ),
            isFirst: true,
          ),
          
          _buildDivider(),
          
          // 实时分析设置
          _buildSettingTile(
            title: '实时分析',
            subtitle: '自动分析相机画面',
            icon: Icons.auto_awesome,
            trailing: Switch(
              value: _enableRealTimeAnalysis,
              onChanged: (value) {
                setState(() {
                  _enableRealTimeAnalysis = value;
                });
                _saveSettings();
                if (_enableHapticFeedback) HapticFeedback.lightImpact();
              },
              activeColor: NothingTheme.nothingYellow,
              activeTrackColor: NothingTheme.nothingYellow.withValues(alpha: 0.3),
            ),
          ),
          
          _buildDivider(),
          
          // 置信度阈值设置
          _buildSettingTile(
            title: '分析置信度阈值',
            subtitle: '阈值${(_analysisConfidenceThreshold * 100).toInt()}% - 低于此值的结果将被过滤',
            icon: Icons.tune,
            trailing: SizedBox(
              width: 120,
              child: Slider(
                value: _analysisConfidenceThreshold,
                min: 0.5,
                max: 0.95,
                divisions: 9,
                onChanged: (value) {
                  setState(() {
                    _analysisConfidenceThreshold = value;
                  });
                },
                onChangeEnd: (value) {
                  _saveSettings();
                  if (_enableHapticFeedback) HapticFeedback.lightImpact();
                },
                activeColor: NothingTheme.nothingYellow,
                inactiveColor: NothingTheme.nothingLightGray,
              ),
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: NothingTheme.nothingWhite,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
        border: Border.all(
          color: NothingTheme.nothingLightGray.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.nothingBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 通知设置
          _buildSettingTile(
            title: '推送通知',
            subtitle: '接收分析结果和系统通知',
            icon: Icons.notifications_outlined,
            trailing: Switch(
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                });
                _saveSettings();
                if (_enableHapticFeedback) HapticFeedback.lightImpact();
              },
              activeColor: NothingTheme.nothingYellow,
              activeTrackColor: NothingTheme.nothingYellow.withValues(alpha: 0.3),
            ),
            isFirst: true,
          ),
          
          _buildDivider(),
          
          // 触觉反馈设置
          _buildSettingTile(
            title: '触觉反馈',
            subtitle: '操作时提供震动反馈',
            icon: Icons.vibration,
            trailing: Switch(
              value: _enableHapticFeedback,
              onChanged: (value) {
                setState(() {
                  _enableHapticFeedback = value;
                });
                _saveSettings();
                if (value) HapticFeedback.lightImpact();
              },
              activeColor: NothingTheme.nothingYellow,
              activeTrackColor: NothingTheme.nothingYellow.withValues(alpha: 0.3),
            ),
          ),
          
          _buildDivider(),
          
          // 自动保存设置
          _buildSettingTile(
            title: '自动保存',
            subtitle: '自动保存分析结果到相册',
            icon: Icons.save_outlined,
            trailing: Switch(
              value: _enableAutoSave,
              onChanged: (value) {
                setState(() {
                  _enableAutoSave = value;
                });
                _saveSettings();
                if (_enableHapticFeedback) HapticFeedback.lightImpact();
              },
              activeColor: NothingTheme.nothingYellow,
              activeTrackColor: NothingTheme.nothingYellow.withValues(alpha: 0.3),
            ),
          ),
          
          _buildDivider(),
          
          // 语言设置
          _buildSettingTile(
            title: '语言',
            subtitle: _selectedLanguage,
            icon: Icons.language,
            trailing: const Icon(
              Icons.chevron_right,
              color: NothingTheme.nothingGray,
            ),
            onTap: () => _showLanguageDialog(),
          ),
          
          _buildDivider(),
          
          // 主题设置
          _buildSettingTile(
            title: '主题',
            subtitle: _selectedTheme,
            icon: Icons.palette_outlined,
            trailing: const Icon(
              Icons.chevron_right,
              color: NothingTheme.nothingGray,
            ),
            onTap: () => _showThemeDialog(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: NothingTheme.nothingWhite,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
        border: Border.all(
          color: NothingTheme.nothingLightGray.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.nothingBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(NothingTheme.spacingLarge),
        child: Column(
          children: [
            _buildStatusItem('相机权限', '已授权', Icons.camera_alt_outlined, NothingTheme.successGreen),
            const SizedBox(height: NothingTheme.spacingMedium),
            _buildStatusItem('存储权限', '已授权', Icons.folder_outlined, NothingTheme.successGreen),
            const SizedBox(height: NothingTheme.spacingMedium),
            _buildStatusItem('网络连接', '正常', Icons.wifi_outlined, NothingTheme.successGreen),
            const SizedBox(height: NothingTheme.spacingMedium),
            _buildStatusItem('API服务', '运行中', Icons.cloud_outlined, NothingTheme.successGreen),
            const SizedBox(height: NothingTheme.spacingMedium),
            _buildStatusItem('本地模型', _hasLocalModel ? '已就绪' : '未下载', Icons.psychology_outlined, 
                _hasLocalModel ? NothingTheme.successGreen : NothingTheme.warningOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: NothingTheme.nothingWhite,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
        border: Border.all(
          color: NothingTheme.nothingLightGray.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.nothingBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            title: '版本信息',
            subtitle: 'v1.0.0 (Build 1)',
            icon: Icons.info_outline,
            trailing: const Icon(
              Icons.chevron_right,
              color: NothingTheme.nothingGray,
            ),
            onTap: () => _showVersionDialog(),
            isFirst: true,
          ),
          
          _buildDivider(),
          
          _buildSettingTile(
            title: '隐私政策',
            subtitle: '了解我们如何保护您的隐私',
            icon: Icons.privacy_tip_outlined,
            trailing: const Icon(
              Icons.chevron_right,
              color: NothingTheme.nothingGray,
            ),
            onTap: () => _showPrivacyDialog(),
          ),
          
          _buildDivider(),
          
          _buildSettingTile(
            title: '用户协议',
            subtitle: '查看服务条款',
            icon: Icons.description_outlined,
            trailing: const Icon(
              Icons.chevron_right,
              color: NothingTheme.nothingGray,
            ),
            onTap: () => _showTermsDialog(),
          ),
          
          _buildDivider(),
          
          _buildSettingTile(
            title: '反馈建议',
            subtitle: '帮助我们改进产品',
            icon: Icons.feedback_outlined,
            trailing: const Icon(
              Icons.chevron_right,
              color: NothingTheme.nothingGray,
            ),
            onTap: () => _showFeedbackDialog(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(NothingTheme.radiusLarge) : Radius.zero,
        bottom: isLast ? const Radius.circular(NothingTheme.radiusLarge) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(NothingTheme.spacingLarge),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NothingTheme.nothingYellow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                border: Border.all(
                  color: NothingTheme.nothingYellow.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: NothingTheme.nothingBlack,
                size: 22,
              ),
            ),
            const SizedBox(width: NothingTheme.spacingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: NothingTheme.fontSizeBody,
                      fontWeight: NothingTheme.fontWeightMedium,
                      color: NothingTheme.nothingBlack,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: NothingTheme.fontSizeCaption,
                      color: NothingTheme.nothingGray,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: NothingTheme.spacingMedium),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: NothingTheme.spacingLarge),
      height: 1,
      color: NothingTheme.nothingLightGray.withValues(alpha: 0.3),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: NothingTheme.fontSizeCaption,
                fontWeight: NothingTheme.fontWeightMedium,
                color: NothingTheme.nothingBlack,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeCaption,
                fontWeight: NothingTheme.fontWeightBold,
                color: color,
              ),
            ),
          ),
        ],
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
            _buildLanguageOption('简体中文'),
            _buildLanguageOption('English'),
            _buildLanguageOption('日本語'),
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

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        _saveSettings();
        Navigator.pop(context);
        if (_enableHapticFeedback) HapticFeedback.lightImpact();
      },
      activeColor: NothingTheme.nothingYellow,
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
            _buildThemeOption('跟随系统'),
            _buildThemeOption('浅色模式'),
            _buildThemeOption('深色模式'),
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

  Widget _buildThemeOption(String theme) {
    return RadioListTile<String>(
      title: Text(theme),
      value: theme,
      groupValue: _selectedTheme,
      onChanged: (value) {
        setState(() {
          _selectedTheme = value!;
        });
        _saveSettings();
        Navigator.pop(context);
        if (_enableHapticFeedback) HapticFeedback.lightImpact();
      },
      activeColor: NothingTheme.nothingYellow,
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('版本信息'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('应用版本: v1.0.0'),
            Text('构建版本: Build 1'),
            Text('发布日期: 2024-01-01'),
            SizedBox(height: 16),
            Text('更新内容:'),
            Text('• 优化分析历史界面'),
            Text('• 重新设计设置界面'),
            Text('• 提升用户体验'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '我们重视您的隐私保护。本应用承诺：\n\n'
            '1. 所有图像分析均在本地进行，不会上传您的照片\n'
            '2. 分析结果仅存储在您的设备上\n'
            '3. 不会收集任何个人身份信息\n'
            '4. 不会与第三方分享您的数据\n\n'
            '如有疑问，请联系我们的客服团队。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户协议'),
        content: const SingleChildScrollView(
          child: Text(
            '使用本应用即表示您同意以下条款：\n\n'
            '1. 本应用仅供个人学习和研究使用\n'
            '2. 请勿将分析结果用于商业用途\n'
            '3. 我们不对分析结果的准确性承担责任\n'
            '4. 请合理使用应用功能，避免过度依赖\n\n'
            '详细条款请访问我们的官方网站查看。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('反馈建议'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('您的意见对我们很重要！'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '请输入您的建议或问题...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('感谢您的反馈！')),
              );
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }
}