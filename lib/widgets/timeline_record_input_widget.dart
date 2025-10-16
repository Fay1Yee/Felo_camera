import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/nothing_theme.dart';
import '../services/timeline_record_parser.dart';
import '../services/history_manager.dart';

/// JSON时间轴记录输入组件
class TimelineRecordInputWidget extends StatefulWidget {
  final VoidCallback? onRecordAdded;
  
  const TimelineRecordInputWidget({
    super.key,
    this.onRecordAdded,
  });

  @override
  State<TimelineRecordInputWidget> createState() => _TimelineRecordInputWidgetState();
}

class _TimelineRecordInputWidgetState extends State<TimelineRecordInputWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<String> _validationErrors = [];
  TimelineParseResult? _parseResult;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    // 设置示例文本
    _textController.text = TimelineRecordParser.generateFormatExample();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _validationErrors = [];
        _parseResult = null;
        _showPreview = false;
      });
      return;
    }

    // 实时验证
    final errors = TimelineRecordParser.validateFormat(_textController.text);
    setState(() {
      _validationErrors = errors;
    });
  }

  /// 预览解析结果
  void _previewRecords() {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    final result = TimelineRecordParser.parseTimelineText(content);
    setState(() {
      _parseResult = result;
      _showPreview = true;
    });
  }

  /// 导入记录
  Future<void> _importRecords() async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      _showErrorSnackBar('请输入时间轴记录文本');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = TimelineRecordParser.parseTimelineText(content);
      
      if (result.records.isEmpty) {
        _showErrorSnackBar('未找到有效的记录');
        return;
      }

      if (result.errors.isNotEmpty) {
        // 显示错误但继续处理有效记录
        _showWarningDialog(result);
        return;
      }

      // 导入所有记录
      for (final record in result.records) {
        await HistoryManager.instance.addHistoryWithTimestamp(
          imagePath: null,
          result: record.toAIResult(),
          mode: 'timeline_import',
          isRealtimeAnalysis: false,
          timestamp: record.timestamp,
        );
      }

      _showSuccessSnackBar('成功导入 ${result.successCount} 条记录');
      
      // 清空输入框
      _textController.clear();
      setState(() {
        _parseResult = null;
        _showPreview = false;
      });

      // 通知父组件
      widget.onRecordAdded?.call();
      
    } catch (e) {
      _showErrorSnackBar('导入失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 显示警告对话框
  void _showWarningDialog(TimelineParseResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NothingTheme.nothingWhite,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: NothingTheme.nothingYellow,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              '导入警告',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeHeadline,
                fontWeight: NothingTheme.fontWeightBold,
                color: NothingTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '发现 ${result.errorCount} 个错误，${result.successCount} 条记录可以正常导入：',
              style: const TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                color: NothingTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.errors.map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $error',
                      style: const TextStyle(
                        fontSize: NothingTheme.fontSizeCaption,
                        color: NothingTheme.nothingDarkGray,
                      ),
                    ),
                  )).toList(),
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
                fontSize: NothingTheme.fontSizeBody,
                color: NothingTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // 只导入有效记录
              for (final record in result.records) {
                await HistoryManager.instance.addHistoryWithTimestamp(
                  imagePath: null,
                  result: record.toAIResult(),
                  mode: 'timeline_import',
                  isRealtimeAnalysis: false,
                  timestamp: record.timestamp,
                );
              }

              _showSuccessSnackBar('成功导入 ${result.successCount} 条记录，跳过 ${result.errorCount} 条错误记录');
              
              // 清空输入框
              _textController.clear();
              setState(() {
                _parseResult = null;
                _showPreview = false;
              });

              widget.onRecordAdded?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NothingTheme.successGreen,
              foregroundColor: NothingTheme.nothingWhite,
            ),
            child: const Text(
              '继续导入',
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: NothingTheme.nothingDarkGray,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: NothingTheme.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: NothingTheme.nothingYellow,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'JSON时间轴记录导入',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeHeadline,
                  fontWeight: NothingTheme.fontWeightBold,
                  color: NothingTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: NothingTheme.spacingMedium),

          // 格式说明
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NothingTheme.brandSecondary,
              borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              border: Border.all(
                color: NothingTheme.nothingYellow.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '格式要求：',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '每行格式：timestamp\\tcategory\\tconfidence\\treasons',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeCaption,
                    color: NothingTheme.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• timestamp: YYYY-MM-DD HH:MM:SS 格式\n• confidence: 0.0-1.0 之间的浮点数\n• reasons: 完整的JSON对象',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeCaption,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),

          // 文本输入区域
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _validationErrors.isNotEmpty 
                    ? NothingTheme.nothingDarkGray 
                    : NothingTheme.nothingLightGray,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
            ),
            child: TextField(
              controller: _textController,
              maxLines: 12,
              style: const TextStyle(
                fontSize: NothingTheme.fontSizeCaption,
                fontFamily: 'monospace',
                color: NothingTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '请输入JSON格式的时间轴记录...',
                hintStyle: const TextStyle(
                  color: NothingTheme.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),

          // 验证错误显示
          if (_validationErrors.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NothingTheme.nothingDarkGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                border: Border.all(
                  color: NothingTheme.nothingDarkGray.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: NothingTheme.nothingDarkGray,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '发现 ${_validationErrors.length} 个错误：',
                        style: const TextStyle(
                          fontSize: NothingTheme.fontSizeCaption,
                          fontWeight: NothingTheme.fontWeightMedium,
                          color: NothingTheme.nothingDarkGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: Scrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _validationErrors.map((error) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '• $error',
                              style: const TextStyle(
                                fontSize: NothingTheme.fontSizeCaption,
                                color: NothingTheme.nothingDarkGray,
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NothingTheme.spacingMedium),
          ],

          // 预览结果
          if (_showPreview && _parseResult != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NothingTheme.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                border: Border.all(
                  color: NothingTheme.successGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.preview,
                        color: NothingTheme.successGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '预览结果：共 ${_parseResult!.successCount} 条有效记录',
                        style: const TextStyle(
                          fontSize: NothingTheme.fontSizeCaption,
                          fontWeight: NothingTheme.fontWeightMedium,
                          color: NothingTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _parseResult!.records.take(5).map((record) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${record.timestamp.toString().substring(0, 19)} - ${record.category} (${(record.confidence * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              fontSize: NothingTheme.fontSizeCaption,
                              color: NothingTheme.textSecondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  if (_parseResult!.records.length > 5)
                    Text(
                      '... 还有 ${_parseResult!.records.length - 5} 条记录',
                      style: const TextStyle(
                        fontSize: NothingTheme.fontSizeCaption,
                        color: NothingTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: NothingTheme.spacingMedium),
          ],

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _textController.text.trim().isEmpty ? null : _previewRecords,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: NothingTheme.nothingLightGray),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '预览',
                    style: TextStyle(
                      fontSize: NothingTheme.fontSizeBody,
                      fontWeight: NothingTheme.fontWeightMedium,
                      color: NothingTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: NothingTheme.spacingMedium),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: (_isLoading || _textController.text.trim().isEmpty || _validationErrors.isNotEmpty) 
                      ? null 
                      : _importRecords,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NothingTheme.successGreen,
                    foregroundColor: NothingTheme.nothingWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              NothingTheme.nothingWhite,
                            ),
                          ),
                        )
                      : const Text(
                          '导入记录',
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeBody,
                            fontWeight: NothingTheme.fontWeightMedium,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}