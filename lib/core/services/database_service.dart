import 'package:flutter/foundation.dart' show kIsWeb;

import '../utils/logger.dart';
import '../../app/app_config.dart';

// 条件导入：仅在非 Web 平台导入数据库相关包
import 'database_helper.dart'
    if (dart.library.io) 'database_helper_io.dart';

/// 数据库服务
/// 在 Web 平台上，SQLite 不可用，数据库功能将被禁用
class DatabaseService {
  dynamic _database;
  bool _isInitialized = false;
  
  /// 获取数据库实例
  dynamic get database => _database;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 初始化数据库
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      Logger.info('正在初始化数据库...');
      
      if (kIsWeb) {
        Logger.info('Web 平台不支持 SQLite，数据库功能将不可用');
        _isInitialized = true;
        return;
      }
      
      // 非 Web 平台初始化数据库
      _database = await DatabaseHelper.openDatabase(
        AppConfig.databaseName,
        AppConfig.databaseVersion,
      );
      
      _isInitialized = true;
      Logger.info('数据库初始化完成');
      
    } catch (e, stackTrace) {
      Logger.error('数据库初始化失败', error: e, stackTrace: stackTrace);
      if (kIsWeb) {
        _isInitialized = true;
        Logger.info('Web 平台上数据库初始化失败，但应用将继续运行');
        return;
      }
      rethrow;
    }
  }
  
  /// 关闭数据库
  Future<void> dispose() async {
    if (!kIsWeb && _database != null) {
      try {
        await DatabaseHelper.closeDatabase(_database);
        _database = null;
        Logger.info('数据库已关闭');
      } catch (e, stackTrace) {
        Logger.error('关闭数据库失败', error: e, stackTrace: stackTrace);
      }
    }
    _isInitialized = false;
  }
}
