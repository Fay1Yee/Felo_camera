import 'package:flutter/material.dart';

/// Nothing Phone OS 设计规范主题配置
/// 基于Design System Foundations的配色方案和设计令牌
/// 采用米白背景、亮黄强调、墨绿辅助的极简配色方案
class NothingTheme {
  // === 品牌色彩 ===
  // 主色调 - 亮黄系 (Brand Colors)
  static const Color brandPrimary = Color(0xFFFFD84D);     // 明亮黄 - 按钮、提示
  static const Color brandSecondary = Color(0xFFFFFBEA);   // 极浅黄 - 卡片背景
  static const Color brandAccent = Color(0xFFF5C842);      // 柔和黄 - hover状态
  
  // 辅助色 - 墨绿系 (Accent Colors)
  static const Color accentPrimary = Color(0xFF2F5233);    // 墨绿色 - 重要信息
  static const Color accentSecondary = Color(0xFFEDF7ED);  // 极浅绿色 - 背景
  static const Color accentTertiary = Color(0xFF66BB6A);   // 柔和绿 - 成功状态
  
  // === 中性色系 ===
  // 灰度系统 - 冷色调中性 (Neutral Gray Scale)
  static const Color gray50 = Color(0xFFFAFAFA);   // 极浅灰 - 主背景
  static const Color gray100 = Color(0xFFF5F5F5);  // 浅灰 - 次级背景
  static const Color gray200 = Color(0xFFEEEEEE);  // 浅灰 - 分隔线
  static const Color gray300 = Color(0xFFE0E0E0);  // 中浅灰 - 边框
  static const Color gray400 = Color(0xFFBDBDBD);  // 中灰 - 图标
  static const Color gray500 = Color(0xFF9E9E9E);  // 中深灰 - 次要文字
  static const Color gray600 = Color(0xFF757575);  // 深灰 - 文字
  static const Color gray700 = Color(0xFF616161);  // 更深灰
  static const Color gray800 = Color(0xFF424242);  // 最深灰 - 主文字
  static const Color gray900 = Color(0xFF212121);  // 黑色
  
  // 透明度黑白色 (Alpha Black/White Colors)
  static const Color blackAlpha05 = Color(0x0D000000);  // 5% 透明度黑色
  static const Color blackAlpha10 = Color(0x1A000000);  // 10% 透明度黑色
  static const Color blackAlpha20 = Color(0x33000000);  // 20% 透明度黑色
  static const Color blackAlpha30 = Color(0x4D000000);  // 30% 透明度黑色
  static const Color blackAlpha70 = Color(0xB3000000);  // 70% 透明度黑色
  static const Color blackAlpha90 = Color(0xE6000000);  // 90% 透明度黑色
  static const Color whiteAlpha10 = Color(0x1AFFFFFF);  // 10% 透明度白色
  static const Color whiteAlpha20 = Color(0x33FFFFFF);  // 20% 透明度白色
  static const Color whiteAlpha90 = Color(0xE6FFFFFF);  // 90% 透明度白色
  
  // 透明度灰色 (Alpha Gray Colors)
  static const Color grayAlpha30 = Color(0x4D9E9E9E);  // 30% 透明度中灰
  static const Color grayAlpha50 = Color(0x809CA3AF);  // 50% 透明度灰色
  static const Color grayAlpha80 = Color(0xCC9CA3AF);  // 80% 透明度灰色
  
  // 透明度品牌色 (Alpha Brand Colors)
  static const Color yellowAlpha10 = Color(0x1AFFD84D);  // 10% 透明度黄色
  static const Color yellowAlpha20 = Color(0x33FFD84D);  // 20% 透明度黄色
  static const Color yellowAlpha30 = Color(0x4DFFD84D);  // 30% 透明度黄色
  static const Color yellowAlpha60 = Color(0x99FFD84D);  // 60% 透明度黄色
  static const Color yellowAlpha70 = Color(0xB3FFD84D);  // 70% 透明度黄色
  
