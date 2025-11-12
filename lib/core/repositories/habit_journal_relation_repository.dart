import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/logger.dart';

/// 习惯-日志关联数据访问仓库
class HabitJournalRelationRepository {
  final DatabaseService _databaseService;

  HabitJournalRelationRepository(this._databaseService);

  /// 获取数据库实例
  Database get _database {
    if (_databaseService.database == null) {
      throw Exception('数据库未初始化');
    }
    return _databaseService.database!;
  }

  /// 创建关联关系
  Future<HabitJournalRelation> create(HabitJournalRelation relation) async {
    try {
      Logger.info('创建习惯-日志关联: 习惯ID=${relation.habitId}, 日志ID=${relation.journalId}');
      
      final id = await _database.insert(
        'habit_journal_relations', 
        relation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      final createdRelation = relation.copyWith(id: id);
      
      Logger.info('关联关系创建成功，ID: $id');
      return createdRelation;
      
    } catch (e, stackTrace) {
      Logger.error('创建关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据ID获取关联关系
  Future<HabitJournalRelation?> getById(int id) async {
    try {
      Logger.debug('获取关联关系: ID=$id');
      
      final result = await _database.query(
        'habit_journal_relations',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (result.isEmpty) {
        Logger.debug('关联关系不存在: ID=$id');
        return null;
      }
      
      final relation = HabitJournalRelation.fromMap(result.first);
      Logger.debug('获取关联关系成功');
      return relation;
      
    } catch (e, stackTrace) {
      Logger.error('获取关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据习惯ID和日志ID获取关联关系
  Future<HabitJournalRelation?> getByHabitAndJournal(int habitId, int journalId) async {
    try {
      Logger.debug('获取习惯-日志关联: 习惯ID=$habitId, 日志ID=$journalId');
      
      final result = await _database.query(
        'habit_journal_relations',
        where: 'habit_id = ? AND journal_id = ?',
        whereArgs: [habitId, journalId],
        limit: 1,
      );
      
      if (result.isEmpty) {
        Logger.debug('关联关系不存在');
        return null;
      }
      
      final relation = HabitJournalRelation.fromMap(result.first);
      Logger.debug('获取关联关系成功');
      return relation;
      
    } catch (e, stackTrace) {
      Logger.error('获取关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯关联的所有日志
  Future<List<Map<String, dynamic>>> getJournalsByHabit(int habitId) async {
    try {
      Logger.debug('获取习惯关联的所有日志: 习惯ID=$habitId');
      
      final result = await _database.rawQuery('''
        SELECT 
          j.*,
          hjr.relation_type,
          hjr.relation_note,
          hjr.weight,
          hjr.is_auto_generated,
          hjr.is_confirmed,
          hjr.created_at as relation_created_at
        FROM journals j
        INNER JOIN habit_journal_relations hjr ON j.id = hjr.journal_id
        WHERE hjr.habit_id = ? AND j.is_deleted = 0
        ORDER BY hjr.created_at DESC
      ''', [habitId]);
      
      Logger.debug('获取习惯关联日志成功: ${result.length}篇');
      return result;
      
    } catch (e, stackTrace) {
      Logger.error('获取习惯关联日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取日志关联的所有习惯
  Future<List<Map<String, dynamic>>> getHabitsByJournal(int journalId) async {
    try {
      Logger.debug('获取日志关联的所有习惯: 日志ID=$journalId');
      
      final result = await _database.rawQuery('''
        SELECT 
          h.*,
          hjr.relation_type,
          hjr.relation_note,
          hjr.weight,
          hjr.is_auto_generated,
          hjr.is_confirmed,
          hjr.created_at as relation_created_at
        FROM habits h
        INNER JOIN habit_journal_relations hjr ON h.id = hjr.habit_id
        WHERE hjr.journal_id = ? AND h.is_deleted = 0
        ORDER BY hjr.created_at DESC
      ''', [journalId]);
      
      Logger.debug('获取日志关联习惯成功: ${result.length}个');
      return result;
      
    } catch (e, stackTrace) {
      Logger.error('获取日志关联习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取所有关联关系
  Future<List<HabitJournalRelation>> getAll() async {
    try {
      Logger.debug('获取所有关联关系');
      
      final result = await _database.query(
        'habit_journal_relations',
        orderBy: 'created_at DESC',
      );
      
      final relations = result.map((map) => HabitJournalRelation.fromMap(map)).toList();
      
      Logger.debug('获取所有关联关系成功: ${relations.length}个');
      return relations;
      
    } catch (e, stackTrace) {
      Logger.error('获取所有关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据关联类型获取关联关系
  Future<List<HabitJournalRelation>> getByType(String relationType) async {
    try {
      Logger.debug('获取指定类型的关联关系: $relationType');
      
      final result = await _database.query(
        'habit_journal_relations',
        where: 'relation_type = ?',
        whereArgs: [relationType],
        orderBy: 'created_at DESC',
      );
      
      final relations = result.map((map) => HabitJournalRelation.fromMap(map)).toList();
      
      Logger.debug('获取指定类型关联关系成功: ${relations.length}个');
      return relations;
      
    } catch (e, stackTrace) {
      Logger.error('获取指定类型关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取自动生成的关联关系
  Future<List<HabitJournalRelation>> getAutoGenerated() async {
    try {
      Logger.debug('获取自动生成的关联关系');
      
      final result = await _database.query(
        'habit_journal_relations',
        where: 'is_auto_generated = 1',
        orderBy: 'created_at DESC',
      );
      
      final relations = result.map((map) => HabitJournalRelation.fromMap(map)).toList();
      
      Logger.debug('获取自动生成关联关系成功: ${relations.length}个');
      return relations;
      
    } catch (e, stackTrace) {
      Logger.error('获取自动生成关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取未确认的关联关系
  Future<List<HabitJournalRelation>> getUnconfirmed() async {
    try {
      Logger.debug('获取未确认的关联关系');
      
      final result = await _database.query(
        'habit_journal_relations',
        where: 'is_confirmed = 0',
        orderBy: 'created_at DESC',
      );
      
      final relations = result.map((map) => HabitJournalRelation.fromMap(map)).toList();
      
      Logger.debug('获取未确认关联关系成功: ${relations.length}个');
      return relations;
      
    } catch (e, stackTrace) {
      Logger.error('获取未确认关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新关联关系
  Future<HabitJournalRelation> update(HabitJournalRelation relation) async {
    try {
      Logger.info('更新关联关系: ID=${relation.id}');
      
      if (relation.id == null) {
        throw ArgumentError('关联关系ID不能为空');
      }
      
      final updateCount = await _database.update(
        'habit_journal_relations',
        relation.toMap(),
        where: 'id = ?',
        whereArgs: [relation.id],
      );
      
      if (updateCount == 0) {
        throw Exception('未找到要更新的关联关系');
      }
      
      Logger.info('关联关系更新成功');
      return relation;
      
    } catch (e, stackTrace) {
      Logger.error('更新关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除关联关系
  Future<bool> delete(int id) async {
    try {
      Logger.info('删除关联关系: ID=$id');
      
      final deleteCount = await _database.delete(
        'habit_journal_relations',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      final success = deleteCount > 0;
      
      if (success) {
        Logger.info('关联关系删除成功');
      } else {
        Logger.warning('未找到要删除的关联关系');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('删除关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除习惯的所有关联关系
  Future<int> deleteByHabitId(int habitId) async {
    try {
      Logger.info('删除习惯的所有关联关系: 习惯ID=$habitId');
      
      final deleteCount = await _database.delete(
        'habit_journal_relations',
        where: 'habit_id = ?',
        whereArgs: [habitId],
      );
      
      Logger.info('删除习惯关联关系成功: ${deleteCount}个');
      return deleteCount;
      
    } catch (e, stackTrace) {
      Logger.error('删除习惯关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除日志的所有关联关系
  Future<int> deleteByJournalId(int journalId) async {
    try {
      Logger.info('删除日志的所有关联关系: 日志ID=$journalId');
      
      final deleteCount = await _database.delete(
        'habit_journal_relations',
        where: 'journal_id = ?',
        whereArgs: [journalId],
      );
      
      Logger.info('删除日志关联关系成功: ${deleteCount}个');
      return deleteCount;
      
    } catch (e, stackTrace) {
      Logger.error('删除日志关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除特定习惯和日志的关联关系
  Future<bool> deleteByHabitAndJournal(int habitId, int journalId) async {
    try {
      Logger.info('删除特定习惯-日志关联: 习惯ID=$habitId, 日志ID=$journalId');
      
      final deleteCount = await _database.delete(
        'habit_journal_relations',
        where: 'habit_id = ? AND journal_id = ?',
        whereArgs: [habitId, journalId],
      );
      
      final success = deleteCount > 0;
      
      if (success) {
        Logger.info('特定关联关系删除成功');
      } else {
        Logger.warning('未找到要删除的特定关联关系');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('删除特定关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 批量创建关联关系
  Future<List<HabitJournalRelation>> createBatch(List<HabitJournalRelation> relations) async {
    try {
      Logger.info('批量创建关联关系: ${relations.length}个');
      
      final batch = _database.batch();
      for (final relation in relations) {
        batch.insert('habit_journal_relations', relation.toMap());
      }
      
      final results = await batch.commit();
      
      final createdRelations = <HabitJournalRelation>[];
      for (int i = 0; i < relations.length; i++) {
        final id = results[i] as int;
        createdRelations.add(relations[i].copyWith(id: id));
      }
      
      Logger.info('批量创建关联关系成功');
      return createdRelations;
      
    } catch (e, stackTrace) {
      Logger.error('批量创建关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 检查关联关系是否存在
  Future<bool> exists(int habitId, int journalId) async {
    try {
      final relation = await getByHabitAndJournal(habitId, journalId);
      return relation != null;
      
    } catch (e, stackTrace) {
      Logger.error('检查关联关系是否存在失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 确认关联关系
  Future<HabitJournalRelation> confirmRelation(int id) async {
    try {
      Logger.info('确认关联关系: ID=$id');
      
      final relation = await getById(id);
      if (relation == null) {
        throw Exception('关联关系不存在');
      }
      
      final confirmedRelation = relation.copyWith(isConfirmed: true);
      return await update(confirmedRelation);
      
    } catch (e, stackTrace) {
      Logger.error('确认关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取关联统计信息
  Future<Map<String, int>> getStats() async {
    try {
      Logger.debug('获取关联统计信息');
      
      final totalResult = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM habit_journal_relations'
      );
      final total = totalResult.first['count'] as int;
      
      final confirmedResult = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM habit_journal_relations WHERE is_confirmed = 1'
      );
      final confirmed = confirmedResult.first['count'] as int;
      
      final autoGeneratedResult = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM habit_journal_relations WHERE is_auto_generated = 1'
      );
      final autoGenerated = autoGeneratedResult.first['count'] as int;
      
      final stats = {
        'total': total,
        'confirmed': confirmed,
        'unconfirmed': total - confirmed,
        'autoGenerated': autoGenerated,
        'manual': total - autoGenerated,
      };
      
      Logger.debug('关联统计信息: $stats');
      return stats;
      
    } catch (e, stackTrace) {
      Logger.error('获取关联统计信息失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取按类型分组的统计
  Future<Map<String, int>> getTypeStats() async {
    try {
      Logger.debug('获取按类型分组的关联统计');
      
      final result = await _database.rawQuery('''
        SELECT relation_type, COUNT(*) as count
        FROM habit_journal_relations 
        GROUP BY relation_type 
        ORDER BY count DESC
      ''');
      
      final stats = <String, int>{};
      for (final row in result) {
        stats[row['relation_type'] as String] = row['count'] as int;
      }
      
      Logger.debug('按类型分组关联统计: ${stats.keys.length}种类型');
      return stats;
      
    } catch (e, stackTrace) {
      Logger.error('获取按类型分组关联统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取最活跃的关联（按权重排序）
  Future<List<Map<String, dynamic>>> getTopRelations({int limit = 10}) async {
    try {
      Logger.debug('获取最活跃的关联: 前${limit}个');
      
      final result = await _database.rawQuery('''
        SELECT 
          hjr.*,
          h.name as habit_name,
          j.title as journal_title
        FROM habit_journal_relations hjr
        INNER JOIN habits h ON hjr.habit_id = h.id
        INNER JOIN journals j ON hjr.journal_id = j.id
        WHERE h.is_deleted = 0 AND j.is_deleted = 0
        ORDER BY hjr.weight DESC, hjr.created_at DESC
        LIMIT ?
      ''', [limit]);
      
      Logger.debug('获取最活跃关联成功: ${result.length}个');
      return result;
      
    } catch (e, stackTrace) {
      Logger.error('获取最活跃关联失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 搜索关联关系
  Future<List<Map<String, dynamic>>> search(String keyword) async {
    try {
      Logger.debug('搜索关联关系: $keyword');
      
      final result = await _database.rawQuery('''
        SELECT 
          hjr.*,
          h.name as habit_name,
          j.title as journal_title
        FROM habit_journal_relations hjr
        INNER JOIN habits h ON hjr.habit_id = h.id
        INNER JOIN journals j ON hjr.journal_id = j.id
        WHERE (h.name LIKE ? OR j.title LIKE ? OR hjr.relation_note LIKE ?)
          AND h.is_deleted = 0 AND j.is_deleted = 0
        ORDER BY hjr.created_at DESC
      ''', ['%$keyword%', '%$keyword%', '%$keyword%']);
      
      Logger.debug('搜索关联关系结果: ${result.length}个');
      return result;
      
    } catch (e, stackTrace) {
      Logger.error('搜索关联关系失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}