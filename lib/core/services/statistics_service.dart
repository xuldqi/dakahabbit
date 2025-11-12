import 'dart:math' as math;

import '../models/models.dart';
import '../repositories/habit_repository.dart';
import '../repositories/check_in_repository.dart';
import '../repositories/journal_repository.dart';
import '../repositories/habit_journal_relation_repository.dart';
import '../utils/logger.dart';
import '../utils/time_utils.dart';

/// 统计分析服务
class StatisticsService {
  final HabitRepository _habitRepository;
  final CheckInRepository _checkInRepository;
  final JournalRepository _journalRepository;
  final HabitJournalRelationRepository _relationRepository;

  StatisticsService(
    this._habitRepository,
    this._checkInRepository,
    this._journalRepository,
    this._relationRepository,
  );

  /// 计算总体统计数据 (别名方法)
  Future<Map<String, dynamic>> calculateOverallStats() async {
    return getOverallStats();
  }

  /// 获取总体统计数据
  Future<Map<String, dynamic>> getOverallStats() async {
    try {
      Logger.info('获取总体统计数据');

      // 并行获取基础统计
      final results = await Future.wait([
        _getHabitStats(),
        _getCheckInStats(),
        _getJournalStats(),
        _getRelationStats(),
      ]);

      final habitStats = results[0] as Map<String, dynamic>;
      final checkInStats = results[1] as Map<String, dynamic>;
      final journalStats = results[2] as Map<String, dynamic>;
      final relationStats = results[3] as Map<String, dynamic>;

      // 计算综合指标
      final totalScore = _calculateOverallScore(
        habitStats: habitStats,
        checkInStats: checkInStats,
        journalStats: journalStats,
      );

      final overallStats = {
        'timestamp': DateTime.now().toIso8601String(),
        'totalScore': totalScore,
        'habits': habitStats,
        'checkIns': checkInStats,
        'journals': journalStats,
        'relations': relationStats,
        'summary': {
          'activeHabits': habitStats['activeCount'] ?? 0,
          'todayCheckIns': checkInStats['todayCount'] ?? 0,
          'totalJournals': journalStats['totalCount'] ?? 0,
          'currentStreak': checkInStats['averageStreak'] ?? 0,
        },
      };

      Logger.info('总体统计数据获取成功');
      return overallStats;

    } catch (e, stackTrace) {
      Logger.error('获取总体统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯统计数据
  Future<Map<String, dynamic>> _getHabitStats() async {
    try {
      final habits = await _habitRepository.getAll();
      final activeHabits = habits.where((h) => h.isActive).toList();
      final pausedHabits = habits.where((h) => !h.isActive).toList();

      // 按分类统计
      final categoryStats = <String, int>{};
      for (final habit in habits) {
        categoryStats[habit.category] = (categoryStats[habit.category] ?? 0) + 1;
      }

      // 按频率统计
      final frequencyStats = <String, int>{};
      for (final habit in habits) {
        final frequency = habit.cycleType.name;
        frequencyStats[frequency] = (frequencyStats[frequency] ?? 0) + 1;
      }

      return {
        'totalCount': habits.length,
        'activeCount': activeHabits.length,
        'pausedCount': pausedHabits.length,
        'categoryStats': categoryStats,
        'frequencyStats': frequencyStats,
        'averageCreationDate': _calculateAverageDate(
          habits.map((h) => h.createdAt ?? DateTime.now()).toList(),
        ),
      };
    } catch (e, stackTrace) {
      Logger.error('获取习惯统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取打卡统计数据
  Future<Map<String, dynamic>> _getCheckInStats() async {
    try {
      // 获取今天打卡数
      final todayCheckIns = await _checkInRepository.getTodayCheckIns();

      // 获取本周打卡数据
      final weekCheckIns = await _checkInRepository.getWeekCheckIns();

      // 获取本月打卡数据
      final monthCheckIns = await _checkInRepository.getMonthCheckIns();

      // 计算平均连击数
      final habits = await _habitRepository.getActive();
      double totalStreak = 0;
      int maxStreak = 0;
      
      for (final habit in habits) {
        final streakCount = await _checkInRepository.getStreakCount(habit.id!);
        final maxStreakCount = await _checkInRepository.getMaxStreakCount(habit.id!);
        totalStreak += streakCount;
        maxStreak = math.max(maxStreak, maxStreakCount);
      }

      final averageStreak = habits.isEmpty ? 0.0 : totalStreak / habits.length;

      // 计算完成率统计
      final completionRates = <String, double>{};
      final now = DateTime.now();
      final thisWeek = _getWeekRange(now);
      final thisMonth = _getMonthRange(now);

      final weekCompletionRate = await _calculatePeriodCompletionRate(
        thisWeek['start']!,
        thisWeek['end']!,
      );
      
      final monthCompletionRate = await _calculatePeriodCompletionRate(
        thisMonth['start']!,
        thisMonth['end']!,
      );

      completionRates['week'] = weekCompletionRate;
      completionRates['month'] = monthCompletionRate;

      return {
        'todayCount': todayCheckIns.length,
        'weekCount': weekCheckIns.length,
        'monthCount': monthCheckIns.length,
        'averageStreak': averageStreak.round(),
        'maxStreak': maxStreak,
        'completionRates': completionRates,
      };
    } catch (e, stackTrace) {
      Logger.error('获取打卡统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取日志统计数据
  Future<Map<String, dynamic>> _getJournalStats() async {
    try {
      return await _journalRepository.getStats();
    } catch (e, stackTrace) {
      Logger.error('获取日志统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取关联统计数据
  Future<Map<String, int>> _getRelationStats() async {
    try {
      return await _relationRepository.getStats();
    } catch (e, stackTrace) {
      Logger.error('获取关联统计失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯详细分析
  Future<Map<String, dynamic>> getHabitAnalysis(int habitId) async {
    try {
      Logger.info('获取习惯详细分析: 习惯ID=$habitId');

      final habit = await _habitRepository.getById(habitId);
      if (habit == null) {
        throw Exception('习惯不存在');
      }

      // 获取基础统计
      final totalCheckIns = await _checkInRepository.getTotalCheckInCount(habitId);
      final streakCount = await _checkInRepository.getStreakCount(habitId);
      final maxStreakCount = await _checkInRepository.getMaxStreakCount(habitId);

      // 获取打卡历史
      final checkIns = await _checkInRepository.getByHabitId(habitId);

      // 计算时间分析
      final timeAnalysis = _analyzeHabitTiming(checkIns);

      // 计算质量分析
      final qualityAnalysis = _analyzeHabitQuality(checkIns);

      // 计算趋势分析
      final trendAnalysis = await _analyzeHabitTrend(habitId);

      // 获取关联的日志
      final relatedJournals = await _relationRepository.getJournalsByHabit(habitId);

      final analysis = {
        'habit': habit.toJson(),
        'basicStats': {
          'totalCheckIns': totalCheckIns,
          'streakCount': streakCount,
          'maxStreakCount': maxStreakCount,
          'daysSinceStart': DateTime.now().difference(habit.startDate).inDays,
        },
        'timeAnalysis': timeAnalysis,
        'qualityAnalysis': qualityAnalysis,
        'trendAnalysis': trendAnalysis,
        'relatedJournalsCount': relatedJournals.length,
      };

      Logger.info('习惯详细分析获取成功');
      return analysis;

    } catch (e, stackTrace) {
      Logger.error('获取习惯详细分析失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取时间段统计报告
  Future<Map<String, dynamic>> getPeriodReport({
    required DateTime startDate,
    required DateTime endDate,
    List<int>? habitIds,
  }) async {
    try {
      Logger.info('获取时间段统计报告: ${TimeUtils.formatDate(startDate)} ~ ${TimeUtils.formatDate(endDate)}');

      final periodDays = endDate.difference(startDate).inDays + 1;

      // 获取期间的打卡数据
      final checkIns = await _checkInRepository.getByDateRange(
        startDate: TimeUtils.formatDate(startDate),
        endDate: TimeUtils.formatDate(endDate),
        habitId: null,
      );

      // 筛选指定习惯的打卡
      final filteredCheckIns = habitIds != null 
          ? checkIns.where((c) => habitIds.contains(c.habitId)).toList()
          : checkIns;

      // 按日期分组
      final dailyStats = <String, List<CheckIn>>{};
      for (final checkIn in filteredCheckIns) {
        final date = checkIn.checkDate;
        dailyStats[date] ??= [];
        dailyStats[date]!.add(checkIn);
      }

      // 计算完成率
      final totalPossibleCheckIns = await _calculatePossibleCheckIns(
        startDate, 
        endDate, 
        habitIds,
      );
      final completionRate = totalPossibleCheckIns > 0 
          ? filteredCheckIns.length / totalPossibleCheckIns 
          : 0.0;

      // 分析打卡分布
      final hourlyDistribution = _analyzeHourlyDistribution(filteredCheckIns);
      final weeklyDistribution = _analyzeWeeklyDistribution(filteredCheckIns);

      final report = {
        'period': {
          'startDate': TimeUtils.formatDate(startDate),
          'endDate': TimeUtils.formatDate(endDate),
          'days': periodDays,
        },
        'summary': {
          'totalCheckIns': filteredCheckIns.length,
          'completionRate': (completionRate * 100).toDouble(),
          'activeDays': dailyStats.keys.length,
          'averageCheckInsPerDay': dailyStats.isEmpty 
              ? 0.0 
              : filteredCheckIns.length / dailyStats.length,
        },
        'distribution': {
          'hourly': hourlyDistribution,
          'weekly': weeklyDistribution,
        },
        'dailyStats': dailyStats.map(
          (date, checkIns) => MapEntry(date, checkIns.length),
        ),
      };

      Logger.info('时间段统计报告获取成功');
      return report;

    } catch (e, stackTrace) {
      Logger.error('获取时间段统计报告失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取排行榜数据
  Future<Map<String, dynamic>> getLeaderboard({
    LeaderboardType type = LeaderboardType.streak,
    int limit = 10,
  }) async {
    try {
      Logger.info('获取排行榜数据: 类型=${type.name}');

      final habits = await _habitRepository.getActive();
      final leaderboardData = <Map<String, dynamic>>[];

      for (final habit in habits) {
        late final double score;
        late final String metric;

        switch (type) {
          case LeaderboardType.streak:
            score = (await _checkInRepository.getStreakCount(habit.id!)).toDouble();
            metric = '连击天数';
            break;
          case LeaderboardType.checkIns:
            score = (await _checkInRepository.getTotalCheckInCount(habit.id!)).toDouble();
            metric = '总打卡数';
            break;
          case LeaderboardType.completion:
            final stats = await _checkInRepository.getCompletionStats(habit.id!, days: 30);
            score = (stats['completionRate'] as double? ?? 0.0) * 100;
            metric = '30天完成率(%)';
            break;
        }

        leaderboardData.add({
          'habit': habit.toJson(),
          'score': score,
          'metric': metric,
        });
      }

      // 排序并限制数量
      leaderboardData.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
      final topHabits = leaderboardData.take(limit).toList();

      final leaderboard = {
        'type': type.name,
        'metric': topHabits.isNotEmpty ? topHabits.first['metric'] : '',
        'data': topHabits,
        'totalHabits': habits.length,
      };

      Logger.info('排行榜数据获取成功: ${topHabits.length}个项目');
      return leaderboard;

    } catch (e, stackTrace) {
      Logger.error('获取排行榜数据失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取成就进度
  Future<Map<String, dynamic>> getAchievementProgress() async {
    try {
      Logger.info('获取成就进度');

      final habits = await _habitRepository.getAll();
      final achievements = <Map<String, dynamic>>[];

      // 连击成就
      for (final habit in habits) {
        final streak = await _checkInRepository.getStreakCount(habit.id!);
        final maxStreak = await _checkInRepository.getMaxStreakCount(habit.id!);

        achievements.add(_createAchievement(
          'streak_7',
          '7天连击',
          '连续打卡7天',
          maxStreak >= 7,
          math.min(maxStreak / 7, 1.0),
          habitName: habit.name,
        ));

        achievements.add(_createAchievement(
          'streak_30',
          '30天连击',
          '连续打卡30天',
          maxStreak >= 30,
          math.min(maxStreak / 30, 1.0),
          habitName: habit.name,
        ));
      }

      // 总打卡成就
      final totalCheckIns = await _getTotalCheckInsCount();
      achievements.add(_createAchievement(
        'checkins_100',
        '百次打卡',
        '累计打卡100次',
        totalCheckIns >= 100,
        math.min(totalCheckIns / 100, 1.0),
      ));

      // 日志成就
      final journalStats = await _journalRepository.getStats();
      final totalJournals = journalStats['totalCount'] as int? ?? 0;
      achievements.add(_createAchievement(
        'journals_50',
        '日志达人',
        '写作50篇日志',
        totalJournals >= 50,
        math.min(totalJournals / 50, 1.0),
      ));

      final progress = {
        'achievements': achievements,
        'completed': achievements.where((a) => a['completed'] == true).length,
        'total': achievements.length,
      };

      Logger.info('成就进度获取成功');
      return progress;

    } catch (e, stackTrace) {
      Logger.error('获取成就进度失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 计算总体得分
  double _calculateOverallScore({
    required Map<String, dynamic> habitStats,
    required Map<String, dynamic> checkInStats,
    required Map<String, dynamic> journalStats,
  }) {
    try {
      // 习惯活跃度得分 (0-30分)
      final activeHabits = habitStats['activeCount'] as int? ?? 0;
      final habitScore = math.min(activeHabits * 5.0, 30.0);

      // 打卡一致性得分 (0-40分)
      final weekCompletionRate = checkInStats['completionRates']['week'] as double? ?? 0.0;
      final streakScore = math.min((checkInStats['averageStreak'] as int? ?? 0) * 2.0, 20.0);
      final checkInScore = (weekCompletionRate * 20) + streakScore;

      // 日志记录得分 (0-20分)
      final totalJournals = journalStats['totalCount'] as int? ?? 0;
      final journalScore = math.min(totalJournals * 0.5, 20.0);

      // 综合得分 (0-10分额外加分)
      final bonusScore = activeHabits > 0 && weekCompletionRate > 0.8 ? 10.0 : 0.0;

      return habitScore + checkInScore + journalScore + bonusScore;
    } catch (e) {
      Logger.warning('计算总体得分失败: $e');
      return 0.0;
    }
  }

  /// 分析习惯时间规律
  Map<String, dynamic> _analyzeHabitTiming(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return {'hourlyDistribution': {}, 'weeklyDistribution': {}, 'preferredTime': null};
    }

    final hourlyDistribution = <int, int>{};
    final weeklyDistribution = <int, int>{};

    for (final checkIn in checkIns) {
      final dateTime = checkIn.createdAt;
      final hour = dateTime?.hour ?? 0;
      final weekday = dateTime?.weekday ?? 1;

      hourlyDistribution[hour] = (hourlyDistribution[hour] ?? 0) + 1;
      weeklyDistribution[weekday] = (weeklyDistribution[weekday] ?? 0) + 1;
    }

    // 找到最常用的时间
    final mostCommonHour = hourlyDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'hourlyDistribution': hourlyDistribution,
      'weeklyDistribution': weeklyDistribution,
      'preferredTime': mostCommonHour,
    };
  }

  /// 分析习惯质量
  Map<String, dynamic> _analyzeHabitQuality(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return {'averageQuality': 0.0, 'qualityTrend': [], 'hasQualityData': false};
    }

    final qualityScores = checkIns
        .where((c) => c.qualityScore != null)
        .map((c) => c.qualityScore!)
        .toList();

    if (qualityScores.isEmpty) {
      return {'averageQuality': 0.0, 'qualityTrend': [], 'hasQualityData': false};
    }

    final averageQuality = qualityScores.reduce((a, b) => a + b) / qualityScores.length;

    return {
      'averageQuality': averageQuality,
      'qualityTrend': qualityScores.take(30).toList(), // 最近30次
      'hasQualityData': true,
    };
  }

  /// 分析习惯趋势
  Future<Map<String, dynamic>> _analyzeHabitTrend(int habitId) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final recentCheckIns = await _checkInRepository.getByDateRange(
        habitId: habitId,
        startDate: TimeUtils.formatDate(thirtyDaysAgo),
        endDate: TimeUtils.formatDate(now),
      );

      final weeklyData = <String, int>{};
      
      // 按周分组
      for (int i = 0; i < 4; i++) {
        final weekStart = now.subtract(Duration(days: (i + 1) * 7));
        final weekEnd = now.subtract(Duration(days: i * 7));
        
        final weekCheckIns = recentCheckIns.where((c) {
          final checkInDate = CheckIn.parseDate(c.checkDate);
          return checkInDate.isAfter(weekStart) && checkInDate.isBefore(weekEnd);
        }).length;

        weeklyData['week${i + 1}'] = weekCheckIns;
      }

      return {
        'weeklyData': weeklyData,
        'trend': _calculateTrend(weeklyData.values.toList()),
      };
    } catch (e) {
      Logger.warning('分析习惯趋势失败: $e');
      return {'weeklyData': {}, 'trend': 'stable'};
    }
  }

  /// 计算时间段内完成率
  Future<double> _calculatePeriodCompletionRate(DateTime startDate, DateTime endDate) async {
    try {
      final habits = await _habitRepository.getActive();
      if (habits.isEmpty) return 0.0;

      int totalPossible = 0;
      int totalCompleted = 0;

      for (final habit in habits) {
        final possibleDays = _calculateHabitPossibleDays(habit, startDate, endDate);
        final checkIns = await _checkInRepository.getByDateRange(
          habitId: habit.id!,
          startDate: TimeUtils.formatDate(startDate),
          endDate: TimeUtils.formatDate(endDate),
        );

        totalPossible += possibleDays;
        totalCompleted += checkIns.length;
      }

      return totalPossible > 0 ? totalCompleted / totalPossible : 0.0;
    } catch (e) {
      Logger.warning('计算完成率失败: $e');
      return 0.0;
    }
  }

  /// 辅助方法们
  String? _calculateAverageDate(List<DateTime> dates) {
    if (dates.isEmpty) return null;
    
    final totalMilliseconds = dates
        .map((d) => d.millisecondsSinceEpoch)
        .reduce((a, b) => a + b);
    
    final averageMilliseconds = totalMilliseconds ~/ dates.length;
    return DateTime.fromMillisecondsSinceEpoch(averageMilliseconds).toIso8601String();
  }

  Map<String, DateTime> _getWeekRange(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return {'start': startOfWeek, 'end': endOfWeek};
  }

  Map<String, DateTime> _getMonthRange(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);
    return {'start': startOfMonth, 'end': endOfMonth};
  }

  Map<String, int> _analyzeHourlyDistribution(List<CheckIn> checkIns) {
    final distribution = <String, int>{};
    for (final checkIn in checkIns) {
      final hour = (checkIn.createdAt?.hour ?? 0).toString();
      distribution[hour] = (distribution[hour] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _analyzeWeeklyDistribution(List<CheckIn> checkIns) {
    final distribution = <String, int>{};
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    
    for (final checkIn in checkIns) {
      final weekday = weekdays[(checkIn.createdAt?.weekday ?? 1) - 1];
      distribution[weekday] = (distribution[weekday] ?? 0) + 1;
    }
    return distribution;
  }

  Future<int> _calculatePossibleCheckIns(
    DateTime startDate,
    DateTime endDate,
    List<int>? habitIds,
  ) async {
    final habits = habitIds != null
        ? await Future.wait(habitIds.map((id) => _habitRepository.getById(id)))
        : await _habitRepository.getActive();

    final validHabits = habits.whereType<Habit>().toList();
    
    int total = 0;
    for (final habit in validHabits) {
      total += _calculateHabitPossibleDays(habit, startDate, endDate);
    }
    
    return total;
  }

  int _calculateHabitPossibleDays(Habit habit, DateTime startDate, DateTime endDate) {
    final habitStart = habit.startDate.isAfter(startDate) ? habit.startDate : startDate;
    final habitEnd = habit.endDate != null && habit.endDate!.isBefore(endDate) 
        ? habit.endDate! 
        : endDate;
    
    if (habitStart.isAfter(habitEnd)) return 0;
    
    final totalDays = habitEnd.difference(habitStart).inDays + 1;
    
    // 根据习惯频率计算实际应该打卡的天数
    switch (habit.cycleType) {
      case HabitCycleType.daily:
        return totalDays;
      case HabitCycleType.weekly:
        return (totalDays / 7).ceil();
      case HabitCycleType.monthly:
        return (totalDays / 30).ceil();
      case HabitCycleType.custom:
        return totalDays; // 简化处理，假设自定义也是每天
    }
  }

  Future<int> _getTotalCheckInsCount() async {
    final habits = await _habitRepository.getAll();
    int total = 0;
    for (final habit in habits) {
      if (habit.id != null) {
        total += await _checkInRepository.getTotalCheckInCount(habit.id!);
      }
    }
    return total;
  }

  Map<String, dynamic> _createAchievement(
    String id,
    String title,
    String description,
    bool completed,
    double progress, {
    String? habitName,
  }) {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'progress': math.min(progress, 1.0),
      'habitName': habitName,
    };
  }

  String _calculateTrend(List<int> values) {
    if (values.length < 2) return 'stable';
    
    final first = values.first;
    final last = values.last;
    
    if (last > first * 1.1) return 'increasing';
    if (last < first * 0.9) return 'decreasing';
    return 'stable';
  }
}

/// 排行榜类型枚举
enum LeaderboardType {
  streak,      // 连击排行
  checkIns,    // 打卡总数排行  
  completion,  // 完成率排行
}