  // === 表面色彩 ===
  // 背景色系 (Surface Colors)
  static const Color background = Color(0xFFFAFAFA);       // 极浅灰主背景 - 中性不偏色
  static const Color surface = Color(0xFFFFFFFF);          // 纯白卡片
  static const Color surfaceSecondary = Color(0xFFFFF9E6); // 极浅黄卡片
  static const Color surfaceTertiary = Color(0xFFF5F5F5);  // 浅灰背景
  static const Color surfaceAccent = Color(0xFFEDF7ED);    // 极浅绿背景
  
  // === 文字色彩 ===
  // 文字颜色 (Text Colors)
  static const Color textPrimary = Color(0xFF424242);      // 深灰 - 主文字
  static const Color textSecondary = Color(0xFF9E9E9E);    // 中灰 - 次要文字
  static const Color textTertiary = Color(0xFFBDBDBD);     // 浅灰 - 辅助文字
  static const Color textInverse = Color(0xFFFFFFFF);      // 白色 - 反色文字
  static const Color textAccent = Color(0xFF2F5233);       // 墨绿 - 强调文字
  
  // === 语义色彩 ===
  // 功能性颜色 (Semantic Colors)
  static const Color success = Color(0xFF66BB6A);          // 柔和绿 - 成功
  static const Color warning = Color(0xFFFFA726);          // 柔和橙 - 警告
  static const Color error = Color(0xFFEF5350);            // 红色 - 错误
  static const Color info = Color(0xFF42A5F5);             // 蓝色 - 信息
  
  // === 别名映射 (Alias Mapping) ===
  // 保持向后兼容性的颜色别名
  static const Color nothingWhite = surface;
  static const Color nothingOffWhite = background;
  static const Color nothingLightGray = gray100;
  static const Color nothingYellow = brandPrimary;
  static const Color nothingYellowLight = brandSecondary;
  static const Color nothingYellowDark = brandAccent;
  static const Color nothingGray = gray500;
  static const Color nothingDarkGray = gray800;
  static const Color nothingMediumGray = gray600;
  static const Color nothingBlack = gray900;
  
  // 图表颜色别名
  static const Color successGreen = success;
  static const Color infoBlue = info;
  static const Color warningOrange = warning;
  
  // === 设计令牌 ===
  // 圆角半径 (Border Radius)
  static const double radiusXs = 4.0;      // 极小圆角
  static const double radiusSm = 8.0;      // 小圆角
  static const double radiusMd = 12.0;     // 中等圆角
  static const double radiusLg = 16.0;     // 大圆角
  static const double radiusXl = 20.0;     // 极大圆角
  static const double radiusFull = 9999.0; // 完全圆角
  
  // 语义化圆角别名 (Semantic Radius Aliases)
  static const double radiusMedium = radiusMd;  // 12.0 - 中等圆角
  static const double radiusLarge = radiusLg;   // 16.0 - 大圆角
  
  // 间距系统 (Spacing)
  static const double spacing1 = 4.0;      // 0.25rem
  static const double spacing2 = 8.0;      // 0.5rem
  static const double spacing3 = 12.0;     // 0.75rem
  static const double spacing4 = 16.0;     // 1rem
  static const double spacing5 = 20.0;     // 1.25rem
  static const double spacing6 = 24.0;     // 1.5rem
  static const double spacing8 = 32.0;     // 2rem
  static const double spacing10 = 40.0;    // 2.5rem
  static const double spacing12 = 48.0;    // 3rem
  static const double spacing16 = 64.0;    // 4rem
  static const double spacing20 = 80.0;    // 5rem
  static const double spacing24 = 96.0;    // 6rem
  
  // 语义化间距别名 (Semantic Spacing Aliases)
  static const double spacingXSmall = spacing1;  // 4.0 - 极小间距
  static const double spacingSmall = spacing2;   // 8.0 - 小间距
  static const double spacingMedium = spacing4;  // 16.0 - 中等间距
  static const double spacingLarge = spacing6;   // 24.0 - 大间距
  static const double spacingXLarge = spacing8;  // 32.0 - 极大间距
  
  // 字体大小 (Font Sizes)
  static const double fontSizeXs = 12.0;   // 极小字体
  static const double fontSizeSm = 14.0;   // 小字体
  static const double fontSizeBase = 16.0; // 基础字体
  static const double fontSizeLg = 18.0;   // 大字体
  static const double fontSizeXl = 20.0;   // 极大字体
  static const double fontSize2xl = 24.0;  // 2倍大字体
  
