import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../repositories/check_in_repository.dart';
import '../repositories/habit_repository.dart';
import '../services/check_in_service.dart';
import '../services/service_locator.dart';
import '../utils/logger.dart';
import 'app_providers.dart';
import 'habit_provider.dart';

/// 打卡仓库Provider
final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return CheckInRepository(databaseService);
});

/// 习惯仓库Provider
final habitRepositoryProvider = Provider((ref) {
  return ServiceLocator.get<HabitRepository>();
});

/// 打卡服务Provider
final checkInServiceProvider = Provider<CheckInService>((ref) {
  final checkInRepository = ref.watch(checkInRepositoryProvider);
  final habitRepository = ref.watch(habitRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return CheckInService(checkInRepository, habitRepository, notificationService);
});

/// 今天打卡记录Provider
final todayCheckInsProvider = FutureProvider<List<CheckIn>>((ref) async {
  final checkInService = ref.watch(checkInServiceProvider);
  return await checkInService.getTodayCheckIns();
});

/// 最近打卡记录Provider
final recentCheckInsProvider = FutureProviderFamily<List<CheckIn>, int>((ref, days) async {
  final checkInService = ref.watch(checkInServiceProvider);
  return await checkInService.getRecentCheckIns(days);
});

/// 习惯打卡记录Provider
final habitCheckInsProvider = FutureProviderFamily<List<CheckIn>, int>((ref, habitId) async {
  final checkInService = ref.watch(checkInServiceProvider);
  return await checkInService.getCheckInsByHabit(habitId);
});

/// 习惯连击统计Provider
final habitStreakStatsProvider = FutureProviderFamily<Map<String, int>, int>((ref, habitId) async {
  final checkInService = ref.watch(checkInServiceProvider);
  return await checkInService.getHabitStreakStats(habitId);
});

/// 特定打卡记录Provider
final checkInProvider = FutureProviderFamily<CheckIn?, int>((ref, checkInId) async {
  final checkInService = ref.watch(checkInServiceProvider);
  return await checkInService.getCheckInById(checkInId);
});

/// 今天打卡状态Provider
final todayCheckInStatusProvider = FutureProviderFamily<CheckIn?, int>((ref, habitId) async {
  final checkInService = ref.watch(checkInServiceProvider);
  return await checkInService.getTodayCheckIn(habitId);
});

/// 可补打卡日期Provider
final missedDatesProvider = FutureProviderFamily<List<DateTime>, int>((ref, habitId) async {
  final checkInService = ref.watch(checkInServiceProvider);
  return await checkInService.getMissedDates(habitId);
});

/// 打卡管理状态
class CheckInManagementState {
  const CheckInManagementState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.checkIns = const [],
    this.todayCheckIns = const {},
    this.selectedDate,
    this.selectedHabitId,
    this.error,
  });

  /// 是否正在加载
  final bool isLoading;

  /// 是否正在提交
  final bool isSubmitting;

  /// 打卡记录列表
  final List<CheckIn> checkIns;

  /// 今天的打卡记录（habitId -> CheckIn）
  final Map<int, CheckIn> todayCheckIns;

  /// 选中的日期
  final DateTime? selectedDate;

  /// 选中的习惯ID
  final int? selectedHabitId;

  /// 错误信息
  final String? error;

  /// 复制状态
  CheckInManagementState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<CheckIn>? checkIns,
    Map<int, CheckIn>? todayCheckIns,
    DateTime? selectedDate,
    int? selectedHabitId,
    String? error,
  }) {
    return CheckInManagementState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      checkIns: checkIns ?? this.checkIns,
      todayCheckIns: todayCheckIns ?? this.todayCheckIns,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedHabitId: selectedHabitId ?? this.selectedHabitId,
      error: error ?? this.error,
    );
  }

  /// 清除选中日期
  CheckInManagementState clearSelectedDate() {
    return copyWith(selectedDate: DateTime(1970));
  }

  /// 清除选中习惯ID
  CheckInManagementState clearSelectedHabitId() {
    return copyWith(selectedHabitId: -1);
  }

  /// 清除错误
  CheckInManagementState clearError() {
    return copyWith(error: '');
  }

  /// 获取指定日期的打卡记录
  List<CheckIn> getCheckInsForDate(DateTime date) {
    final dateStr = _formatDate(date);
    return checkIns.where((checkIn) => checkIn.checkDate == dateStr).toList();
  }

  /// 获取指定习惯的打卡记录
  List<CheckIn> getCheckInsForHabit(int habitId) {
    return checkIns.where((checkIn) => checkIn.habitId == habitId).toList();
  }

  /// 检查习惯今天是否已打卡
  bool hasTodayCheckIn(int habitId) {
    return todayCheckIns.containsKey(habitId);
  }

  /// 获取习惯今天的打卡记录
  CheckIn? getTodayCheckIn(int habitId) {
    return todayCheckIns[habitId];
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'CheckInManagementState('
           'isLoading: $isLoading, '
           'isSubmitting: $isSubmitting, '
           'checkInsCount: ${checkIns.length}, '
           'todayCheckInsCount: ${todayCheckIns.length}, '
           'selectedDate: $selectedDate, '
           'selectedHabitId: $selectedHabitId, '
           'error: $error'
           ')';
  }
}

