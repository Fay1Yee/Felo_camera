import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../services/consistency_validator.dart';
import '../../widgets/nothing_card.dart';
import '../../widgets/nothing_button.dart';

/// 数据一致性管理界面
class DataConsistencyScreen extends StatefulWidget {
  const DataConsistencyScreen({super.key});

  @override
  State<DataConsistencyScreen> createState() => _DataConsistencyScreenState();
}

class _DataConsistencyScreenState extends State<DataConsistencyScreen> {
  ConsistencyValidationResult? _validationResult;
  bool _isValidating = false;
  bool _isFixing = false;
  List<String> _fixedIssues = [];

  @override
  void initState() {
    super.initState();
    _validateConsistency();
  }

  /// 执行一致性验证
  Future<void> _validateConsistency() async {
    setState(() {
      _isValidating = true;
    });

    try {
      final result = await ConsistencyValidator.instance.validateConsistency();
      setState(() {
        _validationResult = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('验证失败: $e'),
            backgroundColor: NothingTheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  /// 自动修复问题
  Future<void> _autoFixIssues() async {
    if (_validationResult == null) return;

    setState(() {
      _isFixing = true;
    });

    try {
      final fixableIssues = _validationResult!.issues
          .where((issue) => _isFixableIssue(issue))
          .toList();

      final fixedIds = await ConsistencyValidator.instance.autoFixIssues(fixableIssues);
      
      setState(() {
        _fixedIssues = fixedIds;
      });

      if (fixedIds.isNotEmpty) {
        // 重新验证
        await _validateConsistency();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已修复 ${fixedIds.length} 个问题'),
              backgroundColor: NothingTheme.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('没有可自动修复的问题'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('修复失败: $e'),
            backgroundColor: NothingTheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isFixing = false;
      });
    }
  }

  /// 判断问题是否可自动修复
  bool _isFixableIssue(ConsistencyIssue issue) {
    return issue.type == ConsistencyIssueType.duplicateRecord ||
           issue.type == ConsistencyIssueType.invalidData ||
           issue.type == ConsistencyIssueType.missingAssociation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        title: const Text('数据一致性'),
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isValidating ? null : _validateConsistency,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isValidating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: NothingTheme.brandPrimary,
            ),
            SizedBox(height: NothingTheme.spacingMedium),
            Text(
              '正在验证数据一致性...',
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: NothingTheme.fontSizeBase,
              ),
            ),
          ],
        ),
      );
    }

    if (_validationResult == null) {
      return const Center(
        child: Text(
          '验证结果不可用',
          style: TextStyle(
            color: NothingTheme.textSecondary,
            fontSize: NothingTheme.fontSizeBase,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(NothingTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(),
          const SizedBox(height: NothingTheme.spacingMedium),
          _buildMetricsCard(),
          const SizedBox(height: NothingTheme.spacingMedium),
          _buildIssuesCard(),
          const SizedBox(height: NothingTheme.spacingMedium),
          _buildActionsCard(),
        ],
      ),
    );
  }

  /// 构建概览卡片
  Widget _buildOverviewCard() {
    final result = _validationResult!;
    
    return NothingCard(
      child: Padding(
        padding: const EdgeInsets.all(NothingTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isValid ? Icons.check_circle : Icons.error,
                  color: result.isValid ? NothingTheme.success : NothingTheme.error,
                  size: 24,
                ),
                const SizedBox(width: NothingTheme.spacingSmall),
                Text(
                  result.isValid ? '数据一致性良好' : '发现一致性问题',
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeLg,
                    fontWeight: NothingTheme.fontWeightSemiBold,
                    color: NothingTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: NothingTheme.spacingMedium),
            
            // 一致性评分
            Row(
              children: [
                const Text(
                  '一致性评分: ',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBase,
                    color: NothingTheme.textSecondary,
                  ),
                ),
                Text(
                  '${(result.consistencyScore * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBase,
                    fontWeight: NothingTheme.fontWeightSemiBold,
                    color: _getScoreColor(result.consistencyScore),
                  ),
                ),
              ],
            ),
            const SizedBox(height: NothingTheme.spacingSmall),
            
            // 评分进度条
            LinearProgressIndicator(
              value: result.consistencyScore,
              backgroundColor: NothingTheme.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(result.consistencyScore),
              ),
            ),
            const SizedBox(height: NothingTheme.spacingMedium),
            
            Text(
              '验证时间: ${_formatDateTime(result.validatedAt)}',
              style: const TextStyle(
                fontSize: NothingTheme.fontSizeSm,
                color: NothingTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建指标卡片
  Widget _buildMetricsCard() {
    final metrics = _validationResult!.metrics;
    
    return NothingCard(
      child: Padding(
        padding: const EdgeInsets.all(NothingTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '数据统计',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeLg,
                fontWeight: NothingTheme.fontWeightSemiBold,
                color: NothingTheme.textPrimary,
              ),
            ),
            const SizedBox(height: NothingTheme.spacingMedium),
            
            _buildMetricRow('分析历史记录', '${metrics['totalAnalysisHistories']}'),
            _buildMetricRow('生活记录', '${metrics['totalLifeRecords']}'),
            _buildMetricRow('关联记录', '${metrics['totalAssociations']}'),
            _buildMetricRow('关联覆盖率', '${(metrics['associationCoverage'] * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('平均分析置信度', '${metrics['averageAnalysisConfidence'].toStringAsFixed(1)}%'),
            _buildMetricRow('平均关联置信度', '${(metrics['averageAssociationConfidence'] * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  /// 构建指标行
  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              color: NothingTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建问题卡片
  Widget _buildIssuesCard() {
    final issues = _validationResult!.issues;
    
    if (issues.isEmpty) {
      return NothingCard(
        child: Padding(
          padding: const EdgeInsets.all(NothingTheme.spacingMedium),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: NothingTheme.success,
                size: 24,
              ),
              const SizedBox(width: NothingTheme.spacingSmall),
              const Text(
                '未发现一致性问题',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeBase,
                  color: NothingTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return NothingCard(
      child: Padding(
        padding: const EdgeInsets.all(NothingTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '一致性问题',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeLg,
                    fontWeight: NothingTheme.fontWeightSemiBold,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                Text(
                  '${issues.length} 个问题',
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeBase,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: NothingTheme.spacingMedium),
            
            // 按严重程度分组显示问题
            ...issues.map((issue) => _buildIssueItem(issue)),
          ],
        ),
      ),
    );
  }

  /// 构建问题项
  Widget _buildIssueItem(ConsistencyIssue issue) {
    final isFixed = _fixedIssues.contains(issue.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: NothingTheme.spacingSmall),
      padding: const EdgeInsets.all(NothingTheme.spacingSmall),
      decoration: BoxDecoration(
        color: isFixed ? NothingTheme.brandSecondary : NothingTheme.gray100,
        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
        border: Border.all(
          color: isFixed ? NothingTheme.brandPrimary : _getSeverityColor(issue.severity),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSeverityIcon(issue.severity),
                color: _getSeverityColor(issue.severity),
                size: 16,
              ),
              const SizedBox(width: NothingTheme.spacingXSmall),
              Expanded(
                child: Text(
                  issue.title,
                  style: const TextStyle(
                    fontSize: NothingTheme.fontSizeBase,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.textPrimary,
                  ),
                ),
              ),
              if (isFixed)
                const Icon(
                  Icons.check_circle,
                  color: NothingTheme.success,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: NothingTheme.spacingXSmall),
          Text(
            issue.description,
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeSm,
              color: NothingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingXSmall),
          Text(
            '建议: ${issue.recommendation}',
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeSm,
              color: NothingTheme.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作卡片
  Widget _buildActionsCard() {
    final hasFixableIssues = _validationResult!.issues.any(_isFixableIssue);
    
    return NothingCard(
      child: Padding(
        padding: const EdgeInsets.all(NothingTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '操作',
              style: TextStyle(
                fontSize: NothingTheme.fontSizeLg,
                fontWeight: NothingTheme.fontWeightSemiBold,
                color: NothingTheme.textPrimary,
              ),
            ),
            const SizedBox(height: NothingTheme.spacingMedium),
            
            Row(
              children: [
                Expanded(
                  child: NothingButton(
                    text: '重新验证',
                    onPressed: _isValidating ? null : _validateConsistency,
                    type: NothingButtonType.secondary,
                  ),
                ),
                const SizedBox(width: NothingTheme.spacingSmall),
                Expanded(
                  child: NothingButton(
                    text: _isFixing ? '修复中...' : '自动修复',
                    onPressed: hasFixableIssues && !_isFixing ? _autoFixIssues : null,
                    type: NothingButtonType.primary,
                  ),
                ),
              ],
            ),
            
            if (hasFixableIssues) ...[
              const SizedBox(height: NothingTheme.spacingSmall),
              Text(
                '可自动修复 ${_validationResult!.issues.where(_isFixableIssue).length} 个问题',
                style: const TextStyle(
                  fontSize: NothingTheme.fontSizeSm,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 获取评分颜色
  Color _getScoreColor(double score) {
    if (score >= 0.8) return NothingTheme.success;
    if (score >= 0.6) return NothingTheme.warning;
    return NothingTheme.error;
  }

  /// 获取严重程度颜色
  Color _getSeverityColor(ConsistencyIssueSeverity severity) {
    switch (severity) {
      case ConsistencyIssueSeverity.critical:
        return NothingTheme.error;
      case ConsistencyIssueSeverity.high:
        return NothingTheme.error;
      case ConsistencyIssueSeverity.medium:
        return NothingTheme.warning;
      case ConsistencyIssueSeverity.low:
        return NothingTheme.info;
    }
  }

  /// 获取严重程度图标
  IconData _getSeverityIcon(ConsistencyIssueSeverity severity) {
    switch (severity) {
      case ConsistencyIssueSeverity.critical:
        return Icons.error;
      case ConsistencyIssueSeverity.high:
        return Icons.warning;
      case ConsistencyIssueSeverity.medium:
        return Icons.info;
      case ConsistencyIssueSeverity.low:
        return Icons.info_outline;
    }
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}