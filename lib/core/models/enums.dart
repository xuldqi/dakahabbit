/// 习惯周期类型
enum HabitCycleType {
  /// 每日
  daily,
  /// 每周
  weekly,
  /// 每月
  monthly,
  /// 自定义
  custom,
}

/// 习惯重要性级别
enum HabitImportance {
  /// 很重要
  veryHigh(5),
  /// 重要
  high(4),
  /// 中等
  medium(3),
  /// 一般
  low(2),
  /// 很低
  veryLow(1);

  const HabitImportance(this.value);
  final int value;

  static HabitImportance fromValue(int value) {
    return HabitImportance.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HabitImportance.medium,
    );
  }
}

/// 习惯难度级别
enum HabitDifficulty {
  /// 很简单
  veryEasy(1),
  /// 简单
  easy(2),
  /// 中等
  medium(3),
  /// 困难
  hard(4),
  /// 很困难
  veryHard(5);

  const HabitDifficulty(this.value);
  final int value;

  static HabitDifficulty fromValue(int value) {
    return HabitDifficulty.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HabitDifficulty.medium,
    );
  }
}

/// 打卡状态
enum CheckInStatus {
  /// 已完成
  completed,
  /// 部分完成
  partial,
  /// 跳过
  skipped,
  /// 未完成
  missed,
}

/// 情绪类型
enum MoodType {
  /// 非常好
  excellent('😄'),
  /// 好
  good('😊'),
  /// 一般
  neutral('😐'),
  /// 不好
  bad('😞'),
  /// 很不好
  terrible('😢');

  const MoodType(this.emoji);
  final String emoji;

  static MoodType? fromName(String? name) {
    if (name == null) return null;
    return MoodType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => MoodType.neutral,
    );
  }
}

/// 成就稀有度
enum AchievementRarity {
  /// 普通
  common,
  /// 少见
  uncommon,
  /// 稀有
  rare,
  /// 史诗
  epic,
  /// 传说
  legendary,
}

/// 成就条件类型
enum AchievementConditionType {
  /// 连续打卡天数
  streak,
  /// 总打卡次数
  totalCheckIns,
  /// 完成特定习惯
  specificHabit,
  /// 完成某类习惯
  categoryCompletion,
  /// 在时间窗口内完成
  timeWindow,
}

/// 日志类型
enum JournalType {
  /// 日常
  daily,
  /// 习惯相关
  habit,
  /// 反思
  reflection,
  /// 目标
  goal,
  /// 成就
  achievement,
}