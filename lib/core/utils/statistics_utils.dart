import '../models/models.dart';

/// 统计计算工具类
class StatisticsUtils {
  // 私有构造函数，防止实例化
  StatisticsUtils._();

  /// 计算连击统计
  static Map<String, int> calculateStreakStats(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return {
        'currentStreak': 0,
        'maxStreak': 0,
        'totalCheckIns': 0,
      };
    }

    // 按日期排序（升序）
    final sortedCheckIns = checkIns
        .where((checkIn) => checkIn.isSuccessful())
        .toList()
      ..sort((a, b) => a.checkDate.compareTo(b.checkDate));

    int currentStreak = 0;
    int maxStreak = 0;
    int tempStreak = 0;

    final today = DateTime.now();
    DateTime? lastDate;
    DateTime? latestSuccessDate;

    for (final checkIn in sortedCheckIns) {
      final checkDate = DateTime.parse(checkIn.checkDate);
      
      // 记录最新的成功打卡日期
      if (latestSuccessDate == null || checkDate.isAfter(latestSuccessDate)) {
        latestSuccessDate = checkDate;
      }

      if (lastDate == null) {
        // 第一条记录
        tempStreak = 1;
        lastDate = checkDate;
      } else {
        final daysDifference = checkDate.difference(lastDate).inDays;
        
        if (daysDifference == 1) {
          // 连续的日期
          tempStreak++;
        } else if (daysDifference > 1) {
          // 不连续，更新最大连击并重新开始计数
          maxStreak = maxStreak > tempStreak ? maxStreak : tempStreak;
          tempStreak = 1;
        }
        // daysDifference == 0 表示同一天有多条记录，忽略
        
        lastDate = checkDate;
      }
    }

    // 更新最大连击
    maxStreak = maxStreak > tempStreak ? maxStreak : tempStreak;

    // 计算当前连击
    if (latestSuccessDate != null) {
      final daysSinceLatest = today.difference(latestSuccessDate).inDays;
      
      if (daysSinceLatest <= 1) {
        // 如果最新打卡是今天或昨天，当前连击有效
        currentStreak = tempStreak;
      } else {
        // 否则当前连击为0
        currentStreak = 0;
      }
    }

