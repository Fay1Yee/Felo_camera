import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../ui/camera_screen_io.dart' if (dart.library.html) '../ui/camera_screen_web.dart';

/// AI Camera Interface - Pet Camera Demo专用界面
class AICameraInterface extends StatefulWidget {
  final VoidCallback onClose;
  
  const AICameraInterface({
    super.key,
    required this.onClose,
  });

  @override
  State<AICameraInterface> createState() => _AICameraInterfaceState();
}

class _AICameraInterfaceState extends State<AICameraInterface> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.surface,
      appBar: AppBar(
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: NothingTheme.textPrimary,
          ),
          onPressed: widget.onClose,
        ),
        title: Text(
          'Pet Camera Demo',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: NothingTheme.fontSizeXl,
            fontWeight: NothingTheme.fontWeightSemiBold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 功能介绍卡片
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NothingTheme.brandPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
              border: Border.all(
                color: NothingTheme.brandPrimary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      color: NothingTheme.brandPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI宠物识别与健康分析',
                      style: TextStyle(
                        fontSize: NothingTheme.fontSizeLg,
                        fontWeight: NothingTheme.fontWeightSemiBold,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• 智能识别宠物品种和特征\n• 实时健康状态评估\n• 行为分析和活动追踪\n• 专业的宠物护理建议',
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBase,
                    color: NothingTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          // 启动按钮
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const PetCameraScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NothingTheme.brandPrimary,
                    foregroundColor: NothingTheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '开始宠物拍摄',
                        style: TextStyle(
                          fontSize: NothingTheme.fontSizeLg,
                          fontWeight: NothingTheme.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Pet Camera Screen - 专门用于宠物模式的相机界面
class PetCameraScreen extends StatefulWidget {
  const PetCameraScreen({super.key});

  @override
  State<PetCameraScreen> createState() => _PetCameraScreenState();
}

class _PetCameraScreenState extends State<PetCameraScreen> {
  @override
  Widget build(BuildContext context) {
    // 直接使用CameraScreen，但默认设置为宠物模式
    return const CameraScreen();
  }
}