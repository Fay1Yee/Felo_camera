import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Nothing Phone 3a设备配置
class DeviceConfig {
  // Nothing Phone 3a屏幕规格
  static const double screenWidth = 1080.0;  // 像素宽度
  static const double screenHeight = 2392.0; // 像素高度
  static const double screenDiagonal = 6.77; // 英寸
  static const double aspectRatio = screenWidth / screenHeight; // 约0.45
  
  // 物理尺寸 (毫米)
  static const double physicalWidth = 77.50;   // mm
  static const double physicalHeight = 163.52; // mm
  static const double physicalDepth = 8.35;    // mm
  static const double weight = 201.0;          // g
  
  // 显示特性
  static const double refreshRate = 120.0;     // Hz
  static const double peakBrightness = 3000.0; // nits
  static const double outdoorBrightness = 1300.0; // nits
  
  // 性能优化配置
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB缓存限制
  static const int imageCompressionQuality = 85; // 图片压缩质量
  static const Duration analysisTimeout = Duration(seconds: 30); // 分析超时时间
  
  // 像素密度计算
  static double get pixelDensity {
    final diagonal = math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
    return diagonal / screenDiagonal; // PPI
  }
  
  // 获取适配的UI尺寸
  static Size getAdaptedSize(Size currentSize) {
    final currentAspectRatio = currentSize.width / currentSize.height;
    
    // 如果当前比例与Nothing Phone 3a不匹配，进行适配
    if ((currentAspectRatio - aspectRatio).abs() > 0.01) {
      if (currentAspectRatio > aspectRatio) {
        // 当前屏幕更宽，以高度为准
        return Size(currentSize.height * aspectRatio, currentSize.height);
      } else {
        // 当前屏幕更高，以宽度为准
        return Size(currentSize.width, currentSize.width / aspectRatio);
      }
    }
    
    return currentSize;
  }
  
  // 获取安全区域边距（考虑刘海、圆角等）
  static EdgeInsets getSafeAreaPadding() {
    return const EdgeInsets.only(
      top: 44.0,    // 状态栏高度
      bottom: 34.0, // 导航栏高度（手势导航）
    );
  }
  
  // 判断是否为平板设备
  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;
    // 通常认为最短边大于600dp的设备为平板
    return shortestSide >= 600;
  }
  
  // 获取响应式字体大小
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / DeviceConfig.screenWidth;
    return baseSize * scaleFactor.clamp(0.8, 1.2);
  }
  
  // 获取响应式间距
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / DeviceConfig.screenWidth;
    return baseSpacing * scaleFactor.clamp(0.8, 1.2);
  }
  
  // 检查是否为低端设备（用于性能优化）
  static bool isLowEndDevice() {
    // 基于内存和处理器判断，这里简化为固定值
    // 实际应用中可以通过device_info_plus获取设备信息
    return false; // Nothing Phone 3a是高端设备
  }
  
  // 获取相机预览的最佳分辨率
  static Size getOptimalCameraResolution() {
    return const Size(1920, 1080); // 1080p，平衡质量和性能
  }
}