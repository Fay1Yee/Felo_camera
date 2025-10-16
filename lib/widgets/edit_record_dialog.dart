import 'package:flutter/material.dart';
import '../models/analysis_history.dart';
import '../models/ai_result.dart';
import '../config/nothing_theme.dart';
import '../services/history_manager.dart';
import '../services/history_notifier.dart';

class EditRecordDialog extends StatefulWidget {
  final AnalysisHistory history;

  const EditRecordDialog({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  State<EditRecordDialog> createState() => _EditRecordDialogState();
}

class _EditRecordDialogState extends State<EditRecordDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _summaryController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.history.result.title);
    _contentController = TextEditingController(text: widget.history.result.subInfo ?? '');
    _summaryController = TextEditingController(text: widget.history.result.subInfo ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildContent(),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            Icons.edit,
            color: NothingTheme.accentPrimary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '编辑记录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: NothingTheme.textPrimary,
              ),
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

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _titleController,
          label: '标题',
          maxLines: 1,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _contentController,
          label: '内容',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _summaryController,
          label: '摘要',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildInfoSection(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: NothingTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              borderSide: BorderSide(color: NothingTheme.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              borderSide: BorderSide(color: NothingTheme.accentPrimary),
            ),
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: NothingTheme.gray50,
          ),
          style: TextStyle(
            fontSize: 14,
            color: NothingTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.gray50,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(color: NothingTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '记录信息',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('创建时间', _formatDateTime(widget.history.timestamp)),
          _buildInfoRow('分析模式', widget.history.mode),
          _buildInfoRow('置信度', '${widget.history.result.confidence}%'),
        ],
      ),
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
                fontSize: 12,
                color: NothingTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: NothingTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: NothingTheme.gray300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
              ),
              child: Text(
                '取消',
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.accentPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '保存',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('标题不能为空');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('内容不能为空');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 创建更新后的历史记录
      final updatedHistory = AnalysisHistory(
        id: widget.history.id,
        timestamp: widget.history.timestamp,
        mode: widget.history.mode,
        imagePath: widget.history.imagePath,
        result: AIResult(
          title: _titleController.text.trim(),
          confidence: widget.history.result.confidence,
          subInfo: _contentController.text.trim(),
          bbox: widget.history.result.bbox,
          multipleEvents: widget.history.result.multipleEvents,
        ),
      );

      // 删除原记录并添加新记录来实现更新
      await HistoryManager.instance.deleteHistory(widget.history.id);
      await HistoryManager.instance.addHistoryWithTimestamp(
        result: updatedHistory.result,
        imagePath: updatedHistory.imagePath,
        mode: updatedHistory.mode,
        isRealtimeAnalysis: updatedHistory.isRealtimeAnalysis,
        timestamp: updatedHistory.timestamp,
      );

      // 通知更新
      HistoryNotifier.instance.notifyHistoryUpdated(updatedHistory);

      if (mounted) {
        Navigator.of(context).pop(updatedHistory);
        _showSuccessSnackBar('记录已保存');
      }
    } catch (e) {
      debugPrint('保存记录失败: $e');
      _showErrorSnackBar('保存失败，请重试');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}