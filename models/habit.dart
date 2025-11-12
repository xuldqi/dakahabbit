import 'package:json_annotation/json_annotation.dart';

part 'habit.g.dart';

/// 习惯周期类型
enum HabitCycleType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('custom')
  custom,
}

/// 习惯分类
enum HabitCategory {
  @JsonValue('health')
  health,
  @JsonValue('exercise')
  exercise,
  @JsonValue('study')
  study,
  @JsonValue('work')
  work,
  @JsonValue('life')
  life,
  @JsonValue('social')
  social,
  @JsonValue('hobby')
  hobby,
  @JsonValue('other')
  other,
}

/// 习惯难度
enum HabitDifficulty {
  @JsonValue('easy')
  easy,
  @JsonValue('medium')
  medium,
  @JsonValue('hard')
  hard,
}

/// 时间范围配置
@JsonSerializable()
class TimeRange {
  final String start; // HH:mm格式
  final String end;   // HH:mm格式
  
  const TimeRange({
    required this.start,
    required this.end,
  });
  
  factory TimeRange.fromJson(Map<String, dynamic> json) => _$TimeRangeFromJson(json);
  Map<String, dynamic> toJson() => _$TimeRangeToJson(this);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// 周期配置
@JsonSerializable()
class CycleConfig {
  /// 对于weekly类型：一周中的哪几天 (1-7, 1=周一)
  final List<int>? weekdays;
  
  /// 对于custom类型：间隔天数
  final int? intervalDays;
  
  /// 对于custom类型：特定日期列表
  final List<String>? specificDates;
  
  /// 对于weekly类型：间隔周数（默认为1，即每周）
  final int? weeksInterval;
  
  const CycleConfig({
    this.weekdays,
    this.intervalDays,
    this.specificDates,
    this.weeksInterval,
  });
  
  factory CycleConfig.fromJson(Map<String, dynamic> json) => _$CycleConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CycleConfigToJson(this);
  
  /// 创建每日周期配置
  factory CycleConfig.daily() => const CycleConfig();
  
  /// 创建每周周期配置
  factory CycleConfig.weekly(List<int> weekdays, {int weeksInterval = 1}) =>
      CycleConfig(weekdays: weekdays, weeksInterval: weeksInterval);
  
  /// 创建自定义间隔周期配置
  factory CycleConfig.customInterval(int intervalDays) =>
      CycleConfig(intervalDays: intervalDays);
  
  /// 创建特定日期周期配置
  factory CycleConfig.specificDates(List<String> dates) =>
      CycleConfig(specificDates: dates);
}

/// 提醒配置
@JsonSerializable()
class ReminderConfig {
  final bool enabled;
  final List<String> times; // HH:mm格式的时间列表
  final bool vibration;
  final String? sound;
  
  const ReminderConfig({
    required this.enabled,
    required this.times,
    this.vibration = true,
    this.sound,
  });
  
  factory ReminderConfig.fromJson(Map<String, dynamic> json) => _$ReminderConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ReminderConfigToJson(this);
  
  /// 创建默认提醒配置
  factory ReminderConfig.defaultConfig() => const ReminderConfig(
    enabled: false,
    times: [],
  );
}

/// 习惯统计信息
@JsonSerializable()
class HabitStats {
  final int totalCheckins;       // 总打卡次数
  final int streakCount;         // 当前连续天数
  final int maxStreak;           // 最大连续天数
  final double completionRate;   // 完成率
  final DateTime? lastCheckinDate; // 最后打卡日期
  
  const HabitStats({
    this.totalCheckins = 0,
    this.streakCount = 0,
    this.maxStreak = 0,
    this.completionRate = 0.0,
    this.lastCheckinDate,
  });
  
  factory HabitStats.fromJson(Map<String, dynamic> json) => _$HabitStatsFromJson(json);
  Map<String, dynamic> toJson() => _$HabitStatsToJson(this);
  
  /// 创建初始统计信息
  factory HabitStats.initial() => const HabitStats();
  
  /// 复制并更新统计信息
  HabitStats copyWith({
    int? totalCheckins,
    int? streakCount,
    int? maxStreak,
    double? completionRate,
    DateTime? lastCheckinDate,
  }) {
    return HabitStats(
      totalCheckins: totalCheckins ?? this.totalCheckins,
      streakCount: streakCount ?? this.streakCount,
      maxStreak: maxStreak ?? this.maxStreak,
      completionRate: completionRate ?? this.completionRate,
      lastCheckinDate: lastCheckinDate ?? this.lastCheckinDate,
    );
  }
}

/// 习惯模型
@JsonSerializable()
class Habit {
  final int? id;
  final String name;
  final String? description;
  final String icon;
  final HabitCategory category;
  final int importance; // 1-5
  final HabitDifficulty difficulty;
  
  // 时间设置
  final HabitCycleType cycleType;
  final CycleConfig? cycleConfig;
  final TimeRange? timeRange;
  final int? durationMinutes; // 持续时间(分钟)
  
  // 目标设置
  final int? targetDays;      // 目标天数
  final int? targetTotal;     // 总目标次数
  
  // 状态
  final bool isActive;
  final bool isDeleted;
  final DateTime startDate;
  final DateTime? endDate;
  
  // 提醒设置
  final ReminderConfig reminderConfig;
  
  // 统计信息
  final HabitStats stats;
  
  // 排序顺序
  final int sortOrder;
  
  // 扩展配置
  final Map<String, dynamic>? extraConfig;
  
