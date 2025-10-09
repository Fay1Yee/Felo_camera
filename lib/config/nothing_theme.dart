import 'package:flutter/material.dart';

/// Nothing Phone OS 设计规范主题配置
/// 采用白色主色调，黄色强调色，灰色辅助色的三色配色方案
class NothingTheme {
  // 主色调 - 白色系
  static const Color nothingWhite = Color(0xFFFFFFFF);
  static const Color nothingOffWhite = Color(0xFFFAFAFA);
  static const Color nothingLightGray = Color(0xFFF2F2F7);
  
  // 强调色 - 黄色系
  static const Color nothingYellow = Color(0xFFFFD54A);
  static const Color nothingYellowLight = Color(0xFFFFE082);
  static const Color nothingYellowDark = Color(0xFFFFB300);
  
  // 辅助色 - 灰色系
  static const Color nothingGray = Color(0xFF8E8E93);
  static const Color nothingDarkGray = Color(0xFF1C1C1E);
  static const Color nothingMediumGray = Color(0xFF48484A);
  static const Color nothingBlack = Color(0xFF000000);
  
  // 功能性颜色 - 基于主配色方案调整
  static const Color successGreen = Color(0xFF34C759);
  static const Color warningOrange = Color(0xFFFF9500);
  static const Color errorRed = Color(0xFFFF3B30);
  static const Color infoBlue = Color(0xFF007AFF);
  
  // 透明度变体 - 白色系
  static const Color whiteAlpha10 = Color(0x1AFFFFFF);
  static const Color whiteAlpha20 = Color(0x33FFFFFF);
  static const Color whiteAlpha30 = Color(0x4DFFFFFF);
  static const Color whiteAlpha50 = Color(0x80FFFFFF);
  static const Color whiteAlpha70 = Color(0xB3FFFFFF);
  static const Color whiteAlpha90 = Color(0xE6FFFFFF);
  
  // 透明度变体 - 黄色系
  static const Color yellowAlpha10 = Color(0x1AFFD54A);
  static const Color yellowAlpha20 = Color(0x33FFD54A);
  static const Color yellowAlpha30 = Color(0x4DFFD54A);
  static const Color yellowAlpha50 = Color(0x80FFD54A);
  static const Color yellowAlpha60 = Color(0x99FFD54A);
  static const Color yellowAlpha70 = Color(0xB3FFD54A);
  
  // 透明度变体 - 灰色系
  static const Color grayAlpha10 = Color(0x1A8E8E93);
  static const Color grayAlpha20 = Color(0x338E8E93);
  static const Color grayAlpha30 = Color(0x4D8E8E93);
  static const Color grayAlpha50 = Color(0x808E8E93);
  static const Color grayAlpha80 = Color(0xCC8E8E93);
  
  // 透明度变体 - 黑色系
  static const Color blackAlpha05 = Color(0x0D000000);
  static const Color blackAlpha10 = Color(0x1A000000);
  static const Color blackAlpha20 = Color(0x33000000);
  static const Color blackAlpha30 = Color(0x4D000000);
  static const Color blackAlpha50 = Color(0x80000000);
  static const Color blackAlpha70 = Color(0xB3000000);
  static const Color blackAlpha90 = Color(0xE6000000);
  
