import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 应用文字样式定义
class AppTextStyles {
  // 私有构造函数，防止实例化
  AppTextStyles._();
  
  // 字体家族
  static const String fontFamily = 'DakaHabit';
  static const String fallbackFontFamily = 'PingFang SC';
  
  // 浅色主题文字样式
  static const TextTheme lightTextTheme = TextTheme(
    // Display 样式 - 用于大标题
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.25,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.29,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.33,
    ),
    
    // Headline 样式 - 用于标题
    headlineLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.33,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.25,
    ),
    
    // Title 样式 - 用于小标题
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.5,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.43,
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.lightSecondaryText,
      fontFamily: fontFamily,
      height: 1.33,
      letterSpacing: 0.1,
    ),
    
    // Body 样式 - 用于正文
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.5,
      letterSpacing: 0.1,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.43,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.lightSecondaryText,
      fontFamily: fontFamily,
      height: 1.33,
      letterSpacing: 0.4,
    ),
    
    // Label 样式 - 用于标签和按钮
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.lightPrimaryText,
      fontFamily: fontFamily,
      height: 1.43,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.lightSecondaryText,
      fontFamily: fontFamily,
      height: 1.33,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.lightSecondaryText,
      fontFamily: fontFamily,
      height: 1.6,
      letterSpacing: 0.5,
    ),
  );
  
  // 深色主题文字样式
  static const TextTheme darkTextTheme = TextTheme(
    // Display 样式
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.25,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.29,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.33,
    ),
    
    // Headline 样式
    headlineLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.33,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.25,
    ),
    
    // Title 样式
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.5,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.43,
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.darkSecondaryText,
      fontFamily: fontFamily,
      height: 1.33,
      letterSpacing: 0.1,
    ),
    
    // Body 样式
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.5,
      letterSpacing: 0.1,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.43,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.darkSecondaryText,
      fontFamily: fontFamily,
      height: 1.33,
      letterSpacing: 0.4,
    ),
    
    // Label 样式
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkPrimaryText,
      fontFamily: fontFamily,
      height: 1.43,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.darkSecondaryText,
      fontFamily: fontFamily,
      height: 1.33,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.darkSecondaryText,
      fontFamily: fontFamily,
      height: 1.6,
      letterSpacing: 0.5,
    ),
  );
  
  // 特殊用途文字样式
  
  // 页面标题样式
  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.lightPrimaryText,
    fontFamily: fontFamily,
    height: 1.33,
  );
  
  // 卡片标题样式
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.lightPrimaryText,
    fontFamily: fontFamily,
    height: 1.33,
  );
  
  // 卡片副标题样式
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.lightSecondaryText,
    fontFamily: fontFamily,
    height: 1.43,
  );
  
  // 按钮文字样式
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.25,
    letterSpacing: 0.1,
  );
  
  // 小按钮文字样式
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.43,
    letterSpacing: 0.1,
  );
  
  // 输入框样式
  static const TextStyle input = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.lightPrimaryText,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  // 输入框提示文字样式
  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.lightHintText,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  // 标签样式
  static const TextStyle tag = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.33,
    letterSpacing: 0.1,
  );
  
  // 徽章样式
  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.6,
    letterSpacing: 0.5,
  );
  
  // 数字显示样式 - 用于统计数据
  static const TextStyle numberLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    fontFamily: fontFamily,
    height: 1.25,
    letterSpacing: -0.5,
  );
  
  static const TextStyle numberMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: fontFamily,
    height: 1.33,
  );
  
  static const TextStyle numberSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  // 日期时间样式
  static const TextStyle dateTime = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.lightSecondaryText,
    fontFamily: fontFamily,
    height: 1.43,
  );
  
  // 表单标签样式
  static const TextStyle formLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.lightPrimaryText,
    fontFamily: fontFamily,
    height: 1.43,
    letterSpacing: 0.1,
  );
  
  // 错误文字样式
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    fontFamily: fontFamily,
    height: 1.33,
  );
  
  // 成功文字样式
  static const TextStyle success = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.success,
    fontFamily: fontFamily,
    height: 1.33,
  );
  
  // 链接样式
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    fontFamily: fontFamily,
    height: 1.43,
    decoration: TextDecoration.underline,
  );
  
  // 导航栏标题样式
  static const TextStyle navBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.lightPrimaryText,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  // 导航标签样式
  static const TextStyle navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    height: 1.33,
  );
  
  // 统计标题样式
  static const TextStyle statsTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.lightPrimaryText,
    fontFamily: fontFamily,
    height: 1.33,
  );
  
  // 统计数值样式
  static const TextStyle statsValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  // 统计单位样式
  static const TextStyle statsUnit = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.lightSecondaryText,
    fontFamily: fontFamily,
    height: 1.33,
  );
  
  // 空状态样式
  static const TextStyle emptyTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.lightSecondaryText,
    fontFamily: fontFamily,
    height: 1.33,
  );
  
  static const TextStyle emptyDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.lightSecondaryText,
    fontFamily: fontFamily,
    height: 1.43,
  );
  
  // 工具方法
  
  // 根据主题获取对应的文字颜色
  static Color getTextColor(BuildContext context, {bool isPrimary = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isPrimary) {
      return isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    } else {
      return isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    }
  }
  
  // 创建自定义文字样式
  static TextStyle custom({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.lightPrimaryText,
      fontFamily: fontFamily ?? AppTextStyles.fontFamily,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
  
  // 应用主题色彩到文字样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  // 应用透明度到文字样式
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(
      color: style.color?.withOpacity(opacity) ?? 
             AppColors.lightPrimaryText.withOpacity(opacity),
    );
  }
  
  // 应用权重到文字样式
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  // 应用尺寸到文字样式
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}