  // 时间戳
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Habit({
    this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.category,
    this.importance = 3,
    this.difficulty = HabitDifficulty.medium,
    this.cycleType = HabitCycleType.daily,
    this.cycleConfig,
    this.timeRange,
    this.durationMinutes,
    this.targetDays,
    this.targetTotal,
    this.isActive = true,
    this.isDeleted = false,
    required this.startDate,
    this.endDate,
    required this.reminderConfig,
    required this.stats,
    this.sortOrder = 0,
    this.extraConfig,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
  Map<String, dynamic> toJson() => _$HabitToJson(this);
  
  /// 创建新习惯
  factory Habit.create({
    required String name,
    String? description,
    required String icon,
    required HabitCategory category,
    int importance = 3,
    HabitDifficulty difficulty = HabitDifficulty.medium,
    HabitCycleType cycleType = HabitCycleType.daily,
    CycleConfig? cycleConfig,
    TimeRange? timeRange,
    int? durationMinutes,
    int? targetDays,
    int? targetTotal,
    DateTime? startDate,
    DateTime? endDate,
    ReminderConfig? reminderConfig,
    int sortOrder = 0,
    Map<String, dynamic>? extraConfig,
  }) {
    final now = DateTime.now();
    return Habit(
      name: name,
      description: description,
      icon: icon,
      category: category,
      importance: importance,
      difficulty: difficulty,
      cycleType: cycleType,
      cycleConfig: cycleConfig ?? CycleConfig.daily(),
      timeRange: timeRange,
      durationMinutes: durationMinutes,
      targetDays: targetDays,
      targetTotal: targetTotal,
      startDate: startDate ?? now,
      endDate: endDate,
      reminderConfig: reminderConfig ?? ReminderConfig.defaultConfig(),
      stats: HabitStats.initial(),
      sortOrder: sortOrder,
      extraConfig: extraConfig,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// 复制并更新习惯
  Habit copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    HabitCategory? category,
    int? importance,
    HabitDifficulty? difficulty,
    HabitCycleType? cycleType,
    CycleConfig? cycleConfig,
    TimeRange? timeRange,
    int? durationMinutes,
    int? targetDays,
    int? targetTotal,
    bool? isActive,
    bool? isDeleted,
    DateTime? startDate,
    DateTime? endDate,
    ReminderConfig? reminderConfig,
    HabitStats? stats,
    int? sortOrder,
    Map<String, dynamic>? extraConfig,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      difficulty: difficulty ?? this.difficulty,
      cycleType: cycleType ?? this.cycleType,
      cycleConfig: cycleConfig ?? this.cycleConfig,
      timeRange: timeRange ?? this.timeRange,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      targetDays: targetDays ?? this.targetDays,
      targetTotal: targetTotal ?? this.targetTotal,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderConfig: reminderConfig ?? this.reminderConfig,
      stats: stats ?? this.stats,
      sortOrder: sortOrder ?? this.sortOrder,
      extraConfig: extraConfig ?? this.extraConfig,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  /// 检查今天是否需要打卡
  bool shouldCheckInToday() {
    final today = DateTime.now();
    
    // 检查是否在有效期内
    if (today.isBefore(startDate)) return false;
    if (endDate != null && today.isAfter(endDate!)) return false;
    
    // 检查是否激活
    if (!isActive || isDeleted) return false;
    
    switch (cycleType) {
      case HabitCycleType.daily:
        return true;
        
      case HabitCycleType.weekly:
        if (cycleConfig?.weekdays == null) return false;
        final weekday = today.weekday; // 1=周一, 7=周日
        return cycleConfig!.weekdays!.contains(weekday);
        
      case HabitCycleType.custom:
        if (cycleConfig?.intervalDays != null) {
          final daysSinceStart = today.difference(startDate).inDays;
          return daysSinceStart % cycleConfig!.intervalDays! == 0;
        }
        if (cycleConfig?.specificDates != null) {
          final todayStr = _formatDate(today);
          return cycleConfig!.specificDates!.contains(todayStr);
        }
        return false;
    }
  }
  
  /// 检查时间范围内是否可以打卡
  bool canCheckInAtTime(DateTime dateTime) {
    if (timeRange == null) return true;
    
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return time.compareTo(timeRange!.start) >= 0 && time.compareTo(timeRange!.end) <= 0;
  }
  
  /// 获取显示标题
  String get displayName => name;
  
  /// 获取重要性描述
  String get importanceText {
    switch (importance) {
      case 1: return '很低';
      case 2: return '较低';
      case 3: return '一般';
      case 4: return '重要';
      case 5: return '非常重要';
      default: return '一般';
    }
  }
  
  /// 获取难度描述
  String get difficultyText {
    switch (difficulty) {
      case HabitDifficulty.easy: return '简单';
      case HabitDifficulty.medium: return '中等';
      case HabitDifficulty.hard: return '困难';
    }
  }
  
  /// 获取分类描述
  String get categoryText {
    switch (category) {
      case HabitCategory.health: return '健康';
      case HabitCategory.exercise: return '运动';
      case HabitCategory.study: return '学习';
      case HabitCategory.work: return '工作';
      case HabitCategory.life: return '生活';
      case HabitCategory.social: return '社交';
      case HabitCategory.hobby: return '爱好';
      case HabitCategory.other: return '其他';
    }
  }
  
  /// 格式化日期为YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
  
  @override
  String toString() {
    return 'Habit{id: $id, name: $name, category: $category, isActive: $isActive}';
  }
}