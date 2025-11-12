import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/check_in_service.dart';

/// 打卡状态
class CheckInState {
  final Map<int, List<CheckIn>> checkInsByHabit;
  final Map<String, List<CheckIn>> checkInsByDate;
  final bool isLoading;
  final String? error;

  const CheckInState({
    this.checkInsByHabit = const {},
    this.checkInsByDate = const {},
    this.isLoading = false,
    this.error,
  });

  CheckInState copyWith({
    Map<int, List<CheckIn>>? checkInsByHabit,
    Map<String, List<CheckIn>>? checkInsByDate,
    bool? isLoading,
    String? error,
  }) {
    return CheckInState(
      checkInsByHabit: checkInsByHabit ?? this.checkInsByHabit,
      checkInsByDate: checkInsByDate ?? this.checkInsByDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 打卡管理Provider
class CheckInNotifier extends StateNotifier<CheckInState> {
  final CheckInService _checkInService;

  CheckInNotifier(this._checkInService) : super(const CheckInState());

  /// 打卡
  Future<bool> checkIn(int habitId, {
    String? note,
    String? mood,
    int? qualityScore,
    int? durationMinutes,
    List<String>? photos,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final createdCheckIn = await _checkInService.checkIn(
        habitId: habitId,
        status: CheckInStatus.completed,
        note: note,
        mood: MoodType.fromName(mood),
        qualityScore: qualityScore,
        durationMinutes: durationMinutes,
        photos: photos,
      );
      
      // 更新状态
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final checkInsByDate = Map<String, List<CheckIn>>.from(state.checkInsByDate);
      final todayCheckIns = List<CheckIn>.from(checkInsByDate[dateStr] ?? []);
      todayCheckIns.add(createdCheckIn);
      checkInsByDate[dateStr] = todayCheckIns;
      
      state = state.copyWith(
        checkInsByDate: checkInsByDate,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 检查今日是否已打卡
  bool hasCheckedInToday(int habitId) {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayCheckIns = state.checkInsByDate[dateStr] ?? [];
    return todayCheckIns.any((checkIn) => 
      checkIn.habitId == habitId && 
      checkIn.status == CheckInStatus.completed
    );
  }

  /// 获取今日打卡统计
  Map<String, int> getTodayStats() {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayCheckIns = state.checkInsByDate[dateStr] ?? [];
    
    final completed = todayCheckIns.where((c) => c.status == CheckInStatus.completed).length;
    
    return {
      'completed': completed,
      'total': completed, // 简化实现
      'pending': 0,
    };
  }
}

/// 打卡Provider
final checkInProvider = StateNotifierProvider<CheckInNotifier, CheckInState>((ref) {
  final checkInService = ServiceLocator.get<CheckInService>();
  return CheckInNotifier(checkInService);
});

/// 今日打卡统计Provider
final todayStatsProvider = Provider<Map<String, int>>((ref) {
  final checkInNotifier = ref.watch(checkInProvider.notifier);
  return checkInNotifier.getTodayStats();
});

/// 检查是否已打卡Provider
final hasCheckedInProvider = Provider.family<bool, int>((ref, habitId) {
  final checkInNotifier = ref.watch(checkInProvider.notifier);
  return checkInNotifier.hasCheckedInToday(habitId);
});