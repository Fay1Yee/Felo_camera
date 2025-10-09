import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// 智能图像优化服务
/// 根据图像内容、网络状况和设备性能动态调整压缩参数
class ImageOptimizer {
  static ImageOptimizer? _instance;
  static ImageOptimizer get instance {
    _instance ??= ImageOptimizer._();
    return _instance!;
  }
  
  ImageOptimizer._();
  
  // 压缩配置
  static const int _maxFileSizeBytes = 1 * 1024 * 1024; // 减少到1MB
  static const int _maxDimensionPixels = 1280; // 减少最大尺寸
  static const int _minQuality = 50; // 降低最低质量
  static const int _maxQuality = 85; // 降低最高质量
  
  // 网络状况评估缓存
  NetworkQuality? _cachedNetworkQuality;
  DateTime? _lastNetworkCheck;
  static const Duration _networkCacheTimeout = Duration(minutes: 2);
  
  /// 智能优化图像文件
  Future<File> optimizeImage(File imageFile, {
    String? mode,
    bool forceOptimization = false,
  }) async {
    try {
      debugPrint('🖼️ 开始智能图像优化: ${imageFile.path}');
      
      // 1. 检查文件是否需要优化
      final fileSize = await imageFile.length();
      if (!forceOptimization && fileSize <= _maxFileSizeBytes) {
        debugPrint('✅ 图像文件大小合适，无需优化 (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)');
        return imageFile;
      }
      
      // 2. 读取图像数据
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        debugPrint('❌ 无法解码图像文件');
        return imageFile;
      }
      
      // 3. 分析图像特征
      final imageFeatures = _analyzeImageFeatures(image);
      debugPrint('📊 图像特征分析: ${imageFeatures.toString()}');
      
      // 4. 评估网络质量
      final networkQuality = await _getNetworkQuality();
      debugPrint('📡 网络质量评估: ${networkQuality.toString()}');
      
      // 5. 计算最优压缩参数
      final compressionParams = _calculateOptimalCompression(
        imageFeatures: imageFeatures,
        networkQuality: networkQuality,
        originalSize: fileSize,
        mode: mode,
      );
      debugPrint('⚙️ 压缩参数: ${compressionParams.toString()}');
      
      // 6. 执行图像优化
      final optimizedImage = await _compressImage(
        image,
        compressionParams,
      );
      
      // 7. 保存优化后的图像
      final optimizedFile = await _saveOptimizedImage(
        imageFile,
        optimizedImage,
      );
      
      final optimizedSize = await optimizedFile.length();
      final compressionRatio = (1 - optimizedSize / fileSize) * 100;
      
      debugPrint('✅ 图像优化完成: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB → ${(optimizedSize / 1024 / 1024).toStringAsFixed(1)}MB (压缩${compressionRatio.toStringAsFixed(1)}%)');
      
      return optimizedFile;
      
    } catch (e) {
      debugPrint('❌ 图像优化失败: $e');
      return imageFile; // 返回原文件作为备用
    }
  }
  
  /// 分析图像特征
  ImageFeatures _analyzeImageFeatures(img.Image image) {
    // 计算图像复杂度
    final complexity = _calculateImageComplexity(image);
    
    // 检测是否包含文字
    final hasText = _detectText(image);
    
    // 分析颜色分布
    final colorAnalysis = _analyzeColors(image);
    
    return ImageFeatures(
      width: image.width,
      height: image.height,
      complexity: complexity,
      hasText: hasText,
      colorVariance: colorAnalysis.variance,
      dominantColors: colorAnalysis.dominantColors,
    );
  }
  
  /// 计算图像复杂度（基于边缘检测）
  double _calculateImageComplexity(img.Image image) {
    // 简化的复杂度计算：基于像素变化程度
    int edgeCount = 0;
    int totalPixels = 0;
    
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final current = image.getPixel(x, y);
        final right = image.getPixel(x + 1, y);
        final bottom = image.getPixel(x, y + 1);
        
        // 计算颜色差异
        final diffR = (current.r - right.r).abs() + (current.r - bottom.r).abs();
        final diffG = (current.g - right.g).abs() + (current.g - bottom.g).abs();
        final diffB = (current.b - right.b).abs() + (current.b - bottom.b).abs();
        
        final totalDiff = diffR + diffG + diffB;
        if (totalDiff > 30) { // 阈值可调整
          edgeCount++;
        }
        totalPixels++;
      }
    }
    
    return totalPixels > 0 ? edgeCount / totalPixels : 0.0;
  }
  
  /// 检测图像中是否包含文字（简化版）
  bool _detectText(img.Image image) {
    // 简化的文字检测：基于高对比度区域密度
    int highContrastRegions = 0;
    int totalRegions = 0;
    
    const int blockSize = 16;
    
    for (int y = 0; y < image.height - blockSize; y += blockSize) {
      for (int x = 0; x < image.width - blockSize; x += blockSize) {
        double variance = 0;
        double mean = 0;
        int pixelCount = 0;
        
        // 计算块内像素的亮度方差
        for (int by = y; by < y + blockSize && by < image.height; by++) {
          for (int bx = x; bx < x + blockSize && bx < image.width; bx++) {
            final pixel = image.getPixel(bx, by);
            final brightness = (pixel.r + pixel.g + pixel.b) / 3;
            mean += brightness;
            pixelCount++;
          }
        }
        
        if (pixelCount > 0) {
          mean /= pixelCount;
          
          for (int by = y; by < y + blockSize && by < image.height; by++) {
            for (int bx = x; bx < x + blockSize && bx < image.width; bx++) {
              final pixel = image.getPixel(bx, by);
              final brightness = (pixel.r + pixel.g + pixel.b) / 3;
              variance += math.pow(brightness - mean, 2);
            }
          }
          
          variance /= pixelCount;
          
          if (variance > 2000) { // 高方差可能表示文字
            highContrastRegions++;
          }
        }
        
        totalRegions++;
      }
    }
    
    return totalRegions > 0 && (highContrastRegions / totalRegions) > 0.3;
  }
  
  /// 分析图像颜色分布
  ColorAnalysis _analyzeColors(img.Image image) {
    Map<int, int> colorCounts = {};
    double totalVariance = 0;
    int pixelCount = 0;
    
    // 采样分析（每4个像素采样一个以提高性能）
    for (int y = 0; y < image.height; y += 4) {
      for (int x = 0; x < image.width; x += 4) {
        final pixel = image.getPixel(x, y);
        
        // 量化颜色以减少计算复杂度
        final quantizedColor = _quantizeColor(pixel);
        colorCounts[quantizedColor] = (colorCounts[quantizedColor] ?? 0) + 1;
        
        pixelCount++;
      }
    }
    
    // 计算颜色方差
    final uniqueColors = colorCounts.length;
    final variance = uniqueColors / pixelCount.toDouble();
    
    // 找出主要颜色
    final sortedColors = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final dominantColors = sortedColors.take(5).map((e) => e.key).toList();
    
    return ColorAnalysis(
      variance: variance,
      dominantColors: dominantColors,
    );
  }
  
  /// 量化颜色（减少颜色数量以提高性能）
  int _quantizeColor(img.Pixel pixel) {
    final r = (pixel.r ~/ 32) * 32;
    final g = (pixel.g ~/ 32) * 32;
    final b = (pixel.b ~/ 32) * 32;
    return (r << 16) | (g << 8) | b;
  }
  
  /// 评估网络质量
  Future<NetworkQuality> _getNetworkQuality() async {
    // 检查缓存
    if (_cachedNetworkQuality != null && 
        _lastNetworkCheck != null &&
        DateTime.now().difference(_lastNetworkCheck!) < _networkCacheTimeout) {
      return _cachedNetworkQuality!;
    }
    
    try {
      // 简单的网络质量测试
      final stopwatch = Stopwatch()..start();
      
      await HttpClient()
          .getUrl(Uri.parse('https://www.baidu.com'))
          .timeout(const Duration(seconds: 5))
          .then((request) => request.close());
      
      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;
      
      NetworkQuality quality;
      if (latency < 100) {
        quality = NetworkQuality.excellent;
      } else if (latency < 300) {
        quality = NetworkQuality.good;
      } else if (latency < 800) {
        quality = NetworkQuality.fair;
      } else {
        quality = NetworkQuality.poor;
      }
      
      // 缓存结果
      _cachedNetworkQuality = quality;
      _lastNetworkCheck = DateTime.now();
      
      return quality;
      
    } catch (e) {
      debugPrint('⚠️ 网络质量检测失败: $e');
      return NetworkQuality.poor;
    }
  }
  
  /// 计算最优压缩参数
  CompressionParams _calculateOptimalCompression({
    required ImageFeatures imageFeatures,
    required NetworkQuality networkQuality,
    required int originalSize,
    String? mode,
  }) {
    // 基础质量设置
    int quality = _maxQuality;
    int maxDimension = _maxDimensionPixels;
    
    // 根据网络质量调整
    switch (networkQuality) {
      case NetworkQuality.poor:
        quality = math.max(_minQuality, quality - 25);
        maxDimension = math.min(maxDimension, 1280);
        break;
      case NetworkQuality.fair:
        quality = math.max(_minQuality, quality - 15);
        maxDimension = math.min(maxDimension, 1600);
        break;
      case NetworkQuality.good:
        quality = math.max(_minQuality, quality - 5);
        break;
      case NetworkQuality.excellent:
        // 保持高质量
        break;
    }
    
    // 根据图像特征调整
    if (imageFeatures.hasText) {
      // 包含文字的图像需要更高质量
      quality = math.min(_maxQuality, quality + 10);
    }
    
    if (imageFeatures.complexity > 0.3) {
      // 复杂图像需要更高质量
      quality = math.min(_maxQuality, quality + 5);
    } else if (imageFeatures.complexity < 0.1) {
      // 简单图像可以更大压缩
      quality = math.max(_minQuality, quality - 10);
    }
    
    // 根据分析模式调整
    if (mode == 'health' || mode == 'pet') {
      // 健康和宠物分析需要更高质量
      quality = math.min(_maxQuality, quality + 5);
    }
    
    // 根据原始文件大小调整
    if (originalSize > 10 * 1024 * 1024) { // 10MB以上
      quality = math.max(_minQuality, quality - 15);
      maxDimension = math.min(maxDimension, 1280);
    }
    
    return CompressionParams(
      quality: quality,
      maxDimension: maxDimension,
      format: img.JpegEncoder(),
    );
  }
  
  /// 执行图像压缩
  Future<Uint8List> _compressImage(
    img.Image image,
    CompressionParams params,
  ) async {
    // 调整图像尺寸
    img.Image resizedImage = image;
    
    final maxDim = math.max(image.width, image.height);
    if (maxDim > params.maxDimension) {
      final scale = params.maxDimension / maxDim;
      final newWidth = (image.width * scale).round();
      final newHeight = (image.height * scale).round();
      
      resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic,
      );
    }
    
    // 编码图像
    final encoder = img.JpegEncoder(quality: params.quality);
    return Uint8List.fromList(encoder.encode(resizedImage));
  }
  
  /// 保存优化后的图像
  Future<File> _saveOptimizedImage(File originalFile, Uint8List optimizedBytes) async {
    final directory = originalFile.parent;
    final fileName = originalFile.path.split('/').last;
    final nameWithoutExt = fileName.split('.').first;
    final optimizedPath = '${directory.path}/${nameWithoutExt}_optimized.jpg';
    
    final optimizedFile = File(optimizedPath);
    await optimizedFile.writeAsBytes(optimizedBytes);
    
    return optimizedFile;
  }
}

