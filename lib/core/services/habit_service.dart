import 'dart:convert';

import '../models/models.dart';
import '../repositories/habit_repository.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

/// 习惯管理服务
class HabitService {
  final HabitRepository _habitRepository;
  final NotificationService _notificationService;

  HabitService(this._habitRepository, this._notificationService);

  /// 创建新习惯
  Future<Habit> createHabit({
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

      // 验证输入
      _validateHabitInput(name, category);

      final now = DateTime.now();
      final habit = Habit(
        name: name.trim(),
        description: description?.trim(),
        icon: icon,
        category: category,
        importance: importance,
        difficulty: difficulty,
        cycleType: cycleType,
        cycleConfig: cycleConfig != null && cycleConfig.isNotEmpty 
            ? jsonEncode(cycleConfig)
            : null,
        timeRangeStart: timeRangeStart,
        timeRangeEnd: timeRangeEnd,
        durationMinutes: durationMinutes,
        targetDays: targetDays,
        targetTotal: targetTotal,
        startDate: startDate ?? DateTime(now.year, now.month, now.day),
        endDate: endDate,
        reminderEnabled: reminderEnabled,
        reminderTimes: reminderTimes != null && reminderTimes.isNotEmpty 
            ? jsonEncode(reminderTimes)
            : null,
        createdAt: now,
        updatedAt: now,
      );

      final createdHabit = await _habitRepository.create(habit);

      // 如果启用了提醒，设置通知
      if (createdHabit.reminderEnabled && createdHabit.id != null) {
        await _scheduleHabitReminders(createdHabit);
      }

      Logger.info('习惯创建成功: ${createdHabit.name} (ID: ${createdHabit.id})');
      return createdHabit;

    } catch (e, stackTrace) {
      Logger.error('创建习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新习惯
  Future<Habit> updateHabit(Habit habit) async {
    try {
      Logger.info('更新习惯: ${habit.name} (ID: ${habit.id})');

      if (habit.id == null) {
        throw ArgumentError('习惯ID不能为空');
      }

      _validateHabitInput(habit.name, habit.category);

      final updatedHabit = await _habitRepository.update(habit);

      // 更新通知设置
      await _updateHabitReminders(updatedHabit);

      Logger.info('习惯更新成功');
      return updatedHabit;

    } catch (e, stackTrace) {
      Logger.error('更新习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除习惯
  Future<bool> deleteHabit(int habitId) async {
    try {
      Logger.info('删除习惯: ID=$habitId');

      // 取消相关通知
      await _notificationService.cancelHabitReminder(habitId);

      final success = await _habitRepository.delete(habitId);

      if (success) {
        Logger.info('习惯删除成功');
      }

      return success;

    } catch (e, stackTrace) {
      Logger.error('删除习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 恢复已删除的习惯
  Future<bool> restoreHabit(int habitId) async {
    try {
      Logger.info('恢复习惯: ID=$habitId');

      final success = await _habitRepository.restore(habitId);

      if (success) {
        // 恢复后重新获取习惯信息，设置通知
        final habit = await _habitRepository.getById(habitId);
        if (habit != null && habit.reminderEnabled) {
          await _scheduleHabitReminders(habit);
        }
        
        Logger.info('习惯恢复成功');
      }

      return success;

    } catch (e, stackTrace) {
      Logger.error('恢复习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 切换习惯激活状态
  Future<Habit> toggleHabitActive(int habitId) async {
    try {
      Logger.info('切换习惯激活状态: ID=$habitId');

      final updatedHabit = await _habitRepository.toggleActive(habitId);

      // 根据激活状态更新通知
      if (updatedHabit.isActive && updatedHabit.reminderEnabled) {
        await _scheduleHabitReminders(updatedHabit);
      } else {
        await _notificationService.cancelHabitReminder(habitId);
      }

      Logger.info('习惯激活状态切换成功: ${updatedHabit.isActive}');
      return updatedHabit;

    } catch (e, stackTrace) {
      Logger.error('切换习惯激活状态失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯详情
  Future<Habit?> getHabit(int habitId) async {
    try {
      return await _habitRepository.getById(habitId);
    } catch (e, stackTrace) {
      Logger.error('获取习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取所有激活的习惯
  Future<List<Habit>> getActiveHabits() async {
    try {
      return await _habitRepository.getActive();
    } catch (e, stackTrace) {
      Logger.error('获取激活习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取所有习惯
  Future<List<Habit>> getAllHabits() async {
    try {
      return await _habitRepository.getAll();
    } catch (e, stackTrace) {
      Logger.error('获取所有习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取今天应该执行的习惯
  Future<List<Habit>> getTodayHabits() async {
    try {
      return await _habitRepository.getTodayHabits();
    } catch (e, stackTrace) {
      Logger.error('获取今天习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据分类获取习惯
  Future<List<Habit>> getHabitsByCategory(String category) async {
    try {
      return await _habitRepository.getByCategory(category);
    } catch (e, stackTrace) {
      Logger.error('获取分类习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 搜索习惯
  Future<List<Habit>> searchHabits(String keyword) async {
    try {
      if (keyword.trim().isEmpty) {
        return await getAllHabits();
      }
      return await _habitRepository.search(keyword.trim());
    } catch (e, stackTrace) {
      Logger.error('搜索习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 重新排序习惯
  Future<void> reorderHabits(List<int> habitIds) async {
    try {
      Logger.info('重新排序习惯');
      await _habitRepository.reorder(habitIds);
      Logger.info('习惯排序成功');
    } catch (e, stackTrace) {
      Logger.error('重新排序习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 复制习惯
  Future<Habit> duplicateHabit(int habitId, {String? newName}) async {
    try {
      Logger.info('复制习惯: ID=$habitId');

      final originalHabit = await _habitRepository.getById(habitId);
      if (originalHabit == null) {
        throw Exception('要复制的习惯不存在');
      }

      final duplicatedHabit = originalHabit.copyWith(
        id: null,
        name: newName ?? '${originalHabit.name} (副本)',
        totalCheckIns: 0,
        streakCount: 0,
        maxStreak: 0,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdHabit = await _habitRepository.create(duplicatedHabit);

      // 如果启用了提醒，设置通知
      if (createdHabit.reminderEnabled) {
        await _scheduleHabitReminders(createdHabit);
      }

      Logger.info('习惯复制成功');
      return createdHabit;

    } catch (e, stackTrace) {
      Logger.error('复制习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 从模板创建习惯
  Future<Habit> createFromTemplate(Map<String, dynamic> template) async {
    try {
      Logger.info('从模板创建习惯: ${template['name']}');

      return await createHabit(
        name: template['name'] as String,
        description: template['description'] as String?,
        icon: template['icon'] as String? ?? 'default',
        category: template['category'] as String,
        importance: HabitImportance.fromValue(
          template['default_importance'] as int? ?? 3,
        ),
        difficulty: HabitDifficulty.fromValue(
          template['default_difficulty'] as int? ?? 2,
        ),
        cycleType: HabitCycleType.values.firstWhere(
          (e) => e.name == (template['default_cycle_type'] as String? ?? 'daily'),
          orElse: () => HabitCycleType.daily,
        ),
        timeRangeStart: template['default_time_range_start'] as String?,
        timeRangeEnd: template['default_time_range_end'] as String?,
        durationMinutes: template['default_duration_minutes'] as int?,
        targetDays: template['suggested_target_days'] as int?,
      );

    } catch (e, stackTrace) {
      Logger.error('从模板创建习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯统计信息
  Future<Map<String, dynamic>> getHabitStats() async {
    try {
      Logger.debug('获取习惯统计信息');

      final totalCount = await _habitRepository.getTotalCount();
      final activeCount = await _habitRepository.getActiveCount();
      final categoryStats = await _habitRepository.getCategoryStats();
      final todayHabits = await getTodayHabits();

      final stats = {
        'totalCount': totalCount,
        'activeCount': activeCount,
        'inactiveCount': totalCount - activeCount,
        'todayCount': todayHabits.length,
        'categoryStats': categoryStats,
        'completedToday': 0, // 需要结合CheckIn数据计算
      };

      Logger.debug('习惯统计信息获取成功');
      return stats;

    } catch (e, stackTrace) {
      Logger.error('获取习惯统计信息失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 验证习惯输入
  void _validateHabitInput(String name, String category) {
    if (name.trim().isEmpty) {
      throw ArgumentError('习惯名称不能为空');
    }

    if (name.trim().length > 50) {
      throw ArgumentError('习惯名称不能超过50个字符');
    }

    if (category.trim().isEmpty) {
      throw ArgumentError('习惯分类不能为空');
    }
  }

  /// 安排习惯提醒通知
  Future<void> _scheduleHabitReminders(Habit habit) async {
    if (!habit.reminderEnabled || habit.id == null) return;

    try {
      Logger.debug('安排习惯提醒: ${habit.name}');

      // 先取消现有的通知
      await _notificationService.cancelHabitReminder(habit.id!);

      final reminderTimes = habit.getReminderTimesList();
      if (reminderTimes.isEmpty) return;

      // 为每个提醒时间创建通知
      for (final timeStr in reminderTimes) {
        final timeParts = timeStr.split(':');
        if (timeParts.length != 2) continue;

        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        
        if (hour == null || minute == null) continue;

        final now = DateTime.now();
        var reminderTime = DateTime(now.year, now.month, now.day, hour, minute);
        
        // 如果时间已过，安排到明天
        if (reminderTime.isBefore(now)) {
          reminderTime = reminderTime.add(const Duration(days: 1));
        }

        await _notificationService.scheduleHabitReminder(
          habitId: habit.id!,
          habitName: habit.name,
          reminderTime: reminderTime,
          description: habit.description,
        );
      }

      Logger.debug('习惯提醒安排完成');

    } catch (e, stackTrace) {
      Logger.error('安排习惯提醒失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 更新习惯提醒通知
  Future<void> _updateHabitReminders(Habit habit) async {
    if (habit.id == null) return;

    try {
      // 先取消现有通知
      await _notificationService.cancelHabitReminder(habit.id!);

      // 如果启用提醒且习惯激活，重新安排
      if (habit.reminderEnabled && habit.isActive) {
        await _scheduleHabitReminders(habit);
      }

    } catch (e, stackTrace) {
      Logger.error('更新习惯提醒失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 获取预设习惯分类
  List<String> getHabitCategories() {
    return [
      'health',      // 健康
      'exercise',    // 运动
      'study',       // 学习
      'work',        // 工作
      'social',      // 社交
      'hobby',       // 爱好
      'mindfulness', // 冥想
      'productivity',// 效率
      'creativity',  // 创意
      'finance',     // 理财
      'family',      // 家庭
      'personal',    // 个人发展
    ];
  }

  /// 获取预设习惯图标
  List<String> getHabitIcons() {
    return [
      'default',
      'sunrise',       // 早起
      'water_drop',    // 喝水
      'fitness_center',// 运动
      'book',          // 读书
      'meditation',    // 冥想
      'music',         // 音乐
      'palette',       // 画画
      'code',          // 编程
      'camera',        // 拍照
      'cooking',       // 烹饪
      'cleaning',      // 清洁
      'garden',        // 园艺
      'walk',          // 散步
      'sleep',         // 睡眠
    ];
  }
}