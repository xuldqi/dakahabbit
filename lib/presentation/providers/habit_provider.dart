import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/habit_service.dart';
import '../../core/utils/logger.dart';

/// 习惯状态
class HabitState {
  final List<Habit> habits;
  final bool isLoading;
  final String? error;

  const HabitState({
    this.habits = const [],
    this.isLoading = false,
    this.error,
  });

  HabitState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    String? error,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 习惯管理Provider
class HabitNotifier extends StateNotifier<HabitState> {
  final HabitService _habitService;

  HabitNotifier(this._habitService) : super(const HabitState()) {
    loadHabits();
  }

  /// 加载所有习惯
  Future<void> loadHabits() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final habits = await _habitService.getAllHabits();
      state = state.copyWith(habits: habits, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 创建习惯
  Future<bool> createHabit(Habit habit) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 安全解析 cycleConfig
      Map<String, dynamic>? cycleConfig;
      if (habit.cycleConfig != null && habit.cycleConfig!.isNotEmpty) {
        try {
          cycleConfig = Map<String, dynamic>.from(json.decode(habit.cycleConfig!));
        } catch (e) {
          Logger.error('解析 cycleConfig 失败', error: e);
          cycleConfig = null;
        }
      }
      
      // 安全解析 reminderTimes
      List<String>? reminderTimes;
      if (habit.reminderTimes != null && habit.reminderTimes!.isNotEmpty) {
        try {
          reminderTimes = List<String>.from(json.decode(habit.reminderTimes!));
        } catch (e) {
          Logger.error('解析 reminderTimes 失败', error: e);
          reminderTimes = null;
        }
      }
      
      final createdHabit = await _habitService.createHabit(
        name: habit.name,
        description: habit.description,
        icon: habit.icon,
        category: habit.category,
        importance: habit.importance,
        difficulty: habit.difficulty,
        cycleType: habit.cycleType,
        cycleConfig: cycleConfig,
        timeRangeStart: habit.timeRangeStart,
        timeRangeEnd: habit.timeRangeEnd,
        durationMinutes: habit.durationMinutes,
        targetDays: habit.targetDays,
        targetTotal: habit.targetTotal,
        startDate: habit.startDate,
        endDate: habit.endDate,
        reminderEnabled: habit.reminderEnabled,
        reminderTimes: reminderTimes,
      );
      final updatedHabits = [...state.habits, createdHabit];
      state = state.copyWith(
        habits: updatedHabits,
        isLoading: false,
      );
      return true;
    } catch (e, stackTrace) {
      Logger.error('创建习惯失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 更新习惯
  Future<bool> updateHabit(Habit habit) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedHabit = await _habitService.updateHabit(habit);
      final updatedHabits = state.habits.map((h) {
        return h.id == updatedHabit.id ? updatedHabit : h;
      }).toList();
      state = state.copyWith(
        habits: updatedHabits,
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

  /// 删除习惯
  Future<bool> deleteHabit(int id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final success = await _habitService.deleteHabit(id);
      if (success) {
        final updatedHabits = state.habits.where((h) => h.id != id).toList();
        state = state.copyWith(
          habits: updatedHabits,
          isLoading: false,
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 切换习惯激活状态
  Future<bool> toggleHabitActive(int id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedHabit = await _habitService.toggleHabitActive(id);
      final updatedHabits = state.habits.map((h) {
        return h.id == updatedHabit.id ? updatedHabit : h;
      }).toList();
      state = state.copyWith(
        habits: updatedHabits,
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

  /// 获取今日习惯
  Future<List<Habit>> getTodayHabits() async {
    try {
      return await _habitService.getTodayHabits();
    } catch (e) {
      return [];
    }
  }

  /// 根据ID获取习惯
  Habit? getHabitById(int id) {
    try {
      return state.habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// 习惯Provider
final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  final habitService = ServiceLocator.get<HabitService>();
  return HabitNotifier(habitService);
});

/// 今日习惯Provider
final todayHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final habitNotifier = ref.read(habitProvider.notifier);
  return await habitNotifier.getTodayHabits();
});

/// 根据ID获取习惯Provider
final habitByIdProvider = Provider.family<Habit?, int>((ref, id) {
  final habitState = ref.watch(habitProvider);
  try {
    return habitState.habits.firstWhere((h) => h.id == id);
  } catch (e) {
    return null;
  }
});