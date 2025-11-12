import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../core/services/shared_preferences_service.dart';
import '../core/services/database_service.dart';
import '../core/utils/logger.dart';

/// 应用配置类
/// 管理应用的全局配置信息和初始化逻辑
class AppConfig {
  static late PackageInfo _packageInfo;
  static late DeviceInfoPlugin _deviceInfo;
  static bool _initialized = false;
  
  // 应用信息
  static String get appName => _packageInfo.appName;
  static String get packageName => _packageInfo.packageName;
  static String get version => _packageInfo.version;
  static String get buildNumber => _packageInfo.buildNumber;
  static String get versionName => '$version+$buildNumber';
  
  // 环境配置
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  static bool get isProfile => kProfileMode;
  
  // 构建信息
  static String get buildMode {
    if (kDebugMode) return 'debug';
    if (kReleaseMode) return 'release';
    if (kProfileMode) return 'profile';
    return 'unknown';
  }
  
  // 平台信息
  static String get platformName => defaultTargetPlatform.name;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => 
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
  
  // 数据库配置
  static const String databaseName = 'dakahabit.db';
  static const int databaseVersion = 1;
  
  // 缓存配置
  static const Duration defaultCacheDuration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // 网络配置
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // UI配置
  static const double minTextScaleFactor = 0.8;
  static const double maxTextScaleFactor = 1.4;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // 通知配置
  static const String notificationChannelId = 'dakahabit_reminders';
  static const String notificationChannelName = '习惯提醒';
  static const String notificationChannelDescription = '习惯打卡提醒通知';
  
  // 权限配置
  static const List<String> requiredPermissions = [
    'android.permission.POST_NOTIFICATIONS',
    'android.permission.SCHEDULE_EXACT_ALARM',
    'android.permission.CAMERA',
    'android.permission.READ_EXTERNAL_STORAGE',
  ];
  
  // 文件配置
  static const List<String> supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'
  ];
  static const List<String> supportedAudioFormats = [
    'mp3', 'wav', 'm4a', 'aac'
  ];
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxAudioSize = 50 * 1024 * 1024; // 50MB
  
  /// 初始化应用配置
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      Logger.info('正在初始化应用配置...');
      
      // 获取应用信息
      _packageInfo = await PackageInfo.fromPlatform();
      _deviceInfo = DeviceInfoPlugin();
      
      // 初始化服务
      await _initializeServices();
      
      // 记录初始化信息
      await _logInitializationInfo();
      
      _initialized = true;
      Logger.info('应用配置初始化完成');
      
    } catch (e, stackTrace) {
      Logger.error('应用配置初始化失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// 初始化核心服务
  static Future<void> _initializeServices() async {
    // 这里的服务初始化在ServiceLocator中处理
    // 这个方法保留为占位符
  }
  
  /// 记录初始化信息
  static Future<void> _logInitializationInfo() async {
    Logger.info('应用信息:');
    Logger.info('  应用名称: $appName');
    Logger.info('  包名: $packageName');
    Logger.info('  版本: $versionName');
    Logger.info('  构建模式: $buildMode');
    Logger.info('  平台: $platformName');
    
    // 记录设备信息
    if (isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      Logger.info('设备信息:');
      Logger.info('  设备: ${androidInfo.manufacturer} ${androidInfo.model}');
      Logger.info('  Android版本: ${androidInfo.version.release}');
      Logger.info('  API级别: ${androidInfo.version.sdkInt}');
    } else if (isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      Logger.info('设备信息:');
      Logger.info('  设备: ${iosInfo.name} ${iosInfo.model}');
      Logger.info('  iOS版本: ${iosInfo.systemVersion}');
    }
  }
  
  /// 获取完整的应用信息
  static Map<String, dynamic> getAppInfo() {
    return {
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'buildNumber': buildNumber,
      'versionName': versionName,
      'buildMode': buildMode,
      'platform': platformName,
      'initialized': _initialized,
    };
  }
  
  /// 检查是否为第一次启动
  static Future<bool> isFirstLaunch() async {
    // TODO: 通过ServiceLocator获取服务实例
    return true;
  }
  
  /// 设置已完成首次启动
  static Future<void> setFirstLaunchCompleted() async {
    // TODO: 通过ServiceLocator获取服务实例
  }
  
  /// 获取上次应用版本
  static Future<String?> getLastAppVersion() async {
    // TODO: 通过ServiceLocator获取服务实例
    return null;
  }
  
  /// 设置当前应用版本
  static Future<void> setCurrentAppVersion() async {
    // TODO: 通过ServiceLocator获取服务实例
  }
  
  /// 检查是否需要显示版本更新说明
  static Future<bool> shouldShowVersionUpdateInfo() async {
    final lastVersion = await getLastAppVersion();
    return lastVersion != null && lastVersion != versionName;
  }
  
  /// 获取构建时间戳
  static DateTime getBuildTimestamp() {
    // 这里可以通过构建脚本注入真实的构建时间
    return DateTime.now(); // 暂时返回当前时间
  }
  
  /// 检查调试功能是否可用
  static bool isDebugFeatureEnabled(String featureName) {
    if (!isDebug) return false;
    
    // 这里可以添加特定调试功能的开关逻辑
    return true;
  }
}