    return {
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'totalCheckIns': checkIns.length,
    };
  }

  /// 计算完成率统计
  static Map<String, double> calculateCompletionStats(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return {
        'completionRate': 0.0,
        'partialRate': 0.0,
        'skippedRate': 0.0,
        'missedRate': 0.0,
      };
    }

    final total = checkIns.length;
    final completed = checkIns.where((c) => c.status == CheckInStatus.completed).length;
    final partial = checkIns.where((c) => c.status == CheckInStatus.partial).length;
    final skipped = checkIns.where((c) => c.status == CheckInStatus.skipped).length;
    final missed = checkIns.where((c) => c.status == CheckInStatus.missed).length;

    return {
      'completionRate': (completed / total) * 100,
      'partialRate': (partial / total) * 100,
      'skippedRate': (skipped / total) * 100,
      'missedRate': (missed / total) * 100,
    };
  }

  /// 计算平均质量评分
  static double calculateAverageQuality(List<CheckIn> checkIns) {
    final checkInsWithQuality = checkIns
        .where((checkIn) => checkIn.qualityScore != null)
        .toList();
    
    if (checkInsWithQuality.isEmpty) {
      return 0.0;
    }

    final totalScore = checkInsWithQuality
        .map((checkIn) => checkIn.qualityScore!)
        .reduce((a, b) => a + b);
    
    return totalScore / checkInsWithQuality.length;
  }

  /// 计算平均用时（分钟）
  static double calculateAverageDuration(List<CheckIn> checkIns) {
    final checkInsWithDuration = checkIns
        .where((checkIn) => checkIn.durationMinutes != null)
        .toList();
    
    if (checkInsWithDuration.isEmpty) {
      return 0.0;
    }

    final totalDuration = checkInsWithDuration
        .map((checkIn) => checkIn.durationMinutes!)
        .reduce((a, b) => a + b);
    
    return totalDuration / checkInsWithDuration.length;
  }

  /// 按心情分组统计
  static Map<String, int> calculateMoodStats(List<CheckIn> checkIns) {
    final moodStats = <String, int>{};
    
    for (final checkIn in checkIns) {
      if (checkIn.mood != null && checkIn.mood!.isNotEmpty) {
        moodStats[checkIn.mood!] = (moodStats[checkIn.mood!] ?? 0) + 1;
      }
    }
    
    return moodStats;
  }

  /// 按周统计打卡数据
  static Map<int, int> calculateWeeklyStats(List<CheckIn> checkIns) {
    final weekStats = <int, int>{};
    
    for (final checkIn in checkIns) {
      final date = DateTime.parse(checkIn.checkDate);
      final weekday = date.weekday;
      weekStats[weekday] = (weekStats[weekday] ?? 0) + 1;
    }
    
    return weekStats;
  }

  /// 按月统计打卡数据
  static Map<int, int> calculateMonthlyStats(List<CheckIn> checkIns) {
    final monthStats = <int, int>{};
    
    for (final checkIn in checkIns) {
      final date = DateTime.parse(checkIn.checkDate);
      final month = date.month;
      monthStats[month] = (monthStats[month] ?? 0) + 1;
    }
    
    return monthStats;
  }

  /// 计算打卡时间分布
  static Map<int, int> calculateHourlyStats(List<CheckIn> checkIns) {
    final hourStats = <int, int>{};
    
    for (final checkIn in checkIns) {
      try {
        final timeParts = checkIn.checkTime.split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          hourStats[hour] = (hourStats[hour] ?? 0) + 1;
        }
      } catch (e) {
        // 忽略无效的时间格式
      }
    }
    
    return hourStats;
  }

  /// 计算成功率趋势
  static List<Map<String, dynamic>> calculateSuccessTrend(
    List<CheckIn> checkIns, 
    int days,
  ) {
    final trend = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (int i = days - 1; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dateStr = '${targetDate.year.toString().padLeft(4, '0')}-'
                     '${targetDate.month.toString().padLeft(2, '0')}-'
                     '${targetDate.day.toString().padLeft(2, '0')}';
      
      final dayCheckIns = checkIns
          .where((checkIn) => checkIn.checkDate == dateStr)
          .toList();
      
      final successCount = dayCheckIns
          .where((checkIn) => checkIn.isSuccessful())
          .length;
      
      trend.add({
        'date': targetDate,
        'dateStr': dateStr,
        'totalCheckIns': dayCheckIns.length,
        'successCount': successCount,
        'successRate': dayCheckIns.isNotEmpty ? (successCount / dayCheckIns.length) * 100 : 0.0,
      });
    }
    
    return trend;
  }

  /// 计算连击天数分布
  static Map<String, int> calculateStreakDistribution(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return {
        '1-3天': 0,
        '4-7天': 0,
        '8-14天': 0,
        '15-30天': 0,
        '30天以上': 0,
      };
    }

    // 计算所有的连击段
    final streaks = <int>[];
    final sortedCheckIns = checkIns
        .where((checkIn) => checkIn.isSuccessful())
        .toList()
      ..sort((a, b) => a.checkDate.compareTo(b.checkDate));

    DateTime? lastDate;
    int currentStreak = 0;

    for (final checkIn in sortedCheckIns) {
      final checkDate = DateTime.parse(checkIn.checkDate);
      
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDifference = checkDate.difference(lastDate).inDays;
        
        if (daysDifference == 1) {
          currentStreak++;
        } else if (daysDifference > 1) {
          if (currentStreak > 0) {
            streaks.add(currentStreak);
          }
          currentStreak = 1;
        }
      }
      
      lastDate = checkDate;
    }
    
    if (currentStreak > 0) {
      streaks.add(currentStreak);
    }

    // 分组统计
    final distribution = {
      '1-3天': 0,
      '4-7天': 0,
      '8-14天': 0,
      '15-30天': 0,
      '30天以上': 0,
    };

    for (final streak in streaks) {
      if (streak >= 1 && streak <= 3) {
        distribution['1-3天'] = distribution['1-3天']! + 1;
      } else if (streak >= 4 && streak <= 7) {
        distribution['4-7天'] = distribution['4-7天']! + 1;
      } else if (streak >= 8 && streak <= 14) {
        distribution['8-14天'] = distribution['8-14天']! + 1;
      } else if (streak >= 15 && streak <= 30) {
        distribution['15-30天'] = distribution['15-30天']! + 1;
      } else if (streak > 30) {
        distribution['30天以上'] = distribution['30天以上']! + 1;
      }
    }

    return distribution;
  }

  /// 计算改进建议
  static List<String> generateImprovementSuggestions(
    Map<String, dynamic> stats,
    List<CheckIn> checkIns,
  ) {
    final suggestions = <String>[];
    
    final completionRate = stats['completionRate'] ?? 0.0;
    final currentStreak = stats['currentStreak'] ?? 0;
    final avgQuality = stats['avgQuality'] ?? 0.0;
    
    // 完成率建议
    if (completionRate < 50) {
      suggestions.add('完成率较低，建议降低习惯难度或减少频次');
    } else if (completionRate < 80) {
      suggestions.add('完成率有待提高，可以设置更多提醒或寻找执行障碍');
    }
    
    // 连击建议
    if (currentStreak == 0) {
      suggestions.add('当前没有连击，建议重新开始并坚持下去');
    } else if (currentStreak < 7) {
      suggestions.add('连击天数较短，再坚持${7 - currentStreak}天可达到一周连击');
    }
    
    // 质量建议
    if (avgQuality < 3.0 && avgQuality > 0) {
      suggestions.add('执行质量偏低，建议调整执行方式或环境');
    }
    
    // 时间分布建议
    final hourlyStats = calculateHourlyStats(checkIns);
    if (hourlyStats.isNotEmpty) {
      final mostActiveHour = hourlyStats.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      if (mostActiveHour >= 22 || mostActiveHour <= 5) {
        suggestions.add('大部分打卡在深夜或凌晨，建议调整到更合适的时间');
      }
    }
    
    // 周分布建议
    final weeklyStats = calculateWeeklyStats(checkIns);
    if (weeklyStats.isNotEmpty) {
      final weekendCount = (weeklyStats[6] ?? 0) + (weeklyStats[7] ?? 0);
      final weekdayCount = checkIns.length - weekendCount;
      
      if (weekendCount < weekdayCount * 0.3) {
        suggestions.add('周末执行频率较低，建议设置周末专门的提醒');
      }
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('表现很好！继续保持当前的节奏');
    }
    
    return suggestions;
  }

  /// 预测下次可能错过的日期
  static List<DateTime> predictMissedDates(
    List<CheckIn> checkIns, 
    int daysToPredict,
  ) {
    if (checkIns.length < 7) {
      return []; // 数据不足，无法预测
    }

    // 计算每个工作日的成功率
    final weeklySuccessRates = <int, double>{};
    final weeklyCounts = <int, int>{};
    
    for (final checkIn in checkIns) {
      final date = DateTime.parse(checkIn.checkDate);
      final weekday = date.weekday;
      
      weeklyCounts[weekday] = (weeklyCounts[weekday] ?? 0) + 1;
      
      if (checkIn.isSuccessful()) {
        weeklySuccessRates[weekday] = (weeklySuccessRates[weekday] ?? 0) + 1;
      }
    }
    
    // 计算成功率
    for (final weekday in weeklyCounts.keys) {
      final successCount = weeklySuccessRates[weekday] ?? 0;
      final totalCount = weeklyCounts[weekday]!;
      weeklySuccessRates[weekday] = successCount / totalCount;
    }

    // 预测未来可能错过的日期
    final riskyDates = <DateTime>[];
    final now = DateTime.now();
    
    for (int i = 1; i <= daysToPredict; i++) {
      final futureDate = now.add(Duration(days: i));
      final weekday = futureDate.weekday;
      
      final successRate = weeklySuccessRates[weekday] ?? 0.5;
      
      // 如果该工作日的历史成功率低于60%，标记为风险日期
      if (successRate < 0.6) {
        riskyDates.add(futureDate);
      }
    }
    
    return riskyDates;
  }

  /// 计算习惯健康度评分（0-100）
  static int calculateHabitHealthScore(
    Map<String, dynamic> stats,
    List<CheckIn> recentCheckIns,
  ) {
    int score = 0;
    
    // 完成率权重 40%
    final completionRate = stats['completionRate'] ?? 0.0;
    score += (completionRate * 0.4).round();
    
    // 连击权重 30%
    final currentStreak = stats['currentStreak'] ?? 0;
    final streakScore = (currentStreak >= 30) ? 30 : currentStreak;
    score += streakScore;
    
    // 质量评分权重 20%
    final avgQuality = stats['avgQuality'] ?? 0.0;
    if (avgQuality > 0) {
      score += ((avgQuality / 5.0) * 20).round();
    }
    
    // 一致性权重 10%
    final consistency = calculateConsistency(recentCheckIns);
    score += (consistency * 10).round();
    
    return score.clamp(0, 100);
  }

  /// 计算一致性评分（0-1）
  static double calculateConsistency(List<CheckIn> checkIns) {
    if (checkIns.length < 7) {
      return 0.0;
    }
    
    final last30Days = checkIns
        .where((checkIn) {
          final checkDate = DateTime.parse(checkIn.checkDate);
          final now = DateTime.now();
          return now.difference(checkDate).inDays <= 30;
        })
        .toList();
    
    if (last30Days.isEmpty) {
      return 0.0;
    }
    
    // 计算标准差来衡量一致性
    final successByDay = <int, int>{};
    
    for (final checkIn in last30Days) {
      final date = DateTime.parse(checkIn.checkDate);
      final dayOfMonth = date.day;
      
      if (checkIn.isSuccessful()) {
        successByDay[dayOfMonth] = (successByDay[dayOfMonth] ?? 0) + 1;
      }
    }
    
    if (successByDay.isEmpty) {
      return 0.0;
    }
    
    final values = successByDay.values.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
        .map((value) => (value - mean) * (value - mean))
        .reduce((a, b) => a + b) / values.length;
    
    final standardDeviation = variance == 0 ? 0 : 1.0 / (1.0 + variance);
    
    return standardDeviation.clamp(0.0, 1.0);
  }
}