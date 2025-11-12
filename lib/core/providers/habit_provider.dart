import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../repositories/habit_repository.dart';
import '../services/habit_service.dart';
import '../services/service_locator.dart';
import '../utils/logger.dart';
import 'app_providers.dart';

/// 习惯服务Provider
final habitServiceProvider = Provider<HabitService>((ref) {
  final habitRepository = ServiceLocator.get<HabitRepository>();
  final notificationService = ref.watch(notificationServiceProvider);
  return HabitService(habitRepository, notificationService);
});

/// 习惯列表状态
class HabitListState {
  const HabitListState({
    this.habits = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.searchKeyword = '',
  });

  /// 习惯列表
  final List<Habit> habits;

  /// 是否加载中
  final bool isLoading;

  /// 错误信息
  final String? error;

  /// 选中的分类
  final String? selectedCategory;

  /// 搜索关键词
  final String searchKeyword;

  /// 复制状态
  HabitListState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? searchKeyword,
  }) {
    return HabitListState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }

  /// 获取过滤后的习惯列表
  List<Habit> get filteredHabits {
    var filtered = habits;

    // 按分类过滤
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      filtered = filtered.where((habit) => habit.category == selectedCategory).toList();
    }

    // 按搜索关键词过滤
    if (searchKeyword.isNotEmpty) {
      final keyword = searchKeyword.toLowerCase();
      filtered = filtered.where((habit) {
        return habit.name.toLowerCase().contains(keyword) ||
               (habit.description?.toLowerCase().contains(keyword) ?? false);
      }).toList();
    }

    return filtered;
  }

  /// 获取激活的习惯
  List<Habit> get activeHabits {
    return filteredHabits.where((habit) => habit.isActive).toList();
  }

  /// 获取未激活的习惯
  List<Habit> get inactiveHabits {
    return filteredHabits.where((habit) => !habit.isActive).toList();
  }

  /// 获取今天应该执行的习惯
  List<Habit> get todayHabits {
    return activeHabits.where((habit) => habit.shouldExecuteToday()).toList();
  }

  @override
  String toString() {
    return 'HabitListState(habits: ${habits.length}, isLoading: $isLoading, '
           'error: $error, selectedCategory: $selectedCategory, '
           'searchKeyword: $searchKeyword)';
  }
}

/// 习惯列表Provider
final habitListProvider = StateNotifierProvider<HabitListNotifier, HabitListState>((ref) {
  final habitService = ref.watch(habitServiceProvider);
  return HabitListNotifier(habitService);
});

/// 习惯列表通知器
class HabitListNotifier extends StateNotifier<HabitListState> {
  final HabitService _habitService;

  HabitListNotifier(this._habitService) : super(const HabitListState()) {
    loadHabits();
  }

