// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/ai_result.dart';
import '../models/mode.dart';
import '../services/api_client.dart';
import '../config/device_config.dart';
import '../config/nothing_theme.dart';
import 'overlay/top_tag.dart';
import 'overlay/yellow_frame_painter.dart';
import 'bottom_bar.dart';
import 'overlay/travel_box_painter.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final bool _isInitialized = true; // Web: 直接初始化为 true
  bool _isTakingPicture = false;

  Mode _mode = Mode.normal;
  AIResult? _result;

  final _apiClient = ApiClient.instance;

  Future<void> _takePicture() async {
    if (_isTakingPicture) return; // 防抖
    setState(() => _isTakingPicture = true);

    try {
      // Web版本：使用文件选择器上传图片进行分析
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = false;
      input.click();
      await input.onChange.first;
      final file = input.files?.first;
      if (file == null) {
        throw StateError('未选择图片');
      }
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoadEnd.first;
      final bytes = (reader.result as ByteBuffer).asUint8List();
      
      // 远程API分析 - 使用云端AI服务
      // 为Web版本创建临时文件进行分析
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(bytes);
      
      final res = await _apiClient.analyzeImage(tempFile);
      
      // 清理临时文件
      try {
        await tempFile.delete();
      } catch (e) {
        debugPrint('清理临时文件失败: $e');
      }
      
      if (!mounted) return;
      setState(() => _result = res);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('图片上传完成，远程AI分析结果已生成'),
          backgroundColor: NothingTheme.nothingYellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showError('图片分析失败: $e');
      // 使用错误占位符
      if (!mounted) return;
      setState(() => _result = const AIResult(
        title: '分析失败', 
        confidence: 0,
        subInfo: '远程API处理出现问题'
      ));
    } finally {
      if (mounted) {
        setState(() => _isTakingPicture = false);
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: NothingTheme.nothingDarkGray,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pet Camera Demo — Nothing Phone 3a (Web Preview)',
          style: TextStyle(
            color: NothingTheme.nothingBlack,
            fontWeight: NothingTheme.fontWeightMedium,
          ),
        ),
        backgroundColor: NothingTheme.nothingWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: NothingTheme.nothingBlack),
      ),
      backgroundColor: NothingTheme.nothingBlack,
      body: !_isInitialized
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.nothingYellow),
              ),
            )
          : LayoutBuilder(builder: (context, constraints) {
              // 适配Nothing Phone 3a屏幕尺寸
              final adaptedSize = DeviceConfig.getAdaptedSize(
                Size(constraints.maxWidth, constraints.maxHeight)
              );
              
              final aspectRatio = DeviceConfig.aspectRatio; // 使用Nothing Phone 3a的宽高比
              final rect = Rect.fromLTWH(0.1, 0.15, 0.8, 0.7);

              return Center(
                child: SizedBox(
                  width: adaptedSize.width,
                  height: adaptedSize.height,
                  child: Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: Container(color: const Color(0xFF121416)),
                        ),
                      ),
                      // overlay painter
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _mode == Mode.travel
                              ? TravelBoxPainter(mainRect: rect)
                              : YellowFramePainter(
                                  mainRect: rect,
                                  subRect: _mode == Mode.health ? _result?.bbox : null,
                                ),
                        ),
                      ),
                      // top tag
                      if (_result != null)
                        TopTag(
                          result: _result!,
                        ),
                      // bottom bar
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: BottomBar(
                          current: _mode,
                          onModeChanged: (m) => setState(() {
                            _mode = m;
                            _result = null; // 模式切换清空结果
                          }),
                          onShutter: _takePicture,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
    );
  }
}