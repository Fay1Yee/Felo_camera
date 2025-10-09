import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/camera_screen_io.dart' if (dart.library.html) 'ui/camera_screen_web.dart';
import 'config/nothing_theme.dart';
import 'services/preloader.dart';
import 'services/performance_optimizer.dart';

void main() async {
  // 确保Flutter widgets绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 自定义错误Widget，防止红色错误文字显示
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: NothingTheme.nothingLightGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: NothingTheme.nothingGray,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '加载中...',
              style: TextStyle(
                color: NothingTheme.nothingGray,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  };
  
  // 初始化预加载服务
  await Preloader.instance.initialize();
  
  // 启动性能优化器
  PerformanceOptimizer.instance.startAutoOptimization();
  
  runApp(const PetCameraApp());
}

class PetCameraApp extends StatelessWidget {
  const PetCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Camera Demo — Nothing Phone 3a',
      theme: NothingTheme.lightTheme,
      home: const CameraScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
