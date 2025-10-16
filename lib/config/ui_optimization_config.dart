import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// UI优化配置
/// 集中管理所有性能优化相关的配置
class UIOptimizationConfig {
  // 私有构造函数，防止实例化
  UIOptimizationConfig._();
  
  /// ListView优化配置
  static const listViewConfig = ListViewOptimizationConfig(
    addAutomaticKeepAlives: false,
    addRepaintBoundaries: true,
    cacheExtent: 300.0,
  );
  
  /// GridView优化配置
  static const gridViewConfig = GridViewOptimizationConfig(
    addAutomaticKeepAlives: false,
    addRepaintBoundaries: true,
    cacheExtent: 200.0,
  );
  
  /// 图片优化配置
  static const imageConfig = ImageOptimizationConfig(
    cacheWidth: 300,
    cacheHeight: 300,
    enableMemoryCache: true,
    enableDiskCache: true,
  );
  
  /// 动画优化配置
  static const animationConfig = AnimationOptimizationConfig(
    reducedMotion: false,
    defaultDuration: Duration(milliseconds: 300),
    fastDuration: Duration(milliseconds: 150),
    slowDuration: Duration(milliseconds: 500),
  );
  
  /// 性能监控配置
  static const performanceConfig = PerformanceMonitorConfig(
    enableInDebug: true,
    enableInRelease: false,
    frameHistorySize: 60,
    warningThresholdMs: 32,
    criticalThresholdMs: 48,
  );
  
  /// 是否启用性能优化
  static bool get isOptimizationEnabled => kDebugMode || kProfileMode;
  
  /// 是否启用性能监控
  static bool get isPerformanceMonitorEnabled => 
      kDebugMode && performanceConfig.enableInDebug ||
      kReleaseMode && performanceConfig.enableInRelease;
}

/// ListView优化配置
class ListViewOptimizationConfig {
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final double cacheExtent;
  
  const ListViewOptimizationConfig({
    required this.addAutomaticKeepAlives,
    required this.addRepaintBoundaries,
    required this.cacheExtent,
  });
}

/// GridView优化配置
class GridViewOptimizationConfig {
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final double cacheExtent;
  
  const GridViewOptimizationConfig({
    required this.addAutomaticKeepAlives,
    required this.addRepaintBoundaries,
    required this.cacheExtent,
  });
}

/// 图片优化配置
class ImageOptimizationConfig {
  final int? cacheWidth;
  final int? cacheHeight;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  
  const ImageOptimizationConfig({
    this.cacheWidth,
    this.cacheHeight,
    required this.enableMemoryCache,
    required this.enableDiskCache,
  });
}

/// 动画优化配置
class AnimationOptimizationConfig {
  final bool reducedMotion;
  final Duration defaultDuration;
  final Duration fastDuration;
  final Duration slowDuration;
  
  const AnimationOptimizationConfig({
    required this.reducedMotion,
    required this.defaultDuration,
    required this.fastDuration,
    required this.slowDuration,
  });
}

/// 性能监控配置
class PerformanceMonitorConfig {
  final bool enableInDebug;
  final bool enableInRelease;
  final int frameHistorySize;
  final int warningThresholdMs;
  final int criticalThresholdMs;
  
  const PerformanceMonitorConfig({
    required this.enableInDebug,
    required this.enableInRelease,
    required this.frameHistorySize,
    required this.warningThresholdMs,
    required this.criticalThresholdMs,
  });
}

/// UI优化工具类
class UIOptimizationUtils {
  UIOptimizationUtils._();
  
  /// 创建优化的ListView.builder
  static ListView createOptimizedListView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return ListView.builder(
      key: key,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      addAutomaticKeepAlives: UIOptimizationConfig.listViewConfig.addAutomaticKeepAlives,
      addRepaintBoundaries: UIOptimizationConfig.listViewConfig.addRepaintBoundaries,
      cacheExtent: UIOptimizationConfig.listViewConfig.cacheExtent,
    );
  }
  
  /// 创建优化的GridView.builder
  static GridView createOptimizedGridView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    required SliverGridDelegate gridDelegate,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return GridView.builder(
      key: key,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      gridDelegate: gridDelegate,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      addAutomaticKeepAlives: UIOptimizationConfig.gridViewConfig.addAutomaticKeepAlives,
      addRepaintBoundaries: UIOptimizationConfig.gridViewConfig.addRepaintBoundaries,
      cacheExtent: UIOptimizationConfig.gridViewConfig.cacheExtent,
    );
  }
  
  /// 创建优化的网络图片
  static Widget createOptimizedNetworkImage({
    Key? key,
    required String src,
    double scale = 1.0,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image.network(
      src,
      key: key,
      scale: scale,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
      cacheWidth: UIOptimizationConfig.imageConfig.cacheWidth,
      cacheHeight: UIOptimizationConfig.imageConfig.cacheHeight,
    );
  }
}