  // 渐变色 - 基于三色配色方案
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [nothingWhite, nothingOffWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [nothingYellowLight, nothingYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient neutralGradient = LinearGradient(
    colors: [nothingLightGray, nothingGray],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // 阴影
  static const List<BoxShadow> nothingShadow = [
    BoxShadow(
      color: blackAlpha10,
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> nothingElevatedShadow = [
    BoxShadow(
      color: blackAlpha20,
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  // 圆角半径
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // 间距
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;
  
  // 字体大小
  static const double fontSizeCaption = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeSubheading = 16.0;
  static const double fontSizeSubtitle = 16.0;
  static const double fontSizeTitle = 18.0;
  static const double fontSizeHeadline = 24.0;
  static const double fontSizeDisplay = 32.0;
  
  // 字体权重
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  /// 获取Nothing OS主题数据
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // 颜色方案
      colorScheme: const ColorScheme.light(
        primary: nothingYellow,
        onPrimary: nothingBlack,
        secondary: nothingGray,
        onSecondary: nothingWhite,
        surface: nothingWhite,
        onSurface: nothingBlack,
        background: nothingLightGray,
        onBackground: nothingBlack,
        error: errorRed,
        onError: nothingWhite,
      ),
      
      // 脚手架背景
      scaffoldBackgroundColor: nothingWhite,
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: nothingWhite,
        foregroundColor: nothingBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: nothingBlack,
          fontSize: fontSizeTitle,
          fontWeight: fontWeightSemiBold,
        ),
        iconTheme: IconThemeData(
          color: nothingBlack,
          size: 24,
        ),
      ),
      
      // 卡片主题
      cardTheme: const CardThemeData(
        color: nothingWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          side: BorderSide(
            color: nothingLightGray,
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(spacingSmall),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: nothingYellow,
          foregroundColor: nothingBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeBody,
            fontWeight: fontWeightMedium,
          ),
        ),
      ),
      
      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: nothingBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeBody,
            fontWeight: fontWeightMedium,
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: nothingLightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: nothingYellow,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
      ),
      
      // 文本主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeDisplay,
          fontWeight: fontWeightBold,
          color: nothingBlack,
        ),
        headlineLarge: TextStyle(
          fontSize: fontSizeHeadline,
          fontWeight: fontWeightSemiBold,
          color: nothingBlack,
        ),
        titleLarge: TextStyle(
          fontSize: fontSizeTitle,
          fontWeight: fontWeightMedium,
          color: nothingBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeBody,
          fontWeight: fontWeightRegular,
          color: nothingBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeBody,
          fontWeight: fontWeightRegular,
          color: nothingGray,
        ),
        labelLarge: TextStyle(
          fontSize: fontSizeCaption,
          fontWeight: fontWeightMedium,
          color: nothingGray,
        ),
      ),
      
      // 图标主题
      iconTheme: const IconThemeData(
        color: nothingBlack,
        size: 24,
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: nothingLightGray,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  /// 获取自定义组件样式
  static BoxDecoration get nothingCardDecoration {
    return BoxDecoration(
      color: nothingWhite,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: nothingShadow,
      border: Border.all(
        color: nothingLightGray,
        width: 1,
      ),
    );
  }
  
  static BoxDecoration get nothingElevatedCardDecoration {
    return BoxDecoration(
      color: nothingWhite,
      borderRadius: BorderRadius.circular(radiusLarge),
      boxShadow: nothingElevatedShadow,
    );
  }
  
  static BoxDecoration get nothingYellowCardDecoration {
    return BoxDecoration(
      gradient: primaryGradient,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: nothingShadow,
    );
  }
  
  /// 获取Nothing OS风格的按钮样式
  static ButtonStyle get nothingPrimaryButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: nothingYellow,
      foregroundColor: nothingBlack,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacingLarge,
        vertical: spacingMedium,
      ),
    );
  }
  
  static ButtonStyle get nothingSecondaryButtonStyle {
    return OutlinedButton.styleFrom(
      foregroundColor: nothingBlack,
      side: const BorderSide(color: nothingLightGray, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacingLarge,
        vertical: spacingMedium,
      ),
    );
  }

  /// Nothing OS 点阵设计元素
  static const double dotSize = 2.0;
  static const double dotSpacing = 8.0;
  
  /// 获取点阵装饰
  static BoxDecoration get nothingDotMatrixDecoration {
    return BoxDecoration(
      color: nothingWhite,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: nothingShadow,
      border: Border.all(
        color: nothingLightGray,
        width: 1,
      ),
    );
  }
  
  /// 获取线性装饰
  static BoxDecoration get nothingLinearDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          nothingWhite,
          nothingLightGray.withValues(alpha: 0.3),
          nothingWhite,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: nothingShadow,
    );
  }
  
  /// 获取几何图案装饰
  static BoxDecoration get nothingGeometricDecoration {
    return BoxDecoration(
      color: nothingWhite,
      borderRadius: BorderRadius.circular(radiusLarge),
      boxShadow: nothingElevatedShadow,
      border: Border.all(
        color: nothingYellow.withValues(alpha: 0.2),
        width: 2,
      ),
    );
  }
  
  /// Nothing OS 特色渐变
  static const LinearGradient nothingAccentGradient = LinearGradient(
    colors: [
      Color(0xFFFFE082),
      Color(0xFFFFD54A),
      Color(0xFFFFC107),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient nothingSubtleGradient = LinearGradient(
    colors: [
      Color(0xFFFAFAFA),
      Color(0xFFF5F5F5),
      Color(0xFFEEEEEE),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}