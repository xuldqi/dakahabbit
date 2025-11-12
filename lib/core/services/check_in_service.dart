import 'dart:convert';

import '../models/models.dart';
import '../repositories/check_in_repository.dart';
import '../repositories/habit_repository.dart';
import '../utils/logger.dart';
import 'notification_service.dart';

/// 打卡管理服务
class CheckInService {
  final CheckInRepository _checkInRepository;
  final HabitRepository _habitRepository;
  final NotificationService? _notificationService;

  CheckInService(this._checkInRepository, this._habitRepository, [this._notificationService]);

  /// 创建打卡记录
  Future<CheckIn> checkIn({
    required int habitId,
    DateTime? checkDate,
    CheckInStatus status = CheckInStatus.completed,
    String? note,
    MoodType? mood,
    int? qualityScore,
    int? durationMinutes,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      Logger.info('创建打卡记录: 习惯ID=$habitId');

      // 验证习惯是否存在
      final habit = await _habitRepository.getById(habitId);
      if (habit == null) {
        throw ArgumentError('习惯不存在');
      }

      if (!habit.isActive) {
        throw ArgumentError('习惯未激活，无法打卡');
      }

      // 使用指定的日期或今天
      final targetDate = checkDate ?? DateTime.now();
      final targetDateStr = CheckIn.formatDate(targetDate);
      
      // 检查是否已经打卡
      final existingCheckIn = await _checkInRepository.getByHabitAndDate(habitId, targetDateStr);
      
      if (existingCheckIn != null) {
        throw ArgumentError('该日期已经打过卡了');
      }

      // 验证质量评分范围
      if (qualityScore != null && (qualityScore < 1 || qualityScore > 5)) {
        throw ArgumentError('质量评分必须在1-5之间');
      }

      // 创建打卡记录
      final checkIn = targetDate.year == DateTime.now().year &&
              targetDate.month == DateTime.now().month &&
              targetDate.day == DateTime.now().day
          ? CheckIn.forToday(
              habitId: habitId,
              status: status,
              note: note,
              mood: mood,
              qualityScore: qualityScore,
              durationMinutes: durationMinutes,
              photos: photos,
              latitude: latitude,
              longitude: longitude,
              locationName: locationName,
              extraData: extraData,
            )
          : CheckIn.makeup(
              habitId: habitId,
              originalDate: targetDate,
              status: status,
              note: note,
              mood: mood,
              qualityScore: qualityScore,
              durationMinutes: durationMinutes,
              photos: photos,
              latitude: latitude,
              longitude: longitude,
              locationName: locationName,
              extraData: extraData,
            );

      final createdCheckIn = await _checkInRepository.create(checkIn);

      // 更新习惯统计
      await _updateHabitStats(habitId);

      Logger.info('打卡记录创建成功: ID=${createdCheckIn.id}');
      return createdCheckIn;

    } catch (e, stackTrace) {
      Logger.error('创建打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 补打卡
  Future<CheckIn> makeupCheckIn({
    required int habitId,
    required DateTime targetDate,
    DateTime? originalDate,
    CheckInStatus status = CheckInStatus.completed,
    String? note,
    MoodType? mood,
    int? qualityScore,
    int? durationMinutes,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      Logger.info('创建补打卡记录: 习惯ID=$habitId, 日期=${CheckIn.formatDate(targetDate)}');

      // 验证习惯是否存在
      final habit = await _habitRepository.getById(habitId);
      if (habit == null) {
        throw ArgumentError('习惯不存在');
      }

      // 验证补打卡日期不能是未来
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
      
      if (target.isAfter(today)) {
        throw ArgumentError('不能为未来日期补打卡');
      }

      // 验证补打卡日期不能早于习惯开始日期
      final habitStartDate = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
      if (target.isBefore(habitStartDate)) {
        throw ArgumentError('不能为习惯开始日期之前补打卡');
      }

      // 检查该日期是否已经打卡
      final targetDateStr = CheckIn.formatDate(targetDate);
      final existingCheckIn = await _checkInRepository.getByHabitAndDate(habitId, targetDateStr);
      
      if (existingCheckIn != null) {
        throw ArgumentError('该日期已经打过卡了');
      }

      // 验证质量评分范围
      if (qualityScore != null && (qualityScore < 1 || qualityScore > 5)) {
        throw ArgumentError('质量评分必须在1-5之间');
      }

      // 创建补打卡记录
      final checkIn = CheckIn.makeup(
        habitId: habitId,
        originalDate: originalDate ?? targetDate,
        status: status,
        note: note,
        mood: mood,
        qualityScore: qualityScore,
        durationMinutes: durationMinutes,
        photos: photos,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        extraData: extraData,
      );

      final createdCheckIn = await _checkInRepository.create(checkIn);

      // 更新习惯统计
      await _updateHabitStats(habitId);

      Logger.info('补打卡记录创建成功: ID=${createdCheckIn.id}');
      return createdCheckIn;

    } catch (e, stackTrace) {
      Logger.error('创建补打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新打卡记录
  Future<CheckIn> updateCheckIn(
    int checkInId, {
    CheckInStatus? status,
    String? note,
    MoodType? mood,
    int? qualityScore,
    int? durationMinutes,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      Logger.info('更新打卡记录: ID=$checkInId');

      // 获取现有记录
      final existingCheckIn = await _checkInRepository.getById(checkInId);
      if (existingCheckIn == null) {
        throw ArgumentError('打卡记录不存在');
      }

      // 验证质量评分范围
      if (qualityScore != null && (qualityScore < 1 || qualityScore > 5)) {
        throw ArgumentError('质量评分必须在1-5之间');
      }

      // 更新记录
      final updatedCheckIn = existingCheckIn.copyWith(
        status: status,
        note: note,
        mood: mood?.name,
        qualityScore: qualityScore,
        durationMinutes: durationMinutes,
        photos: photos != null && photos.isNotEmpty ? jsonEncode(photos) : null,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        extraData: extraData != null && extraData.isNotEmpty ? jsonEncode(extraData) : null,
        updatedAt: DateTime.now(),
      );

      final result = await _checkInRepository.update(updatedCheckIn);

      // 更新习惯统计
      await _updateHabitStats(existingCheckIn.habitId);

      Logger.info('打卡记录更新成功');
      return result;

    } catch (e, stackTrace) {
      Logger.error('更新打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新打卡记录（接受CheckIn对象，用于向后兼容）
  Future<CheckIn> updateCheckInRecord(CheckIn checkIn) async {
    try {
      Logger.info('更新打卡记录: ID=${checkIn.id}');

      if (checkIn.id == null) {
        throw ArgumentError('打卡记录ID不能为空');
      }

      // 验证质量评分范围
      if (checkIn.qualityScore != null && 
          (checkIn.qualityScore! < 1 || checkIn.qualityScore! > 5)) {
        throw ArgumentError('质量评分必须在1-5之间');
      }

      final updatedCheckIn = await _checkInRepository.update(checkIn);

      // 更新习惯统计
      await _updateHabitStats(checkIn.habitId);

      Logger.info('打卡记录更新成功');
      return updatedCheckIn;

    } catch (e, stackTrace) {
      Logger.error('更新打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除打卡记录
  Future<bool> deleteCheckIn(int checkInId) async {
    try {
      Logger.info('删除打卡记录: ID=$checkInId');

      // 先获取打卡记录信息
      final checkIn = await _checkInRepository.getById(checkInId);
      if (checkIn == null) {
        throw ArgumentError('打卡记录不存在');
      }

      final success = await _checkInRepository.delete(checkInId);

      if (success) {
        // 更新习惯统计
        await _updateHabitStats(checkIn.habitId);
        Logger.info('打卡记录删除成功');
      }

      return success;

    } catch (e, stackTrace) {
      Logger.error('删除打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取打卡记录详情
  Future<CheckIn?> getCheckIn(int checkInId) async {
    try {
      return await _checkInRepository.getById(checkInId);
    } catch (e, stackTrace) {
      Logger.error('获取打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯的打卡记录
  Future<List<CheckIn>> getHabitCheckIns(int habitId, {int? limit, int? offset}) async {
    try {
      return await _checkInRepository.getByHabitId(habitId, limit: limit, offset: offset);
    } catch (e, stackTrace) {
      Logger.error('获取习惯打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯的打卡记录（别名方法，用于Provider）
  Future<List<CheckIn>> getCheckInsByHabit(int habitId) async {
    return await getHabitCheckIns(habitId);
  }

  /// 获取最近N天的打卡记录
  Future<List<CheckIn>> getRecentCheckIns(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days - 1));
      return await getCheckInsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e, stackTrace) {
      Logger.error('获取最近打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯连击统计（返回Map格式，用于Provider）
  Future<Map<String, int>> getHabitStreakStats(int habitId) async {
    try {
      final stats = await getHabitStats(habitId);
      return {
        'totalCheckIns': stats['totalCheckIns'] as int,
        'streakCount': stats['streakCount'] as int,
        'maxStreak': stats['maxStreak'] as int,
      };
    } catch (e, stackTrace) {
      Logger.error('获取习惯连击统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取打卡记录（别名方法，用于Provider）
  Future<CheckIn?> getCheckInById(int checkInId) async {
    return await getCheckIn(checkInId);
  }

  /// 获取错过的打卡日期
  Future<List<DateTime>> getMissedDates(int habitId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final habit = await _habitRepository.getById(habitId);
      if (habit == null) {
        throw ArgumentError('习惯不存在');
      }

      final start = startDate ?? habit.startDate;
      final end = endDate ?? DateTime.now();
      
      // 获取该日期范围内的所有打卡记录
      final checkIns = await getCheckInsByDateRange(
        habitId: habitId,
        startDate: start,
        endDate: end,
      );
      
      // 创建已打卡日期集合
      final checkedDates = checkIns
          .map((ci) => CheckIn.parseDate(ci.checkDate))
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet();
      
      // 找出错过的日期
      final missedDates = <DateTime>[];
      var current = DateTime(start.year, start.month, start.day);
      final endDay = DateTime(end.year, end.month, end.day);
      
      while (current.isBefore(endDay) || current.isAtSameMomentAs(endDay)) {
        // 检查这个日期是否应该打卡但未打卡
        if (habit.shouldExecuteOnDate(current) && !checkedDates.contains(current)) {
          missedDates.add(DateTime(current.year, current.month, current.day));
        }
        current = current.add(const Duration(days: 1));
      }
      
      return missedDates;
    } catch (e, stackTrace) {
      Logger.error('获取错过日期失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 检查今天是否已打卡
  Future<CheckIn?> getTodayCheckIn(int habitId) async {
    try {
      final today = DateTime.now();
      final todayStr = CheckIn.formatDate(today);
      return await _checkInRepository.getByHabitAndDate(habitId, todayStr);
    } catch (e, stackTrace) {
      Logger.error('检查今日打卡状态失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取今天的所有打卡记录
  Future<List<CheckIn>> getTodayCheckIns() async {
    try {
      return await _checkInRepository.getTodayCheckIns();
    } catch (e, stackTrace) {
      Logger.error('获取今日打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取日期范围内的打卡记录
  Future<List<CheckIn>> getCheckInsByDateRange({
    int? habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _checkInRepository.getByDateRange(
        habitId: habitId,
        startDate: CheckIn.formatDate(startDate),
        endDate: CheckIn.formatDate(endDate),
      );
    } catch (e, stackTrace) {
      Logger.error('获取日期范围打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取本周打卡记录
  Future<List<CheckIn>> getWeekCheckIns({int? habitId}) async {
    try {
      return await _checkInRepository.getWeekCheckIns(habitId: habitId);
    } catch (e, stackTrace) {
      Logger.error('获取本周打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取本月打卡记录
  Future<List<CheckIn>> getMonthCheckIns({int? habitId}) async {
    try {
      return await _checkInRepository.getMonthCheckIns(habitId: habitId);
    } catch (e, stackTrace) {
      Logger.error('获取本月打卡记录失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯统计数据
  Future<Map<String, dynamic>> getHabitStats(int habitId, {int? days}) async {
    try {
      Logger.debug('获取习惯统计: 习惯ID=$habitId');

      // 获取基础统计
      final totalCheckIns = await _checkInRepository.getTotalCheckInCount(habitId);
      final streakCount = await _checkInRepository.getStreakCount(habitId);
      final maxStreak = await _checkInRepository.getMaxStreakCount(habitId);
      final completionStats = await _checkInRepository.getCompletionStats(habitId, days: days);

      final stats = {
        'totalCheckIns': totalCheckIns,
        'streakCount': streakCount,
        'maxStreak': maxStreak,
        'completionStats': completionStats,
      };

      Logger.debug('习惯统计获取成功');
      return stats;

    } catch (e, stackTrace) {
      Logger.error('获取习惯统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取热力图数据
  Future<Map<String, int>> getHeatMapData(int habitId, {int? days}) async {
    try {
      return await _checkInRepository.getHeatMapData(habitId, days: days);
    } catch (e, stackTrace) {
      Logger.error('获取热力图数据失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 批量打卡（用于快速操作）
  Future<List<CheckIn>> batchCheckIn(List<Map<String, dynamic>> checkInData) async {
    try {
      Logger.info('批量打卡: ${checkInData.length}个');

      final createdCheckIns = <CheckIn>[];
      final habitIds = <int>{};

      for (final data in checkInData) {
        final habitId = data['habitId'] as int;
        final status = CheckInStatus.values.firstWhere(
          (e) => e.name == (data['status'] as String? ?? 'completed'),
          orElse: () => CheckInStatus.completed,
        );

        final createdCheckIn = await this.checkIn(
          habitId: habitId,
          status: status,
          note: data['note'] as String?,
          qualityScore: data['qualityScore'] as int?,
          durationMinutes: data['durationMinutes'] as int?,
        );

        createdCheckIns.add(createdCheckIn);
        habitIds.add(habitId);
      }

      // 批量更新习惯统计
      for (final habitId in habitIds) {
        await _updateHabitStats(habitId);
      }

      Logger.info('批量打卡完成: ${createdCheckIns.length}个');
      return createdCheckIns;

    } catch (e, stackTrace) {
      Logger.error('批量打卡失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取打卡日历数据（用于日历视图）
  Future<Map<String, List<CheckIn>>> getCalendarData({
    int? habitId,
    required int year,
    required int month,
  }) async {
    try {
      Logger.debug('获取日历数据: $year-$month');

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final checkIns = await getCheckInsByDateRange(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );

      final calendarData = <String, List<CheckIn>>{};

      for (final checkIn in checkIns) {
        final date = checkIn.checkDate;
        if (calendarData[date] == null) {
          calendarData[date] = [];
        }
        calendarData[date]!.add(checkIn);
      }

      Logger.debug('日历数据获取成功: ${calendarData.length}天');
      return calendarData;

    } catch (e, stackTrace) {
      Logger.error('获取日历数据失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取连击分析数据
  Future<Map<String, dynamic>> getStreakAnalysis(int habitId) async {
    try {
      Logger.debug('获取连击分析: 习惯ID=$habitId');

      final currentStreak = await _checkInRepository.getStreakCount(habitId);
      final maxStreak = await _checkInRepository.getMaxStreakCount(habitId);
      final successfulCheckIns = await _checkInRepository.getSuccessfulCheckIns(habitId);

      // 分析连击历史
      final streakHistory = <Map<String, dynamic>>[];
      int tempStreak = 0;
      DateTime? streakStartDate;

      for (int i = successfulCheckIns.length - 1; i >= 0; i--) {
        final checkIn = successfulCheckIns[i];
        final currentDate = CheckIn.parseDate(checkIn.checkDate);

        if (i == successfulCheckIns.length - 1) {
          // 第一条记录
          tempStreak = 1;
          streakStartDate = currentDate;
        } else {
          final previousCheckIn = successfulCheckIns[i + 1];
          final previousDate = CheckIn.parseDate(previousCheckIn.checkDate);
          final difference = currentDate.difference(previousDate).inDays;

          if (difference == 1) {
            // 连续
            tempStreak++;
          } else {
            // 中断，记录前一段连击
            if (streakStartDate != null) {
              streakHistory.add({
                'startDate': CheckIn.formatDate(streakStartDate),
                'endDate': CheckIn.formatDate(previousDate),
                'days': tempStreak,
              });
            }
            tempStreak = 1;
            streakStartDate = currentDate;
          }
        }
      }

      // 添加最后一段连击（如果有）
      if (tempStreak > 0 && streakStartDate != null) {
        streakHistory.add({
          'startDate': CheckIn.formatDate(streakStartDate),
          'endDate': successfulCheckIns.isNotEmpty 
              ? successfulCheckIns.first.checkDate 
              : CheckIn.formatDate(DateTime.now()),
          'days': tempStreak,
        });
      }

      final analysis = {
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'streakHistory': streakHistory,
        'totalStreakPeriods': streakHistory.length,
        'averageStreakLength': streakHistory.isEmpty 
            ? 0.0 
            : streakHistory.map((s) => s['days'] as int).reduce((a, b) => a + b) / streakHistory.length,
      };

      Logger.debug('连击分析获取成功');
      return analysis;

    } catch (e, stackTrace) {
      Logger.error('获取连击分析失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新习惯统计数据
  Future<void> _updateHabitStats(int habitId) async {
    try {
      Logger.debug('更新习惯统计: 习惯ID=$habitId');

      final totalCheckIns = await _checkInRepository.getTotalCheckInCount(habitId);
      final streakCount = await _checkInRepository.getStreakCount(habitId);
      final maxStreak = await _checkInRepository.getMaxStreakCount(habitId);

      await _habitRepository.updateStats(
        id: habitId,
        totalCheckIns: totalCheckIns,
        streakCount: streakCount,
        maxStreak: maxStreak > streakCount ? maxStreak : streakCount,
      );

      Logger.debug('习惯统计更新完成');

    } catch (e, stackTrace) {
      Logger.error('更新习惯统计失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 批量补打卡
  Future<List<CheckIn>> batchMakeupCheckIn({
    required int habitId,
    required List<DateTime> dates,
    CheckInStatus status = CheckInStatus.completed,
    String? note,
    MoodType? mood,
    int? qualityScore,
    int? durationMinutes,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      Logger.info('批量补打卡: 习惯ID=$habitId, ${dates.length}个日期');

      final createdCheckIns = <CheckIn>[];

      for (final date in dates) {
        try {
          final checkIn = await makeupCheckIn(
            habitId: habitId,
            targetDate: date,
            status: status,
            note: note,
            mood: mood,
            qualityScore: qualityScore,
            durationMinutes: durationMinutes,
            photos: photos,
            latitude: latitude,
            longitude: longitude,
            locationName: locationName,
            extraData: extraData,
          );
          createdCheckIns.add(checkIn);
        } catch (e) {
          Logger.info('补打卡失败: 日期=${CheckIn.formatDate(date)}, 错误=$e');
          // 继续处理下一个日期
        }
      }

      Logger.info('批量补打卡完成: ${createdCheckIns.length}/${dates.length}');
      return createdCheckIns;

    } catch (e, stackTrace) {
      Logger.error('批量补打卡失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 验证是否可以打卡
  Future<bool> canCheckIn(int habitId, {DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final habit = await _habitRepository.getById(habitId);
      
      if (habit == null || !habit.isActive) {
        return false;
      }

      // 检查是否在有效日期范围内
      final targetDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final startDay = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
      
      if (targetDay.isBefore(startDay)) {
        return false;
      }

      if (habit.endDate != null) {
        final endDay = DateTime(habit.endDate!.year, habit.endDate!.month, habit.endDate!.day);
        if (targetDay.isAfter(endDay)) {
          return false;
        }
      }

      // 检查今天是否应该执行此习惯
      if (date == null && !habit.shouldExecuteToday()) {
        return false;
      }

      // 检查是否已经打卡
      final existingCheckIn = await _checkInRepository.getByHabitAndDate(
        habitId, 
        CheckIn.formatDate(targetDate),
      );

      return existingCheckIn == null;

    } catch (e, stackTrace) {
      Logger.error('验证打卡权限失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}