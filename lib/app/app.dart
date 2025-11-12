import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/app_constants.dart';
import '../generated/l10n.dart';
import '../core/providers/theme_provider.dart' as core;
import 'app_router.dart';
import 'app_theme.dart';

class DakaHabitApp extends ConsumerWidget {
  const DakaHabitApp({super.key});

  /// 转换自定义ThemeMode到Flutter的ThemeMode
  ThemeMode _getFlutterThemeMode(core.ThemeMode mode) {
    switch (mode) {
      case core.ThemeMode.light:
        return ThemeMode.light;
      case core.ThemeMode.dark:
        return ThemeMode.dark;
      case core.ThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(core.themeSettingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // 应用基本信息
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // 路由配置
      routerConfig: router,
      
      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getFlutterThemeMode(themeSettings.mode),
      
      // 国际化配置
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      
      // 构建器配置
      builder: (context, child) {
        return MediaQuery(
          // 设置文字缩放因子限制
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: AppConstants.minTextScaleFactor,
              maxScaleFactor: AppConstants.maxTextScaleFactor,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      
      // 滚动行为配置
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        // 支持桌面平台的拖拽滚动
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
    );
  }
}