  /// 加载所有习惯
  Future<void> loadHabits() async {
    try {
      Logger.debug('加载习惯列表');
      
      state = state.copyWith(isLoading: true, error: null);
      
      final habits = await _habitService.getAllHabits();
      
      state = state.copyWith(
        habits: habits,
        isLoading: false,
      );
      
      Logger.debug('习惯列表加载成功: ${habits.length}个');
      
    } catch (e, stackTrace) {
      Logger.error('加载习惯列表失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载激活的习惯
  Future<void> loadActiveHabits() async {
    try {
      Logger.debug('加载激活习惯');
      
      state = state.copyWith(isLoading: true, error: null);
      
      final habits = await _habitService.getActiveHabits();
      
      state = state.copyWith(
        habits: habits,
        isLoading: false,
      );
      
      Logger.debug('激活习惯加载成功: ${habits.length}个');
      
    } catch (e, stackTrace) {
      Logger.error('加载激活习惯失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载今天的习惯
  Future<void> loadTodayHabits() async {
    try {
      Logger.debug('加载今天的习惯');
      
      state = state.copyWith(isLoading: true, error: null);
      
      final habits = await _habitService.getTodayHabits();
      
      state = state.copyWith(
        habits: habits,
        isLoading: false,
      );
      
      Logger.debug('今天习惯加载成功: ${habits.length}个');
      
    } catch (e, stackTrace) {
      Logger.error('加载今天习惯失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 创建习惯
  Future<Habit?> createHabit({
    required String name,
    String? description,
    String icon = 'default',
    required String category,
    HabitImportance importance = HabitImportance.medium,
    HabitDifficulty difficulty = HabitDifficulty.medium,
    HabitCycleType cycleType = HabitCycleType.daily,
    Map<String, dynamic>? cycleConfig,
    String? timeRangeStart,
    String? timeRangeEnd,
    int? durationMinutes,
    int? targetDays,
    int? targetTotal,
    DateTime? startDate,
    DateTime? endDate,
    bool reminderEnabled = false,
    List<String>? reminderTimes,
  }) async {
    try {
      Logger.info('创建新习惯: $name');
      
      final habit = await _habitService.createHabit(
        name: name,
        description: description,
        icon: icon,
        category: category,
        importance: importance,
        difficulty: difficulty,
        cycleType: cycleType,
        cycleConfig: cycleConfig,
        timeRangeStart: timeRangeStart,
        timeRangeEnd: timeRangeEnd,
        durationMinutes: durationMinutes,
        targetDays: targetDays,
        targetTotal: targetTotal,
        startDate: startDate,
        endDate: endDate,
        reminderEnabled: reminderEnabled,
        reminderTimes: reminderTimes,
      );

      // 更新状态
      final updatedHabits = [...state.habits, habit];
      state = state.copyWith(habits: updatedHabits);
      
      Logger.info('习惯创建成功并添加到列表');
      return habit;
      
    } catch (e, stackTrace) {
      Logger.error('创建习惯失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// 更新习惯
  Future<bool> updateHabit(Habit habit) async {
    try {
      Logger.info('更新习惯: ${habit.name}');
      
      final updatedHabit = await _habitService.updateHabit(habit);
      
      // 更新状态中的习惯
      final habitIndex = state.habits.indexWhere((h) => h.id == habit.id);
      if (habitIndex != -1) {
        final updatedHabits = [...state.habits];
        updatedHabits[habitIndex] = updatedHabit;
        state = state.copyWith(habits: updatedHabits);
      }
      
      Logger.info('习惯更新成功');
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('更新习惯失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 删除习惯
  Future<bool> deleteHabit(int habitId) async {
    try {
      Logger.info('删除习惯: ID=$habitId');
      
      final success = await _habitService.deleteHabit(habitId);
      
      if (success) {
        // 从状态中移除习惯
        final updatedHabits = state.habits.where((h) => h.id != habitId).toList();
        state = state.copyWith(habits: updatedHabits);
        
        Logger.info('习惯删除成功并从列表移除');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      Logger.error('删除习惯失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 切换习惯激活状态
  Future<bool> toggleHabitActive(int habitId) async {
    try {
      Logger.info('切换习惯激活状态: ID=$habitId');
      
      final updatedHabit = await _habitService.toggleHabitActive(habitId);
      
      // 更新状态中的习惯
      final habitIndex = state.habits.indexWhere((h) => h.id == habitId);
      if (habitIndex != -1) {
        final updatedHabits = [...state.habits];
        updatedHabits[habitIndex] = updatedHabit;
        state = state.copyWith(habits: updatedHabits);
      }
      
      Logger.info('习惯激活状态切换成功: ${updatedHabit.isActive}');
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('切换习惯激活状态失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 复制习惯
  Future<Habit?> duplicateHabit(int habitId, {String? newName}) async {
    try {
      Logger.info('复制习惯: ID=$habitId');
      
      final duplicatedHabit = await _habitService.duplicateHabit(habitId, newName: newName);
      
      // 添加到状态
      final updatedHabits = [...state.habits, duplicatedHabit];
      state = state.copyWith(habits: updatedHabits);
      
      Logger.info('习惯复制成功');
      return duplicatedHabit;
      
    } catch (e, stackTrace) {
      Logger.error('复制习惯失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// 重新排序习惯
  Future<void> reorderHabits(List<int> habitIds) async {
    try {
      Logger.info('重新排序习惯');
      
      await _habitService.reorderHabits(habitIds);
      
      // 重新加载习惯列表以获取新的排序
      await loadHabits();
      
      Logger.info('习惯排序成功');
      
    } catch (e, stackTrace) {
      Logger.error('重新排序习惯失败', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(error: e.toString());
    }
  }

  /// 设置选中的分类
  void setSelectedCategory(String? category) {
    Logger.debug('设置选中分类: $category');
    state = state.copyWith(selectedCategory: category);
  }

  /// 设置搜索关键词
  void setSearchKeyword(String keyword) {
    Logger.debug('设置搜索关键词: $keyword');
    state = state.copyWith(searchKeyword: keyword);
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 刷新习惯列表
  Future<void> refresh() async {
    await loadHabits();
  }
}

/// 单个习惯Provider
final habitProvider = FutureProvider.family<Habit?, int>((ref, habitId) async {
  final habitService = ref.watch(habitServiceProvider);
  return await habitService.getHabit(habitId);
});

/// 今天习惯Provider
final todayHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final habitService = ref.watch(habitServiceProvider);
  return await habitService.getTodayHabits();
});

/// 习惯统计Provider
final habitStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final habitService = ref.watch(habitServiceProvider);
  return await habitService.getHabitStats();
});

/// 习惯分类Provider
final habitCategoriesProvider = Provider<List<String>>((ref) {
  final habitService = ref.watch(habitServiceProvider);
  return habitService.getHabitCategories();
});

/// 习惯图标Provider
final habitIconsProvider = Provider<List<String>>((ref) {
  final habitService = ref.watch(habitServiceProvider);
  return habitService.getHabitIcons();
});