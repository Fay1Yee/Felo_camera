import 'package:flutter/material.dart';

class PageTransitions {
  // 淡入淡出过渡
  static Route<T> fadeTransition<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // 滑动过渡（从右到左）
  static Route<T> slideTransition<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // 缩放过渡
  static Route<T> scaleTransition<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: child,
        );
      },
    );
  }

  // 组合过渡（淡入+滑动）
  static Route<T> fadeSlideTransition<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
    Offset begin = const Offset(0.0, 0.3),
    Offset end = Offset.zero,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  // 旋转过渡
  static Route<T> rotationTransition<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: child,
        );
      },
    );
  }

  // 自定义弹性过渡
  static Route<T> elasticTransition<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

// 扩展Navigator类，添加自定义过渡方法
extension NavigatorExtensions on NavigatorState {
  Future<T?> pushWithFadeTransition<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.fadeTransition<T>(page));
  }

  Future<T?> pushWithSlideTransition<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.slideTransition<T>(page));
  }

  Future<T?> pushWithScaleTransition<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.scaleTransition<T>(page));
  }

  Future<T?> pushWithFadeSlideTransition<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.fadeSlideTransition<T>(page));
  }

  Future<T?> pushReplacementWithFadeTransition<T extends Object?, TO extends Object?>(Widget page, {TO? result}) {
    return pushReplacement<T, TO>(PageTransitions.fadeTransition<T>(page), result: result);
  }

  Future<T?> pushReplacementWithSlideTransition<T extends Object?, TO extends Object?>(Widget page, {TO? result}) {
    return pushReplacement<T, TO>(PageTransitions.slideTransition<T>(page), result: result);
  }

  Future<T?> pushReplacementWithFadeSlideTransition<T extends Object?, TO extends Object?>(Widget page, {TO? result}) {
    return pushReplacement<T, TO>(PageTransitions.fadeSlideTransition<T>(page), result: result);
  }
}