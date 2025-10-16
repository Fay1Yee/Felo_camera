import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/nothing_theme.dart';
import '../services/json_paste_parser.dart';
import '../services/history_manager.dart';
import '../services/json_format_fixer.dart';
import '../services/history_analyzer.dart';
import '../models/analysis_history.dart';

/// JSON粘贴记录输入组件
class JsonPasteInputWidget extends StatefulWidget {
  final VoidCallback? onRecordAdded;

  const JsonPasteInputWidget({super.key, this.onRecordAdded});

  @override
  State<JsonPasteInputWidget> createState() => _JsonPasteInputWidgetState();
}

class _JsonPasteInputWidgetState extends State<JsonPasteInputWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<String> _validationErrors = [];
  JsonPasteParseResult? _parseResult;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    // 设置示例文本
    _textController.text = JsonPasteParser.generateFormatExample();
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

    // 实时验证JSON格式
    final content = _textController.text.trim();
    List<String> errors = [];

    // 首先尝试作为JSON验证
    try {
      final jsonErrors = JsonFormatFixer.validateJsonFormat(content);
      if (jsonErrors.isNotEmpty) {
        errors.addAll(jsonErrors);
      }
    } catch (e) {
      // 如果不是JSON格式，尝试作为制表符分隔格式验证
      final formatErrors = JsonPasteParser.validateFormat(content);
      errors.addAll(formatErrors);
    }

    setState(() {
      _validationErrors = errors;
    });
  }

  /// 从剪贴板粘贴
  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        setState(() {
          _textController.text = clipboardData!.text!;
        });
      }
    } catch (e) {
      _showErrorSnackBar('粘贴失败: $e');
    }
  }

  /// 清空输入框
  void _clearInput() {
    setState(() {
      _textController.clear();
      _parseResult = null;
      _showPreview = false;
      _validationErrors = [];
    });
  }

  /// 预览解析结果
  void _previewRecords() {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    // 使用JSON解析方法（支持自动修正）
    final result = JsonPasteParser.parseJsonPaste(content, autoFix: true);
    setState(() {
      _parseResult = result;
      _showPreview = true;
    });
  }

  /// 自动分析和导入记录
  ///
  /// [content] JSON内容
  /// [showProgress] 是否显示进度提示
  Future<bool> _autoAnalyzeAndImport(
    String content, {
    bool showProgress = true,
  }) async {
    if (content.isEmpty) return false;

    if (showProgress) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // 1. 解析JSON内容
      final result = JsonPasteParser.parseJsonPaste(content, autoFix: true);

      if (result.records.isEmpty) {
        if (showProgress) {
          _showErrorSnackBar('未找到有效的记录');
        }
        return false;
      }

      // 2. 导入所有记录到历史管理器
      int importedCount = 0;
      for (final record in result.records) {
        await HistoryManager.instance.addHistoryWithTimestamp(
          imagePath: null,
          result: record.toAIResult(),
          mode: 'json_paste_import',
          isRealtimeAnalysis: false,
          timestamp: record.timestamp,
        );
        importedCount++;
      }

      // 3. 获取最新的历史记录进行分析
      final allHistories = await HistoryManager.instance.getAllHistories();
      if (allHistories.isNotEmpty) {
        // 触发历史记录分析（异步执行，不阻塞UI）
        _triggerHistoryAnalysis(allHistories);
      }

      if (showProgress) {
        if (result.errors.isNotEmpty) {
          _showSuccessSnackBar(
            '成功导入 $importedCount 条记录并触发分析，跳过 ${result.errorCount} 条错误记录',
          );
        } else {
          _showSuccessSnackBar('成功导入 $importedCount 条记录并触发分析');
        }

        // 清空输入框
        _clearInput();

        // 通知父组件
        widget.onRecordAdded?.call();
      }

      return true;
    } catch (e) {
      if (showProgress) {
        _showErrorSnackBar('自动分析和导入失败: $e');
      }
      return false;
    } finally {
      if (showProgress) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 触发历史记录分析（异步执行）
  Future<void> _triggerHistoryAnalysis(List<AnalysisHistory> histories) async {
    try {
      // 异步执行分析，不阻塞UI
      Future.microtask(() async {
        final analyzer = HistoryAnalyzer();

        // 执行趋势分析
        await analyzer.analyzeHistoryTrend(histories, 'trend');

        // 执行摘要分析
        await analyzer.analyzeHistoryTrend(histories, 'summary');

        // 执行洞察分析
        await analyzer.analyzeHistoryTrend(histories, 'insights');
      });
    } catch (e) {
      // 分析失败不影响导入流程，只记录错误
      debugPrint('历史记录分析失败: $e');
    }
  }

  /// 一键修正JSON格式
  Future<void> _attemptAutoFix() async {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final fixResult = JsonFormatFixer.autoFixJson(content);

      // 显示修正结果对话框
      final dialogResult = await _showFixResultDialog(fixResult);

      if (dialogResult != null && mounted) {
        setState(() {
          _textController.text = fixResult.fixedJson;
          _validationErrors = fixResult.remainingErrors;
        });

        if (fixResult.isValid) {
          if (dialogResult == true) {
            // 用户选择自动分析和导入
            final autoImportSuccess = await _autoAnalyzeAndImport(
              fixResult.fixedJson,
              showProgress: false,
            );

            if (autoImportSuccess) {
              _showSuccessSnackBar(
                'JSON修正成功！已修正 ${fixResult.fixedErrorCount} 个问题并自动导入分析',
              );
            } else {
              _showSuccessSnackBar(
                'JSON格式修正成功！已修正 ${fixResult.fixedErrorCount} 个问题',
              );
            }
          } else {
            // 用户选择仅应用修正
            _showSuccessSnackBar(
              'JSON格式修正成功！已修正 ${fixResult.fixedErrorCount} 个问题',
            );
          }
        } else {
          _showErrorSnackBar(
            '部分修正完成，仍有 ${fixResult.remainingErrors.length} 个问题需要手动处理',
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('自动修正失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 显示修正结果对话框
  /// 返回值：null=取消，false=仅应用修正，true=应用修正并自动分析
  Future<bool?> _showFixResultDialog(JsonFixResult fixResult) async {
    return await showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NothingTheme.nothingWhite,
        title: Row(
          children: [
            Icon(
              fixResult.isValid ? Icons.check_circle : Icons.warning_amber,
              color: fixResult.isValid
                  ? NothingTheme.successGreen
                  : NothingTheme.nothingYellow,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'JSON修正结果',
              style: const TextStyle(
                fontSize: NothingTheme.fontSizeHeadline,
                fontWeight: NothingTheme.fontWeightBold,
                color: NothingTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 修正统计
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NothingTheme.brandSecondary,
                  borderRadius: BorderRadius.circular(
                    NothingTheme.radiusMedium,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '修正统计',
                      style: const TextStyle(
                        fontSize: NothingTheme.fontSizeBody,
                        fontWeight: NothingTheme.fontWeightMedium,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '原始错误: ${fixResult.originalErrorCount}',
                      style: const TextStyle(
                        fontSize: NothingTheme.fontSizeCaption,
                        color: NothingTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '已修正: ${fixResult.fixedErrorCount}',
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeCaption,
                        color: NothingTheme.successGreen,
                        fontWeight: NothingTheme.fontWeightMedium,
                      ),
                    ),
                    if (fixResult.remainingErrors.isNotEmpty)
                      Text(
                        '剩余错误: ${fixResult.remainingErrors.length}',
                        style: TextStyle(
                          fontSize: NothingTheme.fontSizeCaption,
                          color: NothingTheme.error,
                          fontWeight: NothingTheme.fontWeightMedium,
                        ),
                      ),
                  ],
                ),
              ),

              if (fixResult.fixedIssues.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '已修正的问题:',
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...fixResult.fixedIssues.map(
                  (issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: NothingTheme.successGreen,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            issue,
                            style: const TextStyle(
                              fontSize: NothingTheme.fontSizeCaption,
                              color: NothingTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (fixResult.remainingErrors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '剩余错误:',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                ...fixResult.remainingErrors.map(
                  (error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: NothingTheme.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            error,
                            style: const TextStyle(
                              fontSize: NothingTheme.fontSizeCaption,
                              color: NothingTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('取消'),
          ),
          if (fixResult.isValid) ...[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('仅应用修正'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.successGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('应用修正并自动分析'),
            ),
          ] else
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.nothingYellow,
                foregroundColor: Colors.white,
              ),
              child: const Text('应用部分修正'),
            ),
        ],
      ),
    );
  }

  /// 导入记录
  Future<void> _importRecords() async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      _showErrorSnackBar('请输入JSON格式的记录文本');
      return;
    }

    // 使用自动分析和导入功能
    final success = await _autoAnalyzeAndImport(content, showProgress: true);

    if (!success) {
      // 如果自动导入失败，尝试传统的导入方式（不带分析）
      await _fallbackImport(content);
    }
  }

  /// 传统导入方式（不带分析）
  Future<void> _fallbackImport(String content) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 首先尝试作为JSON格式解析（支持自动修正）
      final result = JsonPasteParser.parseJsonPaste(content, autoFix: true);

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
          mode: 'json_paste_import',
          isRealtimeAnalysis: false,
          timestamp: record.timestamp,
        );
      }

      _showSuccessSnackBar('成功导入 ${result.successCount} 条记录');

      // 清空输入框
      _clearInput();

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
  void _showWarningDialog(JsonPasteParseResult result) {
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
                  children: result.errors
                      .map(
                        (error) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $error',
                            style: const TextStyle(
                              fontSize: NothingTheme.fontSizeCaption,
                              color: NothingTheme.nothingDarkGray,
                            ),
                          ),
                        ),
                      )
                      .toList(),
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

              // 只导入有效记录（不带分析）
              for (final record in result.records) {
                await HistoryManager.instance.addHistoryWithTimestamp(
                  imagePath: null,
                  result: record.toAIResult(),
                  mode: 'json_paste_import',
                  isRealtimeAnalysis: false,
                  timestamp: record.timestamp,
                );
              }

              _showSuccessSnackBar(
                '成功导入 ${result.successCount} 条记录，跳过 ${result.errorCount} 条错误记录',
              );

              // 清空输入框
              _clearInput();

              widget.onRecordAdded?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NothingTheme.nothingGray,
              foregroundColor: NothingTheme.textPrimary,
            ),
            child: const Text(
              '仅导入',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                fontWeight: NothingTheme.fontWeightMedium,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // 导入有效记录并触发分析
              for (final record in result.records) {
                await HistoryManager.instance.addHistoryWithTimestamp(
                  imagePath: null,
                  result: record.toAIResult(),
                  mode: 'json_paste_import',
                  isRealtimeAnalysis: false,
                  timestamp: record.timestamp,
                );
              }

              _showSuccessSnackBar(
                '成功导入 ${result.successCount} 条记录并开始分析，跳过 ${result.errorCount} 条错误记录',
              );

              // 触发历史分析
              final allHistories = await HistoryManager.instance
                  .getAllHistories();
              if (allHistories.isNotEmpty) {
                _triggerHistoryAnalysis(allHistories);
              }

              // 清空输入框
              _clearInput();

              widget.onRecordAdded?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NothingTheme.successGreen,
              foregroundColor: NothingTheme.nothingWhite,
            ),
            child: const Text(
              '导入并分析',
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
                  Icons.content_paste,
                  color: NothingTheme.nothingYellow,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'JSON粘贴记录导入',
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
                    '支持制表符分隔格式：timestamp\\tcategory\\tconfidence\\treasons',
                    style: TextStyle(
                      fontSize: NothingTheme.fontSizeCaption,
                      color: NothingTheme.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '其中reasons字段为JSON格式，可包含```json包装',
                    style: TextStyle(
                      fontSize: NothingTheme.fontSizeCaption,
                      color: NothingTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: NothingTheme.nothingYellow,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '自动解析JSON内容并生成活动标签',
                        style: TextStyle(
                          fontSize: NothingTheme.fontSizeCaption,
                          color: NothingTheme.textSecondary,
                          fontWeight: NothingTheme.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: NothingTheme.spacingMedium),

            // 工具栏
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste, size: 16),
                  label: const Text('粘贴'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NothingTheme.nothingYellow,
                    foregroundColor: NothingTheme.nothingBlack,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearInput,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('清空'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: NothingTheme.nothingLightGray),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: NothingTheme.spacingMedium),

            // 输入框
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: NothingTheme.nothingLightGray),
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
                  hintText: '请粘贴JSON格式的记录文本...',
                  hintStyle: const TextStyle(color: NothingTheme.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: NothingTheme.spacingMedium),

            // 一键修正按钮区域 - 始终显示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NothingTheme.successGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                border: Border.all(
                  color: NothingTheme.successGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        size: 16,
                        color: NothingTheme.successGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'JSON格式智能修正',
                        style: const TextStyle(
                          fontSize: NothingTheme.fontSizeCaption,
                          fontWeight: NothingTheme.fontWeightMedium,
                          color: NothingTheme.successGreen,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _textController.text.trim().isNotEmpty
                            ? _attemptAutoFix
                            : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          backgroundColor:
                              _textController.text.trim().isNotEmpty
                              ? NothingTheme.successGreen
                              : NothingTheme.nothingDarkGray.withValues(
                                  alpha: 0.3,
                                ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              NothingTheme.radiusSm,
                            ),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '一键修正',
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeCaption,
                            color: _textController.text.trim().isNotEmpty
                                ? Colors.white
                                : NothingTheme.nothingDarkGray.withValues(
                                    alpha: 0.7,
                                  ),
                            fontWeight: NothingTheme.fontWeightMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _textController.text.trim().isEmpty
                        ? '请输入JSON内容后使用智能修正功能'
                        : _validationErrors.isNotEmpty
                        ? '检测到格式问题，点击修正按钮自动修复'
                        : '内容格式正确，可选择性使用修正功能优化格式',
                    style: TextStyle(
                      fontSize: NothingTheme.fontSizeCaption,
                      color: _textController.text.trim().isEmpty
                          ? NothingTheme.nothingDarkGray.withValues(alpha: 0.6)
                          : _validationErrors.isNotEmpty
                          ? NothingTheme.nothingDarkGray
                          : NothingTheme.successGreen.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NothingTheme.spacingMedium),

            // 验证错误显示
            if (_validationErrors.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NothingTheme.nothingDarkGray.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    NothingTheme.radiusMedium,
                  ),
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
                          '发现 ${_validationErrors.length} 个格式错误：',
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
                            children: _validationErrors
                                .map(
                                  (error) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      '• $error',
                                      style: const TextStyle(
                                        fontSize: NothingTheme.fontSizeCaption,
                                        color: NothingTheme.nothingDarkGray,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
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
                  borderRadius: BorderRadius.circular(
                    NothingTheme.radiusMedium,
                  ),
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
                          '预览结果：共 ${_parseResult!.records.length} 条记录',
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
                          children: _parseResult!.records
                              .take(5)
                              .map(
                                (record) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${record.timestamp.toString().substring(0, 19)} - ${record.category} (${(record.confidence * 100).toStringAsFixed(1)}%) [${record.tags.join(', ')}]',
                                    style: const TextStyle(
                                      fontSize: NothingTheme.fontSizeCaption,
                                      color: NothingTheme.textSecondary,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
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
                    onPressed: _textController.text.trim().isEmpty
                        ? null
                        : _previewRecords,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: NothingTheme.nothingLightGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          NothingTheme.radiusMedium,
                        ),
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
                    onPressed:
                        (_isLoading ||
                            _textController.text.trim().isEmpty ||
                            _validationErrors.isNotEmpty)
                        ? null
                        : _importRecords,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NothingTheme.successGreen,
                      foregroundColor: NothingTheme.nothingWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          NothingTheme.radiusMedium,
                        ),
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