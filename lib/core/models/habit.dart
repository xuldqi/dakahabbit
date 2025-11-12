import 'dart:convert';

import 'enums.dart';

/// 习惯数据模型
class Habit {
  const Habit({
    this.id,
    required this.name,
    this.description,
    this.icon = 'default',
    required this.category,
    this.importance = HabitImportance.medium,
    this.difficulty = HabitDifficulty.medium,
    this.cycleType = HabitCycleType.daily,
    this.cycleConfig,
    this.timeRangeStart,
    this.timeRangeEnd,
    this.durationMinutes,
    this.targetDays,
    this.targetTotal,
    this.isActive = true,
    this.isDeleted = false,
    required this.startDate,
    this.endDate,
    this.reminderEnabled = false,
    this.reminderTimes,
    this.totalCheckIns = 0,
    this.streakCount = 0,
    this.maxStreak = 0,
    this.sortOrder = 0,
    this.extraConfig,
    this.createdAt,
    this.updatedAt,
  });

  /// 习惯ID
  final int? id;

  /// 习惯名称
  final String name;

  /// 习惯描述
  final String? description;

  /// 图标名称
  final String icon;

  /// 习惯分类
  final String category;

  /// 重要性级别
  final HabitImportance importance;

  /// 难度级别
  final HabitDifficulty difficulty;

  /// 循环类型
  final HabitCycleType cycleType;

  /// 循环配置（JSON字符串）
  final String? cycleConfig;

  /// 时间范围开始
  final String? timeRangeStart;

  /// 时间范围结束
  final String? timeRangeEnd;

  /// 目标时长（分钟）
  final int? durationMinutes;

  /// 目标天数
  final int? targetDays;

  /// 目标总数
  final int? targetTotal;

  /// 是否激活
  final bool isActive;

  /// 是否删除
  final bool isDeleted;

  /// 开始日期
  final DateTime startDate;

  /// 结束日期
  final DateTime? endDate;

  /// 是否启用提醒
  final bool reminderEnabled;

  /// 提醒时间列表（JSON字符串）
  final String? reminderTimes;

  /// 总打卡次数
  final int totalCheckIns;

  /// 当前连击数
  final int streakCount;

  /// 最大连击数
  final int maxStreak;

  /// 排序顺序
  final int sortOrder;

