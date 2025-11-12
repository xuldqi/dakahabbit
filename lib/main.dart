import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'core/services/service_locator.dart';
import 'core/utils/logger.dart';
import 'generated/l10n.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 设置首选方向（竖屏）
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 初始化应用配置
  await AppConfig.initialize();
  
  // 初始化服务定位器
  await ServiceLocator.initialize();
  
  // 初始化日志系统
  Logger.initialize(
    level: AppConfig.isDebug ? LogLevel.debug : LogLevel.info,
    enableFileLogging: true,
  );
  
  Logger.info('DakaHabit应用启动');
  
  // 启动应用
  runApp(
    ProviderScope(
      child: DakaHabitApp(),
    ),
  );
}