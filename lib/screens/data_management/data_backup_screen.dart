import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 备份状态
enum BackupStatus {
  idle('空闲', Icons.cloud_off, NothingTheme.textSecondary),
  syncing('同步中', Icons.cloud_sync, NothingTheme.info),
  success('成功', Icons.cloud_done, NothingTheme.success),
  failed('失败', Icons.cloud_off, NothingTheme.error),
  paused('暂停', Icons.pause_circle, NothingTheme.warning);

  const BackupStatus(this.displayName, this.icon, this.color);
  
  final String displayName;
  final IconData icon;
  final Color color;
}

/// 数据类型
enum DataType {
  all('全部数据', Icons.storage, 0),
  photos('照片视频', Icons.photo_library, 1),
  records('生活记录', Icons.assignment, 2),
  habits('习惯数据', Icons.analytics, 3),
  settings('设置配置', Icons.settings, 4),
  devices('设备数据', Icons.devices, 5);

  const DataType(this.displayName, this.icon, this.priority);
  
  final String displayName;
  final IconData icon;
  final int priority;
}

/// 备份计划
class BackupPlan {
  final String id;
  final String name;
  final List<DataType> dataTypes;
  final bool autoBackup;
  final Duration frequency;
  final bool wifiOnly;
  final bool lowPowerMode;
  final DateTime? lastBackup;
  final DateTime? nextBackup;
  final BackupStatus status;
  final double progress;

  const BackupPlan({
    required this.id,
    required this.name,
    required this.dataTypes,
    required this.autoBackup,
    required this.frequency,
    required this.wifiOnly,
    required this.lowPowerMode,
    this.lastBackup,
    this.nextBackup,
    required this.status,
    this.progress = 0.0,
  });

  BackupPlan copyWith({
    String? id,
    String? name,
    List<DataType>? dataTypes,
    bool? autoBackup,
    Duration? frequency,
    bool? wifiOnly,
    bool? lowPowerMode,
    DateTime? lastBackup,
    DateTime? nextBackup,
    BackupStatus? status,
    double? progress,
  }) {
    return BackupPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      dataTypes: dataTypes ?? this.dataTypes,
      autoBackup: autoBackup ?? this.autoBackup,
      frequency: frequency ?? this.frequency,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      lowPowerMode: lowPowerMode ?? this.lowPowerMode,
      lastBackup: lastBackup ?? this.lastBackup,
      nextBackup: nextBackup ?? this.nextBackup,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}

/// 备份记录
class BackupRecord {
  final String id;
  final String planName;
  final List<DataType> dataTypes;
  final DateTime startTime;
  final DateTime? endTime;
  final BackupStatus status;
  final int totalFiles;
  final int processedFiles;
  final int totalSize; // bytes
  final int processedSize; // bytes
  final String? errorMessage;

  const BackupRecord({
    required this.id,
    required this.planName,
    required this.dataTypes,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.totalFiles,
    required this.processedFiles,
    required this.totalSize,
    required this.processedSize,
    this.errorMessage,
  });

  double get progress => totalFiles > 0 ? processedFiles / totalFiles : 0.0;
  
  Duration? get duration => endTime?.difference(startTime);
  
  String get sizeText => '${_formatBytes(processedSize)}/${_formatBytes(totalSize)}';
  
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// 存储信息
class StorageInfo {
  final int totalSpace; // bytes
  final int usedSpace; // bytes
  final int availableSpace; // bytes
  final Map<DataType, int> dataTypeUsage; // bytes per data type

  const StorageInfo({
    required this.totalSpace,
    required this.usedSpace,
    required this.availableSpace,
    required this.dataTypeUsage,
  });

  double get usagePercentage => totalSpace > 0 ? usedSpace / totalSpace : 0.0;
  
  String get totalSpaceText => _formatBytes(totalSpace);
  String get usedSpaceText => _formatBytes(usedSpace);
  String get availableSpaceText => _formatBytes(availableSpace);
  
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// 数据备份界面
class DataBackupScreen extends StatefulWidget {
  final ScenarioMode currentScenario;
  final String petId;

  const DataBackupScreen({
    super.key,
    required this.currentScenario,
    required this.petId,
  });

  @override
  State<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends State<DataBackupScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  List<BackupPlan> _backupPlans = [];
  List<BackupRecord> _backupRecords = [];
  StorageInfo? _storageInfo;
  int _currentTabIndex = 0;

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

