import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// 应用主题配置
class AppTheme {
  // 私有构造函数，防止实例化
  AppTheme._();
  
  /// 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      // 基础配置
      brightness: Brightness.light,
      useMaterial3: true,
      
      // 颜色方案
      colorScheme: _lightColorScheme,
      
      // 应用栏主题
      appBarTheme: _lightAppBarTheme,
      
      // 底部导航栏主题
      bottomNavigationBarTheme: _lightBottomNavigationBarTheme,
      
      // 卡片主题
      cardTheme: _cardTheme,
      
      // 按钮主题
      elevatedButtonTheme: _lightElevatedButtonTheme,
      textButtonTheme: _lightTextButtonTheme,
      outlinedButtonTheme: _lightOutlinedButtonTheme,
      floatingActionButtonTheme: _lightFabTheme,
      
      // 输入框主题
      inputDecorationTheme: _lightInputDecorationTheme,
      
      // 对话框主题
      dialogTheme: _dialogTheme,
      
      // 底部弹窗主题
      bottomSheetTheme: _bottomSheetTheme,
      
      // 分隔线主题
      dividerTheme: _lightDividerTheme,
      
      // 列表瓦片主题
      listTileTheme: _lightListTileTheme,
      
      // 开关主题
      switchTheme: _lightSwitchTheme,
      
      // 复选框主题
      checkboxTheme: _lightCheckboxTheme,
      
      // 滑块主题
      sliderTheme: _lightSliderTheme,
      
      // 文本主题
      textTheme: AppTextStyles.lightTextTheme,
      
      // 图标主题
      iconTheme: _lightIconTheme,
      
      // 脚手架背景色
      scaffoldBackgroundColor: AppColors.lightBackground,
      
      // 页面过渡
      pageTransitionsTheme: _pageTransitionsTheme,
      
