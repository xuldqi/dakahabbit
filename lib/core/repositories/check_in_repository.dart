import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/logger.dart';

/// 打卡记录数据访问仓库
class CheckInRepository {
  final DatabaseService _databaseService;

  CheckInRepository(this._databaseService);

  /// 获取数据库实例
  Database get _database {
    if (_databaseService.database == null) {
      throw Exception('数据库未初始化');
    }
    return _databaseService.database!;
  }

  /// 创建打卡记录
  Future<CheckIn> create(CheckIn checkIn) async {
    try {
      Logger.info('创建打卡记录: 习惯ID=${checkIn.habitId}, 日期=${checkIn.checkDate}');
      
      final id = await _database.insert(
        'check_ins', 
        checkIn.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      final createdCheckIn = checkIn.copyWith(id: id);
      
      Logger.info('打卡记录创建成功，ID: $id');
      return createdCheckIn;
      
    } catch (e, stackTrace) {
      Logger.error('创建打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据ID获取打卡记录
  Future<CheckIn?> getById(int id) async {
    try {
      Logger.debug('获取打卡记录: ID=$id');
      
      final result = await _database.query(
        'check_ins',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (result.isEmpty) {
        Logger.debug('打卡记录不存在: ID=$id');
        return null;
      }
      
      final checkIn = CheckIn.fromMap(result.first);
      Logger.debug('获取打卡记录成功: ${checkIn.habitId}');
      return checkIn;
      
    } catch (e, stackTrace) {
      Logger.error('获取打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据习惯ID和日期获取打卡记录
  Future<CheckIn?> getByHabitAndDate(int habitId, String date) async {
    try {
      Logger.debug('获取打卡记录: 习惯ID=$habitId, 日期=$date');
      
      final result = await _database.query(
        'check_ins',
        where: 'habit_id = ? AND check_date = ?',
        whereArgs: [habitId, date],
        limit: 1,
      );
      
      if (result.isEmpty) {
        Logger.debug('打卡记录不存在: 习惯ID=$habitId, 日期=$date');
        return null;
      }
      
      final checkIn = CheckIn.fromMap(result.first);
      Logger.debug('获取打卡记录成功');
      return checkIn;
      
    } catch (e, stackTrace) {
      Logger.error('获取打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯的所有打卡记录
  Future<List<CheckIn>> getByHabitId(int habitId, {int? limit, int? offset}) async {
    try {
      Logger.debug('获取习惯打卡记录: 习惯ID=$habitId');
      
      final result = await _database.query(
        'check_ins',
        where: 'habit_id = ?',
        whereArgs: [habitId],
        orderBy: 'check_date DESC, check_time DESC',
        limit: limit,
        offset: offset,
      );
      
      final checkIns = result.map((map) => CheckIn.fromMap(map)).toList();
      
      Logger.debug('获取习惯打卡记录成功: ${checkIns.length}个');
      return checkIns;
      
    } catch (e, stackTrace) {
      Logger.error('获取习惯打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取日期范围内的打卡记录
  Future<List<CheckIn>> getByDateRange({
    int? habitId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      Logger.debug('获取日期范围打卡记录: $startDate ~ $endDate');
      
      String whereClause = 'check_date >= ? AND check_date <= ?';
      List<Object> whereArgs = [startDate, endDate];
      
      if (habitId != null) {
        whereClause = 'habit_id = ? AND $whereClause';
        whereArgs.insert(0, habitId);
      }
      
      final result = await _database.query(
        'check_ins',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'check_date ASC, check_time ASC',
      );
      
      final checkIns = result.map((map) => CheckIn.fromMap(map)).toList();
      
      Logger.debug('获取日期范围打卡记录成功: ${checkIns.length}个');
      return checkIns;
      
    } catch (e, stackTrace) {
      Logger.error('获取日期范围打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取今天的打卡记录
  Future<List<CheckIn>> getTodayCheckIns({int? habitId}) async {
    final today = DateTime.now();
    final todayStr = CheckIn.formatDate(today);
    
    return await getByDateRange(
      habitId: habitId,
      startDate: todayStr,
      endDate: todayStr,
    );
  }

  /// 获取本周的打卡记录
  Future<List<CheckIn>> getWeekCheckIns({int? habitId}) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return await getByDateRange(
      habitId: habitId,
      startDate: CheckIn.formatDate(startOfWeek),
      endDate: CheckIn.formatDate(endOfWeek),
    );
  }

  /// 获取本月的打卡记录
  Future<List<CheckIn>> getMonthCheckIns({int? habitId}) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return await getByDateRange(
      habitId: habitId,
      startDate: CheckIn.formatDate(startOfMonth),
      endDate: CheckIn.formatDate(endOfMonth),
    );
  }

  /// 获取成功的打卡记录
  Future<List<CheckIn>> getSuccessfulCheckIns(int habitId, {int? limit}) async {
    try {
      Logger.debug('获取成功打卡记录: 习惯ID=$habitId');
      
      final result = await _database.query(
        'check_ins',
        where: 'habit_id = ? AND (status = ? OR status = ?)',
        whereArgs: [habitId, 'completed', 'partial'],
        orderBy: 'check_date DESC, check_time DESC',
        limit: limit,
      );
      
      final checkIns = result.map((map) => CheckIn.fromMap(map)).toList();
      
      Logger.debug('获取成功打卡记录: ${checkIns.length}个');
      return checkIns;
      
    } catch (e, stackTrace) {
      Logger.error('获取成功打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新打卡记录
  Future<CheckIn> update(CheckIn checkIn) async {
    try {
      Logger.info('更新打卡记录: ID=${checkIn.id}');
      
      if (checkIn.id == null) {
        throw ArgumentError('打卡记录ID不能为空');
      }
      
      final updateCount = await _database.update(
        'check_ins',
        checkIn.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [checkIn.id],
      );
      
      if (updateCount == 0) {
        throw Exception('未找到要更新的打卡记录');
      }
      
      final updatedCheckIn = checkIn.copyWith(updatedAt: DateTime.now());
      
      Logger.info('打卡记录更新成功');
      return updatedCheckIn;
      
    } catch (e, stackTrace) {
      Logger.error('更新打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除打卡记录
  Future<bool> delete(int id) async {
    try {
      Logger.info('删除打卡记录: ID=$id');
      
      final deleteCount = await _database.delete(
        'check_ins',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      final success = deleteCount > 0;
      
      if (success) {
        Logger.info('打卡记录删除成功');
      } else {
        Logger.warning('未找到要删除的打卡记录');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('删除打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除习惯的所有打卡记录
  Future<int> deleteByHabitId(int habitId) async {
    try {
      Logger.info('删除习惯的所有打卡记录: 习惯ID=$habitId');
      
      final deleteCount = await _database.delete(
        'check_ins',
        where: 'habit_id = ?',
        whereArgs: [habitId],
      );
      
      Logger.info('删除打卡记录: ${deleteCount}个');
      return deleteCount;
      
    } catch (e, stackTrace) {
      Logger.error('删除习惯打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 计算习惯的连击天数
  Future<int> getStreakCount(int habitId) async {
    try {
      Logger.debug('计算习惯连击: 习惯ID=$habitId');
      
      final result = await _database.rawQuery('''
        SELECT check_date, status
        FROM check_ins 
        WHERE habit_id = ? AND (status = 'completed' OR status = 'partial')
        ORDER BY check_date DESC
      ''', [habitId]);
      
      if (result.isEmpty) {
        return 0;
      }
      
      int streak = 0;
      DateTime? lastDate;
      
      for (final row in result) {
        final dateStr = row['check_date'] as String;
        final currentDate = DateTime.parse(dateStr);
        
        if (lastDate == null) {
          // 第一条记录
          lastDate = currentDate;
          streak = 1;
        } else {
          // 检查是否连续
          final difference = lastDate.difference(currentDate).inDays;
          if (difference == 1) {
            streak++;
            lastDate = currentDate;
          } else {
            break;
          }
        }
      }
      
      Logger.debug('计算连击完成: ${streak}天');
      return streak;
      
    } catch (e, stackTrace) {
      Logger.error('计算习惯连击失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 计算习惯的最大连击天数
  Future<int> getMaxStreakCount(int habitId) async {
    try {
      Logger.debug('计算最大连击: 习惯ID=$habitId');
      
      final result = await _database.rawQuery('''
        SELECT check_date, status
        FROM check_ins 
        WHERE habit_id = ? AND (status = 'completed' OR status = 'partial')
        ORDER BY check_date ASC
      ''', [habitId]);
      
      if (result.isEmpty) {
        return 0;
      }
      
      int maxStreak = 0;
      int currentStreak = 0;
      DateTime? lastDate;
      
      for (final row in result) {
        final dateStr = row['check_date'] as String;
        final currentDate = DateTime.parse(dateStr);
        
        if (lastDate == null) {
          // 第一条记录
          currentStreak = 1;
          lastDate = currentDate;
        } else {
          // 检查是否连续
          final difference = currentDate.difference(lastDate).inDays;
          if (difference == 1) {
            currentStreak++;
          } else {
            maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
            currentStreak = 1;
          }
          lastDate = currentDate;
        }
      }
      
      // 处理最后一段连击
      maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      
      Logger.debug('计算最大连击完成: ${maxStreak}天');
      return maxStreak;
      
    } catch (e, stackTrace) {
      Logger.error('计算最大连击失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯总打卡次数
  Future<int> getTotalCheckInCount(int habitId) async {
    try {
      final result = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM check_ins WHERE habit_id = ? AND (status = ? OR status = ?)',
        [habitId, 'completed', 'partial'],
      );
      
      final count = result.first['count'] as int;
      Logger.debug('习惯总打卡次数: $count');
      return count;
      
    } catch (e, stackTrace) {
      Logger.error('获取总打卡次数失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取完成率统计
  Future<Map<String, dynamic>> getCompletionStats(int habitId, {int? days}) async {
    try {
      Logger.debug('获取完成率统计: 习惯ID=$habitId');
      
      String whereClause = 'habit_id = ?';
      List<Object> whereArgs = [habitId];
      
      if (days != null) {
        final cutoffDate = DateTime.now().subtract(Duration(days: days));
        whereClause += ' AND check_date >= ?';
        whereArgs.add(CheckIn.formatDate(cutoffDate));
      }
      
      final result = await _database.rawQuery('''
        SELECT 
          status,
          COUNT(*) as count,
          AVG(quality_score) as avg_quality,
          SUM(duration_minutes) as total_duration
        FROM check_ins 
        WHERE $whereClause
        GROUP BY status
      ''', whereArgs);
      
      final stats = <String, dynamic>{
        'total': 0,
        'completed': 0,
        'partial': 0,
        'skipped': 0,
        'missed': 0,
        'successRate': 0.0,
        'averageQuality': 0.0,
        'totalDuration': 0,
      };
      
      for (final row in result) {
        final status = row['status'] as String;
        final count = row['count'] as int;
        final avgQuality = row['avg_quality'] as double?;
        final totalDuration = row['total_duration'] as int?;
        
        stats['total'] = (stats['total'] as int) + count;
        stats[status] = count;
        
        if (avgQuality != null) {
          stats['averageQuality'] = avgQuality;
        }
        
        if (totalDuration != null) {
          stats['totalDuration'] = (stats['totalDuration'] as int) + totalDuration;
        }
      }
      
      // 计算成功率
      final total = stats['total'] as int;
      if (total > 0) {
        final successful = (stats['completed'] as int) + (stats['partial'] as int);
        stats['successRate'] = successful / total;
      }
      
      Logger.debug('完成率统计获取成功');
      return stats;
      
    } catch (e, stackTrace) {
      Logger.error('获取完成率统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取热力图数据（按日期统计）
  Future<Map<String, int>> getHeatMapData(int habitId, {int? days}) async {
    try {
      Logger.debug('获取热力图数据: 习惯ID=$habitId');
      
      String whereClause = 'habit_id = ? AND (status = ? OR status = ?)';
      List<Object> whereArgs = [habitId, 'completed', 'partial'];
      
      if (days != null) {
        final cutoffDate = DateTime.now().subtract(Duration(days: days));
        whereClause += ' AND check_date >= ?';
        whereArgs.add(CheckIn.formatDate(cutoffDate));
      }
      
      final result = await _database.rawQuery('''
        SELECT check_date, COUNT(*) as count
        FROM check_ins 
        WHERE $whereClause
        GROUP BY check_date
        ORDER BY check_date ASC
      ''', whereArgs);
      
      final heatMap = <String, int>{};
      
      for (final row in result) {
        final date = row['check_date'] as String;
        final count = row['count'] as int;
        heatMap[date] = count;
      }
      
      Logger.debug('热力图数据获取成功: ${heatMap.length}天');
      return heatMap;
      
    } catch (e, stackTrace) {
      Logger.error('获取热力图数据失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}