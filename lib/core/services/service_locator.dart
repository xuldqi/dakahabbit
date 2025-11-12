import 'package:get_it/get_it.dart';

import 'database_service.dart';
import 'shared_preferences_service.dart';
import 'notification_service.dart';
import '../repositories/habit_repository.dart';
import '../repositories/check_in_repository.dart';
import '../repositories/journal_repository.dart';
import '../repositories/habit_journal_relation_repository.dart';
import 'habit_service.dart';
import 'check_in_service.dart';
import 'journal_service.dart';
import 'statistics_service.dart';
import '../utils/logger.dart';

/// 服务定位器
/// 用于管理应用中的各种服务实例
class ServiceLocator {
  // GetIt实例
  static final GetIt _getIt = GetIt.instance;
  
  // 获取服务实例
  static T get<T extends Object>() => _getIt.get<T>();
  
  // 是否已初始化
  static bool get isInitialized => _getIt.isRegistered<DatabaseService>();
  
  /// 初始化所有服务
  static Future<void> initialize() async {
    try {
      Logger.info('正在初始化服务定位器...');
      
      // 注册核心服务
      await _registerCoreServices();
      
      // 注册业务服务
      await _registerBusinessServices();
      
      // 注册数据服务
      await _registerDataServices();
      
      Logger.info('服务定位器初始化完成');
      
    } catch (e, stackTrace) {
      Logger.error('服务定位器初始化失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// 注册核心服务
  static Future<void> _registerCoreServices() async {
    Logger.info('注册核心服务...');
    
    // 数据库服务
    final databaseService = DatabaseService();
    await databaseService.initialize();
    _getIt.registerSingleton<DatabaseService>(databaseService);
    
    // SharedPreferences服务
    final sharedPreferencesService = SharedPreferencesService();
    await sharedPreferencesService.initialize();
    _getIt.registerSingleton<SharedPreferencesService>(sharedPreferencesService);
    
    // 通知服务
    final notificationService = NotificationService();
    await notificationService.initialize();
    _getIt.registerSingleton<NotificationService>(notificationService);
    
    Logger.info('核心服务注册完成');
  }
  
  /// 注册业务服务
  static Future<void> _registerBusinessServices() async {
    Logger.info('注册业务服务...');
    
    // 注册数据访问层
    final habitRepository = HabitRepository(_getIt<DatabaseService>());
    _getIt.registerSingleton<HabitRepository>(habitRepository);
    
    final checkInRepository = CheckInRepository(_getIt<DatabaseService>());
    _getIt.registerSingleton<CheckInRepository>(checkInRepository);
    
    final journalRepository = JournalRepository(_getIt<DatabaseService>());
    _getIt.registerSingleton<JournalRepository>(journalRepository);
    
    final habitJournalRelationRepository = HabitJournalRelationRepository(_getIt<DatabaseService>());
    _getIt.registerSingleton<HabitJournalRelationRepository>(habitJournalRelationRepository);
    
    // 注册业务服务层
    final habitService = HabitService(
      _getIt<HabitRepository>(), 
      _getIt<NotificationService>(),
    );
    _getIt.registerSingleton<HabitService>(habitService);
    
    final checkInService = CheckInService(
      _getIt<CheckInRepository>(),
      _getIt<HabitRepository>(),
    );
    _getIt.registerSingleton<CheckInService>(checkInService);
    
    final journalService = JournalService(
      _getIt<JournalRepository>(),
      _getIt<HabitJournalRelationRepository>(),
      _getIt<HabitRepository>(),
    );
    _getIt.registerSingleton<JournalService>(journalService);
    
    final statisticsService = StatisticsService(
      _getIt<HabitRepository>(),
      _getIt<CheckInRepository>(),
      _getIt<JournalRepository>(),
      _getIt<HabitJournalRelationRepository>(),
    );
    _getIt.registerSingleton<StatisticsService>(statisticsService);
    
    Logger.info('业务服务注册完成');
  }
  
  /// 注册数据服务
  static Future<void> _registerDataServices() async {
    Logger.info('注册数据服务...');
    
    // 数据服务现已在业务服务层注册
    // 这里可以注册其他数据相关的配置或初始化
    
    Logger.info('数据服务注册完成');
  }
  
  /// 清理所有服务
  static Future<void> dispose() async {
    try {
      Logger.info('正在清理服务定位器...');
      
      // 清理通知服务
      if (_getIt.isRegistered<NotificationService>()) {
        await _getIt<NotificationService>().dispose();
      }
      
      // 清理数据库服务
      if (_getIt.isRegistered<DatabaseService>()) {
        await _getIt<DatabaseService>().dispose();
      }
      
      // 重置GetIt
      await _getIt.reset();
      
      Logger.info('服务定位器清理完成');
      
    } catch (e, stackTrace) {
      Logger.error('服务定位器清理失败', error: e, stackTrace: stackTrace);
    }
  }
  
  /// 检查服务是否已注册
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
  
  /// 注册单例服务
  static void registerSingleton<T extends Object>(T instance) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerSingleton<T>(instance);
    }
  }
  
  /// 注册懒加载单例服务
  static void registerLazySingleton<T extends Object>(
    T Function() factoryFunc,
  ) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerLazySingleton<T>(factoryFunc);
    }
  }
  
  /// 注册工厂服务
  static void registerFactory<T extends Object>(
    T Function() factoryFunc,
  ) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerFactory<T>(factoryFunc);
    }
  }
  
  /// 注销服务
  static Future<void> unregister<T extends Object>() async {
    if (_getIt.isRegistered<T>()) {
      await _getIt.unregister<T>();
    }
  }
}