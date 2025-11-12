import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 条件导入：仅在非 Web 平台导入 sqflite
import 'database_stub.dart'
    if (dart.library.io) 'package:sqflite/sqflite.dart';

/// 习惯数据访问仓库
class HabitRepository {
  final DatabaseService _databaseService;

  HabitRepository(this._databaseService);

  /// 获取数据库实例
  Database? get _database {
    return _databaseService.database;
  }
  
  /// 检查数据库是否可用
  bool get _isDatabaseAvailable => _database != null && !kIsWeb;

  /// 创建习惯
  Future<Habit> create(Habit habit) async {
    try {
      Logger.info('创建习惯: ${habit.name}');
      
      if (!_isDatabaseAvailable) {
        Logger.info('Web 平台：数据库不可用，返回模拟数据');
        // Web 平台上返回一个带临时 ID 的习惯
        return habit.copyWith(id: DateTime.now().millisecondsSinceEpoch);
      }
      
      final id = await _database!.insert(
        'habits', 
        habit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      final createdHabit = habit.copyWith(id: id);
      
      Logger.info('习惯创建成功，ID: $id');
      return createdHabit;
      
    } catch (e, stackTrace) {
      Logger.error('创建习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 批量创建习惯
  Future<List<Habit>> createBatch(List<Habit> habits) async {
    try {
      Logger.info('批量创建习惯: ${habits.length}个');
      
      final batch = _database.batch();
      for (final habit in habits) {
        batch.insert('habits', habit.toMap());
      }
      
      final results = await batch.commit();
      
      final createdHabits = <Habit>[];
      for (int i = 0; i < habits.length; i++) {
        final id = results[i] as int;
        createdHabits.add(habits[i].copyWith(id: id));
      }
      
      Logger.info('批量创建习惯成功');
      return createdHabits;
      
    } catch (e, stackTrace) {
      Logger.error('批量创建习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据ID获取习惯
  Future<Habit?> getById(int id) async {
    try {
      Logger.debug('获取习惯: ID=$id');
      
      if (!_isDatabaseAvailable) {
        Logger.info('Web 平台：数据库不可用，返回 null');
        return null;
      }
      
      final result = await _database!.query(
        'habits',
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [id],
        limit: 1,
      );
      
      if (result.isEmpty) {
        Logger.debug('习惯不存在: ID=$id');
        return null;
      }
      
      final habit = Habit.fromMap(result.first);
      Logger.debug('获取习惯成功: ${habit.name}');
      return habit;
      
    } catch (e, stackTrace) {
      Logger.error('获取习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取所有激活的习惯
  Future<List<Habit>> getActive() async {
    try {
      Logger.debug('获取所有激活的习惯');
      
      if (!_isDatabaseAvailable) {
        Logger.info('Web 平台：数据库不可用，返回空列表');
        return [];
      }
      
      final result = await _database!.query(
        'habits',
        where: 'is_active = 1 AND is_deleted = 0',
        orderBy: 'sort_order ASC, created_at ASC',
      );
      
      final habits = result.map((map) => Habit.fromMap(map)).toList();
      
      Logger.debug('获取激活习惯成功: ${habits.length}个');
      return habits;
      
    } catch (e, stackTrace) {
      Logger.error('获取激活习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取所有习惯（包括未激活的）
  Future<List<Habit>> getAll() async {
    try {
      Logger.debug('获取所有习惯');
      
      if (!_isDatabaseAvailable) {
        Logger.info('Web 平台：数据库不可用，返回空列表');
        return [];
      }
      
      final result = await _database!.query(
        'habits',
        where: 'is_deleted = 0',
        orderBy: 'sort_order ASC, created_at ASC',
      );
      
      final habits = result.map((map) => Habit.fromMap(map)).toList();
      
      Logger.debug('获取所有习惯成功: ${habits.length}个');
      return habits;
      
    } catch (e, stackTrace) {
      Logger.error('获取所有习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据分类获取习惯
  Future<List<Habit>> getByCategory(String category) async {
    try {
      Logger.debug('获取分类习惯: $category');
      
      final result = await _database.query(
        'habits',
        where: 'category = ? AND is_deleted = 0',
        whereArgs: [category],
        orderBy: 'sort_order ASC, created_at ASC',
      );
      
      final habits = result.map((map) => Habit.fromMap(map)).toList();
      
      Logger.debug('获取分类习惯成功: ${habits.length}个');
      return habits;
      
    } catch (e, stackTrace) {
      Logger.error('获取分类习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取今天应该执行的习惯
  Future<List<Habit>> getTodayHabits() async {
    try {
      Logger.debug('获取今天应该执行的习惯');
      
      final allActiveHabits = await getActive();
      final todayHabits = allActiveHabits.where((habit) => habit.shouldExecuteToday()).toList();
      
      Logger.debug('今天应该执行的习惯: ${todayHabits.length}个');
      return todayHabits;
      
    } catch (e, stackTrace) {
      Logger.error('获取今天习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 搜索习惯
  Future<List<Habit>> search(String keyword) async {
    try {
      Logger.debug('搜索习惯: $keyword');
      
      final result = await _database.query(
        'habits',
        where: '(name LIKE ? OR description LIKE ?) AND is_deleted = 0',
        whereArgs: ['%$keyword%', '%$keyword%'],
        orderBy: 'sort_order ASC, created_at ASC',
      );
      
      final habits = result.map((map) => Habit.fromMap(map)).toList();
      
      Logger.debug('搜索习惯结果: ${habits.length}个');
      return habits;
      
    } catch (e, stackTrace) {
      Logger.error('搜索习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新习惯
  Future<Habit> update(Habit habit) async {
    try {
      Logger.info('更新习惯: ${habit.name} (ID: ${habit.id})');
      
      if (habit.id == null) {
        throw ArgumentError('习惯ID不能为空');
      }
      
      final updateCount = await _database.update(
        'habits',
        habit.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [habit.id],
      );
      
      if (updateCount == 0) {
        throw Exception('未找到要更新的习惯');
      }
      
      final updatedHabit = habit.copyWith(updatedAt: DateTime.now());
      
      Logger.info('习惯更新成功');
      return updatedHabit;
      
    } catch (e, stackTrace) {
      Logger.error('更新习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 批量更新习惯
  Future<List<Habit>> updateBatch(List<Habit> habits) async {
    try {
      Logger.info('批量更新习惯: ${habits.length}个');
      
      final batch = _database.batch();
      final now = DateTime.now();
      
      for (final habit in habits) {
        if (habit.id == null) {
          throw ArgumentError('习惯ID不能为空: ${habit.name}');
        }
        
        batch.update(
          'habits', 
          habit.copyWith(updatedAt: now).toMap(),
          where: 'id = ?',
          whereArgs: [habit.id],
        );
      }
      
      await batch.commit(noResult: true);
      
      final updatedHabits = habits.map((habit) => habit.copyWith(updatedAt: now)).toList();
      
      Logger.info('批量更新习惯成功');
      return updatedHabits;
      
    } catch (e, stackTrace) {
      Logger.error('批量更新习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 软删除习惯
  Future<bool> delete(int id) async {
    try {
      Logger.info('删除习惯: ID=$id');
      
      final updateCount = await _database.update(
        'habits',
        {
          'is_deleted': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      
      final success = updateCount > 0;
      
      if (success) {
        Logger.info('习惯删除成功');
      } else {
        Logger.warning('未找到要删除的习惯');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('删除习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 恢复已删除的习惯
  Future<bool> restore(int id) async {
    try {
      Logger.info('恢复习惯: ID=$id');
      
      final updateCount = await _database.update(
        'habits',
        {
          'is_deleted': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      
      final success = updateCount > 0;
      
      if (success) {
        Logger.info('习惯恢复成功');
      } else {
        Logger.warning('未找到要恢复的习惯');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('恢复习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 硬删除习惯（永久删除）
  Future<bool> permanentDelete(int id) async {
    try {
      Logger.warning('永久删除习惯: ID=$id');
      
      final deleteCount = await _database.delete(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      final success = deleteCount > 0;
      
      if (success) {
        Logger.warning('习惯永久删除成功');
      } else {
        Logger.warning('未找到要永久删除的习惯');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('永久删除习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 切换习惯激活状态
  Future<Habit> toggleActive(int id) async {
    try {
      Logger.info('切换习惯激活状态: ID=$id');
      
      final habit = await getById(id);
      if (habit == null) {
        throw Exception('习惯不存在');
      }
      
      final updatedHabit = await update(habit.copyWith(isActive: !habit.isActive));
      
      Logger.info('习惯激活状态已切换: ${updatedHabit.isActive}');
      return updatedHabit;
      
    } catch (e, stackTrace) {
      Logger.error('切换习惯激活状态失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新习惯统计数据
  Future<Habit> updateStats({
    required int id,
    int? totalCheckIns,
    int? streakCount,
    int? maxStreak,
  }) async {
    try {
      Logger.debug('更新习惯统计: ID=$id');
      
      final habit = await getById(id);
      if (habit == null) {
        throw Exception('习惯不存在');
      }
      
      final updatedHabit = habit.copyWith(
        totalCheckIns: totalCheckIns ?? habit.totalCheckIns,
        streakCount: streakCount ?? habit.streakCount,
        maxStreak: maxStreak ?? habit.maxStreak,
      );
      
      await update(updatedHabit);
      
      Logger.debug('习惯统计更新成功');
      return updatedHabit;
      
    } catch (e, stackTrace) {
      Logger.error('更新习惯统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 重新排序习惯
  Future<void> reorder(List<int> habitIds) async {
    try {
      Logger.info('重新排序习惯: ${habitIds.length}个');
      
      final batch = _database.batch();
      
      for (int i = 0; i < habitIds.length; i++) {
        batch.update(
          'habits',
          {
            'sort_order': i,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [habitIds[i]],
        );
      }
      
      await batch.commit(noResult: true);
      
      Logger.info('习惯排序更新成功');
      
    } catch (e, stackTrace) {
      Logger.error('重新排序习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取已删除的习惯
  Future<List<Habit>> getDeleted() async {
    try {
      Logger.debug('获取已删除的习惯');
      
      final result = await _database.query(
        'habits',
        where: 'is_deleted = 1',
        orderBy: 'updated_at DESC',
      );
      
      final habits = result.map((map) => Habit.fromMap(map)).toList();
      
      Logger.debug('获取已删除习惯成功: ${habits.length}个');
      return habits;
      
    } catch (e, stackTrace) {
      Logger.error('获取已删除习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯分类统计
  Future<Map<String, int>> getCategoryStats() async {
    try {
      Logger.debug('获取习惯分类统计');
      
      final result = await _database.rawQuery('''
        SELECT category, COUNT(*) as count
        FROM habits 
        WHERE is_deleted = 0 
        GROUP BY category 
        ORDER BY count DESC
      ''');
      
      final stats = <String, int>{};
      for (final row in result) {
        stats[row['category'] as String] = row['count'] as int;
      }
      
      Logger.debug('习惯分类统计: ${stats.keys.length}个分类');
      return stats;
      
    } catch (e, stackTrace) {
      Logger.error('获取习惯分类统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯总数
  Future<int> getTotalCount() async {
    try {
      final result = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM habits WHERE is_deleted = 0'
      );
      
      final count = result.first['count'] as int;
      Logger.debug('习惯总数: $count');
      return count;
      
    } catch (e, stackTrace) {
      Logger.error('获取习惯总数失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取激活习惯数
  Future<int> getActiveCount() async {
    try {
      final result = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM habits WHERE is_active = 1 AND is_deleted = 0'
      );
      
      final count = result.first['count'] as int;
      Logger.debug('激活习惯数: $count');
      return count;
      
    } catch (e, stackTrace) {
      Logger.error('获取激活习惯数失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}