    _loadBackupData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadBackupData() {
    // 模拟备份数据
    final now = DateTime.now();
    setState(() {
      _backupPlans = [
        BackupPlan(
          id: '1',
          name: '完整备份',
          dataTypes: DataType.values,
          autoBackup: true,
          frequency: const Duration(days: 7),
          wifiOnly: true,
          lowPowerMode: false,
          lastBackup: now.subtract(const Duration(days: 2)),
          nextBackup: now.add(const Duration(days: 5)),
          status: BackupStatus.success,
        ),
        BackupPlan(
          id: '2',
          name: '照片备份',
          dataTypes: [DataType.photos],
          autoBackup: true,
          frequency: const Duration(days: 1),
          wifiOnly: true,
          lowPowerMode: true,
          lastBackup: now.subtract(const Duration(hours: 6)),
          nextBackup: now.add(const Duration(hours: 18)),
          status: BackupStatus.syncing,
          progress: 0.65,
        ),
        BackupPlan(
          id: '3',
          name: '数据备份',
          dataTypes: [DataType.records, DataType.habits, DataType.settings],
          autoBackup: false,
          frequency: const Duration(days: 3),
          wifiOnly: false,
          lowPowerMode: true,
          lastBackup: now.subtract(const Duration(days: 5)),
          status: BackupStatus.idle,
        ),
      ];

      _backupRecords = [
        BackupRecord(
          id: '1',
          planName: '完整备份',
          dataTypes: DataType.values,
          startTime: now.subtract(const Duration(days: 2, hours: 1)),
          endTime: now.subtract(const Duration(days: 2)),
          status: BackupStatus.success,
          totalFiles: 1250,
          processedFiles: 1250,
          totalSize: 2147483648, // 2GB
          processedSize: 2147483648,
        ),
        BackupRecord(
          id: '2',
          planName: '照片备份',
          dataTypes: [DataType.photos],
          startTime: now.subtract(const Duration(hours: 6, minutes: 30)),
          status: BackupStatus.syncing,
          totalFiles: 85,
          processedFiles: 55,
          totalSize: 524288000, // 500MB
          processedSize: 340787200, // 325MB
        ),
        BackupRecord(
          id: '3',
          planName: '数据备份',
          dataTypes: [DataType.records, DataType.habits],
          startTime: now.subtract(const Duration(days: 5, hours: 2)),
          endTime: now.subtract(const Duration(days: 5, hours: 1, minutes: 45)),
          status: BackupStatus.success,
          totalFiles: 156,
          processedFiles: 156,
          totalSize: 52428800, // 50MB
          processedSize: 52428800,
        ),
        BackupRecord(
          id: '4',
          planName: '完整备份',
          dataTypes: DataType.values,
          startTime: now.subtract(const Duration(days: 9, hours: 3)),
          endTime: now.subtract(const Duration(days: 9, hours: 2)),
          status: BackupStatus.failed,
          totalFiles: 1180,
          processedFiles: 856,
          totalSize: 1932735283, // 1.8GB
          processedSize: 1398101975, // 1.3GB
          errorMessage: '网络连接中断',
        ),
      ];

      _storageInfo = StorageInfo(
        totalSpace: 10737418240, // 10GB
        usedSpace: 3221225472, // 3GB
        availableSpace: 7516192768, // 7GB
        dataTypeUsage: {
          DataType.photos: 1610612736, // 1.5GB
          DataType.records: 536870912, // 512MB
          DataType.habits: 268435456, // 256MB
          DataType.settings: 52428800, // 50MB
          DataType.devices: 104857600, // 100MB
        },
      );
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
          '数据备份',
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
            icon: const Icon(Icons.add, color: NothingTheme.textPrimary),
            onPressed: _showCreateBackupPlan,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 存储概览
            if (_storageInfo != null) _buildStorageOverview(),
            
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

  Widget _buildStorageOverview() {
    final storage = _storageInfo!;
    
    return Container(
      margin: const EdgeInsets.all(16),
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
                Icons.storage,
                color: NothingTheme.info,
                size: 24,
              ),
              const SizedBox(width: 12),
              
              const Text(
                '存储空间',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const Spacer(),
              
              Text(
                '${storage.usedSpaceText} / ${storage.totalSpaceText}',
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 存储进度条
          LinearProgressIndicator(
            value: storage.usagePercentage,
            backgroundColor: NothingTheme.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(
              storage.usagePercentage > 0.8 
                  ? NothingTheme.error 
                  : storage.usagePercentage > 0.6 
                      ? NothingTheme.warning 
                      : NothingTheme.success,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          
          Text(
            '可用空间: ${storage.availableSpaceText}',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['备份计划', '备份记录', '数据导出'];
    
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
        return _buildBackupPlansView();
      case 1:
        return _buildBackupRecordsView();
      case 2:
        return _buildDataExportView();
      default:
        return _buildBackupPlansView();
    }
  }

  Widget _buildBackupPlansView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '备份计划',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NothingTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Text(
                  '${_backupPlans.where((p) => p.autoBackup).length}个自动备份',
                  style: TextStyle(
                    color: NothingTheme.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ..._backupPlans.map((plan) => _buildBackupPlanCard(plan)),
        ],
      ),
    );
  }

  Widget _buildBackupPlanCard(BackupPlan plan) {
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
                  color: plan.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Icon(
                  plan.status.icon,
                  color: plan.status.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: plan.status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                          ),
                          child: Text(
                            plan.status.displayName,
                            style: TextStyle(
                              color: plan.status.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        if (plan.autoBackup)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: NothingTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                            ),
                            child: Text(
                              '自动',
                              style: TextStyle(
                                color: NothingTheme.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Switch(
                value: plan.autoBackup,
                onChanged: (value) {
                  setState(() {
                    final index = _backupPlans.indexOf(plan);
                    _backupPlans[index] = plan.copyWith(autoBackup: value);
                  });
                },
                activeColor: NothingTheme.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 数据类型
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plan.dataTypes.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NothingTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      color: NothingTheme.info,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: NothingTheme.info,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // 进度条（如果正在同步）
          if (plan.status == BackupStatus.syncing) ...[
            LinearProgressIndicator(
              value: plan.progress,
              backgroundColor: NothingTheme.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(plan.status.color),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              '进度: ${(plan.progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: plan.status.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // 备份信息
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '上次备份',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.lastBackup != null 
                          ? _formatBackupTime(plan.lastBackup!)
                          : '从未备份',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (plan.nextBackup != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '下次备份',
                        style: TextStyle(
                          color: NothingTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatBackupTime(plan.nextBackup!),
                        style: const TextStyle(
                          color: NothingTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              Column(
                children: [
                  if (plan.status == BackupStatus.idle || plan.status == BackupStatus.failed)
                    ElevatedButton(
                      onPressed: () => _startBackup(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NothingTheme.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        '立即备份',
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  else if (plan.status == BackupStatus.syncing)
                    ElevatedButton(
                      onPressed: () => _pauseBackup(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NothingTheme.warning,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        '暂停',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackupRecordsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备份记录',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._backupRecords.map((record) => _buildBackupRecordCard(record)),
        ],
      ),
    );
  }

  Widget _buildBackupRecordCard(BackupRecord record) {
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
              Icon(
                record.status.icon,
                color: record.status.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              
              Expanded(
                child: Text(
                  record.planName,
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: record.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                ),
                child: Text(
                  record.status.displayName,
                  style: TextStyle(
                    color: record.status.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 进度信息
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文件进度',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.processedFiles}/${record.totalFiles}',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '数据大小',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.sizeText,
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '开始时间',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRecordTime(record.startTime),
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 进度条
          LinearProgressIndicator(
            value: record.progress,
            backgroundColor: NothingTheme.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(record.status.color),
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          
          // 错误信息
          if (record.errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NothingTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
              ),
              child: Text(
                record.errorMessage!,
                style: TextStyle(
                  color: NothingTheme.error,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // 持续时间
          if (record.duration != null)
            Text(
              '耗时: ${_formatDuration(record.duration!)}',
              style: TextStyle(
                color: NothingTheme.textTertiary,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataExportView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '数据导出',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // 导出选项
          ...DataType.values.where((type) => type != DataType.all).map((type) {
            return _buildExportOptionCard(type);
          }),
          
          const SizedBox(height: 24),
          
          // 批量导出
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
                Row(
                  children: [
                    Icon(
                      Icons.download,
                      color: NothingTheme.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    
                    const Text(
                      '批量导出',
                      style: TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Text(
                  '导出所有数据到本地文件，包括照片、记录、设置等。',
                  style: TextStyle(
                    color: NothingTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _exportAllData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NothingTheme.info,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('导出全部数据'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showExportOptions,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NothingTheme.info,
                          side: BorderSide(color: NothingTheme.info),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('自定义导出'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptionCard(DataType type) {
    final usage = _storageInfo?.dataTypeUsage[type] ?? 0;
    
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
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: NothingTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
            ),
            child: Icon(
              type.icon,
              color: NothingTheme.info,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '大小: ${StorageInfo._formatBytes(usage)}',
                  style: TextStyle(
                    color: NothingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          OutlinedButton(
            onPressed: () => _exportDataType(type),
            style: OutlinedButton.styleFrom(
              foregroundColor: NothingTheme.info,
              side: BorderSide(color: NothingTheme.info),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text(
              '导出',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateBackupPlan() {
    // 显示创建备份计划对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建备份计划'),
        content: const Text('此功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _startBackup(BackupPlan plan) {
    setState(() {
      final index = _backupPlans.indexOf(plan);
      _backupPlans[index] = plan.copyWith(
        status: BackupStatus.syncing,
        progress: 0.0,
      );
    });
    
    // 模拟备份进度
    _simulateBackupProgress(plan);
  }

  void _pauseBackup(BackupPlan plan) {
    setState(() {
      final index = _backupPlans.indexOf(plan);
      _backupPlans[index] = plan.copyWith(status: BackupStatus.paused);
    });
  }

  void _simulateBackupProgress(BackupPlan plan) {
    // 这里应该实现真实的备份逻辑
    // 现在只是模拟进度更新
  }

  void _exportDataType(DataType type) {
    // 导出特定类型的数据
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在导出${type.displayName}...'),
        backgroundColor: NothingTheme.info,
      ),
    );
  }

  void _exportAllData() {
    // 导出所有数据
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在导出全部数据...'),
        backgroundColor: NothingTheme.info,
      ),
    );
  }

  void _showExportOptions() {
    // 显示自定义导出选项
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义导出'),
        content: const Text('此功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _formatBackupTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${time.month}月${time.day}日';
    }
  }

  String _formatRecordTime(DateTime time) {
    return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes % 60}分钟';
    } else {
      return '${duration.inMinutes}分钟';
    }
  }
}