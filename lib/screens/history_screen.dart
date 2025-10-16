import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../models/analysis_history.dart';
import '../services/history_manager.dart';
import '../services/history_notifier.dart';
import '../services/pet_activity_parser.dart';
import '../services/permission_manager.dart';
import '../config/nothing_theme.dart';
import '../config/device_config.dart';
import '../utils/responsive_helper.dart';
import '../widgets/nothing_timeline.dart';
import '../widgets/nothing_photo_album.dart';
import '../widgets/nothing_statistics.dart';
import '../widgets/behavior_analytics_widget.dart';


// 已移除宠物语气助手，统一采用简洁、专业且亲和的文本风格

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AnalysisHistory> _histories = [];
  bool _isLoading = true;
  StreamSubscription<HistoryEvent>? _historySubscription;
  String _currentFilter = 'all'; // 当前过滤器状态

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistories();
    _setupHistoryListener();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _historySubscription?.cancel();
    super.dispose();
  }

  /// 设置历史记录变化监听器
  void _setupHistoryListener() {
    _historySubscription = HistoryNotifier.instance.historyStream.listen((
      event,
    ) {
      if (mounted) {
        switch (event.type) {
          case HistoryEventType.added:
            if (event.history != null) {
              setState(() {
                // 确保新记录在最前面
                _histories.removeWhere((h) => h.id == event.history!.id);
                _histories.insert(0, event.history!);
              });
            }
            break;
          case HistoryEventType.deleted:
            if (event.historyId != null) {
              setState(() {
                _histories.removeWhere((h) => h.id == event.historyId);
              });
            }
            break;
          case HistoryEventType.cleared:
            setState(() {
              _histories.clear();
            });
            break;
          case HistoryEventType.updated:
            if (event.history != null) {
              setState(() {
                final index = _histories.indexWhere(
                  (h) => h.id == event.history!.id,
                );
                if (index != -1) {
                  _histories[index] = event.history!;
                }
              });
            }
            break;
        }
      }
    });
  }

  Future<void> _loadHistories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final histories = await HistoryManager.instance.getAllHistories();
      setState(() {
        _histories = histories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: NothingTheme.nothingWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '加载历史记录失败: $e',
                    style: TextStyle(
                      color: NothingTheme.nothingWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: NothingTheme.nothingDarkGray,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  List<AnalysisHistory> _getFilteredHistories(String filter) {
    switch (filter) {
      case 'realtime':
        return _histories.where((h) => h.isRealtimeAnalysis).toList();
      case 'manual':
        return _histories.where((h) => !h.isRealtimeAnalysis).toList();
      default:
        return _histories;
    }
  }

  void _showHistoryDetail(AnalysisHistory history) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: DeviceConfig.isTablet(context) ? 600 : double.infinity,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: NothingTheme.surface,
            borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
            border: Border.all(color: NothingTheme.gray200, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 增强的标题栏
              Container(
                padding: const EdgeInsets.all(NothingTheme.spacingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      NothingTheme.nothingYellow,
                      NothingTheme.nothingYellow.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(NothingTheme.radiusLarge),
                    topRight: Radius.circular(NothingTheme.radiusLarge),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _deleteHistory(history);
                        },
                        icon: Icon(Icons.delete_outline),
                        label: Text('删除记录'),
                      ),
                    ),
                    const SizedBox(width: NothingTheme.spacingMedium),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.check),
                        label: Text('确定'),
                      ),
                    ),
                  ],
                ),
              ),

              // 内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(NothingTheme.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 改进的图像显示区域
                      if (history.imagePath != null) ...[
                        Container(
                          width: double.infinity,
                          height: 250,
                          margin: const EdgeInsets.only(
                            bottom: NothingTheme.spacingLarge,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              NothingTheme.radiusMedium,
                            ),
                            border: Border.all(
                              color: NothingTheme.nothingLightGray,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              NothingTheme.radiusMedium,
                            ),
                            child: history.imagePath != null
                                ? Image.file(
                                    File(history.imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: NothingTheme.nothingLightGray,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              size: 48,
                                              color: NothingTheme.nothingGray,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '图像无法显示',
                                              style: TextStyle(
                                                fontSize:
                                                    NothingTheme.fontSizeBody,
                                                color: NothingTheme.nothingGray,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              history.isRealtimeAnalysis
                                                  ? '实时分析图像'
                                                  : '手动拍摄图像',
                                              style: TextStyle(
                                                fontSize: NothingTheme
                                                    .fontSizeCaption,
                                                color: NothingTheme.nothingGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: NothingTheme.nothingLightGray,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 48,
                                          color: NothingTheme.nothingGray,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '暂无图像',
                                          style: TextStyle(
                                            fontSize: NothingTheme.fontSizeBody,
                                            color: NothingTheme.nothingGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ] else ...[
                        // 无图像时的占位符
                        Container(
                          width: double.infinity,
                          height: 150,
                          margin: const EdgeInsets.only(
                            bottom: NothingTheme.spacingLarge,
                          ),
                          decoration: BoxDecoration(
                            color: NothingTheme.nothingLightGray.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(
                              NothingTheme.radiusMedium,
                            ),
                            border: Border.all(
                              color: NothingTheme.nothingLightGray,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                history.isRealtimeAnalysis
                                    ? Icons.auto_awesome
                                    : Icons.camera_alt,
                                size: 48,
                                color: NothingTheme.nothingGray,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                history.isRealtimeAnalysis
                                    ? '实时分析记录'
                                    : '手动分析记录',
                                style: TextStyle(
                                  fontSize: NothingTheme.fontSizeBody,
                                  color: NothingTheme.nothingGray,
                                  fontWeight: NothingTheme.fontWeightMedium,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '未保存图像文件',
                                style: TextStyle(
                                  fontSize: NothingTheme.fontSizeCaption,
                                  color: NothingTheme.nothingGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 分析结果描述
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          NothingTheme.spacingMedium,
                        ),
                        margin: const EdgeInsets.only(
                          bottom: NothingTheme.spacingMedium,
                        ),
                        decoration: BoxDecoration(
                          color: NothingTheme.nothingLightGray.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(
                            NothingTheme.radiusMedium,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '分析结果',
                              style: TextStyle(
                                fontSize: NothingTheme.fontSizeSubheading,
                                fontWeight: NothingTheme.fontWeightBold,
                                color: NothingTheme.nothingBlack,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              history.result.title,
                              style: TextStyle(
                                fontSize: NothingTheme.fontSizeBody,
                                color: NothingTheme.nothingBlack,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 详细信息卡片
                      _buildEnhancedDetailCard([
                        _buildDetailRow('分析模式', _getModeName(history.mode)),
                        _buildDetailRow(
                          '分析类型',
                          history.isRealtimeAnalysis ? '实时分析' : '手动拍照',
                        ),
                        _buildDetailRow(
                          '置信度',
                          '${history.result.confidence}%',
                        ), // 清晰专业表达
                        _buildDetailRow(
                          '拍摄时间',
                          DateFormat(
                            'yyyy年MM月dd日 HH:mm:ss',
                          ).format(history.timestamp),
                        ),
                      ]),

                      // 附加信息
                      if (history.result.subInfo != null) ...[
                        const SizedBox(height: NothingTheme.spacingMedium),
                        if (history.mode == 'travel') ...[
                          _buildEnhancedDetailCard([
                            _buildTravelSummary(history.result.subInfo!),
                          ], title: '出行分析'),
                        ] else ...[
                          _buildEnhancedDetailCard([
                            _buildDetailRow(
                              '附加信息',
                              history.result.subInfo ?? '暂无详细信息',
                            ), // 使用原始风格的附加信息
                          ], title: '详细信息'),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              // 底部操作栏
              Container(
                padding: const EdgeInsets.all(NothingTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: NothingTheme.nothingWhite,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(NothingTheme.radiusLarge),
                    bottomRight: Radius.circular(NothingTheme.radiusLarge),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: NothingTheme.nothingLightGray,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _deleteHistory(history);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('删除记录'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NothingTheme.nothingDarkGray,
                          foregroundColor: NothingTheme.nothingWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              NothingTheme.radiusMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: NothingTheme.spacingMedium),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check),
                        label: const Text('确定'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NothingTheme.nothingYellow,
                          foregroundColor: NothingTheme.nothingBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              NothingTheme.radiusMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 新增：构建增强的详细信息卡片
  Widget _buildEnhancedDetailCard(List<Widget> children, {String? title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      decoration: BoxDecoration(
        color: NothingTheme.nothingWhite,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
        border: Border.all(color: NothingTheme.nothingLightGray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeSubheading,
                fontWeight: NothingTheme.fontWeightBold,
                color: NothingTheme.nothingBlack,
              ),
            ),
            const SizedBox(height: NothingTheme.spacingSmall),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NothingTheme.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                color: NothingTheme.nothingGray,
              ),
            ),
          ),
          const SizedBox(width: NothingTheme.spacingMedium),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                fontWeight: NothingTheme.fontWeightMedium,
                color: NothingTheme.nothingBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHistory(AnalysisHistory history) async {
    await HistoryManager.instance.deleteHistory(history.id);
    // 不需要手动调用 _loadHistories()，因为监听器会自动更新界面
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('历史记录已删除')));
    }
  }

  // 分享历史记录
  Future<void> _shareHistory(AnalysisHistory history) async {
    try {
      final timestamp = DateFormat('yyyy年MM月dd日 HH:mm:ss').format(history.timestamp);
      final analysisType = history.isRealtimeAnalysis ? '实时分析' : '手动分析';
      final confidence = history.result.confidence;
      
      String shareText = '''
📊 AI分析记录

🕒 时间: $timestamp
🔍 类型: $analysisType
📈 置信度: $confidence%

📝 分析结果:
${history.result.title}
''';

      if (history.result.subInfo != null && history.result.subInfo!.isNotEmpty) {
        shareText += '\n💡 详细信息:\n${history.result.subInfo}';
      }

      shareText += '\n\n📱 来自 Felo Camera AI助手';

      // 显示分享选项对话框
      _showShareOptions(shareText, history);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: NothingTheme.nothingWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '分享失败: $e',
                    style: TextStyle(
                      color: NothingTheme.nothingWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: NothingTheme.nothingDarkGray,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  // 显示分享选项
  void _showShareOptions(String shareText, AnalysisHistory history) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: NothingTheme.nothingWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: NothingTheme.nothingLightGray,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.share,
                    color: NothingTheme.nothingBlack,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '分享记录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: NothingTheme.nothingBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: NothingTheme.nothingBlack,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // 分享选项
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildShareOption(
                    icon: Icons.content_copy,
                    title: '复制文本',
                    subtitle: '复制分析结果到剪贴板',
                    onTap: () {
                      Navigator.of(context).pop();
                      _copyToClipboard(shareText);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShareOption(
                    icon: Icons.download,
                    title: '导出为文件',
                    subtitle: '保存为文本文件到本地',
                    onTap: () {
                      Navigator.of(context).pop();
                      _exportToFile(shareText, history);
                    },
                  ),
                  if (history.imagePath != null && history.imagePath!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildShareOption(
                      icon: Icons.image,
                      title: '分享图片和文本',
                      subtitle: '同时分享图片和分析结果',
                      onTap: () {
                        Navigator.of(context).pop();
                        _shareImageWithText(shareText, history);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAllHistories() async {
    try {
      await HistoryManager.instance.clearAllHistories();
      // 不需要手动更新状态，监听器会自动处理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('所有历史记录已删除'),
            backgroundColor: NothingTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: NothingTheme.nothingWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '删除失败: $e',
                    style: TextStyle(
                      color: NothingTheme.nothingWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: NothingTheme.nothingDarkGray,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NothingTheme.nothingWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
        ),
        title: const Text(
          '删除所有记录',
          style: TextStyle(
            fontSize: NothingTheme.fontSizeHeadline,
            fontWeight: NothingTheme.fontWeightBold,
            color: NothingTheme.nothingBlack,
          ),
        ),
        content: const Text(
          '确定要删除所有历史记录吗？此操作无法撤销。',
          style: TextStyle(
            fontSize: NothingTheme.fontSizeBody,
            color: NothingTheme.nothingGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                color: NothingTheme.nothingGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteAllHistories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NothingTheme.nothingDarkGray,
              foregroundColor: NothingTheme.nothingWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              ),
            ),
            child: const Text(
              '删除',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                fontWeight: NothingTheme.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getModeName(String mode) {
    switch (mode) {
      case 'normal':
        return '日常模式';
      case 'pet':
        return '宠物模式';
      case 'health':
        return '健康模式';
      case 'travel':
        return '旅行模式';
      default:
        return '未知模式';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.nothingWhite,
      appBar: AppBar(
        backgroundColor: NothingTheme.nothingWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
              decoration: BoxDecoration(
                color: NothingTheme.nothingYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                border: Border.all(
                  color: NothingTheme.nothingYellow.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.history,
                color: NothingTheme.nothingBlack,
                size: ResponsiveHelper.getResponsiveSpacing(context, mobile: 20, tablet: 22, desktop: 24),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobile: NothingTheme.spacingMedium, tablet: 18, desktop: 20)),
            Text(
              '历史记录',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: NothingTheme.fontSizeHeadline, tablet: 20, desktop: 22),
                fontWeight: NothingTheme.fontWeightBold,
                color: NothingTheme.nothingBlack,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // 相册视图切换按钮
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: NothingTheme.nothingWhite,
                    appBar: AppBar(
                      backgroundColor: NothingTheme.nothingWhite,
                      elevation: 0,
                      surfaceTintColor: Colors.transparent,
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: NothingTheme.successGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                NothingTheme.radiusSm,
                              ),
                              border: Border.all(
                                color: NothingTheme.successGreen.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.photo_library,
                              color: NothingTheme.nothingBlack,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: NothingTheme.spacingMedium),
                          const Text(
                            '相册',
                            style: TextStyle(
                              fontSize: NothingTheme.fontSizeHeadline,
                              fontWeight: NothingTheme.fontWeightBold,
                              color: NothingTheme.nothingBlack,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: NothingPhotoAlbum(
                      histories: _histories,
                      onPhotoTap: _showHistoryDetail,
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.photo_library,
              color: NothingTheme.nothingBlack,
              size: 24,
            ),
            tooltip: '相册视图',
          ),
          // 上传选项按钮
          IconButton(
            onPressed: () => _showUploadOptions(),
            icon: const Icon(
              Icons.upload_file,
              color: NothingTheme.nothingBlack,
              size: 24,
            ),
            tooltip: '上传选项',
          ),
          // 删除所有记录按钮
          IconButton(
            onPressed: _histories.isEmpty
                ? null
                : () => _showDeleteAllDialog(),
            icon: Icon(
              Icons.delete_sweep,
              color: _histories.isEmpty
                  ? NothingTheme.nothingGray
                  : NothingTheme.nothingBlack,
              size: 24,
            ),
            tooltip: '删除所有记录',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(ResponsiveHelper.getResponsiveSpacing(context, mobile: 60, tablet: 70, desktop: 80)),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
              vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12),
            ),
            decoration: BoxDecoration(
              color: NothingTheme.nothingLightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              border: Border.all(
                color: NothingTheme.nothingLightGray,
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: NothingTheme.nothingBlack,
              unselectedLabelColor: NothingTheme.nothingGray,
              indicator: BoxDecoration(
                color: NothingTheme.nothingYellow,
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: NothingTheme.fontSizeBody, tablet: NothingTheme.fontSizeBody + 1, desktop: NothingTheme.fontSizeBody + 2),
                fontWeight: NothingTheme.fontWeightMedium,
                letterSpacing: -0.2,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: NothingTheme.fontSizeBody, tablet: NothingTheme.fontSizeBody + 1, desktop: NothingTheme.fontSizeBody + 2),
                fontWeight: NothingTheme.fontWeightRegular,
                letterSpacing: -0.2,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timeline, size: ResponsiveHelper.getResponsiveSpacing(context, mobile: 14, tablet: 16, desktop: 18)),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 2, tablet: 3, desktop: 4)),
                      const Flexible(
                        child: Text('时间线', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics, size: ResponsiveHelper.getResponsiveSpacing(context, mobile: 14, tablet: 16, desktop: 18)),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 2, tablet: 3, desktop: 4)),
                      const Flexible(
                        child: Text('统计', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pets, size: ResponsiveHelper.getResponsiveSpacing(context, mobile: 14, tablet: 16, desktop: 18)),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 2, tablet: 3, desktop: 4)),
                      const Flexible(
                        child: Text('行为', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: NothingTheme.nothingYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        NothingTheme.radiusLarge,
                      ),
                      border: Border.all(
                        color: NothingTheme.nothingYellow.withValues(
                          alpha: 0.3,
                        ),
                        width: 2,
                      ),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        NothingTheme.nothingYellow,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: NothingTheme.spacingLarge),
                  const Text(
                    '正在加载历史记录...',
                    style: TextStyle(
                      fontSize: NothingTheme.fontSizeBody,
                      color: NothingTheme.nothingGray,
                      fontWeight: NothingTheme.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    NothingTheme.nothingWhite,
                    NothingTheme.nothingLightGray.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTimelineView(),
                  _buildStatisticsView(),
                  _buildBehaviorAnalysisView(),
                ],
              ),
            ),
    );
  }

  Widget _buildTravelSummary(String subInfoText) {
    final data = _parseTravelSubInfo(subInfoText);
    if (data == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: NothingTheme.spacingSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                '出行分析',
                style: const TextStyle(
                  fontSize: NothingTheme.fontSizeBody,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: NothingTheme.spacingMedium),
            const Expanded(
              child: Text(
                '暂无结构化出行信息',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeBody,
                  fontWeight: NothingTheme.fontWeightMedium,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final scene = data['scene_analysis'] as Map<String, dynamic>? ?? {};
    final rec = data['recommendations'] as Map<String, dynamic>? ?? {};

    final sceneType = scene['type']?.toString() ?? '未知场景';
    final location = scene['location']?.toString() ?? '未知位置';
    final weather = scene['weather']?.toString() ?? '未知天气';
    final safety = scene['safety_level']?.toString().toUpperCase() ?? 'MEDIUM';

    final activities =
        (rec['activities'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    final safetyTips =
        (rec['safety_tips'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    final travelAdvice =
        (rec['travel_advice'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];

    Color badgeColor;
    String badgeText;
    switch (safety) {
      case 'LOW':
        badgeColor = NothingTheme.successGreen;
        badgeText = '安全风险低';
        break;
      case 'HIGH':
        badgeColor = NothingTheme.error;
        badgeText = '安全风险高';
        break;
      default:
        badgeColor = NothingTheme.warningOrange;
        badgeText = '安全风险中';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 安全徽章与场景基本信息
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NothingTheme.spacingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: badgeColor),
                  const SizedBox(width: NothingTheme.spacingXSmall),
                  Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: NothingTheme.fontSizeCaption,
                      fontWeight: NothingTheme.fontWeightMedium,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              weather,
              style: const TextStyle(
                fontSize: NothingTheme.fontSizeCaption,
                color: NothingTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: NothingTheme.spacingSmall),
        Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: 16,
              color: NothingTheme.textSecondary,
            ),
            const SizedBox(width: NothingTheme.spacingXSmall),
            Expanded(
              child: Text(
                '$sceneType · $location',
                style: const TextStyle(
                  fontSize: NothingTheme.fontSizeBody,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),

        // 推荐活动
        if (activities.isNotEmpty) ...[
          const SizedBox(height: NothingTheme.spacingSmall),
          _sectionTitle('推荐活动', Icons.directions_walk_outlined),
          const SizedBox(height: NothingTheme.spacingXSmall),
          Wrap(
            spacing: NothingTheme.spacingXSmall,
            runSpacing: NothingTheme.spacingXSmall,
            children: activities.map((a) => _chip(a)).toList(),
          ),
        ],

        // 安全提示
        if (safetyTips.isNotEmpty) ...[
          const SizedBox(height: NothingTheme.spacingSmall),
          _sectionTitle('安全提示', Icons.shield_outlined),
          const SizedBox(height: NothingTheme.spacingXSmall),
          Wrap(
            spacing: NothingTheme.spacingXSmall,
            runSpacing: NothingTheme.spacingXSmall,
            children: safetyTips.map((s) => _chip(s)).toList(),
          ),
        ],

        // 旅行建议
        if (travelAdvice.isNotEmpty) ...[
          const SizedBox(height: NothingTheme.spacingSmall),
          _sectionTitle('旅行建议', Icons.map_outlined),
          const SizedBox(height: NothingTheme.spacingXSmall),
          Wrap(
            spacing: NothingTheme.spacingXSmall,
            runSpacing: NothingTheme.spacingXSmall,
            children: travelAdvice.map((t) => _chip(t)).toList(),
          ),
        ],

        if (activities.isEmpty &&
            safetyTips.isEmpty &&
            travelAdvice.isEmpty) ...[
          const SizedBox(height: NothingTheme.spacingSmall),
          _emptyHint('暂无详细建议'),
        ],
      ],
    );
  }

  Map<String, dynamic>? _parseTravelSubInfo(String text) {
    dynamic parsed;
    try {
      parsed = jsonDecode(text);
    } catch (_) {
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (match != null) {
        try {
          parsed = jsonDecode(match.group(0)!);
        } catch (_) {
          return null;
        }
      } else {
        return null;
      }
    }

    if (parsed is Map<String, dynamic>) {
      if (parsed.containsKey('scene_analysis') &&
          parsed.containsKey('recommendations')) {
        return parsed;
      }
      final sub = parsed['subInfo'];
      if (sub is String) {
        try {
          final inner = jsonDecode(sub);
          if (inner is Map<String, dynamic>) return inner;
        } catch (_) {
          final match = RegExp(r'\{[\s\S]*\}').firstMatch(sub);
          if (match != null) {
            try {
              final inner = jsonDecode(match.group(0)!);
              if (inner is Map<String, dynamic>) return inner;
            } catch (_) {}
          }
        }
      }
    }
    return null;
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: NothingTheme.textSecondary),
        const SizedBox(width: NothingTheme.spacingXSmall),
        Text(
          title,
          style: const TextStyle(
            fontSize: NothingTheme.fontSizeCaption,
            fontWeight: NothingTheme.fontWeightMedium,
            color: NothingTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NothingTheme.spacingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: NothingTheme.nothingLightGray.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: NothingTheme.fontSizeCaption,
          color: NothingTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _emptyHint(String text) => Text(
    text,
    style: TextStyle(
      color: NothingTheme.nothingDarkGray,
      fontSize: NothingTheme.fontSizeCaption,
    ),
  );

  /// 显示上传选项对话框
  void _showUploadOptions() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: NothingTheme.nothingWhite,
            borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: NothingTheme.nothingBlack.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(NothingTheme.spacingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      NothingTheme.nothingYellow,
                      NothingTheme.nothingYellow.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(NothingTheme.radiusLarge),
                    topRight: Radius.circular(NothingTheme.radiusLarge),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.upload_file,
                      color: NothingTheme.nothingBlack,
                      size: 24,
                    ),
                    const SizedBox(width: NothingTheme.spacingMedium),
                    const Expanded(
                      child: Text(
                        '上传选项',
                        style: TextStyle(
                          fontSize: NothingTheme.fontSizeHeadline,
                          fontWeight: NothingTheme.fontWeightBold,
                          color: NothingTheme.nothingBlack,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: NothingTheme.nothingBlack,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // 选项列表
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(NothingTheme.spacingLarge),
                  child: Column(
                    children: [
                      _buildUploadOption(
                        icon: Icons.add_photo_alternate,
                        title: '添加图文记录',
                        subtitle: '上传图片并添加文字描述',
                        onTap: () {
                          Navigator.of(context).pop();
                          // TODO: 实现添加图文记录功能
                        },
                      ),
                      const SizedBox(height: NothingTheme.spacingMedium),
                      _buildUploadOption(
                        icon: Icons.description,
                        title: '导入档案文件',
                        subtitle: '导入JSON格式的档案数据',
                        onTap: () {
                          Navigator.of(context).pop();
                          // TODO: 实现导入档案文件功能
                        },
                      ),
                      const SizedBox(height: NothingTheme.spacingMedium),
                      _buildUploadOption(
                        icon: Icons.pets,
                        title: '导入宠物活动数据',
                        subtitle: '导入宠物活动记录文件',
                        onTap: () {
                          Navigator.of(context).pop();
                          _importPetActivityData();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建上传选项项目
  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(NothingTheme.spacingLarge),
        decoration: BoxDecoration(
          color: NothingTheme.nothingLightGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
          border: Border.all(color: NothingTheme.nothingLightGray, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NothingTheme.nothingYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              ),
              child: Icon(icon, color: NothingTheme.nothingBlack, size: 24),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: NothingTheme.fontSizeCaption,
                      color: NothingTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: NothingTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 导入宠物活动数据
  Future<void> _importPetActivityData() async {
    try {
      // 首先检查存储权限
      final permissionManager = PermissionManager();
      bool hasPermission = await permissionManager.hasStoragePermission();

      if (!hasPermission) {
        // 请求存储权限
        bool granted = await permissionManager.requestStoragePermissions();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '需要存储权限才能选择文件，请在设置中授予权限',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
          return;
        }
      }

      // 选择文件
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt', 'csv', 'docx', 'doc'],
        allowMultiple: false,
      );

      if (result != null) {
        int addedCount = 0;

        if (result.files.single.bytes != null) {
          final fileBytes = result.files.single.bytes!;
          final fileName = result.files.single.name;
          final mimeType = result.files.single.extension;

          // 使用基于字节数据的解析方法，解决Scoped Storage限制
          addedCount = await PetActivityParser.parseAndAddToHistoryFromBytes(
            fileBytes,
            fileName,
            mimeType,
          );
        } else if (result.files.single.path != null) {
          // 备用方案：如果字节数据不可用，尝试使用路径方式（兼容旧版本Android）
          final filePath = result.files.single.path!;
          try {
            addedCount = await PetActivityParser.parseAndAddToHistory(filePath);
          } catch (e) {
            // 检查是否是Scoped Storage相关错误
            if (e.toString().contains('unknown_path') ||
                e.toString().contains('Permission denied') ||
                e.toString().contains('No such file or directory')) {
              // 显示Scoped Storage相关错误的用户友好提示
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: NothingTheme.nothingWhite,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '文件访问受限',
                                style: TextStyle(
                                  color: NothingTheme.nothingWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '由于Android安全限制，无法直接访问该文件。请尝试：',
                          style: TextStyle(
                            color: NothingTheme.nothingWhite,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '• 将文件复制到Downloads文件夹后重新选择\n• 使用其他文件管理器重新选择文件\n• 确保文件格式正确（支持txt、csv、json、docx、doc）',
                          style: TextStyle(
                            color: NothingTheme.nothingWhite,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            _showSAFImportDialog();
                          },
                          icon: const Icon(
                            Icons.folder_open,
                            color: NothingTheme.nothingWhite,
                            size: 16,
                          ),
                          label: const Text(
                            '尝试高级文件选择',
                            style: TextStyle(
                              color: NothingTheme.nothingWhite,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.blue.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    duration: const Duration(seconds: 8),
                  ),
                );
              }
              return;
            } else {
              // 其他类型的错误，重新抛出
              rethrow;
            }
          }
        } else {
          // 既没有字节数据也没有路径，显示错误
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: NothingTheme.nothingWhite,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '无法获取文件内容，请重新选择文件',
                        style: TextStyle(
                          color: NothingTheme.nothingWhite,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
          return;
        }

        if (addedCount > 0) {
          // 刷新历史记录显示
          setState(() {});

          // 显示成功消息
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: NothingTheme.nothingWhite,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '成功导入 $addedCount 条宠物活动记录',
                        style: const TextStyle(
                          color: NothingTheme.nothingWhite,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        } else {
          // 没有找到有效数据
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      color: NothingTheme.nothingWhite,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '文件中未找到有效的宠物活动数据',
                        style: TextStyle(
                          color: NothingTheme.nothingWhite,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: NothingTheme.nothingWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '导入失败: ${e.toString()}',
                    style: const TextStyle(
                      color: NothingTheme.nothingWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  // SAF (Storage Access Framework) 高级文件选择对话框
  void _showSAFImportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: NothingTheme.nothingBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.folder_special,
                color: NothingTheme.nothingWhite,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '高级文件选择',
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '如果常规文件选择无法访问您的文件，请尝试以下方法：',
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildSAFOption(
                icon: Icons.download,
                title: '从下载文件夹选择',
                description: '选择保存在Downloads文件夹中的文件',
                onTap: () => _importFromDownloads(),
              ),
              const SizedBox(height: 12),
              _buildSAFOption(
                icon: Icons.cloud_download,
                title: '从云存储选择',
                description: '从Google Drive、OneDrive等云存储选择',
                onTap: () => _importFromCloudStorage(),
              ),
              const SizedBox(height: 12),
              _buildSAFOption(
                icon: Icons.text_snippet,
                title: '手动粘贴内容',
                description: '直接粘贴文件内容进行导入',
                onTap: () => _showManualPasteDialog(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSAFOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: NothingTheme.nothingWhite.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: NothingTheme.nothingWhite, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: NothingTheme.nothingWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: NothingTheme.nothingWhite.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: NothingTheme.nothingWhite.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // 从下载文件夹导入
  void _importFromDownloads() async {
    Navigator.of(context).pop();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv', 'json', 'docx', 'doc'],
        initialDirectory: '/storage/emulated/0/Download', // Android Downloads目录
      );

      if (result != null) {
        await _processSelectedFile(result);
      }
    } catch (e) {
      _importPetActivityData(); // 回退到常规文件选择
    }
  }

  // 从云存储导入
  void _importFromCloudStorage() async {
    Navigator.of(context).pop();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv', 'json', 'docx', 'doc'],
        allowMultiple: false,
      );

      if (result != null) {
        await _processSelectedFile(result);
      }
    } catch (e) {
      _importPetActivityData(); // 回退到常规文件选择
    }
  }

  // 处理选中的文件
  Future<void> _processSelectedFile(FilePickerResult result) async {
    // 复用现有的文件处理逻辑
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

    // 显示结果
    if (addedCount > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: NothingTheme.nothingWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '成功导入 $addedCount 条宠物活动记录',
                    style: const TextStyle(
                      color: NothingTheme.nothingWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  // 手动粘贴内容对话框
  void _showManualPasteDialog() {
    Navigator.of(context).pop();
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: NothingTheme.nothingBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            '手动粘贴内容',
            style: TextStyle(
              color: NothingTheme.nothingWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '请粘贴您的宠物活动数据内容：',
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 8,
                style: const TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  hintText: '粘贴文件内容...',
                  hintStyle: TextStyle(
                    color: NothingTheme.nothingWhite.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: NothingTheme.nothingWhite.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: NothingTheme.nothingWhite.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: NothingTheme.nothingWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (textController.text.isNotEmpty) {
                  await _processManualContent(textController.text);
                }
              },
              child: const Text(
                '导入',
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 处理手动粘贴的内容
  Future<void> _processManualContent(String content) async {
    try {
      // 将内容转换为字节数据，然后使用现有的解析方法
      final contentBytes = utf8.encode(content);
      final addedCount = await PetActivityParser.parseAndAddToHistoryFromBytes(
        contentBytes,
        'manual_paste.txt',
        'text/plain',
      );

      if (addedCount > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: NothingTheme.nothingWhite,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '成功导入 $addedCount 条宠物活动记录',
                      style: const TextStyle(
                        color: NothingTheme.nothingWhite,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: NothingTheme.nothingWhite,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '未找到有效的宠物活动数据',
                      style: TextStyle(
                        color: NothingTheme.nothingWhite,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: NothingTheme.nothingWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '导入失败: ${e.toString()}',
                    style: const TextStyle(
                      color: NothingTheme.nothingWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  // 构建历史记录卡片列表
  // 构建时间线视图
  Widget _buildTimelineView() {
    return Column(
      children: [
        // 过滤器选项
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: NothingTheme.nothingBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NothingTheme.nothingWhite.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterButton('全部', 'all', _currentFilter == 'all'),
              ),
              Expanded(
                child: _buildFilterButton('实时', 'realtime', _currentFilter == 'realtime'),
              ),
              Expanded(
                child: _buildFilterButton('手动', 'manual', _currentFilter == 'manual'),
              ),
            ],
          ),
        ),
        // 历史记录列表
        Expanded(
          child: _buildHistoryCards(_currentFilter),
        ),
      ],
    );
  }

  // 构建过滤器按钮
  Widget _buildFilterButton(String label, String filter, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
            ? NothingTheme.nothingYellow 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected 
              ? NothingTheme.nothingBlack 
              : NothingTheme.nothingWhite.withOpacity(0.7),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCards(String filter) {
    final filteredHistories = _getFilteredHistories(filter);
    
    if (filteredHistories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: NothingTheme.nothingWhite.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无历史记录',
              style: TextStyle(
                color: NothingTheme.nothingWhite.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        // 统计概览卡片
        _buildStatisticsOverviewCard(filteredHistories),
        // 历史记录列表
        ...filteredHistories.map((history) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: _buildHistoryCard(history),
        )).toList(),
      ],
    );
  }

  // 构建统计概览卡片
  Widget _buildStatisticsOverviewCard(List<AnalysisHistory> histories) {
    final today = DateTime.now();
    final totalCount = histories.length;
    final imageCount = histories.where((h) => h.imagePath != null && h.imagePath!.isNotEmpty).length;
    final textCount = totalCount - imageCount;
    final todayCount = histories.where((h) => 
      h.timestamp.day == today.day &&
      h.timestamp.month == today.month &&
      h.timestamp.year == today.year
    ).length;
    final weekCount = histories.where((h) => 
      today.difference(h.timestamp).inDays <= 7
    ).length;
    final realtimeCount = histories.where((h) => h.isRealtimeAnalysis).length;
    final manualCount = totalCount - realtimeCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.nothingBlack,
        border: Border.all(color: NothingTheme.nothingWhite.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '统计概览',
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 主要统计数据
          Row(
            children: [
              Expanded(child: _buildStatItem('总记录', totalCount.toString(), Icons.history, Colors.blue)),
              Expanded(child: _buildStatItem('今日', todayCount.toString(), Icons.today, Colors.green)),
              Expanded(child: _buildStatItem('本周', weekCount.toString(), Icons.date_range, Colors.orange)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 分析类型统计
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NothingTheme.nothingWhite.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: NothingTheme.nothingWhite.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '分析类型分布',
                  style: TextStyle(
                    color: NothingTheme.nothingWhite.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeStatItem(
                        '实时分析',
                        realtimeCount,
                        totalCount,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeStatItem(
                        '手动分析',
                        manualCount,
                        totalCount,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.image,
                            size: 16,
                            color: Colors.purple.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '图像: $imageCount',
                            style: TextStyle(
                              color: NothingTheme.nothingWhite.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.text_fields,
                            size: 16,
                            color: Colors.cyan.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '文本: $textCount',
                            style: TextStyle(
                              color: NothingTheme.nothingWhite.withOpacity(0.7),
                              fontSize: 12,
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
    );
  }

  // 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    final iconColor = color ?? NothingTheme.nothingWhite.withOpacity(0.7);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: NothingTheme.nothingWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: NothingTheme.nothingWhite.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // 构建类型统计项
  Widget _buildTypeStatItem(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: NothingTheme.nothingWhite.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              color: NothingTheme.nothingWhite.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // 构建历史记录卡片
  Widget _buildHistoryCard(AnalysisHistory history) {
    final hasImage = history.imagePath != null && history.imagePath!.isNotEmpty;
    final timestamp = history.timestamp;
    final confidence = history.result.confidence;
    
    return Card(
      color: NothingTheme.nothingBlack,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: NothingTheme.nothingWhite.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showHistoryDetail(history),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息
              Row(
                children: [
                  // 类型图标
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: hasImage 
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      hasImage ? Icons.image : Icons.text_fields,
                      color: hasImage ? Colors.blue : Colors.green,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getModeName(history.mode),
                          style: const TextStyle(
                            color: NothingTheme.nothingWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          history.isRealtimeAnalysis ? '实时分析' : '手动分析',
                          style: TextStyle(
                            color: NothingTheme.nothingWhite.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 置信度标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(confidence).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${confidence}%',
                      style: TextStyle(
                        color: _getConfidenceColor(confidence),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 图像显示（如果有）
              if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.file(
                        File(history.imagePath!),
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 140,
                            width: double.infinity,
                            color: NothingTheme.nothingWhite.withOpacity(0.1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.broken_image,
                                  color: NothingTheme.nothingWhite,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '图像加载失败',
                                  style: TextStyle(
                                    color: NothingTheme.nothingWhite.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // 图像覆盖层
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // 分析结果
              if (history.result.title.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: NothingTheme.nothingWhite.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '分析结果',
                      style: TextStyle(
                        color: NothingTheme.nothingWhite.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NothingTheme.nothingWhite.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: NothingTheme.nothingWhite.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    history.result.title,
                    style: const TextStyle(
                      color: NothingTheme.nothingWhite,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              
              // 描述信息
              if (history.result.subInfo != null && history.result.subInfo!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  history.result.subInfo!,
                  style: TextStyle(
                    color: NothingTheme.nothingWhite.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // 底部信息栏
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: NothingTheme.nothingWhite.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: NothingTheme.nothingWhite.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  // 分享按钮
                  GestureDetector(
                    onTap: () => _shareHistory(history),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: NothingTheme.nothingWhite.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.share,
                        size: 14,
                        color: NothingTheme.nothingWhite.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: NothingTheme.nothingWhite.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 根据置信度获取颜色
  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) {
      return Colors.green;
    } else if (confidence >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // 构建统计视图
  Widget _buildStatisticsView() {
    final allHistories = _histories;
    
    if (allHistories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: NothingTheme.nothingWhite.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无统计数据',
              style: TextStyle(
                color: NothingTheme.nothingWhite.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // 按日期分组统计
    final Map<String, List<AnalysisHistory>> groupedByDate = {};
    for (final history in allHistories) {
      final date = history.timestamp;
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      groupedByDate.putIfAbsent(dateKey, () => []).add(history);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 总体统计卡片
        _buildStatisticsOverviewCard(allHistories),
        const SizedBox(height: 16),
        
        // 日期统计
        Text(
          '每日统计',
          style: const TextStyle(
            color: NothingTheme.nothingWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        ...groupedByDate.entries.map((entry) {
          final date = entry.key;
          final histories = entry.value;
          final imageCount = histories.where((h) => h.imagePath != null && h.imagePath!.isNotEmpty).length;
          final textCount = histories.length - imageCount;
          
          return Card(
            color: NothingTheme.nothingBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: NothingTheme.nothingWhite.withOpacity(0.2)),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      color: NothingTheme.nothingWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatItem('总计', histories.length.toString(), Icons.history)),
                      Expanded(child: _buildStatItem('图像', imageCount.toString(), Icons.image)),
                      Expanded(child: _buildStatItem('文本', textCount.toString(), Icons.text_fields)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // 构建行为分析视图
  Widget _buildBehaviorAnalysisView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 行为分析概览
        Card(
          color: NothingTheme.nothingBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: NothingTheme.nothingWhite.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '行为分析',
                  style: TextStyle(
                    color: NothingTheme.nothingWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '基于您的历史记录，我们分析了您的行为模式和趋势。',
                  style: TextStyle(
                    color: NothingTheme.nothingWhite.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 使用现有的BehaviorAnalyticsWidget
        BehaviorAnalyticsWidget(histories: _histories),
      ],
    );
  }

  // 构建分享选项
  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: NothingTheme.nothingLightGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NothingTheme.nothingYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: NothingTheme.nothingBlack,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: NothingTheme.nothingBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: NothingTheme.nothingBlack.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: NothingTheme.nothingBlack.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  // 复制到剪贴板
  Future<void> _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已复制到剪贴板'),
            backgroundColor: NothingTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('复制失败: $e'),
            backgroundColor: NothingTheme.nothingDarkGray,
          ),
        );
      }
    }
  }

  // 导出为文件
  Future<void> _exportToFile(String content, AnalysisHistory history) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(history.timestamp);
      final fileName = 'analysis_record_$timestamp.txt';
      
      // 这里应该使用文件选择器或路径提供器来保存文件
      // 目前显示一个提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出功能正在开发中\n文件名: $fileName'),
            backgroundColor: NothingTheme.info,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: NothingTheme.nothingDarkGray,
          ),
        );
      }
    }
  }

  // 分享图片和文本
  Future<void> _shareImageWithText(String text, AnalysisHistory history) async {
    try {
      // 这里应该使用分享插件来分享图片和文本
      // 目前显示一个提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('图片分享功能正在开发中'),
            backgroundColor: NothingTheme.info,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: $e'),
            backgroundColor: NothingTheme.nothingDarkGray,
          ),
        );
      }
    }
  }
}