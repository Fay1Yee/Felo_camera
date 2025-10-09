import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/analysis_history.dart';
import '../services/history_manager.dart';
import '../config/nothing_theme.dart';
import '../config/device_config.dart';
import '../widgets/nothing_timeline.dart';
import '../widgets/nothing_photo_album.dart';
import '../widgets/nothing_statistics.dart';
import '../widgets/behavior_analytics_widget.dart';
import '../utils/pet_conversation_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadHistories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          decoration: NothingTheme.nothingCardDecoration,
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NothingTheme.nothingBlack.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
                      ),
                      child: Icon(
                        _getModeIcon(history.mode),
                        color: NothingTheme.nothingBlack,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: NothingTheme.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PetConversationHelper.convertToPetTone(history.result).title, // 使用宠物语气标题
                            style: const TextStyle(
                              fontSize: NothingTheme.fontSizeHeadline,
                              fontWeight: NothingTheme.fontWeightBold,
                              color: NothingTheme.nothingBlack,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: history.isRealtimeAnalysis 
                                      ? NothingTheme.successGreen.withValues(alpha: 0.2)
                                      : NothingTheme.infoBlue.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
                                ),
                                child: Text(
                                  history.isRealtimeAnalysis ? '实时分析' : '手动拍照',
                                  style: TextStyle(
                                    fontSize: NothingTheme.fontSizeCaption,
                                    fontWeight: NothingTheme.fontWeightMedium,
                                    color: history.isRealtimeAnalysis 
                                        ? NothingTheme.successGreen
                                        : NothingTheme.infoBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: NothingTheme.nothingBlack.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
                                ),
                                child: Text(
                                  PetConversationHelper.getConfidenceExpression(history.result.confidence), // 使用友好的置信度表达
                                  style: const TextStyle(
                                    fontSize: NothingTheme.fontSizeCaption,
                                    fontWeight: NothingTheme.fontWeightBold,
                                    color: NothingTheme.nothingBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: NothingTheme.nothingBlack,
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
                          margin: const EdgeInsets.only(bottom: NothingTheme.spacingLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                            border: Border.all(
                              color: NothingTheme.nothingLightGray,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                            child: history.imagePath != null ? Image.file(
                              File(history.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: NothingTheme.nothingLightGray,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 48,
                                        color: NothingTheme.nothingGray,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '图像无法显示',
                                        style: TextStyle(
                                          fontSize: NothingTheme.fontSizeBody,
                                          color: NothingTheme.nothingGray,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        history.isRealtimeAnalysis ? '实时分析图像' : '手动拍摄图像',
                                        style: TextStyle(
                                          fontSize: NothingTheme.fontSizeCaption,
                                          color: NothingTheme.nothingGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ) : Container(
                              color: NothingTheme.nothingLightGray,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                          margin: const EdgeInsets.only(bottom: NothingTheme.spacingLarge),
                          decoration: BoxDecoration(
                            color: NothingTheme.nothingLightGray.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
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
                                history.isRealtimeAnalysis ? Icons.auto_awesome : Icons.camera_alt,
                                size: 48,
                                color: NothingTheme.nothingGray,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                history.isRealtimeAnalysis ? '实时分析记录' : '手动分析记录',
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
                        padding: const EdgeInsets.all(NothingTheme.spacingMedium),
                        margin: const EdgeInsets.only(bottom: NothingTheme.spacingMedium),
                        decoration: BoxDecoration(
                          color: NothingTheme.nothingLightGray.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '分析结果',
                              style: TextStyle(
                                fontSize: NothingTheme.fontSizeSubtitle,
                                fontWeight: NothingTheme.fontWeightBold,
                                color: NothingTheme.nothingBlack,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              PetConversationHelper.convertToPetTone(history.result).title, // 使用宠物语气标题
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
                        _buildDetailRow('分析类型', history.isRealtimeAnalysis ? '实时分析' : '手动拍照'),
                        _buildDetailRow('置信度', PetConversationHelper.getConfidenceExpression(history.result.confidence)), // 使用友好的置信度表达
                        _buildDetailRow('拍摄时间', DateFormat('yyyy年MM月dd日 HH:mm:ss').format(history.timestamp)),
                      ]),
                      
                      // 附加信息
                      if (history.result.subInfo != null) ...[
                        const SizedBox(height: NothingTheme.spacingMedium),
                        _buildEnhancedDetailCard([
                          _buildDetailRow('附加信息', PetConversationHelper.convertToPetTone(history.result).subInfo ?? '暂无详细信息'), // 使用宠物语气子信息
                        ], title: '详细信息'),
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
                            borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
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
                            borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
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
        border: Border.all(
          color: NothingTheme.nothingLightGray,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeSubtitle,
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
    _loadHistories();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('历史记录已删除')),
      );
    }
  }

  Future<void> _deleteAllHistories() async {
    try {
      await HistoryManager.instance.clearAllHistories();
      setState(() {
        _histories.clear();
      });
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

  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'normal':
        return Icons.camera_alt;
      case 'pet':
        return Icons.pets;
      case 'health':
        return Icons.health_and_safety;
      case 'travel':
        return Icons.luggage;
      default:
        return Icons.analytics;
    }
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NothingTheme.nothingYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
                border: Border.all(
                  color: NothingTheme.nothingYellow.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.history,
                color: NothingTheme.nothingBlack,
                size: 20,
              ),
            ),
            const SizedBox(width: NothingTheme.spacingMedium),
            const Text(
              '历史记录',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeHeadline,
                fontWeight: NothingTheme.fontWeightBold,
                color: NothingTheme.nothingBlack,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // 相册视图切换按钮
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: NothingTheme.nothingWhite,
              borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
              border: Border.all(
                color: NothingTheme.nothingLightGray,
                width: 1,
              ),
            ),
            child: IconButton(
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
                                color: NothingTheme.successGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
                                border: Border.all(
                                  color: NothingTheme.successGreen.withValues(alpha: 0.3),
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
                size: 20,
              ),
            ),
          ),
          // 删除所有记录按钮
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _histories.isEmpty 
                  ? NothingTheme.nothingLightGray.withValues(alpha: 0.3)
                  : NothingTheme.nothingDarkGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(NothingTheme.radiusSmall),
              border: Border.all(
                color: _histories.isEmpty 
                    ? NothingTheme.nothingLightGray
                    : NothingTheme.nothingDarkGray.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: _histories.isEmpty ? null : () => _showDeleteAllDialog(),
              icon: Icon(
                Icons.delete_sweep,
                color: _histories.isEmpty ? NothingTheme.nothingGray : NothingTheme.nothingDarkGray,
                size: 20,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              labelStyle: const TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                fontWeight: NothingTheme.fontWeightMedium,
                letterSpacing: -0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                fontWeight: NothingTheme.fontWeightRegular,
                letterSpacing: -0.2,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.all_inclusive, size: 14),
                      const SizedBox(width: 2),
                      const Flexible(
                        child: Text(
                          '全部',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14),
                      const SizedBox(width: 2),
                      const Flexible(
                        child: Text(
                          '实时',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app, size: 14),
                      const SizedBox(width: 2),
                      const Flexible(
                        child: Text(
                          '手动',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.analytics, size: 14),
                      const SizedBox(width: 2),
                      const Flexible(
                        child: Text(
                          '统计',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pets, size: 14),
                      const SizedBox(width: 2),
                      const Flexible(
                        child: Text(
                          '行为',
                          overflow: TextOverflow.ellipsis,
                        ),
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
                      borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                      border: Border.all(
                        color: NothingTheme.nothingYellow.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.nothingYellow),
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
                  NothingTimeline(
                    histories: _getFilteredHistories('all'),
                    onItemTap: _showHistoryDetail,
                    onItemDelete: _deleteHistory,
                  ),
                  NothingTimeline(
                    histories: _getFilteredHistories('realtime'),
                    onItemTap: _showHistoryDetail,
                    onItemDelete: _deleteHistory,
                  ),
                  NothingTimeline(
                    histories: _getFilteredHistories('manual'),
                    onItemTap: _showHistoryDetail,
                    onItemDelete: _deleteHistory,
                  ),
                  NothingStatistics(histories: _histories),
                  BehaviorAnalyticsWidget(histories: _histories),
                ],
              ),
            ),
    );
  }


}