/// 图像特征分析结果
class ImageFeatures {
  final int width;
  final int height;
  final double complexity;
  final bool hasText;
  final double colorVariance;
  final List<int> dominantColors;
  
  ImageFeatures({
    required this.width,
    required this.height,
    required this.complexity,
    required this.hasText,
    required this.colorVariance,
    required this.dominantColors,
  });
  
  @override
  String toString() {
    return 'ImageFeatures(${width}x${height}, complexity: ${complexity.toStringAsFixed(2)}, hasText: $hasText, colorVariance: ${colorVariance.toStringAsFixed(3)})';
  }
}

/// 颜色分析结果
class ColorAnalysis {
  final double variance;
  final List<int> dominantColors;
  
  ColorAnalysis({
    required this.variance,
    required this.dominantColors,
  });
}

/// 网络质量枚举
enum NetworkQuality {
  excellent,
  good,
  fair,
  poor;
  
  @override
  String toString() {
    switch (this) {
      case NetworkQuality.excellent:
        return '优秀';
      case NetworkQuality.good:
        return '良好';
      case NetworkQuality.fair:
        return '一般';
      case NetworkQuality.poor:
        return '较差';
    }
  }
}

/// 压缩参数
class CompressionParams {
  final int quality;
  final int maxDimension;
  final img.Encoder format;
  
  CompressionParams({
    required this.quality,
    required this.maxDimension,
    required this.format,
  });
  
  @override
  String toString() {
    return 'CompressionParams(quality: $quality, maxDimension: $maxDimension)';
  }
}