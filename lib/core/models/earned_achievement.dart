/// 获得的成就数据模型
class EarnedAchievement {
  const EarnedAchievement({
    this.id,
    required this.achievementId,
    this.habitId,
    required this.earnedDate,
    required this.earnedValue,
    this.context,
    this.rewardPoints = 0,
    this.rewardBadge,
    this.rewardTitle,
    this.rewardUnlocks,
    this.isNotified = false,
    this.createdAt,
  });

  /// 获得成就记录ID
  final int? id;

  /// 成就ID
  final int achievementId;

  /// 关联的习惯ID（如果适用）
  final int? habitId;

  /// 获得日期
  final DateTime earnedDate;

  /// 获得时的数值（例如连击天数、总次数等）
  final int earnedValue;

  /// 获得时的上下文信息
  final String? context;

  /// 奖励积分
  final int rewardPoints;

  /// 奖励徽章
  final String? rewardBadge;

  /// 奖励称号
  final String? rewardTitle;

  /// 奖励解锁内容
  final String? rewardUnlocks;

  /// 是否已通知
  final bool isNotified;

  /// 创建时间
  final DateTime? createdAt;

  /// 复制获得成就记录并修改部分属性
  EarnedAchievement copyWith({
    int? id,
    int? achievementId,
    int? habitId,
    DateTime? earnedDate,
    int? earnedValue,
    String? context,
    int? rewardPoints,
    String? rewardBadge,
    String? rewardTitle,
    String? rewardUnlocks,
    bool? isNotified,
    DateTime? createdAt,
  }) {
    return EarnedAchievement(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      habitId: habitId ?? this.habitId,
      earnedDate: earnedDate ?? this.earnedDate,
      earnedValue: earnedValue ?? this.earnedValue,
      context: context ?? this.context,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rewardBadge: rewardBadge ?? this.rewardBadge,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      rewardUnlocks: rewardUnlocks ?? this.rewardUnlocks,
      isNotified: isNotified ?? this.isNotified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 从数据库Map创建获得成就记录对象
  factory EarnedAchievement.fromMap(Map<String, dynamic> map) {
    return EarnedAchievement(
      id: map['id'] as int?,
      achievementId: map['achievement_id'] as int,
      habitId: map['habit_id'] as int?,
      earnedDate: DateTime.parse(map['earned_date'] as String),
      earnedValue: map['earned_value'] as int,
      context: map['context'] as String?,
      rewardPoints: map['reward_points'] as int? ?? 0,
      rewardBadge: map['reward_badge'] as String?,
      rewardTitle: map['reward_title'] as String?,
      rewardUnlocks: map['reward_unlocks'] as String?,
      isNotified: (map['is_notified'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    
    return {
      if (id != null) 'id': id,
      'achievement_id': achievementId,
      'habit_id': habitId,
      'earned_date': earnedDate.toIso8601String(),
      'earned_value': earnedValue,
      'context': context,
      'reward_points': rewardPoints,
      'reward_badge': rewardBadge,
      'reward_title': rewardTitle,
      'reward_unlocks': rewardUnlocks,
      'is_notified': isNotified ? 1 : 0,
      'created_at': (createdAt ?? now).toIso8601String(),
    };
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'achievementId': achievementId,
      'habitId': habitId,
      'earnedDate': earnedDate.toIso8601String(),
      'earnedValue': earnedValue,
      'context': context,
      'rewardPoints': rewardPoints,
      'rewardBadge': rewardBadge,
      'rewardTitle': rewardTitle,
      'rewardUnlocks': rewardUnlocks,
      'isNotified': isNotified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// 从JSON创建获得成就记录对象
  factory EarnedAchievement.fromJson(Map<String, dynamic> json) {
    return EarnedAchievement(
      id: json['id'] as int?,
      achievementId: json['achievementId'] as int,
      habitId: json['habitId'] as int?,
      earnedDate: DateTime.parse(json['earnedDate'] as String),
      earnedValue: json['earnedValue'] as int,
      context: json['context'] as String?,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      rewardBadge: json['rewardBadge'] as String?,
      rewardTitle: json['rewardTitle'] as String?,
      rewardUnlocks: json['rewardUnlocks'] as String?,
      isNotified: json['isNotified'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// 创建今天获得的成就记录
  factory EarnedAchievement.earnedToday({
    required int achievementId,
    int? habitId,
    required int earnedValue,
    String? context,
    int rewardPoints = 0,
    String? rewardBadge,
    String? rewardTitle,
    String? rewardUnlocks,
  }) {
    final now = DateTime.now();
    
    return EarnedAchievement(
      achievementId: achievementId,
      habitId: habitId,
      earnedDate: now,
      earnedValue: earnedValue,
      context: context,
      rewardPoints: rewardPoints,
      rewardBadge: rewardBadge,
      rewardTitle: rewardTitle,
      rewardUnlocks: rewardUnlocks,
      isNotified: false,
      createdAt: now,
    );
  }

  /// 格式化获得日期
  String getFormattedEarnedDate() {
    return '${earnedDate.year}-'
           '${earnedDate.month.toString().padLeft(2, '0')}-'
           '${earnedDate.day.toString().padLeft(2, '0')} '
           '${earnedDate.hour.toString().padLeft(2, '0')}:'
           '${earnedDate.minute.toString().padLeft(2, '0')}';
  }

  /// 判断是否是今天获得的
  bool isEarnedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final earnedDay = DateTime(earnedDate.year, earnedDate.month, earnedDate.day);
    return earnedDay == today;
  }

  /// 判断是否是最近7天内获得的
  bool isEarnedRecently() {
    final now = DateTime.now();
    final difference = now.difference(earnedDate);
    return difference.inDays <= 7;
  }

  /// 获取距离获得时间的天数
  int getDaysFromEarned() {
    final now = DateTime.now();
    final difference = now.difference(earnedDate);
    return difference.inDays;
  }

  /// 获取相对时间描述
  String getRelativeTimeDescription() {
    final now = DateTime.now();
    final difference = now.difference(earnedDate);
    
    if (difference.inMinutes < 60) {
      if (difference.inMinutes == 0) {
        return '刚刚';
      }
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks 周前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months 个月前';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years 年前';
    }
  }

  /// 标记为已通知
  EarnedAchievement markAsNotified() {
    return copyWith(isNotified: true);
  }

  @override
  String toString() {
    return 'EarnedAchievement(id: $id, achievementId: $achievementId, '
           'habitId: $habitId, earnedDate: $earnedDate, '
           'earnedValue: $earnedValue, rewardPoints: $rewardPoints, '
           'isNotified: $isNotified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is EarnedAchievement &&
        other.id == id &&
        other.achievementId == achievementId &&
        other.earnedDate == earnedDate &&
        other.earnedValue == earnedValue;
  }

  @override
  int get hashCode {
    return Object.hash(id, achievementId, earnedDate, earnedValue);
  }
}