  // 语义化字体大小别名 (Semantic Font Size Aliases)
  static const double fontSizeSubheading = fontSizeLg;  // 18.0 - 副标题字体
  static const double fontSizeHeadline = fontSize2xl;   // 24.0 - 标题字体
  static const double fontSize3xl = 30.0;  // 3倍大字体
  static const double fontSize4xl = 36.0;  // 4倍大字体
  
  // 语义化字体大小别名 (Semantic Font Size Aliases)
  static const double fontSizeCaption = fontSizeXs;  // 12.0 - 说明文字
  static const double fontSizeBody = fontSizeBase;   // 16.0 - 正文字体
  
  // 字体粗细 (Font Weights)
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // 语义化字体粗细别名 (Semantic Font Weight Aliases)
  static const FontWeight fontWeightRegular = fontWeightNormal;  // 400 - 常规字重
  
  // 阴影系统 (Elevation/Shadows)
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];
  
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];
  
  // 语义化阴影别名 (Semantic Shadow Aliases)
  static const List<BoxShadow> nothingElevatedShadow = shadowMd;  // 中等阴影
  static const List<BoxShadow> nothingShadow = shadowSm;  // 小阴影
  
  // 渐变定义 (Gradients)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandPrimary, accentPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 点阵系统 (Dot Matrix System)
  static const double dotSize = 2.0;        // 点的大小
  static const double dotSpacing = 8.0;     // 点之间的间距
  
  // === 主题配置 ===
  /// 获取亮色主题配置
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        brightness: Brightness.light,
        primary: brandPrimary,
        onPrimary: textPrimary,
        secondary: accentPrimary,
        onSecondary: textInverse,
        tertiary: accentTertiary,
        onTertiary: textPrimary,
        surface: surface,
        onSurface: textPrimary,
        background: background,
        onBackground: textPrimary,
        error: error,
        onError: textInverse,
        outline: gray300,
        outlineVariant: gray200,
        surfaceVariant: surfaceTertiary,
        onSurfaceVariant: textSecondary,
      ),
      scaffoldBackgroundColor: background,
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: fontSizeLg,
          fontWeight: fontWeightSemiBold,
        ),
        iconTheme: IconThemeData(
          color: textPrimary,
          size: 24,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: gray200, width: 1),
        ),
        margin: EdgeInsets.all(spacing2),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: spacing6,
            vertical: spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: fontSizeBase,
            fontWeight: fontWeightMedium,
          ),
        ),
      ),
      
      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: spacing4,
            vertical: spacing2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: fontSizeBase,
            fontWeight: fontWeightMedium,
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: brandPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing4,
          vertical: spacing3,
        ),
        hintStyle: TextStyle(
          color: textSecondary,
          fontSize: fontSizeBase,
        ),
      ),
      
      // 图标主题
      iconTheme: IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // 文本主题
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: fontSize4xl,
          fontWeight: fontWeightBold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: fontSize3xl,
          fontWeight: fontWeightBold,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: fontSize2xl,
          fontWeight: fontWeightSemiBold,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: fontSize2xl,
          fontWeight: fontWeightSemiBold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: fontSizeXl,
          fontWeight: fontWeightSemiBold,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: fontSizeLg,
          fontWeight: fontWeightMedium,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: fontSizeLg,
          fontWeight: fontWeightMedium,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: fontSizeBase,
          fontWeight: fontWeightMedium,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontSize: fontSizeSm,
          fontWeight: fontWeightMedium,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: fontSizeBase,
          fontWeight: fontWeightNormal,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: fontSizeSm,
          fontWeight: fontWeightNormal,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: fontSizeXs,
          fontWeight: fontWeightNormal,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: fontSizeBase,
          fontWeight: fontWeightMedium,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: fontSizeSm,
          fontWeight: fontWeightMedium,
        ),
        labelSmall: TextStyle(
          color: textTertiary,
          fontSize: fontSizeXs,
          fontWeight: fontWeightMedium,
        ),
      ),
    );
  }
}