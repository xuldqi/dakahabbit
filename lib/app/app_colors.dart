import 'package:flutter/material.dart';

/// 应用颜色定义
class AppColors {
  // 私有构造函数，防止实例化
  AppColors._();
  
  // 主色调 - 薄荷绿系列
  static const Color primary = Color(0xFF4ECDC4);
  static const Color primaryLight = Color(0xFF7EE8E0);
  static const Color primaryDark = Color(0xFF2EA39F);
  static const Color primaryContainer = Color(0xFFA8F0ED);
  
  // 辅助色 - 温暖橙系列
  static const Color secondary = Color(0xFFFFB74D);
  static const Color secondaryLight = Color(0xFFFFC980);
  static const Color secondaryDark = Color(0xFFFF8F00);
  static const Color secondaryContainer = Color(0xFFFFE0B2);
  
  // 强调色 - 柔和粉系列
  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentLight = Color(0xFFFFB3D1);
  static const Color accentDark = Color(0xFFE91E63);
  
  // 信息色 - 宁静蓝系列
  static const Color info = Color(0xFF42A5F5);
  static const Color infoLight = Color(0xFF90CAF9);
  static const Color infoDark = Color(0xFF1976D2);
  
  // 语义色彩
  static const Color success = Color(0xFF66BB6A);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  // 特殊功能色
  static const Color habit = Color(0xFF9775FA);    // 习惯相关 - 薄荷紫
  static const Color journal = Color(0xFF4DABF7);  // 日志相关 - 天空蓝
  static const Color statistics = Color(0xFF51CF66); // 统计相关 - 青草绿
  static const Color achievement = Color(0xFFFFD93D); // 成就相关 - 亮黄色
  
  // 浅色主题颜色
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  
  // 浅色主题文字颜色
  static const Color lightPrimaryText = Color(0xFF1A1A1A);
  static const Color lightSecondaryText = Color(0xFF757575);
  static const Color lightDisabledText = Color(0xFFBDBDBD);
  static const Color lightHintText = Color(0xFF9E9E9E);
  
  // 浅色主题边框和分隔线
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightOutline = Color(0xFFBDBDBD);
  
  // 浅色主题输入框
  static const Color lightInputBackground = Color(0xFFF8F9FA);
  static const Color lightInputBorder = Color(0xFFE9ECEF);
  
  // 浅色主题卡片
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightCardShadow = Color(0x1A000000);
  
  // 深色主题颜色
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  
  // 深色主题文字颜色
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFBDBDBD);
  static const Color darkDisabledText = Color(0xFF616161);
  static const Color darkHintText = Color(0xFF757575);
  
  // 深色主题边框和分隔线
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkBorder = Color(0xFF424242);
  static const Color darkOutline = Color(0xFF616161);
  
  // 深色主题输入框
  static const Color darkInputBackground = Color(0xFF2C2C2C);
  static const Color darkInputBorder = Color(0xFF424242);
  
  // 深色主题卡片
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkCardShadow = Color(0x33000000);
  
  // 渐变色定义
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF44A08D)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, accent],
  );
  
  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [info, habit],
  );
  
  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [achievement, secondary],
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, habit],
  );
  
  // 习惯分类颜色
  static const Map<String, Color> categoryColors = {
    'health': Color(0xFFE91E63),      // 健康 - 粉色
    'exercise': Color(0xFF4CAF50),    // 运动 - 绿色
    'study': Color(0xFF9C27B0),       // 学习 - 紫色
    'work': Color(0xFF2196F3),        // 工作 - 蓝色
    'life': Color(0xFFFF9800),        // 生活 - 橙色
    'social': Color(0xFF00BCD4),      // 社交 - 青色
    'hobby': Color(0xFFFFEB3B),       // 爱好 - 黄色
    'other': Color(0xFF9E9E9E),       // 其他 - 灰色
  };
  
  // 心情颜色
  static const Map<String, Color> moodColors = {
    'very_happy': Color(0xFFFFC107),  // 非常开心 - 金黄色
    'happy': Color(0xFF4CAF50),       // 开心 - 绿色
    'neutral': Color(0xFF9E9E9E),     // 一般 - 灰色
    'sad': Color(0xFF2196F3),         // 难过 - 蓝色
    'very_sad': Color(0xFF9C27B0),    // 非常难过 - 紫色
  };
  
  // 优先级颜色
  static const Map<int, Color> priorityColors = {
    1: Color(0xFFE0E0E0),  // 很低 - 浅灰
    2: Color(0xFFBDBDBD),  // 较低 - 灰色
    3: Color(0xFF757575),  // 一般 - 深灰
    4: Color(0xFF4CAF50),  // 重要 - 绿色
    5: Color(0xFFE91E63),  // 非常重要 - 红色
  };
  
  // 难度颜色
  static const Map<String, Color> difficultyColors = {
    'easy': Color(0xFF4CAF50),     // 简单 - 绿色
    'medium': Color(0xFFFF9800),   // 中等 - 橙色
    'hard': Color(0xFFF44336),     // 困难 - 红色
  };
  
  // 成就稀有度颜色
  static const Map<String, Color> rarityColors = {
    'common': Color(0xFF9E9E9E),    // 普通 - 灰色
    'rare': Color(0xFF2196F3),      // 稀有 - 蓝色
    'epic': Color(0xFF9C27B0),      // 史诗 - 紫色
    'legendary': Color(0xFFFF9800), // 传说 - 橙色
  };
  
  // 透明度变体
  static Color withAlpha(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // 获取对比色（用于文字颜色）
  static Color getContrastColor(Color backgroundColor) {
    // 计算亮度
    final luminance = backgroundColor.computeLuminance();
    // 如果背景较亮，返回深色文字，否则返回浅色文字
    return luminance > 0.5 ? lightPrimaryText : darkPrimaryText;
  }
  
  // 获取分类颜色
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? categoryColors['other']!;
  }
  
  // 获取心情颜色
  static Color getMoodColor(String mood) {
    return moodColors[mood] ?? moodColors['neutral']!;
  }
  
  // 获取优先级颜色
  static Color getPriorityColor(int priority) {
    return priorityColors[priority] ?? priorityColors[3]!;
  }
  
  // 获取难度颜色
  static Color getDifficultyColor(String difficulty) {
    return difficultyColors[difficulty] ?? difficultyColors['medium']!;
  }
  
  // 获取稀有度颜色
  static Color getRarityColor(String rarity) {
    return rarityColors[rarity] ?? rarityColors['common']!;
  }
  
  // 状态颜色
  static const Color completed = success;
  static const Color pending = warning;
  static const Color overdue = error;
  static const Color paused = Color(0xFF9E9E9E);
  static const Color cancelled = Color(0xFF757575);
  
  // 图表颜色序列
  static const List<Color> chartColors = [
    primary,
    secondary,
    accent,
    info,
    success,
    warning,
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFFEB3B),
    Color(0xFF795548),
  ];
  
  // 获取图表颜色
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}