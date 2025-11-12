import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/logger.dart';

/// 日志数据访问仓库
class JournalRepository {
  final DatabaseService _databaseService;

  JournalRepository(this._databaseService);

  /// 获取数据库实例
  Database get _database {
    if (_databaseService.database == null) {
      throw Exception('数据库未初始化');
    }
    return _databaseService.database!;
  }

  /// 创建日志
  Future<Journal> create(Journal journal) async {
    try {
      Logger.info('创建日志: ${journal.title}');
      
      final id = await _database.insert(
        'journals', 
        journal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      final createdJournal = journal.copyWith(id: id);
      
      Logger.info('日志创建成功，ID: $id');
      return createdJournal;
      
    } catch (e, stackTrace) {
      Logger.error('创建日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据ID获取日志
  Future<Journal?> getById(int id) async {
    try {
      Logger.debug('获取日志: ID=$id');
      
      final result = await _database.query(
        'journals',
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [id],
        limit: 1,
      );
      
      if (result.isEmpty) {
        Logger.debug('日志不存在: ID=$id');
        return null;
      }
      
      final journal = Journal.fromMap(result.first);
      Logger.debug('获取日志成功: ${journal.title}');
      return journal;
      
    } catch (e, stackTrace) {
      Logger.error('获取日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取所有日志
  Future<List<Journal>> getAll({int? limit, int? offset}) async {
    try {
      Logger.debug('获取所有日志');
      
      final result = await _database.query(
        'journals',
        where: 'is_deleted = 0',
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      
      final journals = result.map((map) => Journal.fromMap(map)).toList();
      
      Logger.debug('获取所有日志成功: ${journals.length}个');
      return journals;
      
    } catch (e, stackTrace) {
      Logger.error('获取所有日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据日期获取日志
  Future<List<Journal>> getByDate(String date) async {
    try {
      Logger.debug('获取日期日志: $date');
      
      final result = await _database.query(
        'journals',
        where: 'date = ? AND is_deleted = 0',
        whereArgs: [date],
        orderBy: 'created_at DESC',
      );
      
      final journals = result.map((map) => Journal.fromMap(map)).toList();
      
      Logger.debug('获取日期日志成功: ${journals.length}个');
      return journals;
      
    } catch (e, stackTrace) {
      Logger.error('获取日期日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取日期范围内的日志
  Future<List<Journal>> getByDateRange({
    required String startDate,
    required String endDate,
    JournalType? type,
    int? limit,
    int? offset,
  }) async {
    try {
      Logger.debug('获取日期范围日志: $startDate ~ $endDate');
      
      String whereClause = 'date >= ? AND date <= ? AND is_deleted = 0';
      List<Object> whereArgs = [startDate, endDate];
      
      if (type != null) {
        whereClause += ' AND type = ?';
        whereArgs.add(type.name);
      }
      
      final result = await _database.query(
        'journals',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date DESC, created_at DESC',
        limit: limit,
        offset: offset,
      );
      
      final journals = result.map((map) => Journal.fromMap(map)).toList();
      
      Logger.debug('获取日期范围日志成功: ${journals.length}个');
      return journals;
      
    } catch (e, stackTrace) {
      Logger.error('获取日期范围日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据类型获取日志
  Future<List<Journal>> getByType(JournalType type, {int? limit, int? offset}) async {
    try {
      Logger.debug('获取类型日志: ${type.name}');
      
      final result = await _database.query(
        'journals',
        where: 'type = ? AND is_deleted = 0',
        whereArgs: [type.name],
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      
      final journals = result.map((map) => Journal.fromMap(map)).toList();
      
      Logger.debug('获取类型日志成功: ${journals.length}个');
      return journals;
      
    } catch (e, stackTrace) {
      Logger.error('获取类型日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取收藏的日志
  Future<List<Journal>> getFavorites({int? limit, int? offset}) async {
    try {
      Logger.debug('获取收藏日志');
      
      final result = await _database.query(
        'journals',
        where: 'is_favorite = 1 AND is_deleted = 0',
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      
      final journals = result.map((map) => Journal.fromMap(map)).toList();
      
      Logger.debug('获取收藏日志成功: ${journals.length}个');
      return journals;
      
    } catch (e, stackTrace) {
      Logger.error('获取收藏日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取置顶的日志
  Future<List<Journal>> getPinned() async {
    try {
      Logger.debug('获取置顶日志');
      
      final result = await _database.query(
        'journals',
        where: 'is_pinned = 1 AND is_deleted = 0',
        orderBy: 'created_at DESC',
      );
      
      final journals = result.map((map) => Journal.fromMap(map)).toList();
      
      Logger.debug('获取置顶日志成功: ${journals.length}个');
      return journals;
      
    } catch (e, stackTrace) {
      Logger.error('获取置顶日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 搜索日志
  Future<List<Journal>> search(String keyword, {int? limit, int? offset}) async {
    try {
      Logger.debug('搜索日志: $keyword');
      
      final result = await _database.query(
        'journals',
        where: '(title LIKE ? OR content LIKE ?) AND is_deleted = 0',
        whereArgs: ['%$keyword%', '%$keyword%'],
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      
      final journals = result.map((map) => Journal.fromMap(map)).toList();
      
      Logger.debug('搜索日志结果: ${journals.length}个');
      return journals;
      
    } catch (e, stackTrace) {
      Logger.error('搜索日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据标签搜索日志
  Future<List<Journal>> searchByTag(String tag, {int? limit, int? offset}) async {
    try {
      Logger.debug('根据标签搜索日志: $tag');
      
      final result = await _database.query(
        'journals',
        where: 'tags LIKE ? AND is_deleted = 0',
        whereArgs: ['%"$tag"%'],
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      
      final journals = result.map((map) => Journal.fromMap(map)).toList();
      
      Logger.debug('标签搜索结果: ${journals.length}个');
      return journals;
      
    } catch (e, stackTrace) {
      Logger.error('根据标签搜索日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新日志
  Future<Journal> update(Journal journal) async {
    try {
      Logger.info('更新日志: ${journal.title} (ID: ${journal.id})');
      
      if (journal.id == null) {
        throw ArgumentError('日志ID不能为空');
      }
      
      final updateCount = await _database.update(
        'journals',
        journal.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [journal.id],
      );
      
      if (updateCount == 0) {
        throw Exception('未找到要更新的日志');
      }
      
      final updatedJournal = journal.copyWith(updatedAt: DateTime.now());
      
      Logger.info('日志更新成功');
      return updatedJournal;
      
    } catch (e, stackTrace) {
      Logger.error('更新日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 软删除日志
  Future<bool> delete(int id) async {
    try {
      Logger.info('删除日志: ID=$id');
      
      final updateCount = await _database.update(
        'journals',
        {
          'is_deleted': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      
      final success = updateCount > 0;
      
      if (success) {
        Logger.info('日志删除成功');
      } else {
        Logger.warning('未找到要删除的日志');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('删除日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 恢复已删除的日志
  Future<bool> restore(int id) async {
    try {
      Logger.info('恢复日志: ID=$id');
      
      final updateCount = await _database.update(
        'journals',
        {
          'is_deleted': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      
      final success = updateCount > 0;
      
      if (success) {
        Logger.info('日志恢复成功');
      } else {
        Logger.warning('未找到要恢复的日志');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('恢复日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 硬删除日志（永久删除）
  Future<bool> permanentDelete(int id) async {
    try {
      Logger.warning('永久删除日志: ID=$id');
      
      final deleteCount = await _database.delete(
        'journals',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      final success = deleteCount > 0;
      
      if (success) {
        Logger.warning('日志永久删除成功');
      } else {
        Logger.warning('未找到要永久删除的日志');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('永久删除日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 切换收藏状态
  Future<Journal> toggleFavorite(int id) async {
    try {
      Logger.info('切换日志收藏状态: ID=$id');
      
      final journal = await getById(id);
      if (journal == null) {
        throw Exception('日志不存在');
      }
      
      final updatedJournal = await update(journal.copyWith(isFavorite: !journal.isFavorite));
      
      Logger.info('日志收藏状态切换成功: ${updatedJournal.isFavorite}');
      return updatedJournal;
      
    } catch (e, stackTrace) {
      Logger.error('切换日志收藏状态失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 切换置顶状态
  Future<Journal> togglePinned(int id) async {
    try {
      Logger.info('切换日志置顶状态: ID=$id');
      
      final journal = await getById(id);
      if (journal == null) {
        throw Exception('日志不存在');
      }
      
      final updatedJournal = await update(journal.copyWith(isPinned: !journal.isPinned));
      
      Logger.info('日志置顶状态切换成功: ${updatedJournal.isPinned}');
      return updatedJournal;
      
    } catch (e, stackTrace) {
      Logger.error('切换日志置顶状态失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取已删除的日志
  Future<List<Journal>> getDeleted() async {
    try {
      Logger.debug('获取已删除的日志');
      
      final result = await _database.query(
        'journals',
        where: 'is_deleted = 1',
        orderBy: 'updated_at DESC',
      );
      
      final journals = result.map((map) => Journal.fromMap(map)).toList();
      
      Logger.debug('获取已删除日志成功: ${journals.length}个');
      return journals;
      
    } catch (e, stackTrace) {
      Logger.error('获取已删除日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取日志统计
  Future<Map<String, dynamic>> getStats() async {
    try {
      Logger.debug('获取日志统计');
      
      // 总数统计
      final totalResult = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM journals WHERE is_deleted = 0'
      );
      final totalCount = totalResult.first['count'] as int;
      
      // 按类型统计
      final typeResult = await _database.rawQuery('''
        SELECT type, COUNT(*) as count
        FROM journals 
        WHERE is_deleted = 0 
        GROUP BY type 
        ORDER BY count DESC
      ''');
      
      final typeStats = <String, int>{};
      for (final row in typeResult) {
        typeStats[row['type'] as String] = row['count'] as int;
      }
      
      // 收藏数量
      final favoriteResult = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM journals WHERE is_favorite = 1 AND is_deleted = 0'
      );
      final favoriteCount = favoriteResult.first['count'] as int;
      
      // 字数统计
      final wordCountResult = await _database.rawQuery(
        'SELECT SUM(word_count) as total_words FROM journals WHERE is_deleted = 0'
      );
      final totalWords = wordCountResult.first['total_words'] as int? ?? 0;
      
      final stats = {
        'totalCount': totalCount,
        'favoriteCount': favoriteCount,
        'totalWords': totalWords,
        'typeStats': typeStats,
      };
      
      Logger.debug('日志统计获取成功');
      return stats;
      
    } catch (e, stackTrace) {
      Logger.error('获取日志统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取所有标签
  Future<List<String>> getAllTags() async {
    try {
      Logger.debug('获取所有标签');
      
      final result = await _database.rawQuery('''
        SELECT DISTINCT tags 
        FROM journals 
        WHERE tags IS NOT NULL AND tags != '' AND is_deleted = 0
      ''');
      
      final allTags = <String>{};
      
      for (final row in result) {
        final tagsJson = row['tags'] as String?;
        if (tagsJson != null && tagsJson.isNotEmpty) {
          try {
            // 简单解析JSON数组格式的标签
            final tags = tagsJson
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty);
            
            allTags.addAll(tags);
          } catch (e) {
            // 如果解析失败，忽略这个标签
            Logger.debug('标签解析失败: $tagsJson');
          }
        }
      }
      
      final tagList = allTags.toList()..sort();
      
      Logger.debug('获取所有标签成功: ${tagList.length}个');
      return tagList;
      
    } catch (e, stackTrace) {
      Logger.error('获取所有标签失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取今天的日志
  Future<List<Journal>> getTodayJournals() async {
    final today = DateTime.now();
    final todayStr = Journal.formatDate(today);
    return await getByDate(todayStr);
  }

  /// 获取本周的日志
  Future<List<Journal>> getWeekJournals() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return await getByDateRange(
      startDate: Journal.formatDate(startOfWeek),
      endDate: Journal.formatDate(endOfWeek),
    );
  }

  /// 获取本月的日志
  Future<List<Journal>> getMonthJournals() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return await getByDateRange(
      startDate: Journal.formatDate(startOfMonth),
      endDate: Journal.formatDate(endOfMonth),
    );
  }
}