      // Splash颜色
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),
      
      // 视觉密度
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
  
  /// 深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      // 基础配置
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // 颜色方案
      colorScheme: _darkColorScheme,
      
      // 应用栏主题
      appBarTheme: _darkAppBarTheme,
      
      // 底部导航栏主题
      bottomNavigationBarTheme: _darkBottomNavigationBarTheme,
      
      // 卡片主题
      cardTheme: _cardTheme,
      
      // 按钮主题
      elevatedButtonTheme: _darkElevatedButtonTheme,
      textButtonTheme: _darkTextButtonTheme,
      outlinedButtonTheme: _darkOutlinedButtonTheme,
      floatingActionButtonTheme: _darkFabTheme,
      
      // 输入框主题
      inputDecorationTheme: _darkInputDecorationTheme,
      
      // 对话框主题
      dialogTheme: _dialogTheme,
      
      // 底部弹窗主题
      bottomSheetTheme: _bottomSheetTheme,
      
      // 分隔线主题
      dividerTheme: _darkDividerTheme,
      
      // 列表瓦片主题
      listTileTheme: _darkListTileTheme,
      
      // 开关主题
      switchTheme: _darkSwitchTheme,
      
      // 复选框主题
      checkboxTheme: _darkCheckboxTheme,
      
      // 滑块主题
      sliderTheme: _darkSliderTheme,
      
      // 文本主题
      textTheme: AppTextStyles.darkTextTheme,
      
      // 图标主题
      iconTheme: _darkIconTheme,
      
      // 脚手架背景色
      scaffoldBackgroundColor: AppColors.darkBackground,
      
      // 页面过渡
      pageTransitionsTheme: _pageTransitionsTheme,
      
      // Splash颜色
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),
      
      // 视觉密度
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
  
  // 颜色方案
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.lightSurface,
    background: AppColors.lightBackground,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.lightOnSurface,
    onBackground: AppColors.lightOnBackground,
    onError: Colors.white,
  );
  
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.darkSurface,
    background: AppColors.darkBackground,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.darkOnSurface,
    onBackground: AppColors.darkOnBackground,
    onError: Colors.white,
  );
  
  // 应用栏主题
  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.lightBackground,
    foregroundColor: AppColors.lightOnBackground,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.lightOnBackground,
    ),
  );
  
  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkOnBackground,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.darkOnBackground,
    ),
  );
  
  // 底部导航栏主题
  static const BottomNavigationBarThemeData _lightBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
    elevation: 8,
    backgroundColor: AppColors.lightSurface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.lightSecondaryText,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  );
  
  static const BottomNavigationBarThemeData _darkBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
    elevation: 8,
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.darkSecondaryText,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  );
  
  // 卡片主题
  static const CardThemeData _cardTheme = CardThemeData(
    elevation: AppConstants.defaultElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
    margin: EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.smallPadding,
    ),
  );
  
  // 按钮主题
  static final ElevatedButtonThemeData _lightElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: AppConstants.defaultElevation,
      minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppConstants.extraLargeBorderRadius),
        ),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  static final ElevatedButtonThemeData _darkElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: AppConstants.defaultElevation,
      minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppConstants.extraLargeBorderRadius),
        ),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  static final TextButtonThemeData _lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  static final TextButtonThemeData _darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  static final OutlinedButtonThemeData _lightOutlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 2),
      minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppConstants.extraLargeBorderRadius),
        ),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  static final OutlinedButtonThemeData _darkOutlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 2),
      minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppConstants.extraLargeBorderRadius),
        ),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  // 悬浮按钮主题
  static const FloatingActionButtonThemeData _lightFabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.secondary,
    foregroundColor: Colors.white,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.fabSize / 2),
      ),
    ),
  );
  
  static const FloatingActionButtonThemeData _darkFabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.secondary,
    foregroundColor: Colors.white,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.fabSize / 2),
      ),
    ),
  );
  
  // 输入框主题
  static const InputDecorationTheme _lightInputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightInputBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.defaultPadding / 2,
    ),
    hintStyle: TextStyle(
      color: AppColors.lightSecondaryText,
      fontSize: 16,
    ),
  );
  
  static const InputDecorationTheme _darkInputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkInputBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.defaultPadding / 2,
    ),
    hintStyle: TextStyle(
      color: AppColors.darkSecondaryText,
      fontSize: 16,
    ),
  );
  
  // 对话框主题
  static const DialogThemeData _dialogTheme = DialogThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.largeBorderRadius),
      ),
    ),
    elevation: 8,
  );
  
  // 底部弹窗主题
  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.largeBorderRadius),
      ),
    ),
    elevation: 8,
  );
  
  // 分隔线主题
  static const DividerThemeData _lightDividerTheme = DividerThemeData(
    color: AppColors.lightDivider,
    thickness: 1,
    space: 1,
  );
  
  static const DividerThemeData _darkDividerTheme = DividerThemeData(
    color: AppColors.darkDivider,
    thickness: 1,
    space: 1,
  );
  
  // 列表瓦片主题
  static const ListTileThemeData _lightListTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.smallPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
  );
  
  static const ListTileThemeData _darkListTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.smallPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
  );
  
  // 开关主题
  static final SwitchThemeData _lightSwitchTheme = SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.white;
      }
      return AppColors.lightSecondaryText;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.lightDivider;
    }),
  );
  
  static final SwitchThemeData _darkSwitchTheme = SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.white;
      }
      return AppColors.darkSecondaryText;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.darkDivider;
    }),
  );
  
  // 复选框主题
  static final CheckboxThemeData _lightCheckboxTheme = CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: MaterialStateProperty.all(Colors.white),
    side: const BorderSide(color: AppColors.lightDivider, width: 2),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  );
  
  static final CheckboxThemeData _darkCheckboxTheme = CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: MaterialStateProperty.all(Colors.white),
    side: const BorderSide(color: AppColors.darkDivider, width: 2),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  );
  
  // 滑块主题
  static final SliderThemeData _lightSliderTheme = SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.lightDivider,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primary.withOpacity(0.2),
    trackHeight: 4,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
  );
  
  static final SliderThemeData _darkSliderTheme = SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.darkDivider,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primary.withOpacity(0.2),
    trackHeight: 4,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
  );
  
  // 图标主题
  static const IconThemeData _lightIconTheme = IconThemeData(
    color: AppColors.lightOnBackground,
    size: AppConstants.iconSize,
  );
  
  static const IconThemeData _darkIconTheme = IconThemeData(
    color: AppColors.darkOnBackground,
    size: AppConstants.iconSize,
  );
  
  // 页面过渡主题
  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  /// 根据参数动态生成主题数据
  static ThemeData getThemeData({
    Color? primaryColor,
    bool isDarkMode = false,
    bool useMaterial3 = true,
    String? fontFamily,
    double? fontSize,
    double? borderRadius,
  }) {
    // 使用提供的主色调，或默认使用AppColors.primary
    final Color effectivePrimaryColor = primaryColor ?? AppColors.primary;
    
    // 创建基础主题
    final ThemeData baseTheme = isDarkMode ? darkTheme : lightTheme;
    
    // 如果没有自定义参数，直接返回基础主题
    if (primaryColor == null && 
        fontFamily == null && 
        fontSize == null && 
        borderRadius == null) {
      return baseTheme.copyWith(useMaterial3: useMaterial3);
    }
    
    // 创建自定义颜色方案
    final ColorScheme customColorScheme = isDarkMode 
        ? ColorScheme.fromSeed(
            seedColor: effectivePrimaryColor,
            brightness: Brightness.dark,
            primary: effectivePrimaryColor,
          )
        : ColorScheme.fromSeed(
            seedColor: effectivePrimaryColor,
            brightness: Brightness.light,
            primary: effectivePrimaryColor,
          );
    
    // 创建自定义文本主题
    TextTheme? customTextTheme;
    if (fontFamily != null || fontSize != null) {
      final baseTextTheme = isDarkMode 
          ? AppTextStyles.darkTextTheme 
          : AppTextStyles.lightTextTheme;
      
      customTextTheme = _customizeTextTheme(
        baseTextTheme,
        fontFamily: fontFamily,
        fontSize: fontSize,
      );
    }
    
    // 创建自定义按钮主题
    ElevatedButtonThemeData? customElevatedButtonTheme;
    if (borderRadius != null) {
      final baseButtonTheme = isDarkMode 
          ? _darkElevatedButtonTheme 
          : _lightElevatedButtonTheme;
      
      customElevatedButtonTheme = ElevatedButtonThemeData(
        style: baseButtonTheme.style?.copyWith(
          backgroundColor: MaterialStateProperty.all(effectivePrimaryColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      );
    }
    
    // 创建自定义卡片主题
    CardThemeData? customCardTheme;
    if (borderRadius != null) {
      customCardTheme = _cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }
    
    // 创建自定义输入框主题
    InputDecorationTheme? customInputTheme;
    if (borderRadius != null) {
      final baseInputTheme = isDarkMode 
          ? _darkInputDecorationTheme 
          : _lightInputDecorationTheme;
      
      customInputTheme = baseInputTheme.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: effectivePrimaryColor, width: 2),
        ),
      );
    }
    
    // 返回自定义主题
    return baseTheme.copyWith(
      useMaterial3: useMaterial3,
      colorScheme: customColorScheme,
      textTheme: customTextTheme,
      elevatedButtonTheme: customElevatedButtonTheme,
      cardTheme: customCardTheme,
      inputDecorationTheme: customInputTheme,
    );
  }
  
  /// 自定义文本主题
  static TextTheme _customizeTextTheme(
    TextTheme baseTextTheme, {
    String? fontFamily,
    double? fontSize,
  }) {
    if (fontFamily == null && fontSize == null) {
      return baseTextTheme;
    }
    
    final double scaleFactor = fontSize != null ? fontSize / 14.0 : 1.0;
    
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.displayLarge?.fontSize != null 
            ? baseTextTheme.displayLarge!.fontSize! * scaleFactor 
            : null,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.displayMedium?.fontSize != null 
            ? baseTextTheme.displayMedium!.fontSize! * scaleFactor 
            : null,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.displaySmall?.fontSize != null 
            ? baseTextTheme.displaySmall!.fontSize! * scaleFactor 
            : null,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.headlineLarge?.fontSize != null 
            ? baseTextTheme.headlineLarge!.fontSize! * scaleFactor 
            : null,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.headlineMedium?.fontSize != null 
            ? baseTextTheme.headlineMedium!.fontSize! * scaleFactor 
            : null,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.headlineSmall?.fontSize != null 
            ? baseTextTheme.headlineSmall!.fontSize! * scaleFactor 
            : null,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.titleLarge?.fontSize != null 
            ? baseTextTheme.titleLarge!.fontSize! * scaleFactor 
            : null,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.titleMedium?.fontSize != null 
            ? baseTextTheme.titleMedium!.fontSize! * scaleFactor 
            : null,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.titleSmall?.fontSize != null 
            ? baseTextTheme.titleSmall!.fontSize! * scaleFactor 
            : null,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.bodyLarge?.fontSize != null 
            ? baseTextTheme.bodyLarge!.fontSize! * scaleFactor 
            : null,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.bodyMedium?.fontSize != null 
            ? baseTextTheme.bodyMedium!.fontSize! * scaleFactor 
            : null,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.bodySmall?.fontSize != null 
            ? baseTextTheme.bodySmall!.fontSize! * scaleFactor 
            : null,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.labelLarge?.fontSize != null 
            ? baseTextTheme.labelLarge!.fontSize! * scaleFactor 
            : null,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.labelMedium?.fontSize != null 
            ? baseTextTheme.labelMedium!.fontSize! * scaleFactor 
            : null,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: baseTextTheme.labelSmall?.fontSize != null 
            ? baseTextTheme.labelSmall!.fontSize! * scaleFactor 
            : null,
      ),
    );
  }
}