import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/analysis_history.dart';

class RecordDetailDialog extends StatelessWidget {
  final AnalysisHistory record;
  final String behaviorLabel;

  const RecordDetailDialog({
    super.key,
    required this.record,
    required this.behaviorLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: NothingTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 20),
                    _buildInfoSection(),
                    const SizedBox(height: 20),
                    _buildAnalysisSection(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.gray50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(NothingTheme.radiusLg),
          topRight: Radius.circular(NothingTheme.radiusLg),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.pets,
            color: NothingTheme.accentPrimary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  behaviorLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                Text(
                  _formatDateTime(record.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: NothingTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: NothingTheme.gray100,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(
          color: NothingTheme.gray200,
          width: 1,
        ),
      ),
      child: record.imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              child: Image.network(
                record.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: NothingTheme.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            '暂无图片',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基本信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('记录时间', _formatDateTime(record.timestamp)),
        _buildInfoRow('分析模式', record.mode),
        _buildInfoRow('置信度', '${record.result.confidence}%'),
        _buildInfoRow('实时分析', record.isRealtimeAnalysis ? '是' : '否'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: NothingTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: NothingTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI分析结果',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NothingTheme.gray50,
            borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
            border: Border.all(
              color: NothingTheme.gray200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '分析标题: ${record.result.title}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NothingTheme.textPrimary,
                ),
              ),
              if (record.result.subInfo != null) ...[
                const SizedBox(height: 8),
                Text(
                  '详细信息: ${record.result.subInfo}',
                  style: TextStyle(
                    fontSize: 14,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.gray50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(NothingTheme.radiusLg),
          bottomRight: Radius.circular(NothingTheme.radiusLg),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: NothingTheme.gray300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
              ),
              child: Text(
                '关闭',
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: 实现编辑功能
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.accentPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
              ),
              child: const Text(
                '编辑记录',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}