/// 打卡管理状态通知器
class CheckInManagementNotifier extends StateNotifier<CheckInManagementState> {
  final CheckInService _checkInService;

  CheckInManagementNotifier(this._checkInService) : super(const CheckInManagementState()) {
    loadTodayCheckIns();
  }

  /// 加载今天的打卡记录
  Future<void> loadTodayCheckIns() async {
    try {
      Logger.debug('加载今天的打卡记录');
      
      state = state.copyWith(isLoading: true, error: '');
      
      final checkIns = await _checkInService.getTodayCheckIns();
      
      // 转换为Map结构
      final todayCheckInsMap = <int, CheckIn>{};
      for (final checkIn in checkIns) {
        todayCheckInsMap[checkIn.habitId] = checkIn;
      }
      
      state = state.copyWith(
        isLoading: false,
        todayCheckIns: todayCheckInsMap,
      );
      
      Logger.debug('今天打卡记录加载完成: ${checkIns.length}条');
      
    } catch (e, stackTrace) {
      Logger.error('加载今天打卡记录失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        error: '加载打卡记录失败: ${e.toString()}',
      );
    }
  }

  /// 刷新打卡记录
  Future<void> refresh() async {
    await loadTodayCheckIns();
    
    // 如果有选中的习惯，重新加载该习惯的打卡记录
    if (state.selectedHabitId != null) {
      await loadHabitCheckIns(state.selectedHabitId!);
    }
  }

  /// 加载指定习惯的打卡记录
  Future<void> loadHabitCheckIns(int habitId) async {
    try {
      Logger.debug('加载习惯打卡记录: 习惯ID=$habitId');
      
      state = state.copyWith(
        isLoading: true, 
        selectedHabitId: habitId,
        error: '',
      );
      
      final checkIns = await _checkInService.getCheckInsByHabit(habitId);
      
      state = state.copyWith(
        isLoading: false,
        checkIns: checkIns,
      );
      
      Logger.debug('习惯打卡记录加载完成: ${checkIns.length}条');
      
    } catch (e, stackTrace) {
      Logger.error('加载习惯打卡记录失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        error: '加载习惯打卡记录失败: ${e.toString()}',
      );
    }
  }

