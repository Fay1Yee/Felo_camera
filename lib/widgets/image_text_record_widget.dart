import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../config/nothing_theme.dart';
import '../models/ai_result.dart';
import '../services/history_manager.dart';

/// 图片+文字记录功能组件
class ImageTextRecordWidget extends StatefulWidget {
  final VoidCallback? onRecordAdded;
  
  const ImageTextRecordWidget({
    super.key,
    this.onRecordAdded,
  });

  @override
  State<ImageTextRecordWidget> createState() => _ImageTextRecordWidgetState();
}

class _ImageTextRecordWidgetState extends State<ImageTextRecordWidget> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 选择图片
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('选择图片失败: $e');
    }
  }

  /// 拍照
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('拍照失败: $e');
    }
  }

  /// 保存记录
  Future<void> _saveRecord() async {
    if (_selectedImage == null && _textController.text.trim().isEmpty) {
      _showErrorSnackBar('请至少添加图片或文字内容');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? savedImagePath;
      
      // 保存图片到应用目录
      if (_selectedImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${directory.path}/images');
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        
        final fileName = 'manual_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${imagesDir.path}/$fileName');
        await _selectedImage!.copy(savedImage.path);
        savedImagePath = savedImage.path;
      }

      // 创建AI结果对象
      final aiResult = AIResult(
        title: '手动记录',
        confidence: 100,
        subInfo: _textController.text.trim().isNotEmpty 
            ? _textController.text.trim() 
            : '图片记录',
      );

      // 添加到历史记录
      await HistoryManager.instance.addHistory(
        result: aiResult,
        mode: 'manual_record',
        imagePath: savedImagePath,
        isRealtimeAnalysis: false,
      );

      // 清空输入
      setState(() {
        _selectedImage = null;
        _textController.clear();
      });

      // 通知父组件
      widget.onRecordAdded?.call();

      _showSuccessSnackBar('记录保存成功');
    } catch (e) {
      _showErrorSnackBar('保存记录失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                Icons.add_photo_alternate_outlined,
                color: NothingTheme.nothingYellow,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '图片+文字记录',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeHeadline,
                  fontWeight: NothingTheme.fontWeightBold,
                  color: NothingTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: NothingTheme.spacingLarge),

          // 图片选择区域
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: _selectedImage != null 
                  ? Colors.transparent 
                  : NothingTheme.nothingLightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              border: Border.all(
                color: NothingTheme.gray200,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(NothingTheme.radiusMedium - 2),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: NothingTheme.nothingBlack.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.close,
                              color: NothingTheme.nothingWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: NothingTheme.nothingGray,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '点击添加图片',
                        style: TextStyle(
                          fontSize: NothingTheme.fontSizeBody,
                          color: NothingTheme.textSecondary,
                          fontWeight: NothingTheme.fontWeightMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.photo_library_outlined, size: 18),
                            label: Text('相册'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NothingTheme.nothingYellow,
                              foregroundColor: NothingTheme.nothingBlack,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: Icon(Icons.camera_alt_outlined, size: 18),
                            label: Text('拍照'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NothingTheme.surface,
                              foregroundColor: NothingTheme.textPrimary,
                              side: BorderSide(
                                color: NothingTheme.gray200,
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: NothingTheme.spacingLarge),

          // 文字输入区域
          Text(
            '描述文字',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBody,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '请输入描述文字（可选）',
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
              filled: true,
              fillColor: NothingTheme.surface,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBody,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingLarge),

          // 保存按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.nothingYellow,
                foregroundColor: NothingTheme.nothingBlack,
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
                          '保存中...',
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
                        Icon(Icons.save_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '保存记录',
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