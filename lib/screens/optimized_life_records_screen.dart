import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../config/nothing_theme.dart';
import '../models/pet_profile.dart';
import '../services/pet_activity_parser.dart';
import '../services/permission_manager.dart';

/// 优化的生活记录界面
class OptimizedLifeRecordsScreen extends StatefulWidget {
  const OptimizedLifeRecordsScreen({super.key});

  @override
  State<OptimizedLifeRecordsScreen> createState() => _OptimizedLifeRecordsScreenState();
}

class _OptimizedLifeRecordsScreenState extends State<OptimizedLifeRecordsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _uploadAnimationController;
  late Animation<double> _uploadScaleAnimation;
  late Animation<double> _uploadOpacityAnimation;
  
  bool _isUploading = false;
  String? _uploadStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _uploadAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _uploadScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _uploadAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _uploadOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _uploadAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _uploadAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      body: CustomScrollView(
        slivers: [
          // 自定义AppBar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: NothingTheme.surface,
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
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '生活记录',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: NothingTheme.textPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      NothingTheme.brandPrimary.withOpacity(0.1),
                      NothingTheme.brandSecondary.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 60,
                      right: 20,
                      child: Icon(
                        Icons.pets,
                        size: 80,
                        color: NothingTheme.brandPrimary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: NothingTheme.textPrimary,
              unselectedLabelColor: NothingTheme.textSecondary,
              indicatorColor: NothingTheme.brandPrimary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: '照片记录'),
                Tab(text: '活动记录'),
                Tab(text: '数据导入'),
              ],
            ),
          ),
          
          // 内容区域
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPhotoRecords(),
                _buildActivityRecords(),
                _buildDataImport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建照片记录页面
  Widget _buildPhotoRecords() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 快速上传区域
          _buildQuickUploadSection(),
          const SizedBox(height: 24),
          
          // 最近照片
          _buildRecentPhotos(),
        ],
      ),
    );
  }

  /// 构建活动记录页面
  Widget _buildActivityRecords() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 活动统计卡片
          _buildActivityStats(),
          const SizedBox(height: 24),
          
          // 最近活动
          _buildRecentActivities(),
        ],
      ),
    );
  }

  /// 构建数据导入页面
  Widget _buildDataImport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 主要上传区域
          _buildMainUploadArea(),
          const SizedBox(height: 32),
          
          // 支持的文件格式说明
          _buildSupportedFormats(),
          const SizedBox(height: 24),
          
          // 导入历史
          _buildImportHistory(),
        ],
      ),
    );
  }

  /// 构建快速上传区域
  Widget _buildQuickUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NothingTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快速上传',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.camera_alt,
                  title: '拍照',
                  subtitle: '立即拍摄',
                  color: NothingTheme.brandPrimary,
                  onTap: () => _takePhoto(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.photo_library,
                  title: '相册',
                  subtitle: '选择照片',
                  color: NothingTheme.brandSecondary,
                  onTap: () => _pickFromGallery(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建主要上传区域
  Widget _buildMainUploadArea() {
    return AnimatedBuilder(
      animation: _uploadAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _uploadScaleAnimation.value,
          child: Opacity(
            opacity: _uploadOpacityAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isUploading 
                    ? NothingTheme.brandPrimary 
                    : NothingTheme.gray200,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: NothingTheme.brandPrimary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 上传图标
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: NothingTheme.brandPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      _isUploading ? Icons.cloud_upload : Icons.upload_file,
                      size: 40,
                      color: NothingTheme.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 主标题
                  Text(
                    _isUploading ? '正在上传...' : '上传宠物活动数据',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: NothingTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // 副标题
                  Text(
                    _uploadStatus ?? '支持 JSON、TXT、CSV、DOCX、DOC 格式文件',
                    style: const TextStyle(
                      fontSize: 16,
                      color: NothingTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // 上传按钮
                  if (!_isUploading) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _selectAndUploadFile,
                        icon: const Icon(Icons.file_upload, size: 24),
                        label: const Text(
                          '选择文件上传',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NothingTheme.brandPrimary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: NothingTheme.brandPrimary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 或者分隔线
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '或者',
                            style: TextStyle(
                              color: NothingTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 拖拽提示
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: NothingTheme.gray100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: NothingTheme.gray300,
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 32,
                            color: NothingTheme.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '拖拽文件到此处上传',
                            style: TextStyle(
                              fontSize: 16,
                              color: NothingTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // 上传进度指示器
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.brandPrimary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建支持的文件格式说明
  Widget _buildSupportedFormats() {
    final formats = [
      {'icon': Icons.description, 'name': 'JSON', 'desc': '结构化数据文件'},
      {'icon': Icons.text_snippet, 'name': 'TXT', 'desc': '纯文本文件'},
      {'icon': Icons.table_chart, 'name': 'CSV', 'desc': '表格数据文件'},
      {'icon': Icons.article, 'name': 'DOCX', 'desc': 'Word文档'},
      {'icon': Icons.description_outlined, 'name': 'DOC', 'desc': '旧版Word文档'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NothingTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '支持的文件格式',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...formats.map((format) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: NothingTheme.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    format['icon'] as IconData,
                    color: NothingTheme.brandPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        format['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: NothingTheme.textPrimary,
                        ),
                      ),
                      Text(
                        format['desc'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: NothingTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: NothingTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建最近照片
  Widget _buildRecentPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近照片',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: NothingTheme.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image,
                color: NothingTheme.textSecondary,
                size: 32,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建活动统计
  Widget _buildActivityStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NothingTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日活动统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('运动时长', '2.5小时', Icons.timer, NothingTheme.success),
              ),
              Expanded(
                child: _buildStatItem('活动次数', '8次', Icons.directions_run, NothingTheme.brandPrimary),
              ),
              Expanded(
                child: _buildStatItem('休息时间', '6小时', Icons.bedtime, NothingTheme.info),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项目
  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: NothingTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 构建最近活动
  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近活动',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NothingTheme.gray200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: NothingTheme.brandPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: NothingTheme.brandPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '散步活动 ${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: NothingTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${DateTime.now().subtract(Duration(hours: index)).hour}:00 - 持续30分钟',
                          style: const TextStyle(
                            fontSize: 14,
                            color: NothingTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建导入历史
  Widget _buildImportHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '导入历史',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NothingTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NothingTheme.gray200),
          ),
          child: const Center(
            child: Text(
              '暂无导入记录',
              style: TextStyle(
                fontSize: 16,
                color: NothingTheme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 选择并上传文件
  Future<void> _selectAndUploadFile() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = '正在选择文件...';
    });

    _uploadAnimationController.forward();

    try {
      // 检查权限
      final permissionManager = PermissionManager();
      bool hasPermission = await permissionManager.hasStoragePermission();

      if (!hasPermission) {
        bool granted = await permissionManager.requestStoragePermissions();
        if (!granted) {
          _showPermissionError();
          return;
        }
      }

      setState(() {
        _uploadStatus = '正在打开文件选择器...';
      });

      // 选择文件
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt', 'csv', 'docx', 'doc'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _uploadStatus = '正在处理文件...';
        });

        int addedCount = 0;

        if (result.files.single.bytes != null) {
          final fileBytes = result.files.single.bytes!;
          final fileName = result.files.single.name;
          final mimeType = result.files.single.extension;

          addedCount = await PetActivityParser.parseAndAddToHistoryFromBytes(
            fileBytes,
            fileName,
            mimeType,
          );
        } else if (result.files.single.path != null) {
          final filePath = result.files.single.path!;
          addedCount = await PetActivityParser.parseAndAddToHistory(filePath);
        }

        _showUploadSuccess(addedCount);
      } else {
        setState(() {
          _uploadStatus = '用户取消了文件选择';
        });
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isUploading = false;
              _uploadStatus = null;
            });
            _uploadAnimationController.reverse();
          }
        });
      }
    } catch (e) {
      _showUploadError(e.toString());
    }
  }

  /// 显示上传成功
  void _showUploadSuccess(int addedCount) {
    setState(() {
      _uploadStatus = '成功导入 $addedCount 条记录！';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '文件上传成功！已导入 $addedCount 条宠物活动记录',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: NothingTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadStatus = null;
        });
        _uploadAnimationController.reverse();
      }
    });
  }

  /// 显示上传错误
  void _showUploadError(String error) {
    setState(() {
      _uploadStatus = '上传失败，请重试';
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '文件上传失败：$error',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: NothingTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    _uploadAnimationController.reverse();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _uploadStatus = null;
        });
      }
    });
  }

  /// 显示权限错误
  void _showPermissionError() {
    setState(() {
      _isUploading = false;
      _uploadStatus = '需要存储权限';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '需要存储权限才能选择文件，请在设置中授予权限',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: NothingTheme.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    _uploadAnimationController.reverse();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _uploadStatus = null;
        });
      }
    });
  }

  /// 拍照
  void _takePhoto() {
    // TODO: 实现拍照功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('拍照功能开发中...')),
    );
  }

  /// 从相册选择
  void _pickFromGallery() {
    // TODO: 实现从相册选择功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('相册选择功能开发中...')),
    );
  }
}