  /// 打卡
  Future<bool> checkIn({
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
      
      state = state.copyWith(isSubmitting: true, error: '');
      
      final checkIn = await _checkInService.checkIn(
        habitId: habitId,
        checkDate: checkDate,
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
      
      state = state.copyWith(isSubmitting: false);
      
      // 更新今天的打卡记录
      if (checkIn.isToday()) {
        final updatedTodayCheckIns = Map<int, CheckIn>.from(state.todayCheckIns);
        updatedTodayCheckIns[habitId] = checkIn;
        
        state = state.copyWith(todayCheckIns: updatedTodayCheckIns);
      }
      
      // 如果正在查看该习惯的记录，更新列表
      if (state.selectedHabitId == habitId) {
        final updatedCheckIns = [checkIn, ...state.checkIns];
        state = state.copyWith(checkIns: updatedCheckIns);
      }
      
      Logger.info('打卡成功');
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('打卡失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isSubmitting: false,
        error: '打卡失败: ${e.toString()}',
      );
      return false;
    }
  }

  /// 补打卡
  Future<bool> makeupCheckIn({
    required int habitId,
    required DateTime originalDate,
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
      Logger.info('创建补打卡记录: 习惯ID=$habitId, 日期=$originalDate');
      
      state = state.copyWith(isSubmitting: true, error: '');
      
      final checkIn = await _checkInService.makeupCheckIn(
        habitId: habitId,
        targetDate: originalDate,
        originalDate: originalDate,
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
      
      state = state.copyWith(isSubmitting: false);
      
      // 如果正在查看该习惯的记录，更新列表
      if (state.selectedHabitId == habitId) {
        final updatedCheckIns = [checkIn, ...state.checkIns];
        state = state.copyWith(checkIns: updatedCheckIns);
      }
      
      Logger.info('补打卡成功');
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('补打卡失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isSubmitting: false,
        error: '补打卡失败: ${e.toString()}',
      );
      return false;
    }
  }

  /// 更新打卡记录
  Future<bool> updateCheckIn(
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
      
      state = state.copyWith(isSubmitting: true, error: '');
      
      final updatedCheckIn = await _checkInService.updateCheckIn(
        checkInId,
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
      
      state = state.copyWith(isSubmitting: false);
      
      // 更新对应的记录
      if (updatedCheckIn.isToday()) {
        final updatedTodayCheckIns = Map<int, CheckIn>.from(state.todayCheckIns);
        updatedTodayCheckIns[updatedCheckIn.habitId] = updatedCheckIn;
        state = state.copyWith(todayCheckIns: updatedTodayCheckIns);
      }
      
      if (state.selectedHabitId == updatedCheckIn.habitId) {
        final updatedCheckIns = state.checkIns.map((checkIn) {
          return checkIn.id == checkInId ? updatedCheckIn : checkIn;
        }).toList();
        state = state.copyWith(checkIns: updatedCheckIns);
      }
      
      Logger.info('打卡记录更新成功');
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('更新打卡记录失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isSubmitting: false,
        error: '更新打卡记录失败: ${e.toString()}',
      );
      return false;
    }
  }

  /// 删除打卡记录
  Future<bool> deleteCheckIn(int checkInId) async {
    try {
      Logger.info('删除打卡记录: ID=$checkInId');
      
      // 先找到要删除的记录
      CheckIn? targetCheckIn;
      if (state.selectedHabitId != null) {
        targetCheckIn = state.checkIns.firstWhere(
          (checkIn) => checkIn.id == checkInId,
          orElse: () => throw StateError('找不到打卡记录'),
        );
      }
      
      state = state.copyWith(error: '');
      
      final success = await _checkInService.deleteCheckIn(checkInId);
      
      if (success) {
        // 从今天的打卡记录中移除
        if (targetCheckIn != null && targetCheckIn.isToday()) {
          final updatedTodayCheckIns = Map<int, CheckIn>.from(state.todayCheckIns);
          updatedTodayCheckIns.remove(targetCheckIn.habitId);
          state = state.copyWith(todayCheckIns: updatedTodayCheckIns);
        }
        
        // 从习惯打卡记录中移除
        if (state.selectedHabitId != null) {
          final updatedCheckIns = state.checkIns
              .where((checkIn) => checkIn.id != checkInId)
              .toList();
          state = state.copyWith(checkIns: updatedCheckIns);
        }
        
        Logger.info('打卡记录删除成功');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('删除打卡记录失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(error: '删除打卡记录失败: ${e.toString()}');
      return false;
    }
  }

  /// 批量补打卡
  Future<int> batchMakeupCheckIn({
    required int habitId,
    required List<DateTime> dates,
    CheckInStatus status = CheckInStatus.completed,
    String? note,
  }) async {
    try {
      Logger.info('批量补打卡: 习惯ID=$habitId, ${dates.length}个日期');
      
      state = state.copyWith(isSubmitting: true, error: '');
      
      final createdCheckIns = await _checkInService.batchMakeupCheckIn(
        habitId: habitId,
        dates: dates,
        status: status,
        note: note,
      );
      
      state = state.copyWith(isSubmitting: false);
      
      // 如果正在查看该习惯的记录，重新加载
      if (state.selectedHabitId == habitId) {
        await loadHabitCheckIns(habitId);
      }
      
      Logger.info('批量补打卡完成: ${createdCheckIns.length}/${dates.length}');
      return createdCheckIns.length;
      
    } catch (e, stackTrace) {
      Logger.error('批量补打卡失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isSubmitting: false,
        error: '批量补打卡失败: ${e.toString()}',
      );
      return 0;
    }
  }

  /// 设置选中的日期
  void setSelectedDate(DateTime? date) {
    state = state.copyWith(selectedDate: date);
  }

  /// 清除错误状态
  void clearError() {
    state = state.clearError();
  }

  /// 清除选中状态
  void clearSelection() {
    state = state.copyWith(
      selectedDate: null,
      selectedHabitId: null,
    );
  }
}

/// 打卡管理状态Provider
final checkInManagementProvider = StateNotifierProvider<CheckInManagementNotifier, CheckInManagementState>((ref) {
  final checkInService = ref.watch(checkInServiceProvider);
  return CheckInManagementNotifier(checkInService);
});