  /// 额外配置（JSON字符串）
  final String? extraConfig;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 复制习惯并修改部分属性
  Habit copyWith({
    Object? id = _undefined,
    String? name,
    String? description,
    String? icon,
    String? category,
    HabitImportance? importance,
    HabitDifficulty? difficulty,
    HabitCycleType? cycleType,
    String? cycleConfig,
    String? timeRangeStart,
    String? timeRangeEnd,
    int? durationMinutes,
    int? targetDays,
    int? targetTotal,
    bool? isActive,
    bool? isDeleted,
    DateTime? startDate,
    DateTime? endDate,
    bool? reminderEnabled,
    String? reminderTimes,
    int? totalCheckIns,
    int? streakCount,
    int? maxStreak,
    int? sortOrder,
    String? extraConfig,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id == _undefined ? this.id : id as int?,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      difficulty: difficulty ?? this.difficulty,
      cycleType: cycleType ?? this.cycleType,
      cycleConfig: cycleConfig ?? this.cycleConfig,
      timeRangeStart: timeRangeStart ?? this.timeRangeStart,
      timeRangeEnd: timeRangeEnd ?? this.timeRangeEnd,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      targetDays: targetDays ?? this.targetDays,
      targetTotal: targetTotal ?? this.targetTotal,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      streakCount: streakCount ?? this.streakCount,
      maxStreak: maxStreak ?? this.maxStreak,
      sortOrder: sortOrder ?? this.sortOrder,
      extraConfig: extraConfig ?? this.extraConfig,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  static const Object _undefined = Object();

  /// 从数据库Map创建习惯对象
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String? ?? 'default',
      category: map['category'] as String,
      importance: HabitImportance.fromValue(map['importance'] as int? ?? 3),
      difficulty: HabitDifficulty.fromValue(map['difficulty'] as int? ?? 2),
      cycleType: HabitCycleType.values.firstWhere(
        (e) => e.name == (map['cycle_type'] as String? ?? 'daily'),
        orElse: () => HabitCycleType.daily,
      ),
      cycleConfig: map['cycle_config'] as String?,
      timeRangeStart: map['time_range_start'] as String?,
      timeRangeEnd: map['time_range_end'] as String?,
      durationMinutes: map['duration_minutes'] as int?,
      targetDays: map['target_days'] as int?,
      targetTotal: map['target_total'] as int?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null 
          ? DateTime.parse(map['end_date'] as String)
          : null,
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      reminderTimes: map['reminder_times'] as String?,
      totalCheckIns: map['total_checkins'] as int? ?? 0,
      streakCount: map['streak_count'] as int? ?? 0,
      maxStreak: map['max_streak'] as int? ?? 0,
      sortOrder: map['sort_order'] as int? ?? 0,
      extraConfig: map['extra_config'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category,
      'importance': importance.value,
      'difficulty': difficulty.value,
      'cycle_type': cycleType.name,
      'cycle_config': cycleConfig,
      'time_range_start': timeRangeStart,
      'time_range_end': timeRangeEnd,
      'duration_minutes': durationMinutes,
      'target_days': targetDays,
      'target_total': targetTotal,
      'is_active': isActive ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_times': reminderTimes,
      'total_checkins': totalCheckIns,
      'streak_count': streakCount,
      'max_streak': maxStreak,
      'sort_order': sortOrder,
      'extra_config': extraConfig,
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category,
      'importance': importance.value,
      'difficulty': difficulty.value,
      'cycleType': cycleType.name,
      'cycleConfig': cycleConfig != null ? jsonDecode(cycleConfig!) : null,
      'timeRangeStart': timeRangeStart,
      'timeRangeEnd': timeRangeEnd,
      'durationMinutes': durationMinutes,
      'targetDays': targetDays,
      'targetTotal': targetTotal,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderEnabled': reminderEnabled,
      'reminderTimes': reminderTimes != null ? jsonDecode(reminderTimes!) : null,
      'totalCheckIns': totalCheckIns,
      'streakCount': streakCount,
      'maxStreak': maxStreak,
      'sortOrder': sortOrder,
      'extraConfig': extraConfig != null ? jsonDecode(extraConfig!) : null,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 从JSON创建习惯对象
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? 'default',
      category: json['category'] as String,
      importance: HabitImportance.fromValue(json['importance'] as int? ?? 3),
      difficulty: HabitDifficulty.fromValue(json['difficulty'] as int? ?? 2),
      cycleType: HabitCycleType.values.firstWhere(
        (e) => e.name == (json['cycleType'] as String? ?? 'daily'),
        orElse: () => HabitCycleType.daily,
      ),
      cycleConfig: json['cycleConfig'] != null 
          ? jsonEncode(json['cycleConfig'])
          : null,
      timeRangeStart: json['timeRangeStart'] as String?,
      timeRangeEnd: json['timeRangeEnd'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      targetDays: json['targetDays'] as int?,
      targetTotal: json['targetTotal'] as int?,
      isActive: json['isActive'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String)
          : null,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderTimes: json['reminderTimes'] != null 
          ? jsonEncode(json['reminderTimes'])
          : null,
      totalCheckIns: json['totalCheckIns'] as int? ?? 0,
      streakCount: json['streakCount'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
      sortOrder: json['sortOrder'] as int? ?? 0,
      extraConfig: json['extraConfig'] != null 
          ? jsonEncode(json['extraConfig'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// 解析提醒时间列表
  List<String> getReminderTimesList() {
    if (reminderTimes == null || reminderTimes!.isEmpty) {
      return [];
    }
    
    try {
      final decoded = jsonDecode(reminderTimes!) as List;
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// 设置提醒时间列表
  String? setReminderTimesList(List<String> times) {
    if (times.isEmpty) {
      return null;
    }
    
    return jsonEncode(times);
  }

  /// 解析循环配置
  Map<String, dynamic>? getCycleConfigMap() {
    if (cycleConfig == null || cycleConfig!.isEmpty) {
      return null;
    }
    
    try {
      return jsonDecode(cycleConfig!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 设置循环配置
  String? setCycleConfigMap(Map<String, dynamic>? config) {
    if (config == null || config.isEmpty) {
      return null;
    }
    
    return jsonEncode(config);
  }

  /// 解析额外配置
  Map<String, dynamic>? getExtraConfigMap() {
    if (extraConfig == null || extraConfig!.isEmpty) {
      return null;
    }
    
    try {
      return jsonDecode(extraConfig!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 设置额外配置
  String? setExtraConfigMap(Map<String, dynamic>? config) {
    if (config == null || config.isEmpty) {
      return null;
    }
    
    return jsonEncode(config);
  }

  /// 判断今天是否应该执行此习惯
  bool shouldExecuteToday() {
    return shouldExecuteOnDate(DateTime.now());
  }

  /// 判断指定日期是否应该执行此习惯
  bool shouldExecuteOnDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    
    // 如果还未到开始日期
    if (target.isBefore(start)) {
      return false;
    }
    
    // 如果已过结束日期
    if (endDate != null) {
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (target.isAfter(end)) {
        return false;
      }
    }
    
    // 如果未激活或已删除
    if (!isActive || isDeleted) {
      return false;
    }
    
    // 根据循环类型判断
    switch (cycleType) {
      case HabitCycleType.daily:
        return true;
        
      case HabitCycleType.weekly:
        final config = getCycleConfigMap();
        if (config != null && config['weekdays'] != null) {
          final weekdays = (config['weekdays'] as List).cast<int>();
          final targetWeekday = date.weekday; // 1=Monday, 7=Sunday
          return weekdays.contains(targetWeekday);
        }
        return true;
        
      case HabitCycleType.monthly:
        final config = getCycleConfigMap();
        if (config != null && config['days'] != null) {
          final days = (config['days'] as List).cast<int>();
          return days.contains(date.day);
        }
        return true;
        
      case HabitCycleType.custom:
        // 自定义逻辑可以在这里实现
        return true;
    }
  }

  /// 获取下次执行日期
  DateTime? getNextExecutionDate() {
    if (!isActive || isDeleted) {
      return null;
    }
    
    final now = DateTime.now();
    
    switch (cycleType) {
      case HabitCycleType.daily:
        return DateTime(now.year, now.month, now.day + 1);
        
      case HabitCycleType.weekly:
        final config = getCycleConfigMap();
        if (config != null && config['weekdays'] != null) {
          final weekdays = (config['weekdays'] as List).cast<int>();
          final todayWeekday = now.weekday;
          
          // 寻找本周剩余的执行日
          for (int i = todayWeekday + 1; i <= 7; i++) {
            if (weekdays.contains(i)) {
              return now.add(Duration(days: i - todayWeekday));
            }
          }
          
          // 如果本周没有了，找下周第一个执行日
          final firstWeekday = weekdays.isEmpty ? 1 : weekdays.first;
          final daysToAdd = 7 - todayWeekday + firstWeekday;
          return now.add(Duration(days: daysToAdd));
        }
        return now.add(const Duration(days: 7));
        
      case HabitCycleType.monthly:
        final config = getCycleConfigMap();
        if (config != null && config['days'] != null) {
          final days = (config['days'] as List).cast<int>();
          
          // 寻找本月剩余的执行日
          final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
          for (int day = now.day + 1; day <= daysInMonth; day++) {
            if (days.contains(day)) {
              return DateTime(now.year, now.month, day);
            }
          }
          
          // 如果本月没有了，找下月第一个执行日
          final firstDay = days.isEmpty ? 1 : days.first;
          return DateTime(now.year, now.month + 1, firstDay);
        }
        return DateTime(now.year, now.month + 1, now.day);
        
      case HabitCycleType.custom:
        // 自定义逻辑
        return now.add(const Duration(days: 1));
    }
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, category: $category, '
           'importance: $importance, difficulty: $difficulty, '
           'cycleType: $cycleType, isActive: $isActive, '
           'totalCheckIns: $totalCheckIns, streakCount: $streakCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Habit &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.startDate == startDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, category, startDate);
  }
}