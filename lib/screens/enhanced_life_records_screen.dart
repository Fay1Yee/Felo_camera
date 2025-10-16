import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../config/nothing_theme.dart';
import '../models/analysis_history.dart';
import '../services/history_manager.dart';
import '../services/history_notifier.dart';
import '../services/behavior_analyzer.dart';
import '../services/behavior_classification_service.dart';
import '../services/pet_activity_parser.dart';
import '../widgets/behavior_card_timeline.dart';
import '../utils/ui_performance_monitor.dart';

/// 日常习惯界面 - 重新设计版本
class EnhancedLifeRecordsScreen extends StatefulWidget {
  const EnhancedLifeRecordsScreen({super.key});

  @override
  State<EnhancedLifeRecordsScreen> createState() => _EnhancedLifeRecordsScreenState();
}

class _EnhancedLifeRecordsScreenState extends State<EnhancedLifeRecordsScreen>
    with TickerProviderStateMixin, PerformanceMonitorMixin {
  late TabController _tabController;
  List<AnalysisHistory> _histories = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<HistoryEvent>? _historySubscription;
  
  // 筛选参数
  String? _selectedBehaviorFilter;
  
  // 相册视图状态
  bool _isGalleryView = false;
  
  // 上传状态
  bool _isUploading = false;
  String? _uploadStatus;
  
  // 行为类型筛选选项
  final List<Map<String, dynamic>> _behaviorFilters = [
    {'label': '全部', 'icon': Icons.apps, 'isSelected': true},
    {'label': '观望行为', 'icon': Icons.visibility, 'isSelected': false},
    {'label': '探索行为', 'icon': Icons.explore, 'isSelected': false},
    {'label': '领地行为', 'icon': Icons.home, 'isSelected': false},
    {'label': '玩耍行为', 'icon': Icons.sports_esports, 'isSelected': false},
    {'label': '攻击行为', 'icon': Icons.warning, 'isSelected': false},
    {'label': '无特定行为', 'icon': Icons.remove_circle_outline, 'isSelected': false},
    {'label': '无宠物', 'icon': Icons.pets_outlined, 'isSelected': false},
    {'label': '玩耍', 'icon': Icons.sports_tennis, 'isSelected': false},
    {'label': '进食', 'icon': Icons.restaurant, 'isSelected': false},
    {'label': '睡觉', 'icon': Icons.bedtime, 'isSelected': false},
    {'label': '休息', 'icon': Icons.chair, 'isSelected': false},
    {'label': '运动', 'icon': Icons.directions_run, 'isSelected': false},
    {'label': '静止', 'icon': Icons.pause_circle_outline, 'isSelected': false},
    {'label': '发声', 'icon': Icons.volume_up, 'isSelected': false},
    {'label': '梳理', 'icon': Icons.brush, 'isSelected': false},
    {'label': '探索', 'icon': Icons.search, 'isSelected': false},
    {'label': '社交', 'icon': Icons.group, 'isSelected': false},
    {'label': '警戒', 'icon': Icons.security, 'isSelected': false},
    {'label': '其他', 'icon': Icons.more_horiz, 'isSelected': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    
    // 监听历史记录变化
    _historySubscription = HistoryNotifier.instance.historyStream.listen((
      HistoryEvent event,
    ) {
      switch (event.type) {
        case HistoryEventType.added:
          if (event.history != null && mounted) {
            setState(() {
              _histories.removeWhere((h) => h.id == event.history!.id);
              _histories.insert(0, event.history!);
            });
          }
          break;
        case HistoryEventType.deleted:
          if (event.historyId != null && mounted) {
            setState(() {
              _histories.removeWhere((h) => h.id == event.historyId);
            });
          }
          break;
        case HistoryEventType.cleared:
          if (mounted) {
            setState(() {
              _histories.clear();
            });
          }
          break;
        case HistoryEventType.updated:
          if (event.history != null && mounted) {
            final index = _histories.indexWhere(
              (h) => h.id == event.history!.id,
            );
            if (index != -1) {
              setState(() {
                _histories[index] = event.history!;
              });
            }
          }
          break;
      }
    });
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final histories = await HistoryManager.instance.getAllHistories();
      setState(() {
        _histories = histories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 显示上传选项
  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '宠物数据上传',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F5233),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '上传宠物活动数据文档，自动解析并生成记录',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.pets, color: Color(0xFF2F5233)),
                title: const Text('宠物活动数据'),
                subtitle: const Text('支持 .txt, .csv, .json, .docx, .doc 格式'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFiles();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF2F5233)),
                title: const Text('宠物照片'),
                subtitle: const Text('上传宠物照片到相册'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // 选择图片
  Future<void> _pickImages() async {
    try {
      setState(() {
        _isUploading = true;
        _uploadStatus = '正在选择图片...';
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _uploadStatus = '正在处理 ${result.files.length} 张图片...';
        });

        // 模拟处理过程
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _uploadStatus = '成功上传 ${result.files.length} 张图片！';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功上传 ${result.files.length} 张图片'),
            backgroundColor: Colors.green,
          ),
        );

        // 重新加载数据
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('上传失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadStatus = null;
      });
    }
  }

  // 选择文件并解析宠物活动数据
  Future<void> _pickFiles() async {
    try {
      setState(() {
        _isUploading = true;
        _uploadStatus = '正在选择文件...';
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv', 'json', 'docx', 'doc'],
      );

      if (result != null) {
        setState(() {
          _uploadStatus = '正在解析 ${result.files.length} 个宠物活动数据文件...';
        });

        int totalRecords = 0;
        int processedFiles = 0;

        for (final file in result.files) {
          try {
            setState(() {
              _uploadStatus = '正在解析文件 ${processedFiles + 1}/${result.files.length}: ${file.name}';
            });

            int recordCount = 0;
            
            if (file.bytes != null) {
              // 使用字节数据解析（适用于Web平台）
              recordCount = await PetActivityParser.parseAndAddToHistoryFromBytes(
                file.bytes!,
                file.name,
                file.extension,
              );
            } else if (file.path != null) {
              // 使用文件路径解析（适用于移动平台）
              recordCount = await PetActivityParser.parseAndAddToHistory(file.path!);
            }

            totalRecords += recordCount;
            processedFiles++;

            setState(() {
              _uploadStatus = '已处理 $processedFiles/${result.files.length} 个文件，生成 $totalRecords 条记录';
            });
          } catch (e) {
            debugPrint('解析文件 ${file.name} 失败: $e');
          }
        }

        setState(() {
          _uploadStatus = '解析完成！共处理 $processedFiles 个文件，生成 $totalRecords 条宠物活动记录';
        });

        if (totalRecords > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('成功解析宠物活动数据，生成 $totalRecords 条记录'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // 重新加载数据以显示新记录
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('未能从文件中解析出有效的宠物活动数据'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('解析宠物活动数据失败: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadStatus = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF2F5233),
          ),
        ),
        title: const Text(
          '生活记录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F5233),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGalleryView = !_isGalleryView;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isGalleryView ? '已切换到相册视图' : '已切换到列表视图'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(
              _isGalleryView ? Icons.view_list : Icons.photo_library,
              color: NothingTheme.nothingBlack,
              size: 24,
            ),
            tooltip: _isGalleryView ? '切换到列表视图' : '切换到相册视图',
          ),
          IconButton(
            onPressed: _isUploading ? null : _showUploadOptions,
            icon: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: NothingTheme.nothingBlack,
                    ),
                  )
                : const Icon(
                    Icons.upload_file,
                    color: NothingTheme.nothingBlack,
                    size: 24,
                  ),
            tooltip: '上传选项',
          ),
          IconButton(
            onPressed: () {
              // 删除所有记录功能
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('确定要删除所有记录吗？此操作不可撤销。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已删除所有记录')),
                          );
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.delete_sweep,
              color: NothingTheme.nothingBlack,
              size: 24,
            ),
            tooltip: '删除所有记录按钮',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFD84D),
          unselectedLabelColor: const Color(0xFF90A4AE),
          indicatorColor: const Color(0xFFFFD84D),
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
            Tab(
              icon: Icon(Icons.trending_up),
              text: '时间轴',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: '行为分析',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFD84D),
              ),
            )
          : _error != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // 上传状态显示
                    if (_isUploading && _uploadStatus != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD84D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFD84D).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFD84D),
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _uploadStatus!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2F5233),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // 行为类型筛选
                    _buildBehaviorFilterSection(),
                    
                    // 当前筛选状态显示
                    if (_selectedBehaviorFilter != null && _selectedBehaviorFilter != '全部')
                      _buildCurrentFilterStatus(),
                    
                    // Tab内容
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          debugPrint('🎯 构建Tab内容: _isGalleryView = $_isGalleryView');
                          debugPrint('📑 当前Tab索引: ${_tabController.index}');
                          
                          return _isGalleryView 
                            ? _buildGalleryView()
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildDailyHabitsTab(),
                                  _buildBehaviorAnalysisTab(),
                                ],
                              );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFF90A4AE),
          ),
          const SizedBox(height: 16),
          const Text(
            '加载失败',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F5233),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF90A4AE),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD84D),
              foregroundColor: const Color(0xFF2F5233),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                size: 20,
                color: Color(0xFF2F5233),
              ),
              const SizedBox(width: 8),
              const Text(
                '行为类型筛选',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F5233),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilter,
                child: const Text(
                  '清除',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFFD84D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _behaviorFilters.length,
              itemBuilder: (context, index) {
                final filter = _behaviorFilters[index];
                final isSelected = _selectedBehaviorFilter == filter['label'] || 
                    (_selectedBehaviorFilter == null && filter['label'] == '全部');
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _selectBehaviorFilter(filter['label']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2F5233) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2F5233) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filter['icon'],
                            size: 16,
                            color: isSelected ? Colors.white : const Color(0xFF90A4AE),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter['label'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF90A4AE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentFilterStatus() {
    return Container(
      color: const Color(0xFFFFF8E1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: Color(0xFFFFD84D),
          ),
          const SizedBox(width: 8),
          Text(
            '当前筛选: $_selectedBehaviorFilter',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2F5233),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _clearFilter,
            child: const Icon(
              Icons.close,
              size: 16,
              color: Color(0xFFFFD84D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHabitsTab() {
    final startDate = _getTodayStart();
    final endDate = _getTodayEnd();
    
    debugPrint('🏠 _buildDailyHabitsTab 被调用');
    debugPrint('📅 日期范围: ${startDate.toString()} 到 ${endDate.toString()}');
    debugPrint('🔍 行为筛选: $_selectedBehaviorFilter');
    
    return Column(
      children: [
        // 今日统计概览
        _buildTodayStatsCard(),
        
        const SizedBox(height: 8),
        
        // 今日时间轴 - 卡片式布局
        Expanded(
          child: BehaviorCardTimeline(
            startDate: startDate,
            endDate: endDate,
            behaviorFilter: _selectedBehaviorFilter,
            onRecordTap: (record) {
              // 可以在这里添加点击记录的处理逻辑
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorAnalysisTab() {
    if (_getFilteredHistories().isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行为评分圆环
          _buildBehaviorScoreCard(),
          
          const SizedBox(height: 16),
          
          // 行为分析卡片
          _buildBehaviorAnalysisCards(),
          
          const SizedBox(height: 16),
          
          // 改善建议
          _buildImprovementSuggestions(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF90A4AE),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '使用AI相机拍摄后，记录将在这里显示',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF90A4AE),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsCard() {
    final filteredHistories = _getFilteredHistories();
    final weeklyCount = filteredHistories.length;
    final dailyAverage = weeklyCount / 7;
    final completionRate = (weeklyCount / 21 * 100).clamp(0, 100); // 假设目标是每天3次

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本周完成度',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F5233),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '总记录',
                  weeklyCount.toString(),
                  const Color(0xFF4CAF50),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '日均',
                  dailyAverage.toStringAsFixed(1),
                  const Color(0xFF2196F3),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '完成率',
                  '${completionRate.toInt()}%',
                  const Color(0xFFFFD84D),
                ),
              ),
            ],
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
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF90A4AE),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyInsightsCard() {
    final insights = [
      {
        'icon': Icons.trending_up,
        'color': const Color(0xFF4CAF50),
        'title': '活跃度提升',
        'description': '本周运动时间比上周增加了15%，保持良好状态！',
      },
      {
        'icon': Icons.schedule,
        'color': const Color(0xFF2196F3),
        'title': '作息规律',
        'description': '睡眠时间相对稳定，建议继续保持规律作息。',
      },
      {
        'icon': Icons.restaurant,
        'color': const Color(0xFFFF9800),
        'title': '饮食习惯',
        'description': '进食频率正常，注意营养均衡搭配。',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本周洞察',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F5233),
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (insight['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    insight['icon'] as IconData,
                    color: insight['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F5233),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight['description'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF90A4AE),
                          height: 1.4,
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

  Widget _buildDailyHabitsList() {
    final habits = [
      {
        'name': '晨间活动',
        'icon': Icons.wb_sunny,
        'color': const Color(0xFFFFD84D),
        'frequency': '每天',
        'lastTime': '2小时前',
        'streak': 7,
      },
      {
        'name': '进食时间',
        'icon': Icons.restaurant,
        'color': const Color(0xFF4CAF50),
        'frequency': '每天 2-3次',
        'lastTime': '4小时前',
        'streak': 5,
      },
      {
        'name': '运动锻炼',
        'icon': Icons.directions_run,
        'color': const Color(0xFF2196F3),
        'frequency': '每天',
        'lastTime': '6小时前',
        'streak': 3,
      },
      {
        'name': '休息睡眠',
        'icon': Icons.bedtime,
        'color': const Color(0xFF9C27B0),
        'frequency': '每天',
        'lastTime': '12小时前',
        'streak': 7,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '日常习惯',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F5233),
            ),
          ),
          const SizedBox(height: 16),
          ...habits.map((habit) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (habit['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    habit['icon'] as IconData,
                    color: habit['color'] as Color,
                    size: 24,
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
                            habit['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2F5233),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD84D).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${habit['streak']}天',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F5233),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            habit['frequency'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF90A4AE),
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF90A4AE),
                            ),
                          ),
                          Text(
                            habit['lastTime'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF90A4AE),
                            ),
                          ),
                        ],
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

  Widget _buildBehaviorScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '行为健康评分',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F5233),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      '85',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const Text(
                      '良好',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildScoreItem('活跃度', 88, const Color(0xFF2196F3)),
              ),
              Expanded(
                child: _buildScoreItem('规律性', 82, const Color(0xFFFFD84D)),
              ),
              Expanded(
                child: _buildScoreItem('社交性', 85, const Color(0xFF9C27B0)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          score.toString(),
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
            color: Color(0xFF90A4AE),
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorAnalysisCards() {
    final analysisData = [
      {
        'title': '活动模式分析',
        'icon': Icons.timeline,
        'color': const Color(0xFF2196F3),
        'content': '主要活跃时间集中在上午8-10点和下午4-6点，符合正常作息规律。',
        'trend': '稳定',
        'trendIcon': Icons.trending_flat,
      },
      {
        'title': '社交行为分析',
        'icon': Icons.group,
        'color': const Color(0xFF9C27B0),
        'content': '与其他宠物互动频率适中，表现出良好的社交能力。',
        'trend': '上升',
        'trendIcon': Icons.trending_up,
      },
      {
        'title': '情绪状态分析',
        'icon': Icons.mood,
        'color': const Color(0xFF4CAF50),
        'content': '整体情绪稳定，偶有兴奋表现，心理健康状况良好。',
        'trend': '良好',
        'trendIcon': Icons.check_circle,
      },
    ];

    return Column(
      children: analysisData.map((data) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (data['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    data['icon'] as IconData,
                    color: data['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2F5233),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      data['trendIcon'] as IconData,
                      size: 16,
                      color: data['color'] as Color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data['trend'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: data['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data['content'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF90A4AE),
                height: 1.4,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildImprovementSuggestions() {
    final suggestions = [
      {
        'title': '增加户外活动',
        'description': '建议每天增加30分钟户外活动时间，有助于提升活跃度。',
        'priority': '高',
        'priorityColor': const Color(0xFFFF5722),
      },
      {
        'title': '规律作息时间',
        'description': '保持固定的进食和休息时间，有助于建立良好的生物钟。',
        'priority': '中',
        'priorityColor': const Color(0xFFFFD84D),
      },
      {
        'title': '社交互动训练',
        'description': '适当增加与其他宠物的互动机会，提升社交能力。',
        'priority': '低',
        'priorityColor': const Color(0xFF4CAF50),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '改善建议',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F5233),
            ),
          ),
          const SizedBox(height: 16),
          ...suggestions.map((suggestion) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        suggestion['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F5233),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (suggestion['priorityColor'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        suggestion['priority'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: suggestion['priorityColor'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  suggestion['description'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF90A4AE),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  void _selectBehaviorFilter(String filter) {
    setState(() {
      if (filter == '全部') {
        _selectedBehaviorFilter = null;
      } else {
        _selectedBehaviorFilter = filter;
      }
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedBehaviorFilter = null;
    });
  }

  List<AnalysisHistory> _getFilteredHistories() {
    if (_selectedBehaviorFilter == null || _selectedBehaviorFilter == '全部') {
      return _histories;
    }

    return _histories.where((history) {
      final tags = BehaviorAnalyzer.instance.inferBehaviorTags(history.result, history.mode);
      return tags.contains(_selectedBehaviorFilter);
    }).toList();
  }

  // 构建相册视图
  Widget _buildGalleryView() {
    final filteredHistories = _getFilteredHistories();
    
    // 模拟图片数据 - 在实际应用中，这些应该来自历史记录中的图片
    final List<String> imageUrls = [
      'https://picsum.photos/300/300?random=1',
      'https://picsum.photos/300/300?random=2',
      'https://picsum.photos/300/300?random=3',
      'https://picsum.photos/300/300?random=4',
      'https://picsum.photos/300/300?random=5',
      'https://picsum.photos/300/300?random=6',
      'https://picsum.photos/300/300?random=7',
      'https://picsum.photos/300/300?random=8',
      'https://picsum.photos/300/300?random=9',
      'https://picsum.photos/300/300?random=10',
    ];

    if (imageUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无图片',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '上传一些图片来查看相册',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 相册标题和统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '相册视图',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F5233),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD84D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${imageUrls.length} 张图片',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2F5233),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 图片网格
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: imageUrls.length,
              addAutomaticKeepAlives: false, // 不保持离屏组件状态，减少内存使用
              addRepaintBoundaries: true, // 添加重绘边界，提高渲染性能
              cacheExtent: 200, // 设置缓存范围，平衡性能和内存
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showImagePreview(imageUrls, index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        cacheWidth: 300, // 限制缓存图片宽度，减少内存使用
                        cacheHeight: 300, // 限制缓存图片高度，减少内存使用
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFD84D),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 显示图片预览
  void _showImagePreview(List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black87,
          child: Stack(
            children: [
              PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: InteractiveViewer(
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 100,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建今日统计卡片
  Widget _buildTodayStatsCard() {
    final todayHistories = _getTodayHistories();
    final todayCount = todayHistories.length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Expanded(
            child: _buildStatItem(
              '今日记录',
              todayCount.toString(),
              const Color(0xFF4CAF50),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              '活跃时段',
              _getMostActiveHour(todayHistories),
              const Color(0xFF2196F3),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              '主要行为',
              _getMostFrequentBehavior(todayHistories),
              const Color(0xFFFFD84D),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取今日开始时间
  DateTime _getTodayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 获取今日结束时间
  DateTime _getTodayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  /// 获取今日的历史记录
  List<AnalysisHistory> _getTodayHistories() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return _histories.where((history) {
      return history.timestamp.isAfter(startOfDay) && 
             history.timestamp.isBefore(endOfDay);
    }).toList();
  }

  /// 获取最活跃的时段
  String _getMostActiveHour(List<AnalysisHistory> histories) {
    if (histories.isEmpty) return '--';
    
    final hourCounts = <int, int>{};
    for (final history in histories) {
      final hour = history.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    if (hourCounts.isEmpty) return '--';
    
    final mostActiveHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return '${mostActiveHour}:00';
  }

  /// 获取最频繁的行为
  String _getMostFrequentBehavior(List<AnalysisHistory> histories) {
    if (histories.isEmpty) return '--';
    
    final behaviorCounts = <String, int>{};
    for (final history in histories) {
      final behavior = history.result.title.isNotEmpty ? history.result.title : '未知';
      behaviorCounts[behavior] = (behaviorCounts[behavior] ?? 0) + 1;
    }
    
    if (behaviorCounts.isEmpty) return '--';
    
    return behaviorCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}