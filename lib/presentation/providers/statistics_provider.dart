import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/service_locator.dart';
import '../../core/services/statistics_service.dart';

/// 统计数据Provider
final statisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final statisticsService = ServiceLocator.get<StatisticsService>();
  
  try {
    // 获取各种统计数据
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final weeklyStats = await statisticsService.calculateOverallStats();
    final monthlyStats = await statisticsService.calculateOverallStats();
    
    return {
      'weekly': weeklyStats,
      'monthly': monthlyStats,
      'todayCompletions': weeklyStats['totalCompletions'] ?? 0,
      'weeklyCompletionRate': weeklyStats['completionRate'] ?? 0.0,
      'monthlyCompletionRate': monthlyStats['completionRate'] ?? 0.0,
      'activeHabitsCount': weeklyStats['activeHabitsCount'] ?? 0,
      'totalHabitsCount': weeklyStats['totalHabitsCount'] ?? 0,
    };
  } catch (e) {
    return {
      'error': e.toString(),
      'weekly': {},
      'monthly': {},
      'todayCompletions': 0,
      'weeklyCompletionRate': 0.0,
      'monthlyCompletionRate': 0.0,
      'activeHabitsCount': 0,
      'totalHabitsCount': 0,
    };
  }
});

/// 习惯分类统计Provider
final habitCategoryStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final statisticsService = ServiceLocator.get<StatisticsService>();
  
  try {
    return await statisticsService.calculateOverallStats().then((stats) => <String, int>{});  // 简化实现
  } catch (e) {
    return {};
  }
});