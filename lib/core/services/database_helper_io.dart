import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/logger.dart';
import '../../app/app_config.dart';

/// 数据库帮助类（IO 平台实现）
class DatabaseHelper {
  /// 打开数据库
  static Future<Database> openDatabase(String name, int version) async {
    final databasePath = await _getDatabasePath(name);
    Logger.debug('数据库路径: $databasePath');
    
    return await openDatabase(
      databasePath,
      version: version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
      onConfigure: _onConfigure,
    );
  }
  
  /// 关闭数据库
  static Future<void> closeDatabase(sqflite.Database database) async {
    await database.close();
  }
  
  /// 获取数据库路径
  static Future<String> _getDatabasePath(String name) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return path.join(documentsDirectory.path, name);
  }
  
  /// 配置数据库
  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
  
  /// 创建数据库表
  static Future<void> _onCreate(Database db, int version) async {
    Logger.info('创建数据库表...');
    
    try {
      // 创建习惯表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS habits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          icon TEXT,
          category TEXT,
          importance INTEGER DEFAULT 3,
          difficulty TEXT DEFAULT 'medium',
          cycle_type TEXT DEFAULT 'daily',
          cycle_config TEXT,
          start_date TEXT NOT NULL,
          end_date TEXT,
          is_active INTEGER DEFAULT 1,
          is_deleted INTEGER DEFAULT 0,
          total_checkins INTEGER DEFAULT 0,
          streak_count INTEGER DEFAULT 0,
          max_streak INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      
      // 创建打卡记录表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS check_ins (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habit_id INTEGER NOT NULL,
          check_date TEXT NOT NULL,
          check_time TEXT NOT NULL,
          status TEXT DEFAULT 'completed',
          note TEXT,
          mood TEXT,
          quality_score INTEGER,
          duration_minutes INTEGER,
          photos TEXT,
          is_makeup INTEGER DEFAULT 0,
          makeup_original_date TEXT,
          latitude REAL,
          longitude REAL,
          location_name TEXT,
          extra_data TEXT,
          created_at TEXT,
          updated_at TEXT,
          FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
        )
      ''');
      
      // 创建日志表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS journals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT NOT NULL,
          mood TEXT,
          photos TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      
      // 创建习惯-日志关联表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS habit_journal_relations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habit_id INTEGER NOT NULL,
          journal_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
          FOREIGN KEY (journal_id) REFERENCES journals(id) ON DELETE CASCADE,
          UNIQUE(habit_id, journal_id)
        )
      ''');
      
      // 创建用户设置表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT NOT NULL UNIQUE,
          value TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      
      // 创建成就表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS achievements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          icon TEXT,
          category TEXT,
          condition_type TEXT NOT NULL,
          condition_config TEXT NOT NULL,
          reward_type TEXT,
          reward_config TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      
      // 创建获得的成就表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS earned_achievements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          achievement_id INTEGER NOT NULL,
          earned_at TEXT NOT NULL,
          FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
        )
      ''');
      
      // 创建习惯模板表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS habit_templates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          icon TEXT,
          category TEXT,
          cycle_type TEXT DEFAULT 'daily',
          created_at TEXT NOT NULL
        )
      ''');
      
      Logger.info('数据库表创建完成');
      
    } catch (e, stackTrace) {
      Logger.error('数据库表创建失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// 升级数据库
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Logger.info('升级数据库从版本 $oldVersion 到 $newVersion');
    // 这里可以添加数据库升级逻辑
  }
  
  /// 降级数据库
  static Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    Logger.info('降级数据库从版本 $oldVersion 到 $newVersion');
    // 这里可以添加数据库降级逻辑
  }
}

