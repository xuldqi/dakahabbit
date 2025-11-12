import '../../core/services/statistics_service.dart';

/// 统计数据Provider
final statisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final statisticsService = ServiceLocator.get<StatisticsService>();
  return await statisticsService.getStatistics();
});

/// 单个习惯分析Provider
final habitAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, habitId) async {
  final statisticsService = ServiceLocator.get<StatisticsService>();
  return await statisticsService.getHabitAnalysis(habitId);
});

/// 成就进度Provider
final achievementProgressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final statisticsService = ServiceLocator.get<StatisticsService>();
  return await statisticsService.getAchievementProgress();
});
