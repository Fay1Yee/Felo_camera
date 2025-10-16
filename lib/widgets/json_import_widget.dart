import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/nothing_theme.dart';
import '../models/ai_result.dart';
import '../services/history_manager.dart';

/// JSON格式文本导入功能组件
class JsonImportWidget extends StatefulWidget {
  final VoidCallback? onRecordAdded;
  
  const JsonImportWidget({
    super.key,
    this.onRecordAdded,
  });

  @override
  State<JsonImportWidget> createState() => _JsonImportWidgetState();
}

class _JsonImportWidgetState extends State<JsonImportWidget> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _parsedRecords = [];
  String? _validationError;
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 解析JSON文本
  void _parseJsonText() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parsedRecords = [];
        _validationError = null;
      });
      return;
    }

    try {
      setState(() {
        _validationError = null;
        _parsedRecords = [];
      });

      // 尝试解析多种格式
      final records = _parseMultipleFormats(text);
      
      if (records.isEmpty) {
        setState(() {
          _validationError = '未找到有效的记录格式';
        });
        return;
      }

      // 验证每条记录
      final validRecords = <Map<String, dynamic>>[];
      for (final record in records) {
        final validationResult = _validateRecord(record);
        if (validationResult['isValid']) {
          validRecords.add(validationResult['record']);
        } else {
          setState(() {
            _validationError = validationResult['error'];
          });
          return;
        }
      }

      setState(() {
        _parsedRecords = validRecords;
      });
    } catch (e) {
      setState(() {
        _validationError = '解析失败: $e';
        _parsedRecords = [];
      });
    }
  }

  /// 解析多种格式的文本
  List<Map<String, dynamic>> _parseMultipleFormats(String text) {
    final records = <Map<String, dynamic>>[];
    
    // 格式1: 单行格式 "2025-10-13 19:50:51 no_pet 0.5"
    final singleLinePattern = RegExp(
      r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s+(\w+)\s+([\d.]+)'
    );
    
    // 格式2: JSON格式
    final jsonPattern = RegExp(r'\{[^}]+\}');
    
    final lines = text.split('\n');
    Map<String, dynamic>? currentRecord;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // 尝试匹配单行格式
      final singleLineMatch = singleLinePattern.firstMatch(trimmedLine);
      if (singleLineMatch != null) {
        final timestamp = singleLineMatch.group(1)!;
        final category = singleLineMatch.group(2)!;
        final confidence = double.tryParse(singleLineMatch.group(3)!) ?? 0.0;
        
        currentRecord = {
          'timestamp': timestamp,
          'category': category,
          'confidence': confidence,
          'reasons': '',
        };
        continue;
      }
      
      // 尝试匹配JSON格式
      final jsonMatch = jsonPattern.firstMatch(trimmedLine);
      if (jsonMatch != null) {
        try {
          final jsonData = jsonDecode(jsonMatch.group(0)!);
          if (currentRecord != null) {
            // 合并JSON数据到当前记录
            currentRecord['category'] = jsonData['category'] ?? currentRecord['category'];
            currentRecord['confidence'] = jsonData['confidence'] ?? currentRecord['confidence'];
            currentRecord['reasons'] = jsonData['reasons'] ?? '';
            records.add(Map<String, dynamic>.from(currentRecord));
            currentRecord = null;
          } else {
            // 独立的JSON记录
            records.add({
              'timestamp': jsonData['timestamp'] ?? DateTime.now().toString(),
              'category': jsonData['category'] ?? 'unknown',
              'confidence': jsonData['confidence'] ?? 0.0,
              'reasons': jsonData['reasons'] ?? '',
            });
          }
        } catch (e) {
          // JSON解析失败，忽略这行
          continue;
        }
      }
    }
    
    // 如果有未完成的记录，添加到结果中
    if (currentRecord != null) {
      records.add(currentRecord);
    }
    
    return records;
  }

  /// 验证单条记录
  Map<String, dynamic> _validateRecord(Map<String, dynamic> record) {
    try {
      // 验证时间戳
      DateTime? timestamp;
      final timestampStr = record['timestamp']?.toString();
      if (timestampStr != null) {
        try {
          // 尝试多种时间格式
          timestamp = DateTime.tryParse(timestampStr) ??
                     DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(timestampStr) ??
                     DateFormat('yyyy-MM-dd').tryParse(timestampStr);
        } catch (e) {
          // 时间解析失败，使用当前时间
          timestamp = DateTime.now();
        }
      }
      timestamp ??= DateTime.now();

      // 验证分类
      final category = record['category']?.toString() ?? 'unknown';
      if (category.isEmpty) {
        return {
          'isValid': false,
          'error': '分类不能为空',
        };
      }

      // 验证置信度
      double confidence = 0.0;
      final confidenceValue = record['confidence'];
      if (confidenceValue is num) {
        confidence = confidenceValue.toDouble();
      } else if (confidenceValue is String) {
        confidence = double.tryParse(confidenceValue) ?? 0.0;
      }
      
      // 置信度范围检查
      if (confidence < 0.0 || confidence > 1.0) {
        confidence = confidence.clamp(0.0, 1.0);
      }

      // 验证原因描述
      final reasons = record['reasons']?.toString() ?? '';

      return {
        'isValid': true,
        'record': {
          'timestamp': timestamp,
          'category': category,
          'confidence': confidence,
          'reasons': reasons,
        },
      };
    } catch (e) {
      return {
        'isValid': false,
        'error': '记录验证失败: $e',
      };
    }
  }

  /// 导入记录
  Future<void> _importRecords() async {
    if (_parsedRecords.isEmpty) {
      _showErrorSnackBar('没有有效的记录可导入');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int successCount = 0;
      
      for (final record in _parsedRecords) {
        final category = record['category'] as String;
        final confidence = record['confidence'] as double;
        final reasons = record['reasons'] as String;

        // 创建AI结果对象
        final aiResult = AIResult(
          title: _getCategoryDisplayName(category),
          confidence: (confidence * 100).round(),
          subInfo: reasons.isNotEmpty ? reasons : null,
        );

        // 添加到历史记录
        await HistoryManager.instance.addHistory(
          result: aiResult,
          mode: 'json_import',
          imagePath: null,
          isRealtimeAnalysis: false,
        );

        successCount++;
      }

      // 清空输入
      setState(() {
        _textController.clear();
        _parsedRecords = [];
        _validationError = null;
      });

      // 通知父组件
      widget.onRecordAdded?.call();

      _showSuccessSnackBar('成功导入 $successCount 条记录');
    } catch (e) {
      _showErrorSnackBar('导入记录失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取分类显示名称
  String _getCategoryDisplayName(String category) {
    const categoryMap = {
      'no_pet': '无宠物',
      'cat': '猫咪',
      'dog': '狗狗',
      'pet': '宠物',
      'unknown': '未知',
      'manual_record': '手动记录',
    };
    return categoryMap[category] ?? category;
  }

  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: NothingTheme.nothingWhite,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示成功提示
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: NothingTheme.nothingWhite,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: NothingTheme.nothingWhite,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NothingTheme.spacingLarge),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
        border: Border.all(
          color: NothingTheme.gray200,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.upload_file_outlined,
                color: NothingTheme.nothingYellow,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'JSON格式导入',
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
                Text(
                  '支持格式示例:',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '2025-10-13 19:50:51 no_pet 0.5\n{"category": "无宠物", "confidence": 1.0, "reasons": "在提供的图像中未检测到猫的存在..."}',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeCaption,
                    color: NothingTheme.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: NothingTheme.spacingLarge),

          // 文本输入区域
          Text(
            'JSON文本内容',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBody,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 8,
            onChanged: (_) => _parseJsonText(),
            decoration: InputDecoration(
              hintText: '请粘贴JSON格式的文本内容...',
              hintStyle: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: NothingTheme.fontSizeBody,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                borderSide: BorderSide(
                  color: NothingTheme.gray200,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                borderSide: BorderSide(
                  color: NothingTheme.gray200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                borderSide: BorderSide(
                  color: NothingTheme.nothingYellow,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                borderSide: BorderSide(
                  color: NothingTheme.error,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: NothingTheme.surface,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBody,
              color: NothingTheme.textPrimary,
              fontFamily: 'monospace',
            ),
          ),
          
          // 验证错误提示
          if (_validationError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NothingTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                border: Border.all(
                  color: NothingTheme.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: NothingTheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationError!,
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeCaption,
                        color: NothingTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 解析结果预览
          if (_parsedRecords.isNotEmpty) ...[
            const SizedBox(height: NothingTheme.spacingLarge),
            Text(
              '解析结果预览 (${_parsedRecords.length} 条记录)',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBody,
                fontWeight: NothingTheme.fontWeightMedium,
                color: NothingTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: NothingTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                border: Border.all(
                  color: NothingTheme.gray200,
                  width: 1,
                ),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _parsedRecords.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final record = _parsedRecords[index];
                  final timestamp = record['timestamp'] as DateTime;
                  final category = record['category'] as String;
                  final confidence = record['confidence'] as double;
                  final reasons = record['reasons'] as String;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp),
                            style: TextStyle(
                              fontSize: NothingTheme.fontSizeCaption,
                              color: NothingTheme.textSecondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: NothingTheme.nothingYellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(confidence * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: NothingTheme.fontSizeCaption,
                                color: NothingTheme.textPrimary,
                                fontWeight: NothingTheme.fontWeightMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCategoryDisplayName(category),
                        style: TextStyle(
                          fontSize: NothingTheme.fontSizeBody,
                          fontWeight: NothingTheme.fontWeightMedium,
                          color: NothingTheme.textPrimary,
                        ),
                      ),
                      if (reasons.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          reasons,
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeCaption,
                            color: NothingTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: NothingTheme.spacingLarge),

          // 导入按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isLoading || _parsedRecords.isEmpty || _validationError != null) 
                  ? null 
                  : _importRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.nothingYellow,
                foregroundColor: NothingTheme.nothingBlack,
                disabledBackgroundColor: NothingTheme.gray200,
                disabledForegroundColor: NothingTheme.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              NothingTheme.nothingBlack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '导入中...',
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeBody,
                            fontWeight: NothingTheme.fontWeightMedium,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _parsedRecords.isEmpty 
                              ? '请输入有效的JSON格式文本' 
                              : '导入 ${_parsedRecords.length} 条记录',
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeBody,
                            fontWeight: NothingTheme.fontWeightMedium,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}